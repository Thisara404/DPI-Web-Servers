import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../constants.dart';

class WebSocketService {
  static WebSocketService? _instance;
  static WebSocketService get instance => _instance ??= WebSocketService._();
  WebSocketService._();

  IO.Socket? _socket;
  WebSocketChannel? _channel;
  bool _isConnected = false;
  String? _authToken;

  // Callbacks
  Function(Map<String, dynamic>)? onLocationUpdate;
  Function(Map<String, dynamic>)? onScheduleUpdate;
  Function(Map<String, dynamic>)? onNotification;
  Function()? onConnected;
  Function()? onDisconnected;

  bool get isConnected => _isConnected;

  Future<void> connect(String authToken) async {
    if (_isConnected) return;

    _authToken = authToken;

    try {
      _socket = IO.io(
        ApiConstants.socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': authToken})
            .setTimeout(5000)
            .setReconnection(true)
            .setReconnectionAttempts(5)
            .setReconnectionDelay(1000)
            .build(),
      );

      _socket!.onConnect((_) {
        print('🔌 WebSocket connected');
        _isConnected = true;
        onConnected?.call();
      });

      _socket!.onDisconnect((_) {
        print('🔌 WebSocket disconnected');
        _isConnected = false;
        onDisconnected?.call();
      });

      _socket!.onConnectError((error) {
        print('🔌 WebSocket connection error: $error');
        _isConnected = false;
      });

      // Listen for real-time events
      _socket!.on('location-update', (data) {
        if (data is Map<String, dynamic>) {
          onLocationUpdate?.call(data);
        }
      });

      _socket!.on('schedule-update', (data) {
        if (data is Map<String, dynamic>) {
          onScheduleUpdate?.call(data);
        }
      });

      _socket!.on('notification', (data) {
        if (data is Map<String, dynamic>) {
          onNotification?.call(data);
        }
      });

      _socket!.on('eta-update', (data) {
        if (data is Map<String, dynamic>) {
          print('📍 ETA Update: $data');
          onLocationUpdate?.call(data);
        }
      });

      _socket!.on('route-disruption', (data) {
        if (data is Map<String, dynamic>) {
          print('🚨 Route Disruption: $data');
          onNotification?.call(data);
        }
      });

      _socket!.connect();
    } catch (e) {
      print('🔌 WebSocket connection failed: $e');
      _isConnected = false;
    }
  }

  void subscribeToSchedule(String scheduleId) {
    if (_socket?.connected == true) {
      _socket!.emit('subscribe-schedule', {'scheduleId': scheduleId});
      print('📡 Subscribed to schedule: $scheduleId');
    }
  }

  void unsubscribeFromSchedule(String scheduleId) {
    if (_socket?.connected == true) {
      _socket!.emit('unsubscribe-schedule', {'scheduleId': scheduleId});
      print('📡 Unsubscribed from schedule: $scheduleId');
    }
  }

  void subscribeToRoute(String routeId) {
    if (_socket?.connected == true) {
      _socket!.emit('subscribe-route', {'routeId': routeId});
      print('📡 Subscribed to route: $routeId');
    }
  }

  void unsubscribeFromRoute(String routeId) {
    if (_socket?.connected == true) {
      _socket!.emit('unsubscribe-route', {'routeId': routeId});
      print('📡 Unsubscribed from route: $routeId');
    }
  }

  void requestETA(String scheduleId, double lat, double lng) {
    if (_socket?.connected == true) {
      _socket!.emit('request-eta', {
        'scheduleId': scheduleId,
        'passengerLocation': {'lat': lat, 'lng': lng}
      });
      print('📍 Requested ETA for schedule: $scheduleId');
    }
  }

  void disconnect() {
    if (_socket?.connected == true) {
      _socket!.disconnect();
    }
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    print('🔌 WebSocket disconnected manually');
  }

  void reconnect() {
    if (_authToken != null) {
      disconnect();
      connect(_authToken!);
    }
  }
}

extension on IO.OptionBuilder {
  setReconnection(bool bool) {}
}
