// lib/services/driver_service.dart

import 'package:bus_driver_app/config/api.endpoints.dart';
import 'package:bus_driver_app/models/api_response_model.dart';
import 'package:bus_driver_app/models/statistics_model.dart';

import '../models/driver_model.dart';
import 'api_service.dart';

class DriverService extends ApiService {
  Future<Driver> updateStatus(String status) async {
    // e.g., 'online' or 'offline'
    final response = await patch<Driver>(
      ApiEndpoints.driverStatus,
      {'status': status},
      fromJsonT: Driver.fromJson,
    );
    return response.data!;
  }

  Future<ApiResponse<dynamic>> verifyDocuments(
      Map<String, dynamic> documents) async {
    // Assuming documents is { 'licenseImage': base64String, etc. }
    return post<dynamic>(
      ApiEndpoints.verifyDocuments,
      documents,
      fromJsonT: (json) => json, // Generic response
    );
  }

  // Add more if needed, e.g., getStatus
  // Add to lib/services/driver_service.dart
  Future<DriverStatistics> getStatistics() async {
    final response = await get<DriverStatistics>(
      ApiEndpoints.driverStatistics,
      fromJsonT: DriverStatistics.fromJson,
    );
    return response.data!;
  }
}
