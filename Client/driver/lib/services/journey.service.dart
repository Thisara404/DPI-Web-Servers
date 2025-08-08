import 'dart:convert';
import 'dart:math' as math;
import 'package:transit_lanka/core/models/journey.dart';
import 'package:transit_lanka/config/api.endpoints.dart';
import 'package:transit_lanka/core/services/api/api_service.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class JourneyService {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  //
  // DRIVER-FOCUSED JOURNEY METHODS (Using JourneyTrackingData)
  //

  // Start a new journey for a schedule
  Future<JourneyTrackingData?> startJourney(String scheduleId) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.startJourney,
        body: {'scheduleId': scheduleId},
      );

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true && jsonData['data'] != null) {
          return JourneyTrackingData.fromJson(jsonData['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error starting journey: $e');
      return null;
    }
  }

  // End an active journey
  Future<bool> endJourney(String journeyId) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.endJourney(journeyId),
        body: {'endTime': DateTime.now().toIso8601String()},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error ending journey: $e');
      return false;
    }
  }

  // Mark checkpoint as visited
  Future<bool> completeCheckpoint(String journeyId, String stopId) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.completeCheckpoint(journeyId, stopId),
        body: {
          'actualTime': DateTime.now().toIso8601String(),
          'isCompleted': true,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error completing checkpoint: $e');
      return false;
    }
  }

  // Get active journey for driver
  Future<JourneyTrackingData?> getDriverActiveJourney() async {
    try {
      final response = await _apiService.get(ApiEndpoints.driverActiveJourney);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true && jsonData['data'] != null) {
          return JourneyTrackingData.fromJson(jsonData['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching active journey: $e');
      return null;
    }
  }

  // Track driver location
  Future<bool> updateDriverLocation(
      String journeyId, LocationData location) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.trackDriverLocation(journeyId),
        body: {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating driver location: $e');
      return false;
    }
  }

  // Get driver journey history
  Future<List<JourneyTrackingData>> getDriverJourneyHistory() async {
    try {
      final response = await _apiService.get(ApiEndpoints.journeyHistory);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true && jsonData['data'] != null) {
          return List<JourneyTrackingData>.from(
              jsonData['data'].map((x) => JourneyTrackingData.fromJson(x)));
        }
      }
      return [];
    } catch (e) {
      print('Error fetching driver journey history: $e');
      return [];
    }
  }

  // Get driver location for a specific schedule
  Future<LocationData?> getDriverLocation(String scheduleId) async {
    try {
      print('Fetching driver location for schedule ID: $scheduleId');

      // Use the correct endpoint
      final response = await _apiService.get(
        ApiEndpoints.driverLocation(scheduleId),
      );

      print(
          'GET response for ${ApiEndpoints.driverLocation(scheduleId)} - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print(
            'Driver location response data: ${jsonData.toString().substring(0, math.min(100, jsonData.toString().length))}...');

        if (jsonData['status'] == true && jsonData['data'] != null) {
          final locationData = jsonData['data'];

          // Check if coordinates exist in the expected format - fix the is(List) issue
          if (locationData['coordinates'] == null ||
              !(locationData['coordinates'] is List) ||
              (locationData['coordinates'] as List).length < 2) {
            print('Invalid coordinates format in driver location response');
            return null;
          }

          try {
            // Convert to LocationData object - handle GeoJSON format [longitude, latitude]
            return LocationData.fromMap({
              'latitude':
                  double.parse(locationData['coordinates'][1].toString()),
              'longitude':
                  double.parse(locationData['coordinates'][0].toString()),
              'heading': locationData['bearing'] != null
                  ? double.parse(locationData['bearing'].toString())
                  : 0.0,
              'time': locationData['timestamp'] != null
                  ? DateTime.parse(locationData['timestamp'])
                      .millisecondsSinceEpoch
                      .toDouble()
                  : DateTime.now().millisecondsSinceEpoch.toDouble(),
            });
          } catch (e) {
            print('Error parsing location data: $e');
            return null;
          }
        } else {
          print('Status false or no data in driver location response');
        }
      } else {
        print('Error response body: ${response.body}');
      }

      return null;
    } catch (e) {
      print('Error fetching driver location: $e');
      return null;
    }
  }

  //
  // PASSENGER-FOCUSED JOURNEY METHODS (Using Journey)
  //

  // Book a journey for a passenger
  Future<Map<String, dynamic>> bookJourney(
    String scheduleId,
    String paymentMethod,
    List<Map<String, dynamic>> additionalPassengers,
  ) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final Map<String, dynamic> requestBody = {
        'scheduleId': scheduleId,
        'paymentMethod': paymentMethod,
      };

      if (additionalPassengers.isNotEmpty) {
        requestBody['additionalPassengerInfo'] = additionalPassengers;
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.bookJourney),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': false,
        'message': e.toString(),
      };
    }
  }

  // Get journey details for a passenger
  Future<Map<String, dynamic>> getJourneyDetails(String journeyId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.journeyById(journeyId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': false,
        'message': e.toString(),
      };
    }
  }

  // Get passenger journeys (with optional filtering)
  Future<Map<String, dynamic>> getPassengerJourneys({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      String url = '${ApiEndpoints.passengerJourneys}?page=$page&limit=$limit';
      if (status != null && status.isNotEmpty) {
        url += '&status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': false,
        'message': e.toString(),
      };
    }
  }

  // Cancel journey for a passenger
  Future<Map<String, dynamic>> cancelJourney(String journeyId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.cancelJourney(journeyId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': false,
        'message': e.toString(),
      };
    }
  }

  // Driver verifies passenger ticket
  Future<Map<String, dynamic>> verifyJourney(String journeyId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.verifyJourney(journeyId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': false,
        'message': e.toString(),
      };
    }
  }

  // Get passenger's active tickets
  Future<List<Journey>?> getActiveTickets() async {
    try {
      final result = await getPassengerJourneys(status: 'booked');

      if (result['status'] == true && result['data'] != null) {
        final journeys = result['data']['journeys'];
        if (journeys != null && journeys is List) {
          return journeys
              .map<Journey>((journey) => Journey.fromJson(journey))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching active tickets: $e');
      return null;
    }
  }

  // Get passenger's completed tickets
  Future<List<Journey>?> getCompletedTickets(
      {int page = 1, int limit = 10}) async {
    try {
      final result = await getPassengerJourneys(
        status: 'completed',
        page: page,
        limit: limit,
      );

      if (result['status'] == true && result['data'] != null) {
        final journeys = result['data']['journeys'];
        if (journeys != null && journeys is List) {
          return journeys
              .map<Journey>((journey) => Journey.fromJson(journey))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching completed tickets: $e');
      return null;
    }
  }

  // Initiate payment for a journey
  Future<Map<String, dynamic>> initiatePayment(String journeyId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.payJourney(journeyId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': false,
        'message': e.toString(),
      };
    }
  }

  // Capture payment after approval
  Future<Map<String, dynamic>> capturePayment(String orderId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.capturePayment(orderId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': false,
        'message': e.toString(),
      };
    }
  }

  // Get payment details for a journey
  Future<Map<String, dynamic>> getPaymentDetails(String paymentId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.paymentDetails(paymentId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': false,
        'message': e.toString(),
      };
    }
  }

  // Request refund for a journey
  Future<Map<String, dynamic>> requestRefund(
      String paymentId, String reason) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.processRefund(paymentId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'reason': reason}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': false,
        'message': e.toString(),
      };
    }
  }
}
