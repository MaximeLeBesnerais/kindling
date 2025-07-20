import 'package:flutter/material.dart';
import 'package:kindling/providers/topic_provider.dart';
import 'package:kindling/screens/auth/auth_screen.dart';
import 'package:kindling/screens/onboarding/space_choice_screen.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../theme/theme_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final ApiService _apiService = ApiService();
  String _email = '';
  String _username = '';
  String _partnerName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPartnerName();
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

  Future<void> _loadPartnerName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _partnerName = prefs.getString('partner_name') ?? '';
    });
  }

  void _showApiUrlDialog() {
    final controller = TextEditingController();
    _apiService.getBaseUrl().then((value) => controller.text = value);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set API Base URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'http://localhost:8080'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _apiService.setBaseUrl(controller.text);
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('API URL updated successfully!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSecretDialog() async {
    final secret = await _apiService.getSpaceSecret();
    if (mounted && secret != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Space Secret'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Share this secret with your partner to let them join your space.'),
              const SizedBox(height: 20),
              QrImageView(
                data: secret,
                version: QrVersions.auto,
                size: 200.0,
              ),
              const SizedBox(height: 20),
              SelectableText(secret),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No secret found. Are you in a space?')),
      );
    }
  }

  void _showChangePartnerNameDialog() {
    final controller = TextEditingController(text: _partnerName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Partner Name'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'Partner Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newPartnerName = controller.text;
                if (newPartnerName.isNotEmpty) {
                  try {
                    await _apiService.setPartnerName(newPartnerName); // Corrected to use local storage
                    Navigator.of(context).pop();
                    _loadPartnerName();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Partner name updated successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update partner name: $e')),
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
                  SizedBox(height: 10),
                  Text('Partner Name: $_partnerName', style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 20),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _showChangeUsernameDialog,
                        child: Text('Change Username'),
                      ),
                      ElevatedButton(
                        onPressed: _showChangePasswordDialog,
                        child: Text('Change Password'),
                      ),
                      ElevatedButton(
                        onPressed: _showChangePartnerNameDialog,
                        child: Text('Change Partner Name'),
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
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.settings_ethernet),
              title: const Text('Set API URL'),
              onTap: _showApiUrlDialog,
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.vpn_key),
              title: const Text('Display Secret'),
              onTap: _showSecretDialog,
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text('Quit Space', style: TextStyle(color: Colors.red)),
              onTap: () async {
                final shouldQuit = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Quit Space?'),
                    content: const Text('Are you sure you want to quit your current space? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Quit'),
                      ),
                    ],
                  ),
                );

                if (shouldQuit == true) {
                  try {
                    await _apiService.quitSpace();
                    Provider.of<TopicProvider>(context, listen: false).clearTopics();
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => SpaceChoiceScreen()),
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to quit space: $e')),
                      );
                    }
                  }
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () async {
            await _apiService.logout();
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthScreen()),
                (route) => false,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Logout'),
        ),
      ),
    );
  }

  void _showChangeUsernameDialog() {
    final newUsernameController = TextEditingController();
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Username'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newUsernameController,
                decoration: InputDecoration(labelText: 'New Username'),
              ),
              TextField(
                controller: passwordController,
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
                final newUsername = newUsernameController.text;
                final password = passwordController.text;
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
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: InputDecoration(labelText: 'Current Password'),
                obscureText: true,
              ),
              TextField(
                controller: newPasswordController,
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
                final currentPassword = currentPasswordController.text;
                final newPassword = newPasswordController.text;
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
