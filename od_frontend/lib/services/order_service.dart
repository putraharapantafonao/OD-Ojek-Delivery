import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class OrderService {
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api';
    return 'http://127.0.0.1:8000/api';
  }

  Future<Map<String, dynamic>> createOrder({
    required String serviceType,
    required String pickupLocation,
    required String dropoffLocation,
    required double price,
    required String paymentMethod,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {'success': false, 'message': 'Sesi telah habis, silakan login kembali'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'service_type': serviceType,
          'pickup_location': pickupLocation,
          'dropoff_location': dropoffLocation,
          'price': price,
          'payment_method': paymentMethod,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'order': data['order'], 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Gagal membuat pesanan'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server backend'};
    }
  }

  Future<List<dynamic>> getAvailableOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> acceptOrder(int orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {'success': false, 'message': 'Sesi telah habis'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/orders/$orderId/accept'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Gagal menerima pesanan'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server'};
    }
  }
}
