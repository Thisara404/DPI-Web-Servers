import 'package:passenger/constants.dart';

class Booking {
  final String id;
  final String scheduleId;
  final String userId;
  final List<Passenger> passengers;
  final double totalAmount;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final DateTime bookingDate;
  final String? paymentId;
  final String? qrCode;
  final Ticket? ticket;

  Booking({
    required this.id,
    required this.scheduleId,
    required this.userId,
    required this.passengers,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.bookingDate,
    this.paymentId,
    this.qrCode,
    this.ticket,
  });

  int get passengerCount => passengers.length;
  bool get isActive =>
      status == BookingStatus.confirmed &&
      paymentStatus == PaymentStatus.completed;

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'] ?? json['id'],
      scheduleId: json['scheduleId'],
      userId: json['userId'],
      passengers: (json['passengers'] as List)
          .map((p) => Passenger.fromJson(p))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      bookingDate: DateTime.parse(json['bookingDate']),
      paymentId: json['paymentId'],
      qrCode: json['qrCode'],
      ticket: json['ticket'] != null ? Ticket.fromJson(json['ticket']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduleId': scheduleId,
      'userId': userId,
      'passengers': passengers.map((p) => p.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'paymentStatus': paymentStatus.toString().split('.').last,
      'bookingDate': bookingDate.toIso8601String(),
      'paymentId': paymentId,
      'qrCode': qrCode,
      'ticket': ticket?.toJson(),
    };
  }
}

class Passenger {
  final String firstName;
  final String lastName;
  final int age;
  final String? citizenId;
  final String? phone;

  Passenger({
    required this.firstName,
    required this.lastName,
    required this.age,
    this.citizenId,
    this.phone,
  });

  String get fullName => '$firstName $lastName';

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      firstName: json['firstName'],
      lastName: json['lastName'],
      age: json['age'],
      citizenId: json['citizenId'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'citizenId': citizenId,
      'phone': phone,
    };
  }
}

class Ticket {
  final String id;
  final String bookingId;
  final String scheduleId;
  final String qrCode;
  final TicketStatus status;
  final DateTime validFrom;
  final DateTime validUntil;
  final DateTime? usedAt;
  final String? validatedBy;

  Ticket({
    required this.id,
    required this.bookingId,
    required this.scheduleId,
    required this.qrCode,
    required this.status,
    required this.validFrom,
    required this.validUntil,
    this.usedAt,
    this.validatedBy,
  });

  bool get isValid =>
      status == TicketStatus.active &&
      DateTime.now().isBefore(validUntil) &&
      DateTime.now().isAfter(validFrom);

  bool get isExpired => DateTime.now().isAfter(validUntil);

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['_id'] ?? json['id'],
      bookingId: json['bookingId'],
      scheduleId: json['scheduleId'],
      qrCode: json['qrCode'],
      status: TicketStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TicketStatus.active,
      ),
      validFrom: DateTime.parse(json['validFrom']),
      validUntil: DateTime.parse(json['validUntil']),
      usedAt: json['usedAt'] != null ? DateTime.parse(json['usedAt']) : null,
      validatedBy: json['validatedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'scheduleId': scheduleId,
      'qrCode': qrCode,
      'status': status.toString().split('.').last,
      'validFrom': validFrom.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'usedAt': usedAt?.toIso8601String(),
      'validatedBy': validatedBy,
    };
  }
}
