import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager with ChangeNotifier {
  final SharedPreferences prefs;

  ThemeData _lightTheme;
  ThemeData _darkTheme;
  ThemeMode _themeMode;
  bool _useColorGrading;

  ThemeManager(this.prefs)
      : _lightTheme = ThemeData(useMaterial3: true),
        _darkTheme = ThemeData.dark(useMaterial3: true),
        _themeMode = ThemeMode.system,
        _useColorGrading = true {
    loadTheme();
  }

  ThemeData get lightTheme => _lightTheme;
  ThemeData get darkTheme => _darkTheme;
  ThemeMode get themeMode => _themeMode;
  bool get useColorGrading => _useColorGrading;

  void loadTheme() {
    final colorName = prefs.getString('theme_color');
    final themeModeName = prefs.getString('theme_mode');
    _useColorGrading = prefs.getBool('use_color_grading') ?? true;

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

  Future<void> setColorGrading(bool enabled) async {
    _useColorGrading = enabled;
    await prefs.setBool('use_color_grading', enabled);
    notifyListeners();
  }

  Color? getTopicColor(BuildContext context, int importanceLevel) {
    if (!_useColorGrading) {
      return null; // Return null to use the default Card color
    }

    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isDarkMode = theme.brightness == Brightness.dark;

    // Define the start and end colors for the gradient
    final startColor = isDarkMode
        ? HSLColor.fromColor(primaryColor).withLightness(0.2).toColor()
        : HSLColor.fromColor(primaryColor).withLightness(0.95).toColor();
    final endColor = isDarkMode
        ? HSLColor.fromColor(primaryColor).withLightness(0.4).toColor()
        : HSLColor.fromColor(primaryColor).withLightness(0.6).toColor();

    // Calculate the interpolation factor (0.0 for importance 1, 1.0 for importance 10)
    final t = (importanceLevel - 1) / 9.0;

    return Color.lerp(startColor, endColor, t.clamp(0.0, 1.0));
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