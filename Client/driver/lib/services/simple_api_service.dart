import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SimpleApiService {
  static const _storage = FlutterSecureStorage();
  static const String _accessTokenKey = 'access_token';

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  static Future<http.Response> post(
      String url, Map<String, dynamic> body) async {
    final accessToken = await getAccessToken();

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      return response;
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }

  static Future<http.Response> get(String url) async {
    final accessToken = await getAccessToken();

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      return response;
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }
}
