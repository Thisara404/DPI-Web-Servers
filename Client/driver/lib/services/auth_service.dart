// lib/services/auth_service.dart

import '../config/api.endpoints.dart';
import '../models/driver_model.dart';
import 'api_service.dart';

class AuthService extends ApiService {
  Future<AuthResponse> register(Driver driver) async {
    print('🔐 AuthService: Registering driver...');
    print('👤 Driver data: ${driver.toJson()}');

    final apiResponse = await post<Map<String, dynamic>>(
      ApiEndpoints.register,
      driver.toJson(),
      fromJsonT: (json) => json, // Keep raw JSON for AuthResponse parsing
      withAuth: false,
    );

    print('📥 AuthService: Register response received');
    print('📄 Response data: ${apiResponse.data}');

    // FIX: Build the full response shape expected by AuthResponse.fromJson
    final fullResponse = {
      'success': apiResponse.success,
      'message': apiResponse.message,
      'data': apiResponse.data,
      'accessToken': apiResponse.data?['tokens']?['accessToken'] ??
          apiResponse.accessToken,
      'refreshToken': apiResponse.data?['tokens']?['refreshToken'] ??
          apiResponse.refreshToken,
    };

    if (apiResponse.success) {
      return AuthResponse.fromJson(fullResponse);
    } else {
      throw Exception(apiResponse.message ?? 'Registration failed');
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    print('🔐 AuthService: Logging in user: $email');

    final apiResponse = await post<Map<String, dynamic>>(
      ApiEndpoints.login,
      {'email': email, 'password': password},
      fromJsonT: (json) => json, // Keep raw JSON for AuthResponse parsing
      withAuth: false,
    );

    print('📥 AuthService: Login response received');
    print('📄 Response data: ${apiResponse.data}');

    // FIX: Build the full response shape expected by AuthResponse.fromJson
    final fullResponse = {
      'success': apiResponse.success,
      'message': apiResponse.message,
      'data': apiResponse.data,
      'accessToken': apiResponse.data?['tokens']?['accessToken'] ??
          apiResponse.accessToken,
      'refreshToken': apiResponse.data?['tokens']?['refreshToken'] ??
          apiResponse.refreshToken,
    };

    if (apiResponse.success) {
      return AuthResponse.fromJson(fullResponse);
    } else {
      throw Exception(apiResponse.message ?? 'Login failed');
    }
  }

  Future<bool> logout() async {
    try {
      await post<Map<String, dynamic>>(
        ApiEndpoints.logout,
        {},
        fromJsonT: (json) => json,
      );
      await clearTokens();
      return true;
    } catch (e) {
      print('❌ Logout error: $e');
      await clearTokens(); // Clear tokens anyway
      return false;
    }
  }

  Future<Driver?> getProfile() async {
    try {
      final apiResponse = await get<Driver>(
        ApiEndpoints.profile,
        fromJsonT: (json) => Driver.fromJson(json['data'] ?? json),
      );
      return apiResponse.data;
    } catch (e) {
      print('❌ Get profile error: $e');
      return null;
    }
  }

  Future<Driver> updateProfile(Driver driver) async {
    final apiResponse = await put<Driver>(
      ApiEndpoints.profile,
      driver.toJson(),
      fromJsonT: (json) => Driver.fromJson(json['data'] ?? json),
    );

    if (apiResponse.data != null) {
      return apiResponse.data!;
    } else {
      throw Exception(apiResponse.message ?? 'Failed to update profile');
    }
  }
}
