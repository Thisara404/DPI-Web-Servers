// lib/screens/home/profile_screen.dart

import 'package:bus_driver_app/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/driver_model.dart';
import '../../services/driver_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  late Driver _driver;
  final _formKey = GlobalKey<FormState>();
  final DriverService _driverService = DriverService();

  @override
  void initState() {
    super.initState();
    _driver = Provider.of<AuthProvider>(context, listen: false).driver!;
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await Provider.of<AuthProvider>(context, listen: false)
            .updateProfile(_driver);
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Profile updated')));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _toggleStatus(String status) async {
    try {
      final updated = await _driverService.updateStatus(status);
      setState(() => _driver = updated);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _selectLicenseExpiry(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _driver.licenseExpiry ??
          DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null && picked != _driver.licenseExpiry) {
      setState(() {
        _driver = _driver.copyWith(licenseExpiry: picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final driver = authProvider.driver;

        // FIX: Handle null driver
        if (driver == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading profile...'),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          driver.firstName.isNotEmpty
                              ? driver.firstName[0].toUpperCase()
                              : 'D', // FIX: Handle empty firstName
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        driver.firstName.isNotEmpty
                            ? '${driver.firstName} ${driver.lastName}'
                            : 'Driver', // FIX: Show full name or fallback
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        driver.email,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: driver.status == 'online'
                              ? AppTheme.successGreen.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: driver.status == 'online'
                                ? AppTheme.successGreen
                                : Colors.grey,
                          ),
                        ),
                        child: Text(
                          driver.status?.toUpperCase() ?? 'OFFLINE',
                          style: TextStyle(
                            color: driver.status == 'online'
                                ? AppTheme.successGreen
                                : Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Driver Info
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Driver Information',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // FIX: Add null checks for all fields
                      _buildInfoRow('Phone', driver.phone ?? 'Not set'),
                      _buildInfoRow(
                          'License Number', driver.licenseNumber ?? 'Not set'),
                      _buildInfoRow(
                          'Vehicle Number', driver.vehicleNumber ?? 'Not set'),
                      _buildInfoRow(
                          'Vehicle Type', driver.vehicleType ?? 'Not set'),
                      _buildInfoRow(
                          'License Expiry',
                          driver.licenseExpiry != null
                              ? '${driver.licenseExpiry!.day}/${driver.licenseExpiry!.month}/${driver.licenseExpiry!.year}'
                              : 'Not set'), // FIX: Now works since licenseExpiry is DateTime?
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _isEditing
                        ? _updateProfile
                        : () => setState(() => _isEditing = true),
                    child: Text(_isEditing ? 'Save' : 'Edit Profile'),
                  ),
                  SwitchListTile(
                    title: const Text('Online/Offline'),
                    value: driver.status == 'online',
                    onChanged: (bool value) =>
                        _toggleStatus(value ? 'online' : 'offline'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// Update the copyWith extension
extension on Driver {
  Driver copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? licenseNumber,
    DateTime? licenseExpiry, // FIX: Update to DateTime
    String? vehicleNumber,
    String? vehicleType,
    String? status,
    bool? isVerified,
    bool? isOnline,
    // FIX: Remove lastActive (not in Driver model)
  }) {
    return Driver(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email,
      phone: phone ?? this.phone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry, // FIX: Now DateTime
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      status: status ?? this.status,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
