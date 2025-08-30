// lib/models/schedule_model.dart

class Schedule {
  final String id;
  final String routeId; // route id string (if available)
  final String? routeName; // optional friendly name
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
    this.routeName,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.journeyId,
    this.routeDetails,
    this.startLocation,
    this.endLocation,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    // routeId can be either a String or an embedded object
    String resolvedRouteId = '';
    String? resolvedRouteName;
    Map<String, dynamic>? resolvedRouteDetails;

    final dynamic routeField =
        json['routeId'] ?? json['route'] ?? json['routeId'];

    if (routeField is String) {
      resolvedRouteId = routeField;
    } else if (routeField is Map<String, dynamic>) {
      resolvedRouteId =
          (routeField['_id'] ?? routeField['id'] ?? '').toString();
      resolvedRouteName =
          routeField['name'] is String ? routeField['name'] as String : null;
      resolvedRouteDetails = routeField;
    }

    // routeDetails may also be present directly on the JSON
    final Map<String, dynamic>? details =
        (json['routeDetails'] is Map<String, dynamic>)
            ? json['routeDetails'] as Map<String, dynamic>
            : resolvedRouteDetails;

    // start/end locations may be nested or simple strings
    String? startLoc;
    String? endLoc;
    if (json['startLocation'] is String) startLoc = json['startLocation'];
    if (json['endLocation'] is String) endLoc = json['endLocation'];
    // fallback to routeDetails stops or from/to fields
    startLoc ??= details != null &&
            details['stops'] is List &&
            (details['stops'] as List).isNotEmpty
        ? (details['stops'][0]['name']?.toString() ?? null)
        : (json['from']?.toString());
    endLoc ??= details != null &&
            details['stops'] is List &&
            (details['stops'] as List).isNotEmpty
        ? (details['stops'].last['name']?.toString() ?? null)
        : (json['to']?.toString());

    return Schedule(
      id: json['id'] ?? json['_id'] ?? '',
      routeId: resolvedRouteId,
      routeName: resolvedRouteName,
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      journeyId: json['journeyId']?.toString(),
      routeDetails: details,
      startLocation: startLoc,
      endLocation: endLoc,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeId': routeId,
      if (routeName != null) 'routeName': routeName,
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
