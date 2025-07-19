import 'package:flutter/material.dart';
import 'package:kindling/models/topic.dart';
import 'package:kindling/services/api_service.dart';

class ArchivesScreen extends StatefulWidget {
  const ArchivesScreen({super.key});

  @override
  _ArchivesScreenState createState() => _ArchivesScreenState();
}

class _ArchivesScreenState extends State<ArchivesScreen> {
  late Future<List<Topic>> _topicsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _topicsFuture = _fetchTopics();
  }

  Future<List<Topic>> _fetchTopics() async {
    final topicsData = await _apiService.getTopics();
    return topicsData.map((data) => Topic.fromJson(data)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archives'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<Topic>>(
        future: _topicsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No archived topics found.'));
          } else {
            final resolvedTopics = snapshot.data!.where((t) => t.status == 'resolved').toList();
            return ListView.builder(
              itemCount: resolvedTopics.length,
              itemBuilder: (context, index) {
                final topic = resolvedTopics[index];
                return ListTile(
                  title: Text(topic.encryptedContent), // Assuming content is not actually encrypted for now
                  subtitle: Text('Resolved on: ${topic.resolvedAt}'),
                  onTap: () {
                    // TODO: Navigate to topic details
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
