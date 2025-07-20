import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_token');
  }

  Future<Map<String, dynamic>> register(String email, String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
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
      Uri.parse('$baseUrl/users/login'),
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
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/spaces/create'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('space_secret', data['qr_code_secret']);
      await prefs.setBool('is_in_space', true);
      return data;
    } else {
      throw Exception('Failed to create space');
    }
  }

  Future<Map<String, dynamic>> joinSpace(String secret) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/spaces/join'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{'qr_code_secret': secret}),
    );

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_in_space', true);
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to join space');
    }
  }

  Future<String?> getSpaceSecret() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('space_secret');
  }

  Future<void> quitSpace() async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/spaces/quit'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('space_secret');
      await prefs.setBool('is_in_space', false);
    } else {
      throw Exception('Failed to quit space: ${response.body}');
    }
  }

  Future<bool> isInSpace() async {
    final prefs = await SharedPreferences.getInstance();
    bool? inSpace = prefs.getBool('is_in_space');

    if (inSpace != null) {
      return inSpace;
    }

    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/spaces/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      inSpace = data['in_space'] as bool;
      await prefs.setBool('is_in_space', inSpace);
      return inSpace;
    } else {
      // If the endpoint fails, we assume they are not in a space to be safe
      await prefs.setBool('is_in_space', false);
      return false;
    }
  }

  Future<Map<String, dynamic>> getUser() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = data['user'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', user['email']);
      await prefs.setString('user_username', user['username']);
      await prefs.setString('user_id', user['id'].toString());
      return user; // Return the user map
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<Map<String, dynamic>> updateUsername(String newUsername, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');

    final response = await http.patch(
      Uri.parse('$baseUrl/users/me/username'),
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
      Uri.parse('$baseUrl/users/me/password'),
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
      Uri.parse('$baseUrl/topics'),
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
      Uri.parse('$baseUrl/topics/$id'),
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
      Uri.parse('$baseUrl/topics'),
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

  Future<List<dynamic>> getComments(String topicId) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/topics/$topicId/comments'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<Map<String, dynamic>> createComment(String topicId, String content) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/topics/$topicId/comments'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'encrypted_content': content,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create comment: ${response.body}');
    }
  }

  Future<void> setPartnerName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('partner_name', name);
  }

  Future<String> getPartnerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('partner_name') ?? 'Partner';
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
