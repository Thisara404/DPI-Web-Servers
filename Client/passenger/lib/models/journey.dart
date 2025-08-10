import 'package:passenger/constants.dart';
import 'package:passenger/models/schedule.dart';

class Journey {
  final String id;
  final String bookingId;
  final String scheduleId;
  final String routeId;
  final JourneyStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final BusLocation? currentLocation;
  final List<BusStop> completedStops;
  final BusStop? nextStop;
  final Duration? estimatedTimeToArrival;
  final double? distanceRemaining;
  final String? driverId;

  Journey({
    required this.id,
    required this.bookingId,
    required this.scheduleId,
    required this.routeId,
    required this.status,
    required this.startTime,
    this.endTime,
    this.currentLocation,
    required this.completedStops,
    this.nextStop,
    this.estimatedTimeToArrival,
    this.distanceRemaining,
    this.driverId,
  });

  bool get isActive => status == JourneyStatus.inTransit || status == JourneyStatus.boarding;
  bool get isCompleted => status == JourneyStatus.completed;
  Duration get journeyDuration => (endTime ?? DateTime.now()).difference(startTime);

  factory Journey.fromJson(Map<String, dynamic> json) {
    return Journey(
      id: json['_id'] ?? json['id'],
      bookingId: json['bookingId'],
      scheduleId: json['scheduleId'],
      routeId: json['routeId'],
      status: JourneyStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => JourneyStatus.scheduled,
      ),
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      currentLocation: json['currentLocation'] != null
          ? BusLocation.fromJson(json['currentLocation'])
          : null,
      completedStops: (json['completedStops'] as List?)
          ?.map((stop) => BusStop.fromJson(stop))
          .toList() ?? [],
      nextStop: json['nextStop'] != null
          ? BusStop.fromJson(json['nextStop'])
          : null,
      estimatedTimeToArrival: json['estimatedTimeToArrival'] != null
          ? Duration(seconds: json['estimatedTimeToArrival'])
          : null,
      distanceRemaining: json['distanceRemaining']?.toDouble(),
      driverId: json['driverId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'scheduleId': scheduleId,
      'routeId': routeId,
      'status': status.toString().split('.').last,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'currentLocation': currentLocation?.toJson(),
      'completedStops': completedStops.map((stop) => stop.toJson()).toList(),
      'nextStop': nextStop?.toJson(),
      'estimatedTimeToArrival': estimatedTimeToArrival?.inSeconds,
      'distanceRemaining': distanceRemaining,
      'driverId': driverId,
    };
  }
}

class BusLocation {
  final double latitude;
  final double longitude;
  final double? speed;
  final double? heading;
  final DateTime timestamp;
  final double? accuracy;

  BusLocation({
    required this.latitude,
    required this.longitude,
    this.speed,
    this.heading,
    required this.timestamp,
    this.accuracy,
  });

  factory BusLocation.fromJson(Map<String, dynamic> json) {
    return BusLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      speed: json['speed']?.toDouble(),
      heading: json['heading']?.toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      accuracy: json['accuracy']?.toDouble(),
    );
  }

  get scheduleId => null;

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
      'accuracy': accuracy,
    };
  }
}