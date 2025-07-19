import 'package:flutter/material.dart';
import 'package:kindling/models/comment.dart';
import 'package:kindling/models/topic.dart';
import 'package:kindling/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    _commentsFuture = _fetchComments();
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

  Future<List<Comment>> _fetchComments() async {
    try {
      final commentsData = await _apiService.getComments(widget.topic.id);
      return commentsData.map((data) => Comment.fromJson(data)).toList();
    } catch (e) {
      // Handle error appropriately
      return [];
    }
  }

  void _postComment() async {
    if (_commentController.text.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      await _apiService.createComment(widget.topic.id, _commentController.text);
      _commentController.clear();
      // Refresh comments
      setState(() {
        _commentsFuture = _fetchComments();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post comment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.encryptedContent, overflow: TextOverflow.ellipsis),
      ),
      body: Column(
        children: [
          // Topic details at the top
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.topic.encryptedContent,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load comments.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No comments yet.'));
                }

                final comments = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final isAuthor = comment.authorId == _currentUserId;
                    final authorName = isAuthor ? 'You' : _partnerName;

                    return Align(
                      alignment: isAuthor ? Alignment.centerRight : Alignment.centerLeft,
                      child: Card(
                        color: isAuthor ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.secondaryContainer,
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
                );
              },
            ),
          ),
          // Input bar at the bottom
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _postComment(),
                  ),
                ),
                const SizedBox(width: 8),
                _isSending
                    ? const CircularProgressIndicator()
                    : IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _postComment,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
