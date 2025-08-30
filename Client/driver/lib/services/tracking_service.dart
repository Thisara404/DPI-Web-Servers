// lib/services/tracking_service.dart

import 'package:bus_driver_app/config/api.endpoints.dart';
import 'package:bus_driver_app/models/api_response_model.dart';

import '../models/tracking_model.dart';
import 'api_service.dart';

class TrackingService extends ApiService {
  Future<ApiResponse<dynamic>> startTracking(String scheduleId, String journeyId) async {
    return post<dynamic>(
      ApiEndpoints.startTracking,
      {'scheduleId': scheduleId, 'journeyId': journeyId},
      fromJsonT: (json) => json,
    );
  }

  Future<ApiResponse<dynamic>> updateLocation(LocationUpdate update) async {
    return post<dynamic>(
      ApiEndpoints.updateTracking,
      update.toJson(),
      fromJsonT: (json) => json,
    );
  }

  Future<ApiResponse<dynamic>> stopTracking() async {
    return post<dynamic>(
      ApiEndpoints.stopTracking,
      {},
      fromJsonT: (json) => json,
    );
  }

  Future<TrackingHistory> getTrackingHistory({String? dateFrom, String? dateTo, int? page}) async {
    final params = {
      if (dateFrom != null) 'dateFrom': dateFrom,
      if (dateTo != null) 'dateTo': dateTo,
      if (page != null) 'page': page.toString(),
    };
    final response = await get<TrackingHistory>(
      ApiEndpoints.trackingHistory,
      params: params,
      fromJsonT: TrackingHistory.fromJson,
    );
    return response.data!;
  }
}