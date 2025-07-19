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
      body: Consumer<TopicProvider>(
        builder: (context, provider, child) {
          if (provider.status == TopicStatus.loading && provider.allTopics.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.status == TopicStatus.error) {
            return Center(child: Text(provider.errorMessage ?? 'An error occurred'));
          } else if (provider.resolvedTopics.isEmpty) {
            return const Center(child: Text('No resolved topics.'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchTopics(force: true),
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: provider.resolvedTopics.length,
              itemBuilder: (context, index) {
                final topic = provider.resolvedTopics[index];
                return Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      topic.encryptedContent,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.lineThrough,
                          ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Importance: ${topic.importanceLevel}'),
                    ),
                    onTap: () {
                      // TODO: Navigate to topic details
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
