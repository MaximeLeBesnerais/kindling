import 'package:flutter/material.dart';
import 'package:kindling/providers/topic_provider.dart';
import 'package:provider/provider.dart';

class TopicsScreen extends StatelessWidget {
  const TopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topics'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => Provider.of<TopicProvider>(context, listen: false).fetchTopics(force: true),
        child: Consumer<TopicProvider>(
          builder: (context, topicProvider, child) {
            if (topicProvider.status == TopicStatus.loading && topicProvider.activeTopics.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            } else if (topicProvider.status == TopicStatus.error) {
              return Center(child: Text('Error: ${topicProvider.errorMessage}'));
            } else if (topicProvider.activeTopics.isEmpty) {
              return const Center(child: Text('No topics found.'));
            } else {
              return ListView.builder(
                itemCount: topicProvider.activeTopics.length,
                itemBuilder: (context, index) {
                  final topic = topicProvider.activeTopics[index];
                  return ListTile(
                    title: Text(topic.encryptedContent), // Assuming content is not actually encrypted for now
                    subtitle: Text('Importance: ${topic.importanceLevel}'),
                    onTap: () {
                      // TODO: Navigate to topic details
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
