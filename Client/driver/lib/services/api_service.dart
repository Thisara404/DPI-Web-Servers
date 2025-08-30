// lib/services/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api.endpoints.dart';
import '../models/api_response_model.dart';

class ApiService {
  static const _storage = FlutterSecureStorage();
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  final http.Client _client = http.Client();

  // Get stored access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  // Static method to get access token
  static Future<String?> getAccessTokenStatic() async {
    return await _storage.read(key: _accessTokenKey);
  }

  // Store tokens
  Future<void> storeTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  // Clear tokens (for logout)
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  // Simplified refresh token logic without AuthResponse dependency
  Future<bool> refreshAccessToken() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken == null) return false;

    try {
      final response = await _client.post(
        Uri.parse(ApiEndpoints.refreshToken),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['accessToken'] != null) {
          await storeTokens(data['accessToken'], refreshToken);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Generic request method with retry on 401
  Future<http.Response> _request(
    Future<http.Response> Function() requestFunc, {
    bool withAuth = true,
  }) async {
    try {
      var response = await requestFunc();

      if (response.statusCode == 401 && withAuth) {
        // Try refresh
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          response = await requestFunc(); // Retry with new token
        } else {
          throw Exception('Session expired. Please login again.');
        }
      }

      return response;
    } on SocketException {
      throw Exception('No internet connection.');
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }

  // GET request
  Future<ApiResponse<T>> get<T>(
    String url, {
    Map<String, String>? params,
    required T Function(Map<String, dynamic>) fromJsonT,
  }) async {
    final accessToken = await getAccessToken();
    final uri = Uri.parse(url).replace(queryParameters: params);

    final response = await _request(() => _client.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          },
        ));

    return _parseResponse<T>(response, fromJsonT);
  }

  // POST request with debug logs
  Future<ApiResponse<T>> post<T>(
    String url,
    Map<String, dynamic> body, {
    required T Function(Map<String, dynamic>) fromJsonT,
    bool withAuth = true,
  }) async {
    // Check connectivity
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw Exception('No internet connection');
      }
    } on SocketException catch (_) {
      throw Exception('No internet connection');
    }

    print('🌐 API POST: $url');
    print('📤 Request body: $body');
    print('🔐 With auth: $withAuth');

    final accessToken = await getAccessToken();
    print('🔑 Access token exists: ${accessToken != null}');

    final response = await _request(
      () => _client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (withAuth && accessToken != null)
            'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      ),
      withAuth: withAuth,
    );

    print('📥 Response status: ${response.statusCode}');
    print('📄 Response body: ${response.body}');

    return _parseResponse<T>(response, fromJsonT);
  }

  // PUT request
  Future<ApiResponse<T>> put<T>(
    String url,
    Map<String, dynamic> body, {
    required T Function(Map<String, dynamic>) fromJsonT,
  }) async {
    final accessToken = await getAccessToken();

    final response = await _request(() => _client.put(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode(body),
        ));

    return _parseResponse<T>(response, fromJsonT);
  }

  // PATCH request
  Future<ApiResponse<T>> patch<T>(
    String url,
    Map<String, dynamic> body, {
    required T Function(Map<String, dynamic>) fromJsonT,
  }) async {
    final accessToken = await getAccessToken();

    final response = await _request(() => _client.patch(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode(body),
        ));

    return _parseResponse<T>(response, fromJsonT);
  }

  // Enhanced error parsing
  ApiResponse<T> _parseResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    print('🔍 Parsing response for status: ${response.statusCode}');

    try {
      final json = jsonDecode(response.body);
      print('📋 Parsed JSON: $json');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.fromJson(json, fromJsonT);
      } else {
        print('❌ API Error: ${json['message'] ?? 'Unknown error'}');
        print('🔍 Error details: ${json['errors'] ?? 'No details'}');
        throw Exception(json['message'] ?? 'API error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ JSON parsing error: $e');
      print('📄 Raw response: ${response.body}');
      throw Exception('Failed to parse response: $e');
    }
  }
}
