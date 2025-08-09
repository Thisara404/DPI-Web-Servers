import 'dart:convert';
import 'package:flutter/material.dart';
import '../config/api_endpoints.dart';
import '../models/driver.dart';
import '../services/api_service.dart';
import '../utils/shared_prefs.dart';

class AuthProvider extends ChangeNotifier {
  Driver? _driver;
  bool _isLoading = false;
  String? _error;

  Driver? get driver => _driver;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await ApiService.post(
        ApiEndpoints.driverLogin,
        {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        final driverData = data['driver'];

        await SharedPrefs.setToken(token);
        await SharedPrefs.setDriverId(driverData['id']);
        
        _driver = Driver.fromJson(driverData);
        _setLoading(false);
        return true;
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['message'] ?? 'Login failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String email, String password, String name, String phone, String licenseNumber) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await ApiService.post(
        ApiEndpoints.driverRegister,
        {
          'email': email,
          'password': password,
          'name': name,
          'phone': phone,
          'licenseNumber': licenseNumber,
        },
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final token = data['token'];
        final driverData = data['driver'];

        await SharedPrefs.setToken(token);
        await SharedPrefs.setDriverId(driverData['id']);
        
        _driver = Driver.fromJson(driverData);
        _setLoading(false);
        return true;
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['message'] ?? 'Registration failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await ApiService.post(ApiEndpoints.driverLogout, {});
    } catch (e) {
      // Ignore logout errors
    }
    
    await SharedPrefs.clearAll();
    _driver = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
