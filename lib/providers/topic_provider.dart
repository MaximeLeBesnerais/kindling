import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    // Don't trigger rebuilds if it's not necessary
    if (_status == TopicStatus.loading && !force) return;
    if (_status == TopicStatus.loaded && !force) return;

    // Use a post-frame callback to avoid calling notifyListeners during a build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _status = TopicStatus.loading;
      notifyListeners();
    });

    try {
      final topicsData = await _apiService.getTopics();
      _topics = topicsData.map((data) => Topic.fromJson(data)).toList();
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

  void clearTopics() {
    _topics = [];
    _status = TopicStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
