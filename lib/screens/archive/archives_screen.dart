import 'package:flutter/material.dart';
import 'package:kindling/providers/topic_provider.dart';
import 'package:provider/provider.dart';

class ArchivesScreen extends StatelessWidget {
  const ArchivesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archives'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => Provider.of<TopicProvider>(context, listen: false).fetchTopics(force: true),
        child: Consumer<TopicProvider>(
          builder: (context, topicProvider, child) {
            if (topicProvider.status == TopicStatus.loading && topicProvider.resolvedTopics.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            } else if (topicProvider.status == TopicStatus.error) {
              return Center(child: Text('Error: ${topicProvider.errorMessage}'));
            } else if (topicProvider.resolvedTopics.isEmpty) {
              return const Center(child: Text('No archived topics found.'));
            } else {
              return ListView.builder(
                itemCount: topicProvider.resolvedTopics.length,
                itemBuilder: (context, index) {
                  final topic = topicProvider.resolvedTopics[index];
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
      ),
    );
  }
}
