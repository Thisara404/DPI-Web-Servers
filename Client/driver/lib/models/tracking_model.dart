// lib/models/tracking_model.dart

class LocationUpdate {
  final double latitude;
  final double longitude;
  final double? bearing;  // Direction
  final double? speed;  // km/h
  final double? accuracy;  // Meters
  final String? scheduleId;
  final String? journeyId;
  final DateTime timestamp;

  LocationUpdate({
    required this.latitude,
    required this.longitude,
    this.bearing,
    this.speed,
    this.accuracy,
    this.scheduleId,
    this.journeyId,
    required this.timestamp,
  });

  factory LocationUpdate.fromJson(Map<String, dynamic> json) {
    return LocationUpdate(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      bearing: json['bearing'] as double?,
      speed: json['speed'] as double?,
      accuracy: json['accuracy'] as double?,
      scheduleId: json['scheduleId'] as String?,
      journeyId: json['journeyId'] as String?,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (bearing != null) 'bearing': bearing,
      if (speed != null) 'speed': speed,
      if (accuracy != null) 'accuracy': accuracy,
      if (scheduleId != null) 'scheduleId': scheduleId,
      if (journeyId != null) 'journeyId': journeyId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

// For tracking history (list of updates)
class TrackingHistory {
  final List<LocationUpdate> updates;
  final String? scheduleId;

  TrackingHistory({
    required this.updates,
    this.scheduleId,
  });

  factory TrackingHistory.fromJson(Map<String, dynamic> json) {
    return TrackingHistory(
      updates: (json['updates'] as List).map((e) => LocationUpdate.fromJson(e)).toList(),
      scheduleId: json['scheduleId'] as String?,
    );
  }
}