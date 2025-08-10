class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String? citizenId;
  final bool isVerified;
  final DateTime createdAt;
  final UserPreferences? preferences;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.citizenId,
    required this.isVerified,
    required this.createdAt,
    this.preferences,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      citizenId: json['citizenId'],
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      preferences: json['preferences'] != null 
          ? UserPreferences.fromJson(json['preferences'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'citizenId': citizenId,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'preferences': preferences?.toJson(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? citizenId,
    bool? isVerified,
    DateTime? createdAt,
    UserPreferences? preferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      citizenId: citizenId ?? this.citizenId,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      preferences: preferences ?? this.preferences,
    );
  }
}

class UserPreferences {
  final bool emailNotifications;
  final bool smsNotifications;
  final bool pushNotifications;
  final String language;
  final String currency;

  UserPreferences({
    this.emailNotifications = true,
    this.smsNotifications = true,
    this.pushNotifications = true,
    this.language = 'en',
    this.currency = 'LKR',
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      emailNotifications: json['emailNotifications'] ?? true,
      smsNotifications: json['smsNotifications'] ?? true,
      pushNotifications: json['pushNotifications'] ?? true,
      language: json['language'] ?? 'en',
      currency: json['currency'] ?? 'LKR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emailNotifications': emailNotifications,
      'smsNotifications': smsNotifications,
      'pushNotifications': pushNotifications,
      'language': language,
      'currency': currency,
    };
  }
}
