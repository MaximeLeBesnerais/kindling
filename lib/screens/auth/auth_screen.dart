import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../onboarding/welcome_screen.dart';
import '../screen_manager/screen_manager.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  String _email = '';
  String _username = '';
  String _password = '';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      setState(() {
        _email = _emailController.text;
      });
    });
  }

  void _submit() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();

    final Future<Map<String, dynamic>> authFuture = _isLogin
        ? _apiService.login(_email, _password)
        : _apiService.register(_email, _username, _password);

    authFuture.then((response) {
      if (_isLogin) {
        // For login, go directly to main app
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ScreenManager()));
      } else {
        // For registration, go through onboarding flow
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => WelcomeScreen(username: _username)));
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authentication'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_ethernet),
            onPressed: _showApiUrlDialog,
            tooltip: 'Set API URL',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isLogin ? 'Welcome Back' : 'Create Account',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (!_isLogin)
                      TextFormField(
                        key: ValueKey('username'),
                        decoration: InputDecoration(labelText: 'Username'),
                        validator: (value) => value!.isEmpty ? 'Please enter a username' : null,
                        onSaved: (value) => _username = value!,
                      ),
                    TextFormField(
                      key: ValueKey('email'),
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (value) => !value!.contains('@') ? 'Please enter a valid email' : null,
                      onSaved: (value) => _email = value!,
                    ),
                    TextFormField(
                      key: ValueKey('password'),
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
                      onSaved: (value) => _password = value!,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(_isLogin ? 'Login' : 'Register'),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(_isLogin ? 'Create an account' : 'I already have an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
