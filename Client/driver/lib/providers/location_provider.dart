import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  bool _isTracking = false;
  String? _error;
  Timer? _locationTimer;

  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;
  String? get error => _error;

  Future<void> startTracking(String scheduleId, String journeyId) async {
    try {
      _isTracking = true;
      _error = null;
      notifyListeners();

      // Get initial position
      _currentPosition = await LocationService.getCurrentLocation();
      notifyListeners();

      // Start periodic location updates
      _locationTimer =
          Timer.periodic(const Duration(seconds: 10), (timer) async {
        if (_isTracking) {
          try {
            _currentPosition = await LocationService.getCurrentLocation();
            notifyListeners();
          } catch (e) {
            _error = 'Location update failed: ${e.toString()}';
            notifyListeners();
          }
        } else {
          timer.cancel();
        }
      });
    } catch (e) {
      _error = e.toString();
      _isTracking = false;
      notifyListeners();
    }
  }

  Future<void> stopTracking(String scheduleId) async {
    _isTracking = false;
    _locationTimer?.cancel();
    _locationTimer = null;
    _error = null;
    notifyListeners();

    try {
      await LocationService.stopLocationUpdates();
    } catch (e) {
      _error = 'Failed to stop location tracking: ${e.toString()}';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }
}
