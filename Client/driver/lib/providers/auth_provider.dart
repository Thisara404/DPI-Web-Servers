// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import '../models/driver_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  Driver? _driver;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  final AuthService _authService = AuthService();

  Driver? get driver => _driver;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // New method to check if tokens exist locally
  Future<bool> hasValidTokens() async {
    try {
      final token = await _authService.getAccessToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> register(Driver driver) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.register(driver);

      if (response.success) {
        if (response.accessToken != null && response.refreshToken != null) {
          await _authService.storeTokens(
              response.accessToken!, response.refreshToken!);
        }
        _driver = response.driver;
        _isAuthenticated = true;
        notifyListeners(); // FIX: Notify listeners to update UI immediately
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.login(email, password);

      if (response.success) {
        if (response.accessToken != null && response.refreshToken != null) {
          await _authService.storeTokens(
              response.accessToken!, response.refreshToken!);
        }
        _driver = response.driver;
        _isAuthenticated = true;
        notifyListeners(); // FIX: Notify listeners to update UI immediately
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _driver = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // Improved loadProfile with offline fallback
  Future<void> loadProfile() async {
    try {
      _driver = await _authService.getProfile();
      if (_driver != null) {
        _isAuthenticated = true;
      } else {
        final hasTokens = await hasValidTokens();
        if (hasTokens) {
          _isAuthenticated = true;
          _error = 'Profile load failed. Using offline mode.';
        } else {
          _isAuthenticated = false;
        }
      }
      notifyListeners(); // FIX: Ensure UI updates
    } catch (e) {
      final hasTokens = await hasValidTokens();
      if (hasTokens) {
        _isAuthenticated = true;
        _error = 'Network error. Using offline mode.';
      } else {
        _isAuthenticated = false;
        _driver = null;
      }
      notifyListeners();
    }
  }

  Future<void> updateProfile(Driver updatedDriver) async {
    try {
      _driver = await _authService.updateProfile(updatedDriver);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
}
