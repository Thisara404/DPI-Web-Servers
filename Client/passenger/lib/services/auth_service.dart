import 'dart:convert';
import '../models/user.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  static Future<User> login(String email, String password) async {
    try {
      final response = await ApiService.login(email, password);
      
      if (response['success'] == true) {
        final userData = response['user'];
        final token = response['token'];
        
        // Store token and user data
        await StorageService.saveToken(token);
        await StorageService.saveUser(userData);
        
        return User.fromJson(userData);
      } else {
        throw Exception(response['message'] ?? ErrorMessages.invalidCredentials);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<User> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    String? citizenId,
  }) async {
    try {
      final userData = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'phone': phone,
        if (citizenId != null) 'citizenId': citizenId,
      };

      final response = await ApiService.register(userData);
      
      if (response['success'] == true) {
        final user = response['user'];
        final token = response['token'];
        
        // Store token and user data
        await StorageService.saveToken(token);
        await StorageService.saveUser(user);
        
        return User.fromJson(user);
      } else {
        throw Exception(response['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<User?> getCurrentUser() async {
    try {
      final userData = await StorageService.getUser();
      if (userData != null) {
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<User> refreshUserProfile() async {
    try {
      final response = await ApiService.getProfile();
      
      if (response['success'] == true) {
        final userData = response['user'];
        
        // Update stored user data
        await StorageService.saveUser(userData);
        
        return User.fromJson(userData);
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch profile');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    UserPreferences? preferences,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (phone != null) updateData['phone'] = phone;
      if (preferences != null) updateData['preferences'] = preferences.toJson();

      final response = await ApiService.updateProfile(updateData);
      
      if (response['success'] == true) {
        final userData = response['user'];
        
        // Update stored user data
        await StorageService.saveUser(userData);
        
        return User.fromJson(userData);
      } else {
        throw Exception(response['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<bool> isAuthenticated() async {
    final token = await StorageService.getToken();
    return token != null;
  }

  static Future<void> logout() async {
    await StorageService.clearAll();
  }

  // SLUDI Verification (placeholder - implement based on your server)
  static Future<bool> verifyCitizenId(String citizenId) async {
    try {
      // This would call your server's SLUDI verification endpoint
      // For now, returning true as placeholder
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      return true;
    } catch (e) {
      return false;
    }
  }
}