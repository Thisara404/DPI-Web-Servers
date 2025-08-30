// lib/config/api_endpoint.dart

class ApiEndpoints {
  // Base URL - Switch between dev and prod
  static const String baseUrl =
      'http://192.168.43.187:3000'; // Gateway URL for local dev
  // static const String baseUrl = 'https://your-production-gateway.com';  // Uncomment for prod

  // Authentication Endpoints
  static const String register = '$baseUrl/api/driver/auth/register';
  static const String login = '$baseUrl/api/driver/auth/login';
  static const String logout = '$baseUrl/api/driver/auth/logout';
  static const String refreshToken = '$baseUrl/api/driver/auth/refresh';
  static const String profile =
      '$baseUrl/api/driver/profile'; // GET for view, PUT for update

  // Driver Management Endpoints
  static const String driverStatus =
      '$baseUrl/api/driver/status'; // PATCH for online/offline
  static const String verifyDocuments =
      '$baseUrl/api/driver/verify-documents'; // POST for document upload

  // Schedule Management Endpoints
  static const String schedules =
      '$baseUrl/api/driver/schedules'; // GET all schedules
  static const String activeSchedules =
      '$baseUrl/api/driver/schedules/active'; // GET active
  static const String acceptSchedule =
      '$baseUrl/api/driver/schedules/accept'; // POST
  static const String startJourney =
      '$baseUrl/api/driver/schedules/start'; // POST

  // Location Tracking Endpoints
  static const String startTracking =
      '$baseUrl/api/driver/tracking/start'; // POST
  static const String updateTracking =
      '$baseUrl/api/driver/tracking/update'; // POST
  static const String stopTracking =
      '$baseUrl/api/driver/tracking/stop'; // POST
  static const String trackingHistory =
      '$baseUrl/api/driver/tracking/history'; // GET

  // Analytics Endpoints
  static const String driverStatistics =
      '$baseUrl/api/driver/statistics'; // GET

  // Health and Docs (Optional, for debugging)
  static const String health = '$baseUrl/health';
  static const String apiDocs = '$baseUrl/api/docs';
}
