import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager with ChangeNotifier {
  final SharedPreferences prefs;

  ThemeData _lightTheme;
  ThemeData _darkTheme;
  ThemeMode _themeMode;

  ThemeManager(this.prefs)
      : _lightTheme = ThemeData(useMaterial3: true),
        _darkTheme = ThemeData.dark(useMaterial3: true),
        _themeMode = ThemeMode.system {
    loadTheme();
  }

  ThemeData get lightTheme => _lightTheme;
  ThemeData get darkTheme => _darkTheme;
  ThemeMode get themeMode => _themeMode;

  void loadTheme() {
    final colorName = prefs.getString('theme_color');
    final themeModeName = prefs.getString('theme_mode');

    final themeColor = _getColor(colorName);
    _themeMode = _getThemeMode(themeModeName);
    _lightTheme = _buildTheme(themeColor);
    _darkTheme = _buildDarkTheme(themeColor);

    notifyListeners();
  }

  ThemeData _buildTheme(Color color) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );
  }

  ThemeData _buildDarkTheme(Color color) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }

  void setTheme(Color color) {
    _lightTheme = _buildTheme(color);
    _darkTheme = _buildDarkTheme(color);
    prefs.setString('theme_color', _getColorName(color));
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    prefs.setString('theme_mode', mode.toString().split('.').last);
    notifyListeners();
  }

  Color _getColor(String? colorName) {
    switch (colorName) {
      case 'pink':
        return Colors.pink;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'blue':
      default:
        return Colors.blue;
    }
  }

  ThemeMode _getThemeMode(String? themeModeName) {
    switch (themeModeName) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _getColorName(Color color) {
    if (color == Colors.pink) return 'pink';
    if (color == Colors.green) return 'green';
    if (color == Colors.orange) return 'orange';
    return 'blue';
  }
}