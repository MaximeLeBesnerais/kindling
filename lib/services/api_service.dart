import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String _baseUrl = 'http://localhost:8080'; // As per swagger.yml

  Future<Map<String, dynamic>> register(String email, String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_token', data['api_token']);
      return data;
    } else {
      throw Exception('Failed to register');
    }
  }

  Future<Map<String, dynamic>> login(String login, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'login': login,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_token', data['api_token']);
      return data;
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<Map<String, dynamic>> createSpace() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');

    final response = await http.post(
      Uri.parse('$_baseUrl/spaces/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await prefs.setString('space_id', data['space_id'].toString());
      await prefs.setString('qr_code_secret', data['qr_code_secret']);
      return data;
    } else {
      throw Exception('Failed to create space');
    }
  }

  Future<Map<String, dynamic>> joinSpace(String qrCodeSecret) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');

    final response = await http.post(
      Uri.parse('$_baseUrl/spaces/join'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'qr_code_secret': qrCodeSecret,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await prefs.setString('space_id', data['space_id'].toString());
      return data;
    } else {
      throw Exception('Failed to join space');
    }
  }

  Future<Map<String, dynamic>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');

    final response = await http.get(
      Uri.parse('$_baseUrl/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await prefs.setString('email', data['user']['email']);
      await prefs.setString('username', data['user']['username']);
      return data;
    } else {
      throw Exception('Failed to get user data');
    }
  }

  Future<Map<String, dynamic>> updateUsername(String newUsername, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');

    final response = await http.patch(
      Uri.parse('$_baseUrl/users/me/username'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'username': newUsername,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await prefs.setString('username', data['username']);
      return data;
    } else {
      throw Exception('Failed to update username');
    }
  }

  Future<void> updatePassword(String currentPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');

    final response = await http.patch(
      Uri.parse('$_baseUrl/users/me/password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception('Failed to update password: ${error['error']}');
    }
  }

  Future<List<dynamic>> getTopics() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');

    final response = await http.get(
      Uri.parse('$_baseUrl/topics'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load topics');
    }
  }

  Future<Map<String, dynamic>> getTopic(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');

    final response = await http.get(
      Uri.parse('$_baseUrl/topics/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load topic details');
    }
  }

  Future<Map<String, dynamic>> createTopic(String encryptedContent, int importanceLevel) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');

    final response = await http.post(
      Uri.parse('$_baseUrl/topics'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'encrypted_content': encryptedContent,
        'importance_level': importanceLevel,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create topic: ${response.body}');
    }
  }
}
