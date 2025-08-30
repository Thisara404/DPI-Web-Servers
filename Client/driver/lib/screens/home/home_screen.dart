import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/journey_provider.dart';
import '../auth/login_screen.dart';
import 'schedule_selection_screen.dart';
import 'journey_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ScheduleSelectionScreen(),
    const JourneyScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScheduleProvider>(context, listen: false)
          .fetchActiveSchedules();
    });
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  // Helper to get dynamic app bar title based on selected tab
  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Schedules';
      case 2:
        return 'Journey';
      case 3:
        return 'Profile';
      default:
        return 'Bus Driver';
    }
  }

  // Helper to get dynamic app bar actions based on selected tab
  List<Widget> _getAppBarActions() {
    switch (_selectedIndex) {
      case 0: // Dashboard - No specific actions
        return [];
      case 1: // Schedules - Refresh button
        return [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<ScheduleProvider>(context, listen: false)
                  .fetchActiveSchedules();
            },
          ),
        ];
      case 2: // Journey - Stop journey button (if active)
        final journeyProvider =
            Provider.of<JourneyProvider>(context, listen: false);
        if (journeyProvider.isJourneyActive) {
          return [
            IconButton(
              icon: const Icon(Icons.stop, color: AppTheme.errorRed),
              onPressed: () async {
                // Add journey end logic here if needed
                await journeyProvider.endJourney();
              },
            ),
          ];
        }
        return [];
      case 3: // Profile - Logout button
        return [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ];
      default:
        return [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()), // Dynamic title
        actions: _getAppBarActions(), // Dynamic actions
      ),
      body: _screens[_selectedIndex], // Only the selected screen's body
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedules',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.navigation),
            label: 'Journey',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Dashboard Screen
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, ScheduleProvider, JourneyProvider>(
      builder:
          (context, authProvider, scheduleProvider, journeyProvider, child) {
        final driver = authProvider.driver;
        final isJourneyActive = journeyProvider.isJourneyActive;

        // FIX: Handle null driver with a loading state
        if (driver == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading driver details...'),
              ],
            ),
          );
        }

        // FIX: Handle loading/error for schedules
        if (scheduleProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (scheduleProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(scheduleProvider.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => scheduleProvider.fetchActiveSchedules(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Card
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
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppTheme.successGreen,
                            child: Text(
                              driver.firstName.isNotEmpty
                                  ? driver.firstName[0].toUpperCase()
                                  : 'D', // FIX: Handle empty firstName
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back,',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  driver.firstName.isNotEmpty
                                      ? '${driver.firstName} ${driver.lastName}'
                                      : 'Driver', // FIX: Show full name or fallback
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: driver.status == 'online'
                              ? AppTheme.successGreen.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: driver.status == 'online'
                                ? AppTheme.successGreen
                                : Colors.orange,
                          ),
                        ),
                        child: Text(
                          driver.status == 'online' ? 'Online' : 'Offline',
                          style: TextStyle(
                            color: driver.status == 'online'
                                ? AppTheme.successGreen
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Quick Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Active Schedules',
                      '${scheduleProvider.schedules.length}',
                      Icons.schedule,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Status',
                      isJourneyActive ? 'Active' : 'Idle',
                      isJourneyActive ? Icons.play_arrow : Icons.pause,
                      isJourneyActive ? AppTheme.successGreen : Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      'View Schedules',
                      'Check available routes',
                      Icons.schedule,
                      Colors.blue,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const ScheduleSelectionScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      'Start Journey',
                      'Begin tracking',
                      Icons.navigation,
                      AppTheme.successGreen,
                      isJourneyActive
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const JourneyScreen()),
                              ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Recent Activity
              if (scheduleProvider.schedules.isNotEmpty) ...[
                const Text(
                  'Recent Schedules',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...scheduleProvider.schedules.take(3).map(
                      (schedule) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            // Prefer routeName (friendly), fallback to routeId or "Route"
                            schedule.routeName != null &&
                                    schedule.routeName!.isNotEmpty
                                ? schedule.routeName!
                                : (schedule.routeId.isNotEmpty
                                    ? 'Route ${schedule.routeId}'
                                    : 'Route'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                              'Time: ${schedule.startTime} - ${schedule.endTime}'),
                          trailing: Chip(
                            label: Text(schedule.status.toUpperCase()),
                            backgroundColor: schedule.status == 'active'
                                ? AppTheme.successGreen.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                          ),
                        ),
                      ),
                    ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon,
      Color color, VoidCallback? onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Profile Screen (simplified)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final driver = authProvider.driver;

        if (driver == null) {
          return const Center(child: CircularProgressIndicator());
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
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          driver.firstName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${driver.firstName} ${driver.lastName}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              driver.email,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: driver.status == 'online'
                                    ? AppTheme.successGreen.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Driver Information
              const Text(
                'Driver Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildInfoCard('Phone', driver.phone, Icons.phone, context),
              _buildInfoCard('License Number',
                  driver.licenseNumber ?? 'Not provided', Icons.badge, context),
              _buildInfoCard(
                  'License Expiry',
                  driver.licenseExpiry != null
                      ? '${driver.licenseExpiry!.day}/${driver.licenseExpiry!.month}/${driver.licenseExpiry!.year}'
                      : 'Not set',
                  Icons.calendar_today,
                  context),
              _buildInfoCard(
                  'Vehicle Number',
                  driver.vehicleNumber ?? 'Not provided',
                  Icons.directions_bus,
                  context),
              _buildInfoCard(
                  'Vehicle Type',
                  driver.vehicleType ?? 'Not specified',
                  Icons.category,
                  context),

              const SizedBox(height: 20),

              // Actions
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to edit profile screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Edit profile coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(
      String label, String value, IconData icon, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}
