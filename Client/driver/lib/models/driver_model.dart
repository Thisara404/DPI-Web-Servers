// lib/models/driver_model.dart

import 'dart:convert';

class Driver {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? password;
  final String? licenseNumber;
  final DateTime? licenseExpiry; // Add this field
  final String? vehicleNumber;
  final String? vehicleType;
  final String? status;
  final bool? isVerified;
  final DateTime? lastActive;

  Driver({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.password,
    this.licenseNumber,
    this.licenseExpiry, // Add this parameter
    this.vehicleNumber,
    this.vehicleType,
    this.status,
    this.isVerified,
    this.lastActive,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      licenseNumber: json['licenseNumber'],
      licenseExpiry: json['licenseExpiry'] != null
          ? DateTime.parse(json['licenseExpiry'])
          : null,
      vehicleNumber: json['vehicleNumber'],
      vehicleType: json['vehicleType'],
      status: json['status'],
      isVerified: json['isVerified'],
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      if (password != null) 'password': password,
      if (licenseNumber != null) 'licenseNumber': licenseNumber,
      if (licenseExpiry != null)
        'licenseExpiry': licenseExpiry!.toIso8601String(), // Add this
      if (vehicleNumber != null) 'vehicleNumber': vehicleNumber,
      if (vehicleType != null) 'vehicleType': vehicleType,
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
          message: json['message'] ?? '',
          driver:
              data['driver'] != null ? Driver.fromJson(data['driver']) : null,
          accessToken: data['tokens']?['accessToken'],
          refreshToken: data['tokens']?['refreshToken'],
        );

        print(
            '✅ AuthResponse.fromJson: Successfully parsed register/login response');
        return response;
      } else {
        // Refresh token response structure
        final response = AuthResponse(
          success: json['success'] ?? false,
          message: json['message'] ?? '',
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
