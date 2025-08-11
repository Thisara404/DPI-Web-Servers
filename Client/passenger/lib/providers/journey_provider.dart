import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/journey.dart';
import '../models/schedule.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../constants.dart';

class JourneyProvider extends ChangeNotifier {
  List<Journey> _journeys = [];
  Journey? _activeJourney;
  List<BusLocation> _liveBusLocations = [];
  Map<String, BusLocation> _busLocationMap = {};
  
  bool _isLoading = false;
  String? _error;
  
  // Socket connection
  IO.Socket? _socket;
  bool _isSocketConnected = false;

  // Getters
  List<Journey> get journeys => _journeys;
  Journey? get activeJourney => _activeJourney;
  List<BusLocation> get liveBusLocations => _liveBusLocations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSocketConnected => _isSocketConnected;

  // Get bus location by schedule ID
  BusLocation? getBusLocation(String scheduleId) {
    return _busLocationMap[scheduleId];
  }

  // Initialize socket connection
  void initializeSocket() {
    if (_socket != null) return;

    try {
      _socket = IO.io(ApiConstants.socketUrl, {
        'transports': ['websocket'],
        'autoConnect': false,
      });

      _socket!.onConnect((_) {
        _isSocketConnected = true;
        notifyListeners();
      });

      _socket!.onDisconnect((_) {
        _isSocketConnected = false;
        notifyListeners();
      });

      // Listen for bus location updates
      _socket!.on(ApiConstants.busLocationUpdateEvent, (data) {
        _handleBusLocationUpdate(data);
      });

      // Listen for ETA updates
      _socket!.on(ApiConstants.etaUpdateEvent, (data) {
        _handleEtaUpdate(data);
      });

      // Listen for schedule updates
      _socket!.on(ApiConstants.scheduleUpdateEvent, (data) {
        _handleScheduleUpdate(data);
      });

      _socket!.connect();
    } catch (e) {
      _error = 'Failed to connect to real-time service';
      notifyListeners();
    }
  }

  // Disconnect socket
  void disconnectSocket() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isSocketConnected = false;
    notifyListeners();
  }

  // Subscribe to journey tracking
  Future<bool> subscribeToTracking(String scheduleId) async {
    setLoading(true);
    clearError();

    try {
      final response = await ApiService.subscribeToTracking(scheduleId);
      
      if (response['success'] == true) {
        // Join socket room for this schedule
        _socket?.emit('subscribe', {'scheduleId': scheduleId});
        
        // Get initial journey data
        if (response['journey'] != null) {
          final journey = Journey.fromJson(response['journey']);
          _activeJourney = journey;
          
          // Add to journeys list if not exists
          final existingIndex = _journeys.indexWhere((j) => j.id == journey.id);
          if (existingIndex != -1) {
            _journeys[existingIndex] = journey;
          } else {
            _journeys.add(journey);
          }
        }
        
        notifyListeners();
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to subscribe to tracking');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Unsubscribe from tracking
  Future<void> unsubscribeFromTracking(String scheduleId) async {
    _socket?.emit('unsubscribe', {'scheduleId': scheduleId});
    
    // Clear active journey if it matches
    if (_activeJourney?.scheduleId == scheduleId) {
      _activeJourney = null;
      notifyListeners();
    }
  }

  // Get tracking status
  Future<Journey?> getTrackingStatus(String scheduleId) async {
    try {
      final response = await ApiService.getTrackingStatus(scheduleId);
      
      if (response['success'] == true && response['journey'] != null) {
        final journey = Journey.fromJson(response['journey']);
        
        // Update active journey if it matches
        if (_activeJourney?.scheduleId == scheduleId) {
          _activeJourney = journey;
        }
        
        // Update in journeys list
        final existingIndex = _journeys.indexWhere((j) => j.scheduleId == scheduleId);
        if (existingIndex != -1) {
          _journeys[existingIndex] = journey;
        }
        
        notifyListeners();
        return journey;
      }
      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Get ETA
  Future<Duration?> getETA(String scheduleId) async {
    try {
      final response = await ApiService.getETA(scheduleId);
      
      if (response['success'] == true && response['eta'] != null) {
        return Duration(seconds: response['eta']);
      }
      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Load live bus locations
  Future<void> loadLiveBusLocations() async {
    try {
      final response = await ApiService.getLiveBuses();
      
      if (response['success'] == true) {
        _liveBusLocations = (response['buses'] as List)
            .map((bus) => BusLocation.fromJson(bus['location']))
            .toList();
        
        // Update bus location map
        _busLocationMap.clear();
        for (var bus in response['buses']) {
          final scheduleId = bus['scheduleId'];
          final location = BusLocation.fromJson(bus['location']);
          _busLocationMap[scheduleId] = location;
        }
        
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Handle bus location updates from socket
  void _handleBusLocationUpdate(dynamic data) {
    try {
      final scheduleId = data['scheduleId'];
      final location = BusLocation.fromJson(data['location']);
      
      _busLocationMap[scheduleId] = location;
      
      // Update active journey if it matches
      if (_activeJourney?.scheduleId == scheduleId) {
        _activeJourney = _activeJourney!.copyWith(currentLocation: location);
      }
      
      notifyListeners();
    } catch (e) {
      print('Error handling bus location update: $e');
    }
  }

  // Handle ETA updates from socket
  void _handleEtaUpdate(dynamic data) {
    try {
      final scheduleId = data['scheduleId'];
      final etaSeconds = data['eta'];
      final eta = Duration(seconds: etaSeconds);
      
      // Update active journey if it matches
      if (_activeJourney?.scheduleId == scheduleId) {
        _activeJourney = _activeJourney!.copyWith(estimatedTimeToArrival: eta);
        notifyListeners();
      }
    } catch (e) {
      print('Error handling ETA update: $e');
    }
  }

  // Handle schedule updates from socket
  void _handleScheduleUpdate(dynamic data) {
    try {
      final scheduleId = data['scheduleId'];
      final status = data['status'];
      
      // Update journey status if it matches
      if (_activeJourney?.scheduleId == scheduleId) {
        final newStatus = JourneyStatus.values.firstWhere(
          (s) => s.toString().split('.').last == status,
          orElse: () => _activeJourney!.status,
        );
        
        _activeJourney = _activeJourney!.copyWith(status: newStatus);
        notifyListeners();
      }
    } catch (e) {
      print('Error handling schedule update: $e');
    }
  }

  // Helper methods
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnectSocket();
    super.dispose();
  }
}

// Extension for Journey copyWith method
extension JourneyCopyWith on Journey {
  Journey copyWith({
    String? id,
    String? bookingId,
    String? scheduleId,
    String? routeId,
    JourneyStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    BusLocation? currentLocation,
    List<BusStop>? completedStops,
    BusStop? nextStop,
    Duration? estimatedTimeToArrival,
    double? distanceRemaining,
    String? driverId,
  }) {
    return Journey(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      scheduleId: scheduleId ?? this.scheduleId,
      routeId: routeId ?? this.routeId,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      currentLocation: currentLocation ?? this.currentLocation,
      completedStops: completedStops ?? this.completedStops,
      nextStop: nextStop ?? this.nextStop,
      estimatedTimeToArrival: estimatedTimeToArrival ?? this.estimatedTimeToArrival,
      distanceRemaining: distanceRemaining ?? this.distanceRemaining,
      driverId: driverId ?? this.driverId,
    );
  }
}
