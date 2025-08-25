import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Token Management
  static Future<void> saveToken(String token) async {
    await prefs.setString(AppConstants.tokenKey, token);
  }

  static Future<String?> getToken() async {
    return prefs.getString(AppConstants.tokenKey);
  }

  static Future<void> removeToken() async {
    await prefs.remove(AppConstants.tokenKey);
  }

  // User Data Management
  static Future<void> saveUser(Map<String, dynamic> userData) async {
    final userJson = jsonEncode(userData);
    await prefs.setString(AppConstants.userKey, userJson);
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final userJson = prefs.getString(AppConstants.userKey);
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }

  static Future<void> removeUser() async {
    await prefs.remove(AppConstants.userKey);
  }

  // Onboarding
  static Future<void> setOnboardingCompleted(bool completed) async {
    await prefs.setBool(AppConstants.onboardingKey, completed);
  }

  static Future<bool> isOnboardingCompleted() async {
    return prefs.getBool(AppConstants.onboardingKey) ?? false;
  }

  // User Preferences
  static Future<void> savePreferences(Map<String, dynamic> preferences) async {
    final prefJson = jsonEncode(preferences);
    await prefs.setString(AppConstants.preferencesKey, prefJson);
  }

  static Future<Map<String, dynamic>?> getPreferences() async {
    final prefJson = prefs.getString(AppConstants.preferencesKey);
    if (prefJson != null) {
      return jsonDecode(prefJson);
    }
    return null;
  }

  // Generic Methods
  static Future<void> saveString(String key, String value) async {
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    return prefs.getString(key);
  }

  static Future<void> saveBool(String key, bool value) async {
    await prefs.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    return prefs.getBool(key);
  }

  static Future<void> saveInt(String key, int value) async {
    await prefs.setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    return prefs.getInt(key);
  }

  static Future<void> saveDouble(String key, double value) async {
    await prefs.setDouble(key, value);
  }

  static Future<double?> getDouble(String key) async {
    return prefs.getDouble(key);
  }

  // Clear all data
  static Future<void> clearAll() async {
    await prefs.clear();
  }

  // Remove specific key
  static Future<void> remove(String key) async {
    await prefs.remove(key);
  }

  // Check if key exists
  static bool containsKey(String key) {
    return prefs.containsKey(key);
  }
}