import 'package:flutter/material.dart';
import 'package:kindling/models/topic.dart';
import 'package:kindling/providers/topic_provider.dart';
import 'package:kindling/screens/topic/create_topic_screen.dart';
import 'package:kindling/screens/topic/topic_detail_screen.dart';
import 'package:kindling/theme/theme_manager.dart';
import 'package:provider/provider.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<TopicProvider>(context, listen: false).fetchTopics();
      }
    });
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshTopics(BuildContext context) async {
    await Provider.of<TopicProvider>(context, listen: false).fetchTopics(force: true);
  }

  List<Topic> _getFilteredTopics(List<Topic> topics) {
    final searchQuery = _searchController.text.toLowerCase();
    
    final filteredBySearch = searchQuery.isEmpty
        ? topics
        : topics.where((t) => t.encryptedContent.toLowerCase().contains(searchQuery)).toList();

    switch (_selectedFilter) {
      case 'Low':
        return filteredBySearch.where((t) => t.importanceLevel >= 1 && t.importanceLevel <= 3).toList();
      case 'Mid':
        return filteredBySearch.where((t) => t.importanceLevel >= 4 && t.importanceLevel <= 6).toList();
      case 'High':
        return filteredBySearch.where((t) => t.importanceLevel >= 7 && t.importanceLevel <= 10).toList();
      case 'All':
      default:
        return filteredBySearch;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshTopics(context),
          ),
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
          }

          final filteredTopics = _getFilteredTopics(provider.activeTopics);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search Topics',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      children: ['All', 'Low', 'Mid', 'High'].map((label) {
                        return ChoiceChip(
                          label: Text(label),
                          selected: _selectedFilter == label,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedFilter = label;
                              });
                            }
                          },
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _refreshTopics(context),
                  child: filteredTopics.isEmpty
                      ? const Center(child: Text('No topics match your criteria.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: filteredTopics.length,
                          itemBuilder: (context, index) {
                            final topic = filteredTopics[index];
                            final themeManager = Provider.of<ThemeManager>(context, listen: false);
                            final cardColor = themeManager.getTopicColor(context, topic.importanceLevel);
                            final textColor = cardColor != null && Theme.of(context).brightness == Brightness.light
                                ? (HSLColor.fromColor(cardColor).lightness < 0.7 ? Colors.white : Colors.black)
                                : null;

                            return Card(
                              color: cardColor,
                              elevation: 2.0,
                              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16.0),
                                title: Text(
                                  topic.encryptedContent,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Importance: ${topic.importanceLevel}',
                                    style: TextStyle(color: textColor?.withValues(alpha: (0.7 * 255))),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => TopicDetailScreen(topic: topic),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
