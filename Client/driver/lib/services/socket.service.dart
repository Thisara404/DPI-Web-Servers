import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:transit_lanka/config/api.endpoints.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? _socket;
  bool _isConnected = false;

  // Factory constructor
  factory SocketService() {
    return _instance;
  }

  // Private constructor
  SocketService._internal();

  // Initialize socket connection
  void init(String token) {
    print('Initializing socket with token: ${token.substring(0, 10)}...');

    if (_socket != null) {
      _socket!.disconnect();
    }

    try {
      _socket = IO.io(
          ApiEndpoints.baseUrl,
          IO.OptionBuilder()
              .setTransports(['websocket'])
              .enableAutoConnect()
              .setExtraHeaders({'Authorization': 'Bearer $token'})
              .build());

      _setupSocketListeners();
    } catch (e) {
      print('Error initializing socket: $e');
    }
  }

  // Set up socket event listeners
  void _setupSocketListeners() {
    _socket?.onConnect((_) {
      print('Socket connected successfully');
      _isConnected = true;
    });

    _socket?.onDisconnect((_) {
      print('Socket disconnected');
      _isConnected = false;
    });

    _socket?.onConnectError((error) {
      print('Socket connection error: $error');
    });

    _socket?.onError((error) {
      print('Socket error: $error');
    });
  }

  // Subscribe to journey location updates
  void subscribeToJourneyLocation(
      String scheduleId, Function(dynamic) onLocationUpdate) {
    if (!_isConnected || _socket == null) {
      print('Socket is not connected');
      return;
    }

    print('Subscribing to location updates for schedule: $scheduleId');

    _socket!.emit('subscribe', {'scheduleId': scheduleId});

    _socket!.on('location:updated', (data) {
      onLocationUpdate(data);
    });
  }

  // Unsubscribe from journey location updates
  void unsubscribeFromJourneyLocation(String scheduleId) {
    if (_socket != null) {
      print('Unsubscribing from location updates for schedule: $scheduleId');
      _socket!.off('location:updated');
      _socket!.emit('unsubscribe', {'scheduleId': scheduleId});
    }
  }

  // Disconnect socket
  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
  }

  // Check if socket is connected
  bool get isConnected => _isConnected;
}
