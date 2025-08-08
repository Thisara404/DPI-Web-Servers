import 'package:flutter/material.dart';
import 'package:transit_lanka/core/models/schedule.dart';
import 'package:transit_lanka/shared/constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:transit_lanka/core/providers/map.provider.dart';

class ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onStartRoute;
  final VoidCallback? onCompleteRoute;

  const ScheduleCard({
    Key? key,
    required this.schedule,
    required this.onTap,
    required this.onDelete,
    this.onStartRoute,
    this.onCompleteRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      schedule.routeName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      // View on Map button (visible for all schedule statuses)
                      IconButton(
                        icon: const Icon(Icons.map, color: AppColors.primary),
                        onPressed: () => _viewScheduleOnMap(context),
                        tooltip: 'View on map',
                      ),
                      _buildStatusChip(),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Schedule time and day info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Time',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                              '${schedule.formattedStartTime} - ${schedule.formattedEndTime}'),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Days',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(_formatDays(schedule.dayOfWeek)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Driver info
              _buildDriverInfo(),

              const SizedBox(height: 12),

              // Action buttons (Start, Complete, View on Map)
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: schedule.getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: schedule.getStatusColor()),
      ),
      child: Text(
        schedule.getStatusText(),
        style: TextStyle(
          color: schedule.getStatusColor(),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDriverInfo() {
    return schedule.driverName != null
        ? Row(
            children: [
              const Icon(Icons.person, size: 16, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                'Driver: ${schedule.driverName}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          )
        : const Text(
            'No driver assigned',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Start route button
        if (onStartRoute != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onStartRoute,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Route'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),

        // Complete route button
        if (onCompleteRoute != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onCompleteRoute,
              icon: const Icon(Icons.check_circle),
              label: const Text('Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ),

        // View on map button if no other action is available
        if (onStartRoute == null &&
            onCompleteRoute == null &&
            schedule.status != 'completed')
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _viewScheduleOnMap(context),
              icon: const Icon(Icons.map),
              label: const Text('View on Map'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),

        // Delete button
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
            tooltip: 'Delete schedule',
          ),
        ),
      ],
    );
  }

  String _formatDays(List<String> days) {
    if (days.isEmpty) return 'No days set';
    if (days.length == 7) return 'Every day';

    // Sort days in week order
    final weekOrder = {
      'Monday': 0,
      'Tuesday': 1,
      'Wednesday': 2,
      'Thursday': 3,
      'Friday': 4,
      'Saturday': 5,
      'Sunday': 6
    };

    days.sort((a, b) => weekOrder[a]!.compareTo(weekOrder[b]!));

    // If consecutive days, use abbreviations
    if (days.length > 2) {
      return days.map((day) => day.substring(0, 3)).join(', ');
    }

    return days.join(', ');
  }

  // New method to view schedule on map
  void _viewScheduleOnMap(BuildContext context) async {
    // Load the route for this schedule in map provider
    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    // First load the route data
    final routeSuccess = await mapProvider.loadRouteMapData(schedule.routeId);

    if (routeSuccess) {
      // If it's an in-progress schedule, also get driver location
      if (schedule.status == 'in-progress') {
        await mapProvider.refreshDriverLocation(schedule.id);

        // Start tracking for real-time updates
        await mapProvider.startTracking(schedule.routeId);
      }

      // Navigate to map screen
      Navigator.of(context).pushReplacementNamed(
        '/driver/home',
        arguments: {'selectedTab': 'map'},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load route data for map')),
      );
    }
  }
}
