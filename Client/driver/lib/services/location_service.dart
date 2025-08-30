import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static StreamSubscription<Position>? _positionStream;

  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }
  }

  static Future<void> startLocationUpdates() async {
    try {
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      );

      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {
        // Handle position updates
        print('Location updated: ${position.latitude}, ${position.longitude}');
      });
    } catch (e) {
      throw Exception('Failed to start location updates: $e');
    }
  }

  static Future<void> stopLocationUpdates() async {
    await _positionStream?.cancel();
    _positionStream = null;
  }
}
