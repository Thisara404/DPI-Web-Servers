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
      final dataField = json['data'];

      if (dataField != null) {
        if (dataField is List) {
          // If data is a list, pass it as a map with the list under a key (e.g., for schedules)
          parsedData = fromJsonT({'items': dataField});
        } else if (dataField is Map<String, dynamic>) {
          // Standard case: data is a map
          parsedData = fromJsonT(dataField);
        } else {
          // Fallback: pass the raw data
          parsedData = fromJsonT(json);
        }
      } else {
        // No data field, pass the whole JSON
        parsedData = fromJsonT(json);
      }

      return ApiResponse<T>(
        success: json['success'] ?? false,
        message: json['message'] is String
            ? json['message']
            : null, // FIX: Type check
        data: parsedData,
        accessToken: json['accessToken'] is String ? json['accessToken'] : null,
        refreshToken:
            json['refreshToken'] is String ? json['refreshToken'] : null,
      );
    } catch (e) {
      print('❌ ApiResponse parsing error: $e');
      print('📄 Problematic JSON: $json');
      // Return a default response on error to prevent buffering
      return ApiResponse<T>(
        success: false,
        message: 'Parsing error: ${e.toString()}',
        data: null,
      );
    }
  }
}
