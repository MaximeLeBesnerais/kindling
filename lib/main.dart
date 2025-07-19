import 'package:flutter/material.dart';
import 'package:kindling/screens/onboarding/space_choice_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/topic_provider.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/screen_manager/screen_manager.dart';
import 'services/api_service.dart';
import 'theme/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final apiToken = prefs.getString('api_token');
  final themeManager = ThemeManager(prefs);

  bool isInSpace = false;
  if (apiToken != null) {
    final apiService = ApiService();
    isInSpace = await apiService.isInSpace();
    if (isInSpace) {
      // Fetch user and topics in the background if the user is in a space
      apiService.getUser().catchError((e) {
        debugPrint('Failed to get user on startup: $e');
        return <String, dynamic>{}; // Return an empty map as a fallback
      });
      final topicProvider = TopicProvider();
      topicProvider.fetchTopics().catchError((e) => debugPrint('Failed to get topics on startup: $e'));
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => themeManager),
        ChangeNotifierProvider(create: (context) => TopicProvider()),
      ],
      child: MyApp(apiToken: apiToken, isInSpace: isInSpace),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? apiToken;
  final bool isInSpace;

  const MyApp({super.key, this.apiToken, required this.isInSpace});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    // Decide the home screen based on token and space status
    Widget homeScreen;
    if (apiToken != null) {
      if (isInSpace) {
        homeScreen = ScreenManager();
      } else {
        homeScreen = SpaceChoiceScreen();
      }
    } else {
      homeScreen = const AuthScreen();
    }

    return MaterialApp(
      title: 'Kindling',
      theme: themeManager.lightTheme,
      darkTheme: themeManager.darkTheme,
      themeMode: themeManager.themeMode,
      home: homeScreen,
    );
  }
}
