import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api.endpoints.dart';
import '../models/schedule_model.dart';
import '../services/api_service.dart';

class ScheduleProvider extends ChangeNotifier {
  List<Schedule> _schedules = [];
  Schedule? _selectedSchedule;
  bool _isLoading = false;
  String? _error;
  final ApiService _apiService = ApiService(); // Create instance

  List<Schedule> get schedules => _schedules;
  Schedule? get selectedSchedule => _selectedSchedule;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchActiveSchedules() async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiService.get(
        ApiEndpoints.activeSchedules,
        fromJsonT: (json) => json,
      );

      if (response.data != null) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true) {
          final schedulesData = data['schedules'] ?? data['data'] ?? [];

          if (schedulesData is List) {
            _schedules = schedulesData
                .where((item) => item is Map<String, dynamic>)
                .map((scheduleJson) =>
                    Schedule.fromJson(scheduleJson as Map<String, dynamic>))
                .toList();
          } else {
            _schedules = [];
          }
        } else {
          _error = data['message'] as String? ?? 'Failed to fetch schedules';
        }
      } else {
        // FIX: Use the message from the ApiResponse for better error details.
        _error = response.message ?? 'Failed to fetch schedules';
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> acceptSchedule(String scheduleId) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiService.post(
        ApiEndpoints.acceptSchedule,
        {'scheduleId': scheduleId},
        fromJsonT: (json) => json,
      );

      if (response.data != null) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true) {
          // Update the schedule status locally
          _updateScheduleStatus(scheduleId, 'accepted');
          _setLoading(false);
          return true;
        } else {
          _error = data['message'] as String? ?? 'Failed to accept schedule';
          _setLoading(false);
          return false;
        }
      } else {
        // FIX: Use the message from the ApiResponse for better error details.
        _error = response.message ?? 'Failed to accept schedule';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  void _updateScheduleStatus(String scheduleId, String status) {
    final scheduleIndex = _schedules.indexWhere((s) => s.id == scheduleId);
    if (scheduleIndex != -1) {
      final currentSchedule = _schedules[scheduleIndex];
      _schedules[scheduleIndex] = Schedule(
        id: currentSchedule.id,
        routeId: currentSchedule.routeId,
        startTime: currentSchedule.startTime,
        endTime: currentSchedule.endTime,
        status: status,
        journeyId: currentSchedule.journeyId,
        routeDetails: currentSchedule.routeDetails,
        startLocation: currentSchedule.startLocation,
        endLocation: currentSchedule.endLocation,
      );
      notifyListeners();
    }
  }

  void selectSchedule(Schedule schedule) {
    _selectedSchedule = schedule;
    notifyListeners();
  }

  void clearSelectedSchedule() {
    _selectedSchedule = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
