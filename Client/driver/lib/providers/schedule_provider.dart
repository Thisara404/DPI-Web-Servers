import 'dart:convert';
import 'package:flutter/material.dart';
import '../config/api_endpoints.dart';
import '../models/schedule.dart';
import '../services/api_service.dart';

class ScheduleProvider extends ChangeNotifier {
  List<Schedule> _schedules = [];
  Schedule? _selectedSchedule;
  bool _isLoading = false;
  String? _error;

  List<Schedule> get schedules => _schedules;
  Schedule? get selectedSchedule => _selectedSchedule;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchActiveSchedules() async {
    _setLoading(true);
    _error = null;

    try {
      final response = await ApiService.get(ApiEndpoints.activeSchedules);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _schedules = (data['schedules'] as List)
            .map((schedule) => Schedule.fromJson(schedule))
            .toList();
        _setLoading(false);
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['message'] ?? 'Failed to fetch schedules';
        _setLoading(false);
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _setLoading(false);
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