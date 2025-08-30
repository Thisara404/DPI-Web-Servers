// lib/models/api_response_model.dart

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? accessToken;
  final String? refreshToken;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.accessToken,
    this.refreshToken,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    try {
      // Handle different response structures
      T? parsedData;

      if (json.containsKey('data') && json['data'] != null) {
        // Standard API response with 'data' field
        parsedData = fromJsonT(json['data']);
      } else if (json.containsKey('schedules')) {
        // Schedule-specific response
        parsedData = fromJsonT({'schedules': json['schedules']});
      } else {
        // Pass the whole JSON object
        parsedData = fromJsonT(json);
      }

      return ApiResponse<T>(
        success: json['success'] ?? false,
        message: json['message'],
        data: parsedData,
        accessToken: json['accessToken'],
        refreshToken: json['refreshToken'],
      );
    } catch (e) {
      print('❌ ApiResponse parsing error: $e');
      print('📄 Problematic JSON: $json');

      // Return a failed response instead of throwing
      return ApiResponse<T>(
        success: false,
        message: 'Failed to parse response: $e',
        data: null,
      );
    }
  }
}
