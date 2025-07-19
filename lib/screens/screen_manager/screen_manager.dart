import 'package:flutter/material.dart';
import 'package:kindling/screens/archive/archives_screen.dart';
import 'package:kindling/screens/topic/topics_screen.dart';
import '../archive/archive_screen.dart';
import '../settings/settings_screen.dart';

class ScreenManager extends StatefulWidget {
  const ScreenManager({super.key});

  @override
  State<ScreenManager> createState() => _ScreenManagerState();
}

class _ScreenManagerState extends State<ScreenManager> {
  int _selectedIndex = 1; // Start with TopicScreen (center)

  final List<Widget> _screens = [
    ArchivesScreen(),
    TopicsScreen(),
    SettingsScreen(),
  ];

  final List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(Icons.archive_outlined),
      selectedIcon: Icon(Icons.archive),
      label: 'Archive',
    ),
    NavigationDestination(
      icon: Icon(Icons.topic_outlined),
      selectedIcon: Icon(Icons.topic),
      label: 'Topics',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  final List<NavigationRailDestination> _railDestinations = [
    NavigationRailDestination(
      icon: Icon(Icons.archive_outlined),
      selectedIcon: Icon(Icons.archive),
      label: Text('Archive'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.topic_outlined),
      selectedIcon: Icon(Icons.topic),
      label: Text('Topics'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: Text('Settings'),
    ),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool useNavigationRail = screenWidth >= 1024; // Use rail for large screens

    if (useNavigationRail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              useIndicator: true,
              destinations: _railDestinations,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Icon(
                  Icons.local_fire_department,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: _screens[_selectedIndex],
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: _destinations,
        ),
      );
    }
  }
}
