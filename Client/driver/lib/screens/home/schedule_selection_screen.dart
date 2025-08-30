import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/journey_provider.dart';
import '../../models/schedule_model.dart';
import 'journey_screen.dart';

class ScheduleSelectionScreen extends StatefulWidget {
  const ScheduleSelectionScreen({super.key});

  @override
  State<ScheduleSelectionScreen> createState() =>
      _ScheduleSelectionScreenState();
}

class _ScheduleSelectionScreenState extends State<ScheduleSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScheduleProvider>(context, listen: false)
          .fetchActiveSchedules();
    });
  }

  Future<void> _startJourney(Schedule schedule) async {
    final journeyProvider =
        Provider.of<JourneyProvider>(context, listen: false);
    final scheduleProvider =
        Provider.of<ScheduleProvider>(context, listen: false);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Starting journey...'),
          ],
        ),
      ),
    );

    try {
      final success = await journeyProvider.startJourney(schedule.id);

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (success && mounted) {
        scheduleProvider.selectSchedule(schedule);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const JourneyScreen()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(journeyProvider.error ?? 'Failed to start journey'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ScheduleProvider>(
        builder: (context, scheduleProvider, child) {
          if (scheduleProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading schedules...'),
                ],
              ),
            );
          }

          if (scheduleProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorRed,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    scheduleProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      scheduleProvider.fetchActiveSchedules();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (scheduleProvider.schedules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No active schedules available',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Check back later for new schedules',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      scheduleProvider.fetchActiveSchedules();
                    },
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => scheduleProvider.fetchActiveSchedules(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: scheduleProvider.schedules.length,
              itemBuilder: (context, index) {
                final schedule = scheduleProvider.schedules[index];
                return _buildScheduleCard(schedule);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleCard(Schedule schedule) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route Info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.route,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
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
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.my_location,
                              size: 14, color: Colors.green),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _getStartLocation(schedule),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.red),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _getEndLocation(schedule),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(schedule.status),
              ],
            ),

            const SizedBox(height: 16),

            // Time Info
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  '${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: schedule.status == 'pending'
                    ? () => _startJourney(schedule)
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: schedule.status == 'pending'
                      ? AppTheme.successGreen
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  schedule.status == 'pending'
                      ? 'Start Journey'
                      : schedule.status.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods to safely get location data
  String _getStartLocation(Schedule schedule) {
    return schedule.routeDetails?['from']?.toString() ??
        schedule.startLocation ??
        'Start Location';
  }

  String _getEndLocation(Schedule schedule) {
    return schedule.routeDetails?['to']?.toString() ??
        schedule.endLocation ??
        'End Location';
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        text = 'Available';
        break;
      case 'accepted':
        color = Colors.blue;
        text = 'Accepted';
        break;
      case 'active':
        color = AppTheme.successGreen;
        text = 'Active';
        break;
      case 'completed':
        color = Colors.grey;
        text = 'Completed';
        break;
      default:
        color = Colors.grey;
        text = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatTime(String timeString) {
    try {
      // Handle different time formats
      DateTime dateTime;
      if (timeString.contains('T')) {
        dateTime = DateTime.parse(timeString);
      } else {
        // Assume it's just a time string like "09:30"
        final parts = timeString.split(':');
        if (parts.length >= 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          dateTime = DateTime(2024, 1, 1, hour, minute);
        } else {
          return timeString;
        }
      }
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timeString;
    }
  }
}
