import 'constants.dart';

class Schedule {
  final String id;
  final String routeId;
  final String routeName;
  final String busNumber;
  final String from;
  final String to;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double price;
  final int availableSeats;
  final int totalSeats;
  final JourneyStatus status;
  final List<BusStop> stops;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;

  Schedule({
    required this.id,
    required this.routeId,
    required this.routeName,
    required this.busNumber,
    required this.from,
    required this.to,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.availableSeats,
    required this.totalSeats,
    required this.status,
    required this.stops,
    this.driverId,
    this.driverName,
    this.driverPhone,
  });

  Duration get journeyDuration => arrivalTime.difference(departureTime);
  bool get isAvailable =>
      availableSeats > 0 && status == JourneyStatus.scheduled;
  double get occupancyRate =>
      ((totalSeats - availableSeats) / totalSeats) * 100;

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['_id'] ?? json['id'],
      routeId: json['routeId'],
      routeName: json['routeName'],
      busNumber: json['busNumber'],
      from: json['from'],
      to: json['to'],
      departureTime: DateTime.parse(json['departureTime']),
      arrivalTime: DateTime.parse(json['arrivalTime']),
      price: (json['price'] as num).toDouble(),
      availableSeats: json['availableSeats'],
      totalSeats: json['totalSeats'],
      status: JourneyStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => JourneyStatus.scheduled,
      ),
      stops: (json['stops'] as List?)
              ?.map((stop) => BusStop.fromJson(stop))
              .toList() ??
          [],
      driverId: json['driverId'],
      driverName: json['driverName'],
      driverPhone: json['driverPhone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeId': routeId,
      'routeName': routeName,
      'busNumber': busNumber,
      'from': from,
      'to': to,
      'departureTime': departureTime.toIso8601String(),
      'arrivalTime': arrivalTime.toIso8601String(),
      'price': price,
      'availableSeats': availableSeats,
      'totalSeats': totalSeats,
      'status': status.toString().split('.').last,
      'stops': stops.map((stop) => stop.toJson()).toList(),
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
    };
  }
}

class BusStop {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final DateTime? estimatedArrival;
  final int sequence;
  final bool isActive;

  BusStop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.estimatedArrival,
    required this.sequence,
    this.isActive = true,
  });

  factory BusStop.fromJson(Map<String, dynamic> json) {
    return BusStop(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      estimatedArrival: json['estimatedArrival'] != null
          ? DateTime.parse(json['estimatedArrival'])
          : null,
      sequence: json['sequence'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'estimatedArrival': estimatedArrival?.toIso8601String(),
      'sequence': sequence,
      'isActive': isActive,
    };
  }
}
