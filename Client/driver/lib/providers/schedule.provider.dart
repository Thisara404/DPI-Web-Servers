import 'package:flutter/material.dart';
import 'package:transit_lanka/core/models/schedule.dart';
import 'package:transit_lanka/core/services/schedule.service.dart';

class ScheduleProvider with ChangeNotifier {
  final ScheduleService _scheduleService = ScheduleService();

  List<Schedule> _schedules = [];
  List<Schedule> _filteredSchedules = [];
  bool _isLoading = false;
  String? _error;
  Schedule? _selectedSchedule;
  String? _selectedFilter;

  // Getters
  List<Schedule> get schedules => _schedules;
  List<Schedule> get filteredSchedules =>
      _filteredSchedules.isEmpty ? _schedules : _filteredSchedules;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Schedule? get selectedSchedule => _selectedSchedule;

  // Initialize and fetch schedules
  Future<void> fetchSchedules({String filter = ''}) async {
    _setLoading(true);
    try {
      final schedules = await _scheduleService.getSchedules(filter: filter);
      print('Filter: $filter, Schedules: ${schedules.length}');
      _schedules = schedules;
      _filteredSchedules = [];
      _selectedFilter = filter;
      _error = null;
      notifyListeners(); // Make sure this is called to update UI
    } catch (e) {
      print('Error fetching schedules: $e');
      _error = 'Failed to fetch schedules: $e';
      notifyListeners(); // Also notify on error
    } finally {
      _setLoading(false);
    }
  }

  // Search schedules
  void searchSchedules(String keyword) {
    if (keyword.isEmpty) {
      _filteredSchedules = [];
      notifyListeners();
      return;
    }

    _filteredSchedules = _schedules.where((schedule) {
      final routeName = schedule.routeName.toLowerCase();
      final driverName = schedule.driverName?.toLowerCase() ?? '';
      final searchLower = keyword.toLowerCase();

      return routeName.contains(searchLower) ||
          driverName.contains(searchLower) ||
          schedule.dayOfWeek
              .any((day) => day.toLowerCase().contains(searchLower));
    }).toList();

    notifyListeners();
  }

  // Add this method for client-side filtering
  Future<void> filterSchedulesLocally(String filter) async {
    if (_schedules.isEmpty) {
      await fetchSchedules();
    }

    _filteredSchedules = _schedules.where((schedule) {
      switch (filter) {
        case 'today':
          return schedule.isToday;
        case 'upcoming':
          return schedule.status == 'scheduled' ||
              schedule.status == 'in-progress';
        case 'completed':
          return schedule.status == 'completed';
        default:
          return true;
      }
    }).toList();

    notifyListeners();
  }

  // Create new schedule
  Future<Map<String, dynamic>> createSchedule(
      Map<String, dynamic> scheduleData) async {
    _setLoading(true);
    try {
      final result = await _scheduleService.createSchedule(scheduleData);
      if (result['success']) {
        await fetchSchedules(); // Refresh schedules
      }
      return result;
    } catch (e) {
      _error = 'Failed to create schedule: $e';
      return {'success': false, 'message': _error};
    } finally {
      _setLoading(false);
    }
  }

  // Update schedule status
  Future<bool> updateScheduleStatus(String id, String status) async {
    _setLoading(true);
    try {
      final success = await _scheduleService.updateScheduleStatus(id, status);
      if (success) {
        await fetchSchedules(); // Refresh schedules
      }
      return success;
    } catch (e) {
      _error = 'Failed to update schedule status: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update schedule
  Future<Map<String, dynamic>> updateSchedule(
      String id, Map<String, dynamic> scheduleData) async {
    _setLoading(true);
    try {
      final result = await _scheduleService.updateSchedule(id, scheduleData);
      if (result['success']) {
        await fetchSchedules(); // Refresh schedules
      }
      return result;
    } catch (e) {
      _error = 'Failed to update schedule: $e';
      return {'success': false, 'message': _error};
    } finally {
      _setLoading(false);
    }
  }

  // Delete schedule
  Future<bool> deleteSchedule(String id) async {
    _setLoading(true);
    try {
      final success = await _scheduleService.deleteSchedule(id);
      if (success) {
        _schedules.removeWhere((schedule) => schedule.id == id);
        _filteredSchedules =
            _filteredSchedules.where((schedule) => schedule.id != id).toList();
        if (_selectedSchedule?.id == id) {
          _selectedSchedule = null;
        }
        notifyListeners();
      } else {
        _error = 'Failed to delete schedule. Please try again.';
      }
      return success;
    } catch (e) {
      _error = 'Error deleting schedule: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Select a schedule for viewing details
  void selectSchedule(Schedule schedule) {
    _selectedSchedule = schedule;
    notifyListeners();
  }

  // Clear selected schedule
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

  // Add this method to your ScheduleProvider class
  void clearFilters() {
    _filteredSchedules = [];
    notifyListeners();
  }

//--------------------------------
// passenger side
  Future<void> fetchSchedulesByRoute(String routeId) async {
    // TODO: Implement the API call to fetch schedules
    // Example implementation:
    // final response = await _api.getSchedulesByRoute(routeId);
    // Update the provider state with the fetched schedules
    notifyListeners();
  }
}
