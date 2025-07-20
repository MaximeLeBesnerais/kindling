import 'package:flutter/material.dart';
import 'package:kindling/models/comment.dart';
import 'package:kindling/models/topic.dart';
import 'package:kindling/providers/topic_provider.dart';
import 'package:kindling/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TopicDetailScreen extends StatefulWidget {
  final Topic topic;

  const TopicDetailScreen({super.key, required this.topic});

  @override
  TopicDetailScreenState createState() => TopicDetailScreenState();
}

class TopicDetailScreenState extends State<TopicDetailScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _commentController = TextEditingController();
  late Future<List<Comment>> _commentsFuture;
  String? _currentUserId;
  String _partnerName = 'Partner';
  bool _isSending = false;
  bool _canPostComment = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _updateCommentRules(List<Comment> comments) {
    if (_currentUserId == null) return;
    final userCommentCount = comments.where((c) => c.authorId == _currentUserId).length;
    setState(() {
      _canPostComment = userCommentCount < 4;
    });
  }

  void _loadInitialData() {
    _commentsFuture = _fetchComments(force: false);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final partnerName = await _apiService.getPartnerName();
    setState(() {
      _currentUserId = prefs.getString('user_id');
      _partnerName = partnerName;
    });
  }

  Future<List<Comment>> _fetchComments({bool force = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'comments_topic_${widget.topic.id}';

    // Try loading from cache first
    if (!force) {
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final List<dynamic> commentsJson = jsonDecode(cachedData);
        final comments = commentsJson.map((data) => Comment.fromJson(data)).toList();
        _updateCommentRules(comments);
        return comments;
      }
    }

    // If not in cache or force=true, fetch from API
    try {
      final commentsData = await _apiService.getComments(widget.topic.id);
      // Save to cache
      await prefs.setString(cacheKey, jsonEncode(commentsData));
      final comments = commentsData.map((data) => Comment.fromJson(data)).toList();
      _updateCommentRules(comments);
      return comments;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load comments: $e')),
        );
      }
      return [];
    }
  }

  void _postComment() async {
    if (_commentController.text.isEmpty || !_canPostComment) return;

    setState(() {
      _isSending = true;
    });

    try {
      await _apiService.createComment(widget.topic.id, _commentController.text);
      _commentController.clear();
      // Refresh comments from network
      setState(() {
        _commentsFuture = _fetchComments(force: true);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to post comment: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _solveTopic() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Solved?'),
        content: const Text(
          'Are you sure you want to mark this topic as solved? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.solveTopic(widget.topic.id);
        if (mounted) {
          // Refresh the topics list in the provider
          await Provider.of<TopicProvider>(
            context,
            listen: false,
          ).fetchTopics(force: true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Topic marked as solved.')),
          );
          Navigator.of(context).pop(); // Go back to the previous screen
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to solve topic: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.encryptedContent, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _commentsFuture = _fetchComments(force: true);
              });
            },
            tooltip: 'Refresh Comments',
          ),
          if (widget.topic.status == 'active')
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              tooltip: 'Mark as Solved',
              onPressed: _solveTopic,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Topic details at the top
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.topic.encryptedContent,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Importance: ${widget.topic.importanceLevel}'),
                  const Divider(height: 20),
                ],
              ),
            ),
            // List of comments
            Expanded(
              child: FutureBuilder<List<Comment>>(
                future: _commentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Failed to load comments.'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No comments yet.'));
                  }

                  final comments = snapshot.data!;
                  // Ensure rules are updated when data is loaded
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _updateCommentRules(comments);
                  });

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _commentsFuture = _fetchComments(force: true);
                      });
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final isAuthor = comment.authorId == _currentUserId;
                        final authorName = isAuthor ? 'You' : _partnerName;

                        return Align(
                          alignment: isAuthor ? Alignment.centerRight : Alignment.centerLeft,
                          child: Card(
                            color: isAuthor
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authorName,
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(comment.encryptedContent),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            // Input bar at the bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      maxLength: 256,
                      enabled: _canPostComment,
                      decoration: InputDecoration(
                        hintText: _canPostComment ? 'Add a comment...' : 'You have reached your comment limit.',
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: _canPostComment ? (_) => _postComment() : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_isSending)
                    const Padding(
                      padding: EdgeInsets.only(top: 12.0),
                      child: CircularProgressIndicator(),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _canPostComment ? _postComment : null,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
