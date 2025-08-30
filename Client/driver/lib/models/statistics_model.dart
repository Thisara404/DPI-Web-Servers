// lib/models/statistics_model.dart

class DriverStatistics {
  final int totalJourneys;
  final double totalDistance;  // km
  final double averageSpeed;  // km/h
  final double? rating;  // e.g., 4.5/5
  final int? completedSchedules;

  DriverStatistics({
    required this.totalJourneys,
    required this.totalDistance,
    required this.averageSpeed,
    this.rating,
    this.completedSchedules,
  });

  factory DriverStatistics.fromJson(Map<String, dynamic> json) {
    return DriverStatistics(
      totalJourneys: json['totalJourneys'] as int,
      totalDistance: json['totalDistance'] as double,
      averageSpeed: json['averageSpeed'] as double,
      rating: json['rating'] as double?,
      completedSchedules: json['completedSchedules'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalJourneys': totalJourneys,
      'totalDistance': totalDistance,
      'averageSpeed': averageSpeed,
      if (rating != null) 'rating': rating,
      if (completedSchedules != null) 'completedSchedules': completedSchedules,
    };
  }
}