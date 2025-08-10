import 'package:flutter/foundation.dart';
import 'package:flutter/src/widgets/framework.dart';
import '../models/schedule.dart';
import '../models/booking.dart';
import '../services/api_service.dart';
import '../constants.dart';

class ScheduleProvider extends ChangeNotifier {
  List<Schedule> _schedules = [];
  List<Schedule> _filteredSchedules = [];
  List<Booking> _bookings = [];
  List<Ticket> _tickets = [];
  List<Schedule> _favorites = [];
  
  bool _isLoading = false;
  bool _isBookingLoading = false;
  String? _error;
  
  Schedule? _selectedSchedule;
  Booking? _currentBooking;
  
  // Search filters
  String _searchQuery = '';
  String? _fromFilter;
  String? _toFilter;
  DateTime? _dateFilter;

  // Getters
  List<Schedule> get schedules => _filteredSchedules.isNotEmpty ? _filteredSchedules : _schedules;
  List<Booking> get bookings => _bookings;
  List<Ticket> get tickets => _tickets;
  List<Schedule> get favorites => _favorites;
  
  bool get isLoading => _isLoading;
  bool get isBookingLoading => _isBookingLoading;
  String? get error => _error;
  
  Schedule? get selectedSchedule => _selectedSchedule;
  Booking? get currentBooking => _currentBooking;
  
  String get searchQuery => _searchQuery;
  String? get fromFilter => _fromFilter;
  String? get toFilter => _toFilter;
  DateTime? get dateFilter => _dateFilter;

