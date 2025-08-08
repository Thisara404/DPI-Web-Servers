import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transit_lanka/core/models/user.dart';
import 'package:transit_lanka/shared/constants/colors.dart';
import '../../../core/providers/auth.provider.dart';
import '../../../core/models/driver.dart';
import '../../../core/services/api/auth_service.dart';
import '../../../shared/widgets/custom_button.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({Key? key}) : super(key: key);

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  bool _isLoading = true;
  Driver? _driverProfile;
  String? _error;
  final _authService = AuthService();
  final _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadDriverProfile();
  }

  Future<void> _loadDriverProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Debug: Print auth token and user info from provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await _secureStorage.read(key: 'auth_token');
      print(
          'Token from storage: ${token != null ? "${token.substring(0, min(15, token.length))}..." : "missing"}');
      print(
          'User ID from provider: ${authProvider.currentUser?.id ?? "missing"}');
      print(
          'User role from provider: ${authProvider.currentUser?.role ?? "missing"}');

      if (token == null) {
        // Force relogin if token is missing
        _handleSessionExpired();
        return;
      }

      // Fetch profile using AuthService
      final driverProfile = await _authService.getUserProfile('driver');

      print('Driver profile fetched successfully');

      setState(() {
        _driverProfile = driverProfile;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching driver profile: $e');

      // Check if the error is a 403 Forbidden error
      if (e.toString().contains('403') ||
          e.toString().contains('Forbidden') ||
          e.toString().contains('Unauthorized')) {
        print('Authorization error detected - forcing re-login');
        _handleSessionExpired();
      } else {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _handleSessionExpired() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Your session has expired. Please log in again.')));

      // Navigate to login screen
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    // Removed the Scaffold and AppBar since they're provided by the parent DriverHomeScreen
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
            ? _buildErrorView()
            : _buildProfileView(user);
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Failed to load profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(_error ?? 'Unknown error'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadDriverProfile,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView(User? user) {
    return RefreshIndicator(
      onRefresh: _loadDriverProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(user),
            const SizedBox(height: 24),
            _buildPersonalInfo(),
            const SizedBox(height: 16),
            _buildVehicleInfo(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.secondaryLight,
            backgroundImage: _driverProfile?.image != null
                ? NetworkImage(_driverProfile!.image!)
                : null,
            child: _driverProfile?.image == null
                ? const Icon(Icons.person, size: 50, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            _driverProfile?.name ?? user?.name ?? 'Driver',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Driver',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.email, 'Email', _driverProfile?.email ?? 'N/A'),
            _buildInfoRow(Icons.phone, 'Phone', _driverProfile?.phone ?? 'N/A'),
            _buildInfoRow(
                Icons.location_on, 'Address', _driverProfile?.address ?? 'N/A'),
            _buildInfoRow(Icons.badge, 'License Number',
                _driverProfile?.licenseNumber ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vehicle Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.directions_bus, 'Bus Number',
                _driverProfile?.busDetails.busNumber ?? 'N/A'),
            _buildInfoRow(Icons.category, 'Bus Model',
                _driverProfile?.busDetails.busModel ?? 'N/A'),
            _buildInfoRow(Icons.color_lens, 'Bus Color',
                _driverProfile?.busDetails.busColor ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.edit),
          label: const Text('Edit Profile'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            // Navigate to edit profile screen
            // This would be implemented in a separate ticket
          },
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.password),
          label: const Text('Change Password'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            // Navigate to change password screen
            // This would be implemented in a separate ticket
          },
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade50,
            foregroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Confirm Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );

            if (confirmed == true && context.mounted) {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            }
          },
        ),
      ],
    );
  }
}
