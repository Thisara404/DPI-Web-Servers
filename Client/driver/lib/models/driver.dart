class Driver {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String licenseNumber;
  final bool isActive;

  Driver({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.licenseNumber,
    required this.isActive,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      licenseNumber: json['licenseNumber'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'licenseNumber': licenseNumber,
      'isActive': isActive,
    };
  }
}