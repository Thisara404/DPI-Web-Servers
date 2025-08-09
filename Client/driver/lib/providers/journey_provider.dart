import 'dart:convert';
import 'package:flutter/material.dart';
import '../config/api_endpoints.dart';
import '../models/journey.dart';
import '../services/api_service.dart';

class JourneyProvider extends ChangeNotifier {
  Journey? _currentJourney;
  bool _isLoading = false;
  String? _error;

  Journey? get currentJourney => _currentJourney;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isJourneyActive => _currentJourney?.status == 'active';

  Future<bool> startJourney(String scheduleId) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await ApiService.post(
        ApiEndpoints.startJourney,
        {'scheduleId': scheduleId},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentJourney = Journey.fromJson(data['journey']);
        _setLoading(false);
        return true;
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['message'] ?? 'Failed to start journey';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> endJourney() async {
    if (_currentJourney == null) return false;

    _setLoading(true);
    _error = null;

    try {
      final response = await ApiService.put(
        ApiEndpoints.journeyById(_currentJourney!.id),
        {'status': 'completed'},
      );

      if (response.statusCode == 200) {
        _currentJourney = null;
        _setLoading(false);
        return true;
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['message'] ?? 'Failed to end journey';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
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