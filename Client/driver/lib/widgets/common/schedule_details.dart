import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transit_lanka/core/models/schedule.dart';
import 'package:transit_lanka/shared/constants/colors.dart';

class ScheduleDetails extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback onBack;
  final VoidCallback onDelete;
  final VoidCallback? onStartRoute;
  final VoidCallback? onCompleteRoute;

  const ScheduleDetails({
    Key? key,
    required this.schedule,
    required this.onBack,
    required this.onDelete,
    this.onStartRoute,
    this.onCompleteRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with back button and actions
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: schedule.status != 'completed' ? onDelete : null,
                tooltip: 'Delete schedule',
              ),
            ],
          ),
        ),

        // Route name and status
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schedule.routeName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildStatusChip(),
            ],
          ),
        ),

        // Schedule statistics
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: Icons.access_time,
                      label: 'Time',
                      value:
                          '${schedule.formattedStartTime} - ${schedule.formattedEndTime}',
                    ),
                    _buildStatItem(
                      icon: Icons.calendar_today,
                      label: 'Days',
                      value: _formatDays(schedule.dayOfWeek),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDriverInfo(),
                const SizedBox(height: 16),
                _buildActionButtons(),
              ],
            ),
          ),
        ),

        // Stops list
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Stops Schedule',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Expanded(
          child: schedule.stopTimes.isEmpty
              ? Center(
                  child: Text('No stop times available for this schedule'),
                )
              : ListView.builder(
                  itemCount: schedule.stopTimes.length,
                  padding: const EdgeInsets.all(20),
                  itemBuilder: (context, index) {
                    final stopTime = schedule.stopTimes[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
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
                                  stopTime.stopName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Arrival: ${DateFormat('hh:mm a').format(stopTime.arrivalTime)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
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

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDriverInfo() {
    return Row(
      children: [
        Icon(Icons.person, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: schedule.driverName != null
              ? Text(
                  'Driver: ${schedule.driverName}',
                  style: const TextStyle(fontSize: 16),
                )
              : const Text(
                  'No driver assigned',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (onStartRoute != null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start Route'),
          onPressed: onStartRoute,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
    } else if (onCompleteRoute != null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.check),
          label: const Text('Complete Route'),
          onPressed: onCompleteRoute,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
    } else if (schedule.status == 'completed') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.check_circle),
          label: const Text('Route Completed'),
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            disabledBackgroundColor: Colors.grey.shade300,
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
    }
    return SizedBox.shrink();
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

    return days.join(', ');
  }
}
