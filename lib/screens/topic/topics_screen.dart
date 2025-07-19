import 'package:flutter/material.dart';
import 'package:kindling/providers/topic_provider.dart';
import 'package:kindling/screens/topic/create_topic_screen.dart';
import 'package:provider/provider.dart';

class TopicsScreen extends StatelessWidget {
  const TopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateTopicScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<TopicProvider>(
        builder: (context, provider, child) {
          if (provider.status == TopicStatus.loading && provider.allTopics.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.status == TopicStatus.error) {
            return Center(child: Text(provider.errorMessage ?? 'An error occurred'));
          } else if (provider.activeTopics.isEmpty) {
            return const Center(child: Text('No active topics.'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchTopics(force: true),
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: provider.activeTopics.length,
              itemBuilder: (context, index) {
                final topic = provider.activeTopics[index];
                return Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      topic.encryptedContent,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
