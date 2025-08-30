class Journey {
  final String id;
  final String scheduleId;
  final String driverId;
  final String status;
  final DateTime startTime;
  final DateTime? endTime;

  Journey({
    required this.id,
    required this.scheduleId,
    required this.driverId,
    required this.status,
    required this.startTime,
    this.endTime,
  });

  factory Journey.fromJson(Map<String, dynamic> json) {
    return Journey(
      id: json['id'] ?? json['_id'] ?? '',
      scheduleId: json['scheduleId'] ?? '',
      driverId: json['driverId'] ?? '',
      status: json['status'] ?? 'pending',
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduleId': scheduleId,
      'driverId': driverId,
      'status': status,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }
}
