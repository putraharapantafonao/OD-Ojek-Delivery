import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  // Menentukan IP server tergantung perangkat yang digunakan (Windows/Android/Web)
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api';
    return 'http://127.0.0.1:8000/api';
  } 

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({
          'email': email,
          'password': password
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['access_token']);
        return {'success': true, 'user': data['user']};
      } else {
        // Validation errors biasanya ada di dalam object 'errors' untuk Laravel Sanctum
        String errorMessage = 'Login gagal';
        if (data['errors'] != null) {
          errorMessage = data['errors'].values.first[0];
        } else if (data['message'] != null) {
          errorMessage = data['message'];
        }
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server backend'};
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone_number': phone,
          'role': role,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['access_token']);
        return {'success': true, 'user': data['user']};
      } else {
        String errorMessage = 'Pendaftaran gagal';
        if (data['errors'] != null) {
          errorMessage = data['errors'].values.first[0];
        } else if (data['message'] != null) {
          errorMessage = data['message'];
        }
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server backend'};
    }
  }
}
