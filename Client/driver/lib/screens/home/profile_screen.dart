// lib/screens/profile_screen.dart

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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.driver == null)
            return const Center(child: CircularProgressIndicator());
          _driver = authProvider.driver!;
          return Form(
            key: _formKey,
            child: ListView(
              children: [
                Text('Name: ${_driver.firstName} ${_driver.lastName}'),
                if (_isEditing)
                  TextFormField(
                      initialValue: _driver.firstName,
                      onChanged: (v) =>
                          _driver = _driver.copyWith(firstName: v)),
                if (_isEditing)
                  TextFormField(
                      initialValue: _driver.lastName,
                      onChanged: (v) =>
                          _driver = _driver.copyWith(lastName: v)),
                Text('Email: ${_driver.email}'),
                if (_isEditing)
                  TextFormField(
                      initialValue: _driver.phone,
                      onChanged: (v) => _driver = _driver.copyWith(phone: v),
                      validator: (v) => v!.length != 10 ? 'Invalid' : null),
                Text('Phone: ${_driver.phone}'),
                Text('License: ${_driver.licenseNumber}'),
                if (_isEditing)
                  TextFormField(
                    initialValue: _driver.licenseNumber,
                    onChanged: (v) =>
                        _driver = _driver.copyWith(licenseNumber: v),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                Text(
                    'License Expiry: ${_driver.licenseExpiry != null ? '${_driver.licenseExpiry!.day}/${_driver.licenseExpiry!.month}/${_driver.licenseExpiry!.year}' : 'Not set'}'),
                if (_isEditing)
                  ElevatedButton(
                    onPressed: () => _selectLicenseExpiry(context),
                    child: const Text('Select Expiry Date'),
                  ),
                Text(
                    'Vehicle: ${_driver.vehicleNumber} (${_driver.vehicleType})'),
                if (_isEditing)
                  TextFormField(
                      initialValue: _driver.vehicleNumber,
                      onChanged: (v) =>
                          _driver = _driver.copyWith(vehicleNumber: v)),
                if (_isEditing)
                  TextFormField(
                      initialValue: _driver.vehicleType,
                      onChanged: (v) =>
                          _driver = _driver.copyWith(vehicleType: v)),
                Text('Status: ${_driver.status ?? 'Offline'}'),
                SwitchListTile(
                  title: const Text('Online/Offline'),
                  value: _driver.status == 'online',
                  onChanged: (bool value) =>
                      _toggleStatus(value ? 'online' : 'offline'),
                ),
                Text('Verified: ${_driver.isVerified ?? false ? 'Yes' : 'No'}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isEditing
                      ? _updateProfile
                      : () => setState(() => _isEditing = true),
                  child: Text(_isEditing ? 'Save' : 'Edit Profile'),
                ),
              ],
            ),
          );
        },
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
    DateTime? licenseExpiry, // Add this
    String? vehicleNumber,
    String? vehicleType,
  }) {
    return Driver(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email,
      phone: phone ?? this.phone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry, // Add this
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      status: status,
      isVerified: isVerified,
      lastActive: lastActive,
    );
  }
}
