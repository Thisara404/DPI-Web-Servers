// lib/services/schedule_service.dart

import 'package:bus_driver_app/config/api.endpoints.dart';

import '../models/schedule_model.dart';
import 'api_service.dart';

class ScheduleService extends ApiService {
  Future<List<Schedule>> getSchedules({String? status, String? date}) async {
    final params = {
      if (status != null) 'status': status,
      if (date != null) 'date': date,
    };
    final response = await get<List<Schedule>>(
      ApiEndpoints.schedules,
      params: params,
      fromJsonT: (json) => (json as List).map((e) => Schedule.fromJson(e)).toList(),
    );
    return response.data!;
  }

  Future<List<Schedule>> getActiveSchedules() async {
    final response = await get<List<Schedule>>(
      ApiEndpoints.activeSchedules,
      fromJsonT: (json) => (json as List).map((e) => Schedule.fromJson(e)).toList(),
    );
    return response.data!;
  }

  Future<Schedule> acceptSchedule(String scheduleId) async {
    final response = await post<Schedule>(
      ApiEndpoints.acceptSchedule,
      {'scheduleId': scheduleId},
      fromJsonT: Schedule.fromJson,
    );
    return response.data!;
  }

  Future<Schedule> startJourney(String scheduleId) async {
    final response = await post<Schedule>(
      ApiEndpoints.startJourney,
      {'scheduleId': scheduleId},
      fromJsonT: Schedule.fromJson,
    );
    return response.data!;
  }
}