import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:transit_lanka/config/api.endpoints.dart';
import 'package:transit_lanka/core/services/api/api_service.dart';
import 'package:transit_lanka/core/models/map.dart';
import 'package:transit_lanka/core/services/google_directions.service.dart';
import 'package:transit_lanka/core/services/osrm.service.dart';

class MapService {
  final ApiService _apiService = ApiService();
  final Location _location = Location();

  // Get the current location
  Future<LocationData?> getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location service is enabled
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    // Check if permission is granted
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    return await _location.getLocation();
  }

  // Get directions between two points
  Future<Map<String, dynamic>?> getDirections(
      LatLng origin, LatLng destination) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.directions(origin.latitude, origin.longitude,
            destination.latitude, destination.longitude),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting directions: $e');
      return null;
    }
  }

  // Update driver location in real-time
  Future<bool> updateDriverLocation(
      String scheduleId, LocationData location) async {
    try {
      final endpoint = ApiEndpoints.updateDriverLocation(scheduleId);
      print('Updating driver location at endpoint: $endpoint');

      final response = await _apiService.post(
        endpoint,
        body: {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'bearing': location.heading,
          'speed': location.speed,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      print('Location update response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating driver location: $e');
      return false;
    }
  }

  // Add this method to your MapService class
  Future<bool> updateDriverLocationForJourney(
      String journeyId, LocationData location) async {
    try {
      if (journeyId.isEmpty) {
        print('Journey ID is empty');
        return false;
      }

      final endpoint = '${ApiEndpoints.apiUrl}/journeys/$journeyId/track';
      print('Updating journey location at endpoint: $endpoint');

      final response = await _apiService.post(
        endpoint,
        body: {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'bearing': location.heading,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating journey location: $e');
      return false;
    }
  }

  // Get nearest stop for a given location
  Future<Map<String, dynamic>?> getNearestStop(
      double latitude, double longitude) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.nearestStop(latitude, longitude),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      print('Error getting nearest stop: $e');
      return null;
    }
  }

  // Add this method that's referenced in MapProvider
  Future<RouteMapData?> getRouteMapData(String routeId) async {
    try {
      // Construct the URL correctly
      final endpoint = '${ApiEndpoints.apiUrl}/routes/$routeId/map-data';
      print('Fetching route map data from: $endpoint');

      final response = await _apiService.get(endpoint);
      print('Route map data response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true && responseData['data'] != null) {
          return RouteMapData.fromJson(responseData['data']);
        } else {
          print('Invalid data format: ${responseData['message']}');
        }
      } else {
        print('Failed to get route map data: ${response.statusCode}');
        print('Error body: ${response.body}');
      }
      return null;
    } catch (e) {
      print('Error in getRouteMapData: $e');
      return null;
    }
  }

  // Replace the getRouteDirections method
  Future<List<LatLng>> getRouteDirections(
      LatLng origin, LatLng destination) async {
    try {
      // Use OSRM for more accurate road paths
      return await OSRMService.getDirections(
        points: [origin, destination],
      );
    } catch (e) {
      print('Error getting route directions from OSRM: $e');

      // Fall back to your existing backend API if OSRM API fails
      try {
        final response = await _apiService.get(
          ApiEndpoints.directions(
            origin.latitude,
            origin.longitude,
            destination.latitude,
            destination.longitude,
          ),
        );

        if (response.statusCode == 200) {
          // Process API response as before
          // ...
        }
      } catch (e2) {
        print('Error getting route directions from backend: $e2');
      }

      // If all else fails, return a straight line
      return [origin, destination];
    }
  }

  // Replace this method to use OSRM API
  Future<List<LatLng>> getRoutePathWithOSRM(List<LatLng> points) async {
    try {
      return await OSRMService.getDirections(points: points);
    } catch (e) {
      print('Error getting OSRM Directions: $e');
      return points; // Return original points as fallback
    }
  }
}
