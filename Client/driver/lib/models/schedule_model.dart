// lib/models/schedule_model.dart

class Schedule {
  final String id;
  final String routeId;
  final String startTime;
  final String endTime;
  final String status;
  final String? journeyId;
  final Map<String, dynamic>? routeDetails;
  final String? startLocation;
  final String? endLocation;

  Schedule({
    required this.id,
    required this.routeId,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.journeyId,
    this.routeDetails,
    this.startLocation,
    this.endLocation,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] ?? json['_id'] ?? '',
      routeId: json['routeId'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      status: json['status'] ?? 'pending',
      journeyId: json['journeyId'],
      routeDetails: json['routeDetails'],
      startLocation: json['startLocation'] ?? json['from'],
      endLocation: json['endLocation'] ?? json['to'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeId': routeId,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'journeyId': journeyId,
      'routeDetails': routeDetails,
      'startLocation': startLocation,
      'endLocation': endLocation,
    };
  }
}
