import 'package:flutter/material.dart';
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
  final token = prefs.getString('api_token');

  if (token != null) {
    // Fetch user data in the background
    ApiService().getUser().catchError((e) {
      print('Failed to fetch user data on startup: $e');
    });
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager(prefs)),
        ChangeNotifierProvider(create: (_) => TopicProvider()),
      ],
      child: MyApp(token: token),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? token;

  const MyApp({super.key, this.token});

  @override
  Widget build(BuildContext context) {
    if (token != null) {
      Provider.of<TopicProvider>(context, listen: false).fetchTopics();
    }
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return MaterialApp(
          title: 'Kindling',
          theme: themeManager.lightTheme,
          darkTheme: themeManager.darkTheme,
          themeMode: themeManager.themeMode,
          home: token != null ? ScreenManager() : AuthScreen(),
        );
      },
    );
  }
}
