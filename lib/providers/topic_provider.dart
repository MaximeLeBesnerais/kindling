import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/topic.dart';
import '../services/api_service.dart';

enum TopicStatus { initial, loading, loaded, error }

class TopicProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Topic> _topics = [];
  TopicStatus _status = TopicStatus.initial;
  String? _errorMessage;

  List<Topic> get allTopics => _topics;
  List<Topic> get activeTopics => _topics.where((t) => t.status == 'active').toList();
  List<Topic> get resolvedTopics => _topics.where((t) => t.status == 'resolved').toList();
  TopicStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTopics({bool force = false}) async {
    if (_status == TopicStatus.loading && !force) return;

    // Load from cache first
    if (!force) {
      await _loadTopicsFromCache();
      if (_status == TopicStatus.loaded) {
        // Use a post-frame callback to avoid calling notifyListeners during a build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return;
      }
    }

    // If cache is empty or force is true, fetch from network
    _status = TopicStatus.loading;
    // Use a post-frame callback to avoid calling notifyListeners during a build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final topicsData = await _apiService.getTopics();
      _topics = topicsData.map((data) => Topic.fromJson(data)).toList();
      await _saveTopicsToCache();
      _status = TopicStatus.loaded;
    } catch (e) {
      _status = TopicStatus.error;
      _errorMessage = e.toString();
    }
    
    // Use another post-frame callback for the final state update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> _saveTopicsToCache() async {
    final prefs = await SharedPreferences.getInstance();
    final topicsJson = _topics.map((topic) => jsonEncode(topic.toJson())).toList();
    await prefs.setStringList('cached_topics', topicsJson);
  }

  Future<void> _loadTopicsFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final topicsJson = prefs.getStringList('cached_topics');
    if (topicsJson != null) {
      _topics = topicsJson.map((json) => Topic.fromJson(jsonDecode(json))).toList();
      _status = TopicStatus.loaded;
    }
  }

  void clearTopics() {
    _topics = [];
    _status = TopicStatus.initial;
    _errorMessage = null;
    // Also clear from cache on logout/quit
    SharedPreferences.getInstance().then((prefs) => prefs.remove('cached_topics'));
    notifyListeners();
  }
}
