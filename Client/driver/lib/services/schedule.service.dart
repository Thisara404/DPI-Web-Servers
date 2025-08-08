import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:transit_lanka/config/api.endpoints.dart';
import 'package:transit_lanka/core/models/schedule.dart';
import 'package:transit_lanka/core/services/api/api_service.dart';
import 'dart:math';

class ScheduleService {
  final ApiService _apiService = ApiService();

  // Get all schedules with optional filter
  Future<List<Schedule>> getSchedules({String filter = ''}) async {
    try {
      String endpoint = ApiEndpoints.schedules;
      if (filter.isNotEmpty) {
        endpoint += '?filter=$filter';
      }

      print('Fetching schedules from: $endpoint');
      final response = await _apiService.get(endpoint);
      print('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Debug the response structure
        print('Response structure: ${jsonData.runtimeType}');

        if (jsonData['status'] == true && jsonData['data'] != null) {
          final dataList = jsonData['data'] as List;

          final scheduleList = dataList.map((item) {
            // Convert dynamic map to Map<String, dynamic> explicitly
            final Map<String, dynamic> schedule =
                Map<String, dynamic>.from(item);

            // Ensure route data is properly structured
            if (schedule['routeId'] != null) {
              if (schedule['routeId'] is! Map<String, dynamic>) {
                if (schedule['routeId'] is Map) {
                  // Cast from Map<dynamic, dynamic> to Map<String, dynamic>
                  schedule['routeId'] =
                      Map<String, dynamic>.from(schedule['routeId']);
                } else {
                  // Handle string ID case
                  final routeId = schedule['routeId'].toString();
                  schedule['routeId'] = {
                    '_id': routeId,
                    'name': schedule['routeName'] ?? 'Unknown Route'
                  };
                }
              }
            } else {
              schedule['routeId'] = {'_id': '', 'name': 'Unknown Route'};
            }

            // Handle driver data similarly
            if (schedule['driverId'] != null && schedule['driverId'] is Map) {
              schedule['driverId'] =
                  Map<String, dynamic>.from(schedule['driverId']);
            }

            return Schedule.fromJson(schedule);
          }).toList();

          return scheduleList;
        }
      }
      return [];
    } catch (e) {
      print('Error fetching schedules: $e');
      print('Error stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Get schedule by ID
  Future<Schedule?> getScheduleById(String id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.scheduleById(id));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true && jsonData['data'] != null) {
          return Schedule.fromJson(jsonData['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching schedule: $e');
      return null;
    }
  }

  // Get schedules for a specific route
  Future<List<Schedule>> getSchedulesByRoute(String routeId) async {
    try {
      final response =
          await _apiService.get(ApiEndpoints.schedulesByRoute(routeId));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true && jsonData['data'] != null) {
          return List<Schedule>.from(
              jsonData['data'].map((schedule) => Schedule.fromJson(schedule)));
        }
      }
      return [];
    } catch (e) {
      print('Error fetching route schedules: $e');
      return [];
    }
  }

  // Create a new schedule
  Future<Map<String, dynamic>> createSchedule(
      Map<String, dynamic> scheduleData) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.createSchedule,
        body: scheduleData,
      );

      final jsonData = json.decode(response.body);
      return {
        'success': response.statusCode == 201 && jsonData['status'] == true,
        'message': jsonData['message'] ?? 'Failed to create schedule',
        'data': jsonData['data']
      };
    } catch (e) {
      print('Error creating schedule: $e');
      return {'success': false, 'message': 'Error: $e', 'data': null};
    }
  }

  // Update schedule status
  Future<bool> updateScheduleStatus(String id, String status) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.updateScheduleStatus(id),
        body: {'status': status},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['status'] == true;
      }
      return false;
    } catch (e) {
      print('Error updating schedule status: $e');
      return false;
    }
  }

  // Update schedule
  Future<Map<String, dynamic>> updateSchedule(
      String id, Map<String, dynamic> scheduleData) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.updateSchedule(id),
        body: scheduleData,
      );

      final jsonData = json.decode(response.body);
      return {
        'success': response.statusCode == 200 && jsonData['status'] == true,
        'message': jsonData['message'] ?? 'Failed to update schedule',
        'data': jsonData['data']
      };
    } catch (e) {
      print('Error updating schedule: $e');
      return {'success': false, 'message': 'Error: $e', 'data': null};
    }
  }

  // Delete a schedule
  Future<bool> deleteSchedule(String id) async {
    try {
      final response =
          await _apiService.delete(ApiEndpoints.deleteSchedule(id));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['status'] == true;
      }
      return false;
    } catch (e) {
      print('Error deleting schedule: $e');
      return false;
    }
  }
}
