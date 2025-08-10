import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../constants.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;

  // Initialize auth state
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    setLoading(true);
    try {
      _user = await AuthService.getCurrentUser();
      _isInitialized = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      setLoading(false);
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    setLoading(true);
    clearError();

    try {
      _user = await AuthService.login(email, password);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Register
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    String? citizenId,
  }) async {
    setLoading(true);
    clearError();

    try {
      _user = await AuthService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
        citizenId: citizenId,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Update Profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    UserPreferences? preferences,
  }) async {
    setLoading(true);
    clearError();

    try {
      _user = await AuthService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        preferences: preferences,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Refresh User Profile
  Future<void> refreshProfile() async {
    if (!isAuthenticated) return;

    try {
      _user = await AuthService.refreshUserProfile();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Verify Citizen ID
  Future<bool> verifyCitizenId(String citizenId) async {
    setLoading(true);
    clearError();

    try {
      final isValid = await AuthService.verifyCitizenId(citizenId);
      return isValid;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    setLoading(true);
    try {
      await AuthService.logout();
      _user = null;
      _isInitialized = false;
    } catch (e) {
      _error = e.toString();
    } finally {
      setLoading(false);
    }
  }

  // Helper methods
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setError(String error) {
    _error = error;
    notifyListeners();
  }
}