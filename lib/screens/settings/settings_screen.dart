import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../theme/theme_manager.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _apiService = ApiService();
  String _email = '';
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('email') ?? '';
      _username = prefs.getString('username') ?? '';
    });
    try {
      final userData = await _apiService.getUser();
      setState(() {
        _email = userData['user']['email'];
        _username = userData['user']['username'];
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Account', style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 20),
                  Text('Email: $_email', style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 10),
                  Text('Username: $_username', style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _showChangeUsernameDialog,
                        child: Text('Change Username'),
                      ),
                      ElevatedButton(
                        onPressed: _showChangePasswordDialog,
                        child: Text('Change Password'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Theme', style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 20),
                  Text('Color', style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 10),
                  _buildThemeSelector(themeManager),
                  SizedBox(height: 20),
                  Text('Mode', style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 10),
                  _buildThemeModeSelector(context, themeManager),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeUsernameDialog() {
    final _newUsernameController = TextEditingController();
    final _passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Username'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _newUsernameController,
                decoration: InputDecoration(labelText: 'New Username'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newUsername = _newUsernameController.text;
                final password = _passwordController.text;
                if (newUsername.isNotEmpty && password.isNotEmpty) {
                  try {
                    await _apiService.updateUsername(newUsername, password);
                    Navigator.of(context).pop();
                    _loadUserData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Username updated successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update username: $e')),
                    );
                  }
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final _currentPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _currentPasswordController,
                decoration: InputDecoration(labelText: 'Current Password'),
                obscureText: true,
              ),
              TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final currentPassword = _currentPasswordController.text;
                final newPassword = _newPasswordController.text;
                if (currentPassword.isNotEmpty && newPassword.isNotEmpty) {
                  try {
                    await _apiService.updatePassword(currentPassword, newPassword);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password updated successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update password: $e')),
                    );
                  }
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
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
    final isSelected = themeManager.lightTheme.colorScheme.primary == color ||
        (themeManager.lightTheme.colorScheme.primary.value == color.value &&
            themeManager.lightTheme.colorScheme.brightness == Brightness.light);

    // A better way to check for selection
    final currentSeedColor = themeManager.lightTheme.colorScheme.primary;
    bool isActuallySelected = false;
    if (color == Colors.blue && currentSeedColor.value == Colors.blue.value) isActuallySelected = true;
    if (color == Colors.pink && currentSeedColor.value == Colors.pink.value) isActuallySelected = true;
    if (color == Colors.green && currentSeedColor.value == Colors.green.value) isActuallySelected = true;
    if (color == Colors.orange && currentSeedColor.value == Colors.orange.value) isActuallySelected = true;

    final selectedColorName = themeManager.prefs.getString('theme_color');
    isActuallySelected = selectedColorName == _getColorName(color);

    return GestureDetector(
      onTap: () => themeManager.setTheme(color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: isActuallySelected
            ? Icon(Icons.check, color: Colors.white)
            : null,
      ),
    );
  }

  String _getColorName(Color color) {
    if (color == Colors.blue) return 'blue';
    if (color == Colors.pink) return 'pink';
    if (color == Colors.green) return 'green';
    if (color == Colors.orange) return 'orange';
    return 'blue';
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
