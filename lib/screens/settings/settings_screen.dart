
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_manager.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Theme Color', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 10),
            _buildThemeSelector(themeManager),
            SizedBox(height: 20),
            Text('Theme Mode', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 10),
            _buildThemeModeSelector(context, themeManager),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(ThemeManager themeManager) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildThemeCircle(themeManager, Colors.blue),
        _buildThemeCircle(themeManager, Colors.pink),
        _buildThemeCircle(themeManager, Colors.green),
        _buildThemeCircle(themeManager, Colors.orange),
      ],
    );
  }

  Widget _buildThemeCircle(ThemeManager themeManager, Color color) {
    return GestureDetector(
      onTap: () => themeManager.setTheme(color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: themeManager.themeData.primaryColor == color ? Colors.white : Colors.transparent,
            width: 3,
          ),
        ),
      ),
    );
  }

  Widget _buildThemeModeSelector(BuildContext context, ThemeManager themeManager) {
    return DropdownButton<ThemeMode>(
      value: themeManager.themeMode,
      onChanged: (ThemeMode? newValue) {
        if (newValue != null) {
          themeManager.setThemeMode(newValue);
        }
      },
      items: ThemeMode.values.map((ThemeMode mode) {
        return DropdownMenuItem<ThemeMode>(
          value: mode,
          child: Text(mode.toString().split('.').last.capitalize()),
        );
      }).toList(),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
