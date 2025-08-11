import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants.dart';
import 'storage_service.dart';

class ApiService {
  static const String _baseUrl = ApiConstants.baseUrl;
  static const Duration _timeout = ApiConstants.timeoutDuration;

  // Get headers with authentication token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<bool> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  // Generic HTTP request method
  static Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final uriWithQuery =
          queryParams != null ? uri.replace(queryParameters: queryParams) : uri;

      final headers = await _getHeaders();
      late http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response =
              await http.get(uriWithQuery, headers: headers).timeout(_timeout);
          break;
        case 'POST':
          response = await http
              .post(
                uriWithQuery,
                headers: headers,
                body: data != null ? jsonEncode(data) : null,
              )
              .timeout(_timeout);
          break;
        case 'PUT':
          response = await http
              .put(
                uriWithQuery,
                headers: headers,
                body: data != null ? jsonEncode(data) : null,
              )
              .timeout(_timeout);
          break;
        case 'DELETE':
          response = await http
              .delete(uriWithQuery, headers: headers)
              .timeout(_timeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      return _handleResponse(response);
    } on SocketException {
      throw Exception(ErrorMessages.noInternetConnection);
    } on HttpException {
      throw Exception(ErrorMessages.serverError);
    } on FormatException {
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception(ErrorMessages.unknownError);
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> data = jsonDecode(response.body);

    switch (response.statusCode) {
      case 200:
      case 201:
        return data;
      case 400:
        throw Exception(data['message'] ?? 'Bad request');
      case 401:
        throw Exception(ErrorMessages.unauthorized);
      case 403:
        throw Exception('Access forbidden');
      case 404:
        throw Exception('Resource not found');
      case 422:
        throw Exception(data['message'] ?? 'Validation error');
      case 500:
        throw Exception(ErrorMessages.serverError);
      default:
        throw Exception(
            'HTTP ${response.statusCode}: ${data['message'] ?? 'Unknown error'}');
    }
  }

  // Authentication Methods
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      // Check connectivity first
      if (!await _checkConnectivity()) {
        return {
          'success': false,
          'message':
              'No internet connection. Please check your network and try again.',
        };
      }

      final data = {
        'email': email,
        'password': password,
      };
      return _makeRequest('POST', ApiConstants.loginEndpoint, data: data);
    } on SocketException {
      return {
        'success': false,
        'message':
            'Unable to connect to server. Please check your internet connection.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> register(
      Map<String, dynamic> userData) async {
    return _makeRequest('POST', ApiConstants.registerEndpoint, data: userData);
  }

  static Future<Map<String, dynamic>> getProfile() async {
    return _makeRequest('GET', ApiConstants.profileEndpoint);
  }

  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> userData) async {
    return _makeRequest('PUT', ApiConstants.profileEndpoint, data: userData);
  }

  // Schedule Methods
  static Future<Map<String, dynamic>> getSchedules() async {
    return _makeRequest('GET', ApiConstants.activeSchedulesEndpoint);
  }

  static Future<Map<String, dynamic>> searchSchedules(
      Map<String, String> filters) async {
    return _makeRequest('GET', ApiConstants.searchSchedulesEndpoint,
        queryParams: filters);
  }

  static Future<Map<String, dynamic>> getScheduleDetails(
      String scheduleId) async {
    return _makeRequest('GET', '${ApiConstants.schedulesEndpoint}/$scheduleId');
  }

  static Future<Map<String, dynamic>> getScheduleRoute(
      String scheduleId) async {
    return _makeRequest(
        'GET', '${ApiConstants.schedulesEndpoint}/$scheduleId/route');
  }

  // Booking Methods
  static Future<Map<String, dynamic>> createBooking(
      Map<String, dynamic> bookingData) async {
    return _makeRequest('POST', ApiConstants.bookingsEndpoint,
        data: bookingData);
  }

  static Future<Map<String, dynamic>> getBookings() async {
    return _makeRequest('GET', ApiConstants.bookingsEndpoint);
  }

  static Future<Map<String, dynamic>> getBookingDetails(
      String bookingId) async {
    return _makeRequest('GET', '${ApiConstants.bookingsEndpoint}/$bookingId');
  }

  static Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    return _makeRequest(
        'PUT', '${ApiConstants.bookingsEndpoint}/$bookingId/cancel');
  }

  static Future<Map<String, dynamic>> processPayment(
      String bookingId, Map<String, dynamic> paymentData) async {
    return _makeRequest(
        'POST', '${ApiConstants.bookingsEndpoint}/$bookingId/payment',
        data: paymentData);
  }

  // Ticket Methods
  static Future<Map<String, dynamic>> getTickets() async {
    return _makeRequest('GET', ApiConstants.activeTicketsEndpoint);
  }

  static Future<Map<String, dynamic>> getTicketDetails(String ticketId) async {
    return _makeRequest('GET', '${ApiConstants.ticketsEndpoint}/$ticketId');
  }

  static Future<Map<String, dynamic>> getTicketQR(String ticketId) async {
    return _makeRequest('GET',
        '${ApiConstants.ticketsEndpoint}/$ticketId${ApiConstants.qrCodeEndpoint}');
  }

  static Future<Map<String, dynamic>> validateTicket(String qrCode) async {
    final data = {'qrCode': qrCode};
    return _makeRequest('POST', ApiConstants.validateTicketEndpoint,
        data: data);
  }

  // Map Methods
  static Future<Map<String, dynamic>> getRouteMapData(String routeId) async {
    return _makeRequest('GET', '${ApiConstants.mapRoutesEndpoint}/$routeId');
  }

  static Future<Map<String, dynamic>> getLiveBuses() async {
    return _makeRequest('GET', ApiConstants.liveBusesEndpoint);
  }

  static Future<Map<String, dynamic>> getNearbyStops(
      double latitude, double longitude) async {
    final queryParams = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    };
    return _makeRequest('GET', ApiConstants.nearbyStopsEndpoint,
        queryParams: queryParams);
  }

  // Passenger Dashboard Methods
  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      if (!await _checkConnectivity()) {
        return {
          'success': false,
          'message': 'No internet connection',
        };
      }

      return _makeRequest('GET', ApiConstants.dashboardEndpoint);
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> getTravelHistory(
      Map<String, String>? filters) async {
    return _makeRequest('GET', ApiConstants.historyEndpoint,
        queryParams: filters);
  }

  static Future<Map<String, dynamic>> getFavorites() async {
    return _makeRequest('GET', ApiConstants.favoritesEndpoint);
  }

  static Future<Map<String, dynamic>> addFavorite(String routeId) async {
    final data = {'routeId': routeId};
    return _makeRequest('POST', ApiConstants.favoritesEndpoint, data: data);
  }

  static Future<Map<String, dynamic>> removeFavorite(String routeId) async {
    return _makeRequest('DELETE', '${ApiConstants.favoritesEndpoint}/$routeId');
  }

  // Tracking Methods
  static Future<Map<String, dynamic>> subscribeToTracking(
      String scheduleId) async {
    final data = {'scheduleId': scheduleId};
    return _makeRequest('POST', ApiConstants.trackingSubscribeEndpoint,
        data: data);
  }

  static Future<Map<String, dynamic>> getTrackingStatus(
      String scheduleId) async {
    return _makeRequest(
        'GET', '${ApiConstants.trackingStatusEndpoint}/$scheduleId/status');
  }

  static Future<Map<String, dynamic>> getETA(String scheduleId) async {
    return _makeRequest('GET',
        '${ApiConstants.trackingStatusEndpoint}/$scheduleId${ApiConstants.etaEndpoint}');
  }
}