  // Load Schedules
  Future<void> loadSchedules() async {
    setLoading(true);
    clearError();

    try {
      final response = await ApiService.getSchedules();
      
      if (response['success'] == true) {
        _schedules = (response['schedules'] as List)
            .map((schedule) => Schedule.fromJson(schedule))
            .toList();
        _applyFilters();
      } else {
        throw Exception(response['message'] ?? 'Failed to load schedules');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setLoading(false);
    }
  }

  // Search Schedules
  Future<void> searchSchedules({
    String? from,
    String? to,
    DateTime? date,
    String? query,
  }) async {
    setLoading(true);
    clearError();

    try {
      final filters = <String, String>{};
      if (from != null) filters['from'] = from;
      if (to != null) filters['to'] = to;
      if (date != null) filters['date'] = date.toIso8601String().split('T')[0];
      if (query != null && query.isNotEmpty) filters['query'] = query;

      final response = await ApiService.searchSchedules(filters);
      
      if (response['success'] == true) {
        _schedules = (response['schedules'] as List)
            .map((schedule) => Schedule.fromJson(schedule))
            .toList();
        
        // Update filters
        _fromFilter = from;
        _toFilter = to;
        _dateFilter = date;
        _searchQuery = query ?? '';
        
        _applyFilters();
      } else {
        throw Exception(response['message'] ?? 'Failed to search schedules');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setLoading(false);
    }
  }

  // Get Schedule Details
  Future<Schedule?> getScheduleDetails(String scheduleId) async {
    try {
      final response = await ApiService.getScheduleDetails(scheduleId);
      
      if (response['success'] == true) {
        final schedule = Schedule.fromJson(response['schedule']);
        _selectedSchedule = schedule;
        notifyListeners();
        return schedule;
      }
      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Create Booking
  Future<bool> createBooking({
    required String scheduleId,
    required List<Passenger> passengers,
  }) async {
    setBookingLoading(true);
    clearError();

    try {
      final bookingData = {
        'scheduleId': scheduleId,
        'passengers': passengers.map((p) => p.toJson()).toList(),
      };

      final response = await ApiService.createBooking(bookingData);
      
      if (response['success'] == true) {
        _currentBooking = Booking.fromJson(response['booking']);
        notifyListeners();
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to create booking');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      setBookingLoading(false);
    }
  }

  // Process Payment
  Future<bool> processPayment({
    required String bookingId,
    required Map<String, dynamic> paymentData,
  }) async {
    setBookingLoading(true);
    clearError();

    try {
      final response = await ApiService.processPayment(bookingId, paymentData);
      
      if (response['success'] == true) {
        _currentBooking = Booking.fromJson(response['booking']);
        await loadBookings(); // Refresh bookings
        await loadTickets();  // Refresh tickets
        notifyListeners();
        return true;
      } else {
        throw Exception(response['message'] ?? 'Payment failed');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      setBookingLoading(false);
    }
  }

  // Load Bookings
  Future<void> loadBookings() async {
    try {
      final response = await ApiService.getBookings();
      
      if (response['success'] == true) {
        _bookings = (response['bookings'] as List)
            .map((booking) => Booking.fromJson(booking))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load Tickets
  Future<void> loadTickets() async {
    try {
      final response = await ApiService.getTickets();
      
      if (response['success'] == true) {
        _tickets = (response['tickets'] as List)
            .map((ticket) => Ticket.fromJson(ticket))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Cancel Booking
  Future<bool> cancelBooking(String bookingId) async {
    setBookingLoading(true);
    clearError();

    try {
      final response = await ApiService.cancelBooking(bookingId);
      
      if (response['success'] == true) {
        await loadBookings(); // Refresh bookings
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to cancel booking');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      setBookingLoading(false);
    }
  }

  // Load Favorites
  Future<void> loadFavorites() async {
    try {
      final response = await ApiService.getFavorites();
      
      if (response['success'] == true) {
        _favorites = (response['favorites'] as List)
            .map((schedule) => Schedule.fromJson(schedule))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Add to Favorites
  Future<bool> addToFavorites(String routeId) async {
    try {
      final response = await ApiService.addFavorite(routeId);
      
      if (response['success'] == true) {
        await loadFavorites(); // Refresh favorites
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Remove from Favorites
  Future<bool> removeFromFavorites(String routeId) async {
    try {
      final response = await ApiService.removeFavorite(routeId);
      
      if (response['success'] == true) {
        await loadFavorites(); // Refresh favorites
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Apply local filters
  void _applyFilters() {
    _filteredSchedules = _schedules.where((schedule) {
      bool matchesSearch = _searchQuery.isEmpty || 
          schedule.routeName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          schedule.from.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          schedule.to.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          schedule.busNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      
      bool matchesFrom = _fromFilter == null || schedule.from == _fromFilter;
      bool matchesToTo = _toFilter == null || schedule.to == _toFilter;
      
      bool matchesDate = _dateFilter == null || 
          (schedule.departureTime.year == _dateFilter!.year &&
           schedule.departureTime.month == _dateFilter!.month &&
           schedule.departureTime.day == _dateFilter!.day);
      
      return matchesSearch && matchesFrom && matchesToTo && matchesDate;
    }).toList();
    
    notifyListeners();
  }

  // Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // Update filters
  void updateFilters({
    String? from,
    String? to,
    DateTime? date,
  }) {
    _fromFilter = from;
    _toFilter = to;
    _dateFilter = date;
    _applyFilters();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _fromFilter = null;
    _toFilter = null;
    _dateFilter = null;
    _applyFilters();
  }

  // Select schedule
  void selectSchedule(Schedule schedule) {
    _selectedSchedule = schedule;
    notifyListeners();
  }

  // Clear selected schedule
  void clearSelectedSchedule() {
    _selectedSchedule = null;
    notifyListeners();
  }

  // Helper methods
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setBookingLoading(bool loading) {
    _isBookingLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void updateFromFilter(String? from) {
    _fromFilter = from;
    _applyFilters();
  }

  void updateToFilter(String? to) {
    _toFilter = to;
    _applyFilters();
  }

  void updateDateFilter(DateTime? date) {
    _dateFilter = date;
    _applyFilters();
  }
}