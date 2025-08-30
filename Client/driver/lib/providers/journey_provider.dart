import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api.endpoints.dart';
import '../models/journey.dart';
import '../services/api_service.dart';

class JourneyProvider extends ChangeNotifier {
  Journey? _currentJourney;
  bool _isLoading = false;
  String? _error;
  final ApiService _apiService = ApiService(); // Create instance

  Journey? get currentJourney => _currentJourney;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isJourneyActive =>
      _currentJourney?.status == 'active' ||
      _currentJourney?.status == 'started';

  Future<bool> startJourney(String scheduleId) async {
    _setLoading(true);
    _error = null;

    try {
      // Use the instance method and parse the response directly into a Journey object
      final response = await _apiService.post<Journey>(
        ApiEndpoints.startJourney,
        {'scheduleId': scheduleId},
        // FIX: Handle potentially nested JSON from the API response.
        // This now correctly handles responses like { "data": { "journey": {...} } } or { "data": {...} }
        fromJsonT: (json) => Journey.fromJson(json['journey'] ?? json),
      );

      if (response.success && response.data != null) {
        _currentJourney = response.data;
        _setLoading(false);
        return true;
      } else {
        _error = response.message ?? 'Failed to start journey';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> endJourney() async {
    if (_currentJourney == null) return false;

    _setLoading(true);
    _error = null;

    try {
      // Use a generic type since we only care about the success status
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiEndpoints.stopTracking,
        {'scheduleId': _currentJourney!.scheduleId},
        fromJsonT: (json) => json,
      );

      if (response.success) {
        _currentJourney = null;
        _setLoading(false);
        return true;
      } else {
        _error = response.message ?? 'Failed to end journey';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
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
