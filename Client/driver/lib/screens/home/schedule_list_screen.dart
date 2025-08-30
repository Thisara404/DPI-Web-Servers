// lib/screens/schedule_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/journey_provider.dart';
import '../../models/schedule_model.dart';
import '../../config/theme.dart';

class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key});

  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  @override
  void initState() {
    super.initState();
    // Fix: Use fetchActiveSchedules instead of fetchSchedules
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScheduleProvider>(context, listen: false)
          .fetchActiveSchedules();
    });
  }

  // Add missing acceptSchedule method
  Future<void> _acceptSchedule(String scheduleId) async {
    final scheduleProvider =
        Provider.of<ScheduleProvider>(context, listen: false);

    try {
      final success = await scheduleProvider.acceptSchedule(scheduleId);

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(scheduleProvider.error ?? 'Failed to accept schedule'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } catch (e) {
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

  // Add missing startJourney method
  Future<void> _startJourney(String scheduleId) async {
    final journeyProvider =
        Provider.of<JourneyProvider>(context, listen: false);

    try {
      final success = await journeyProvider.startJourney(scheduleId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Journey started successfully'),
            backgroundColor: AppTheme.successGreen,
          ),
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
      appBar: AppBar(
        title: const Text('Schedule List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<ScheduleProvider>(context, listen: false)
                  .fetchActiveSchedules();
            },
          ),
        ],
      ),
      body: Consumer<ScheduleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => provider.fetchActiveSchedules(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.schedules.isEmpty) {
            return const Center(
              child: Text(
                'No schedules available',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => provider.fetchActiveSchedules(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.schedules.length,
              itemBuilder: (context, index) {
                final schedule = provider.schedules[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text('Route: ${schedule.routeId}'),
                    subtitle: Text(
                      'Time: ${schedule.startTime} - ${schedule.endTime}\nStatus: ${schedule.status}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (schedule.status == 'pending')
                          ElevatedButton(
                            onPressed: () => _acceptSchedule(schedule.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.successGreen,
                            ),
                            child: const Text('Accept'),
                          ),
                        if (schedule.status == 'accepted')
                          ElevatedButton(
                            onPressed: () => _startJourney(schedule.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                            ),
                            child: const Text('Start'),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
