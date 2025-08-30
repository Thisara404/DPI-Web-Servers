// lib/models/driver_model.dart

import 'dart:convert';

class Driver {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String licenseNumber;
  final DateTime?
      licenseExpiry; // FIX: Change to DateTime? for proper date handling
  final String vehicleNumber;
  final String vehicleType;
  final String status;
  final bool isVerified;
  final bool isOnline;

  Driver({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.licenseNumber,
    this.licenseExpiry, // Now optional DateTime
    required this.vehicleNumber,
    required this.vehicleType,
    required this.status,
    required this.isVerified,
    this.isOnline = false,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] is String ? json['id'] : '',
      firstName: json['firstName'] is String ? json['firstName'] : '',
      lastName: json['lastName'] is String ? json['lastName'] : '',
      email: json['email'] is String ? json['email'] : '',
      phone: json['phone'] is String ? json['phone'] : '',
      licenseNumber:
          json['licenseNumber'] is String ? json['licenseNumber'] : '',
      licenseExpiry: json['licenseExpiry'] is String
          ? DateTime.tryParse(json['licenseExpiry'])
          : null,
      vehicleNumber:
          json['vehicleNumber'] is String ? json['vehicleNumber'] : '',
      vehicleType: json['vehicleType'] is String ? json['vehicleType'] : 'bus',
      status: json['status'] is String ? json['status'] : 'pending',
      isVerified: json['isVerified'] is bool ? json['isVerified'] : false,
      isOnline: json['isOnline'] is bool ? json['isOnline'] : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'licenseNumber': licenseNumber,
      'licenseExpiry': licenseExpiry
          ?.toIso8601String(), // FIX: Convert DateTime back to string for JSON
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
      'status': status,
      'isVerified': isVerified,
      'isOnline': isOnline,
    };
  }
}

// For login response (includes tokens)
class AuthResponse {
  final bool success;
  final String message;
  final Driver? driver;
  final String? accessToken;
  final String? refreshToken;

  AuthResponse({
    required this.success,
    required this.message,
    this.driver,
    this.accessToken,
    this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    print('🔍 AuthResponse.fromJson: Parsing auth response');
    print('📄 JSON data: $json');

    try {
      final hasData = json.containsKey('data');

      if (hasData) {
        // Register/Login response structure
        final data = json['data'];
        final response = AuthResponse(
          success: json['success'] ?? false,
          message: json['message'] is String
              ? json['message']
              : '', // FIX: Type check
          driver: data != null && data['driver'] != null
              ? Driver.fromJson(data['driver'])
              : null,
          accessToken: data?['tokens']?['accessToken'],
          refreshToken: data?['tokens']?['refreshToken'],
        );

        print(
            '✅ AuthResponse.fromJson: Successfully parsed register/login response');
        return response;
      } else {
        // Refresh token response structure
        final response = AuthResponse(
          success: json['success'] ?? false,
          message: json['message'] is String
              ? json['message']
              : '', // FIX: Type check
          driver: null,
          accessToken: json['accessToken'],
          refreshToken: json['refreshToken'],
        );

        print('✅ AuthResponse.fromJson: Successfully parsed refresh response');
        return response;
      }
    } catch (e) {
      print('❌ AuthResponse.fromJson: Error parsing response: $e');
      print('🔍 Problematic field likely in: $json');
      rethrow;
    }
  }
}
