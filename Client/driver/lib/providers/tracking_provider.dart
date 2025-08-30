// lib/providers/tracking_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/tracking_model.dart';
import '../services/tracking_service.dart';

class TrackingProvider extends ChangeNotifier {
  bool _isTracking = false;
  Position? _currentPosition;
  Timer? _updateTimer;
  final TrackingService _service = TrackingService();

  bool get isTracking => _isTracking;
  Position? get currentPosition => _currentPosition;

  Future<void> startTracking(String scheduleId, String journeyId) async {
    bool permissionGranted = await _requestLocationPermission();
    if (!permissionGranted) throw Exception('Location permission denied');

    await _service.startTracking(scheduleId, journeyId);
    _isTracking = true;
    notifyListeners();

    // Start periodic updates (every 10s)
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      await _updateLocation(scheduleId, journeyId);
    });
  }

  Future<void> _updateLocation(String scheduleId, String journeyId) async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final update = LocationUpdate(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        bearing: _currentPosition!.heading,
        speed: _currentPosition!.speed,
        accuracy: _currentPosition!.accuracy,
        scheduleId: scheduleId,
        journeyId: journeyId,
        timestamp: DateTime.now(),
      );
      await _service.updateLocation(update);
      notifyListeners();
    } catch (e) {
      // Handle error, e.g., GPS off
    }
  }

  Future<void> stopTracking() async {
    await _service.stopTracking();
    _updateTimer?.cancel();
    _isTracking = false;
    _currentPosition = null;
    notifyListeners();
  }

  Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }

  // Add getHistory if needed
}