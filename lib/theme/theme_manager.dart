import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager with ChangeNotifier {
  final SharedPreferences prefs;

  ThemeData _themeData;
  ThemeMode _themeMode;

  ThemeManager(this.prefs)
      : _themeData = ThemeData(),
        _themeMode = ThemeMode.system {
    _loadTheme();
  }

  ThemeData get themeData => _themeData;
  ThemeMode get themeMode => _themeMode;

  void _loadTheme() {
    final colorName = prefs.getString('theme_color');
    final themeModeName = prefs.getString('theme_mode');

    final themeColor = _getColor(colorName);
    _themeMode = _getThemeMode(themeModeName);
    _themeData = _buildTheme(themeColor);

    notifyListeners();
  }

  ThemeData _buildTheme(Color color) {
    return ThemeData(
      primarySwatch: _getMaterialColor(color),
      primaryColor: color,
      buttonTheme: ButtonThemeData(
        buttonColor: color,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }

  void setTheme(Color color) {
    _themeData = _buildTheme(color);
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

  MaterialColor _getMaterialColor(Color color) {
    if (color is MaterialColor) {
      return color;
    }
    final shades = <int, Color>{
      50: color.withOpacity(0.1),
      100: color.withOpacity(0.2),
      200: color.withOpacity(0.3),
      300: color.withOpacity(0.4),
      400: color.withOpacity(0.5),
      500: color.withOpacity(0.6),
      600: color.withOpacity(0.7),
      700: color.withOpacity(0.8),
      800: color.withOpacity(0.9),
      900: color,
    };
    return MaterialColor(color.value, shades);
  }
}