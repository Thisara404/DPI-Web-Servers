import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transit_lanka/core/models/schedule.dart';
import 'package:transit_lanka/core/providers/auth.provider.dart';
import 'package:transit_lanka/core/providers/schedule.provider.dart';
import 'package:transit_lanka/core/providers/map.provider.dart';
import 'package:transit_lanka/shared/constants/colors.dart';
import 'package:transit_lanka/screens/driver/widgets/schedules/create_schedule_form.dart';
import 'package:transit_lanka/screens/driver/widgets/schedules/schedule_card.dart';
import 'package:transit_lanka/screens/driver/widgets/schedules/schedule_details.dart';
import 'package:flutter/foundation.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isCreatingSchedule = false;
  int _selectedTabIndex = 0; // 0: Today, 1: Upcoming, 2: Completed
  String _selectedFilter = 'today'; // 'today', 'upcoming', 'completed'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize with today's schedules by default
      Provider.of<ScheduleProvider>(context, listen: false)
          .fetchSchedules(filter: _selectedFilter);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateScheduleForm() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser == null ||
        authProvider.currentUser!.token?.isEmpty == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to create schedules'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isCreatingSchedule = true;
    });
  }

  void _hideCreateScheduleForm() {
    setState(() {
      _isCreatingSchedule = false;
    });
  }

  void _confirmDeleteSchedule(BuildContext context, Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Schedule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete the following schedule?'),
            SizedBox(height: 12),
            Text('Route: ${schedule.routeName}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Days: ${schedule.dayOfWeek.join(", ")}'),
            Text(
                'Time: ${schedule.formattedStartTime} - ${schedule.formattedEndTime}'),
            Text('Status: ${schedule.getStatusText()}'),
            SizedBox(height: 12),
            Text('This action cannot be undone.',
                style:
                    TextStyle(color: Colors.red, fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSchedule(schedule.id);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSchedule(String id) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Deleting schedule..."),
          ],
        ),
      ),
    );

    final scheduleProvider =
        Provider.of<ScheduleProvider>(context, listen: false);
    final success = await scheduleProvider.deleteSchedule(id);

    // Close loading dialog
    Navigator.of(context, rootNavigator: true).pop();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Schedule deleted successfully'),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(scheduleProvider.error ?? 'Failed to delete schedule'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _updateScheduleStatus(String id, String status) async {
    final scheduleProvider =
        Provider.of<ScheduleProvider>(context, listen: false);
    final success = await scheduleProvider.updateScheduleStatus(id, status);

    if (success) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Schedule status updated to ${status.toUpperCase()}')),
      );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              scheduleProvider.error ?? 'Failed to update schedule status'),
        ),
      );
    }
  }

  void _startRoute(Schedule schedule) async {
    // First, update the schedule status to 'in-progress'
    final scheduleProvider =
        Provider.of<ScheduleProvider>(context, listen: false);
    final success =
        await scheduleProvider.updateScheduleStatus(schedule.id, 'in-progress');

    if (success) {
      // Load the route map data in the map provider
      final mapProvider = Provider.of<MapProvider>(context, listen: false);
      await mapProvider.loadRouteMapData(schedule.routeId);

      // Start tracking
      await mapProvider.startTracking(schedule.routeId);

      // Navigate to the map screen via the driver home screen
      Navigator.of(context).pushReplacementNamed(
        '/driver/home',
        arguments: {'selectedTab': 'map'},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start route')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleProvider>(
      builder: (context, scheduleProvider, child) {
        return Scaffold(
          body: scheduleProvider.selectedSchedule != null
              ? _buildScheduleDetails(scheduleProvider)
              : _isCreatingSchedule
                  ? _buildCreateScheduleForm(scheduleProvider)
                  : _buildSchedulesList(scheduleProvider),
          floatingActionButton:
              scheduleProvider.selectedSchedule == null && !_isCreatingSchedule
                  ? FloatingActionButton(
                      onPressed: _showCreateScheduleForm,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.add),
                    )
                  : null,
        );
      },
    );
  }

  Widget _buildSchedulesList(ScheduleProvider scheduleProvider) {
    final schedules = scheduleProvider.filteredSchedules;

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search schedules...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            onChanged: (value) => scheduleProvider.searchSchedules(value),
          ),
        ),

        // // Debug info panel
        // if (kDebugMode)
        //   Container(
        //     margin: EdgeInsets.only(bottom: 8),
        //     padding: EdgeInsets.all(8),
        //     color: Colors.black.withOpacity(0.05),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         Text('Debug Info:'),
        //         Text('Filter: $_selectedFilter'),
        //         Text('Total Schedules: ${scheduleProvider.schedules.length}'),
        //         Text(
        //             'Filtered Schedules: ${scheduleProvider.filteredSchedules.length}'),
        //         Text('API Status: ${scheduleProvider.error ?? 'OK'}'),
        //         if (scheduleProvider.error != null)
        //           Text('Error: ${scheduleProvider.error}',
        //               style: TextStyle(color: Colors.red)),
        //       ],
        //     ),
        //   ),

        // Filter tabs
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFilterTab('Today', 0),
              const SizedBox(width: 16),
              _buildFilterTab('Upcoming', 1),
              const SizedBox(width: 16),
              _buildFilterTab('Completed', 2),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Schedule list with better loading indicator
        Expanded(
          child: scheduleProvider.isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading schedules...'),
                    ],
                  ),
                )
              : schedules.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 64, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text(
                            _searchController.text.isNotEmpty
                                ? 'No schedules found for "${_searchController.text}"'
                                : 'No ${_selectedFilter} schedules available',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: Icon(Icons.refresh),
                            label: Text('Refresh'),
                            onPressed: () => scheduleProvider.fetchSchedules(
                                filter: _selectedFilter),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await scheduleProvider.fetchSchedules(
                            filter: _selectedFilter);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Schedules refreshed'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: ListView.builder(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: schedules.length,
                        itemBuilder: (context, index) {
                          final schedule = schedules[index];
                          return ScheduleCard(
                            schedule: schedule,
                            onTap: () =>
                                scheduleProvider.selectSchedule(schedule),
                            onDelete: () =>
                                _confirmDeleteSchedule(context, schedule),
                            onStartRoute: schedule.status == 'scheduled'
                                ? () => _startRoute(schedule)
                                : null,
                            onCompleteRoute: schedule.status == 'in-progress'
                                ? () => _updateScheduleStatus(
                                    schedule.id, 'completed')
                                : null,
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    final filters = ['today', 'upcoming', 'completed'];

    return Expanded(
      child: InkWell(
        onTap: () async {
          setState(() {
            _selectedTabIndex = index;
            _selectedFilter = filters[index];
          });

          // Show loading indicator
          final scheduleProvider =
              Provider.of<ScheduleProvider>(context, listen: false);

          // Clear previous filtered schedules
          scheduleProvider.clearFilters();

          // Fetch schedules with the selected filter
          await scheduleProvider.fetchSchedules(filter: filters[index]);

          // Wait a short moment for any asynchronous UI updates
          await Future.delayed(Duration(milliseconds: 300));

          // If no results after server filtering, try client-side filtering
          if (scheduleProvider.filteredSchedules.isEmpty &&
              scheduleProvider.schedules.isNotEmpty) {
            scheduleProvider.filterSchedulesLocally(filters[index]);
          }

          // Debug output
          print(
              'Filter: ${filters[index]}, Schedules: ${scheduleProvider.filteredSchedules.length}');
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleDetails(ScheduleProvider scheduleProvider) {
    return ScheduleDetails(
      schedule: scheduleProvider.selectedSchedule!,
      onBack: scheduleProvider.clearSelectedSchedule,
      onDelete: () =>
          _confirmDeleteSchedule(context, scheduleProvider.selectedSchedule!),
      onStartRoute: scheduleProvider.selectedSchedule!.status == 'scheduled'
          ? () {
              _updateScheduleStatus(
                  scheduleProvider.selectedSchedule!.id, 'in-progress');
              scheduleProvider.clearSelectedSchedule();
            }
          : null,
      onCompleteRoute:
          scheduleProvider.selectedSchedule!.status == 'in-progress'
              ? () {
                  _updateScheduleStatus(
                      scheduleProvider.selectedSchedule!.id, 'completed');
                  scheduleProvider.clearSelectedSchedule();
                }
              : null,
    );
  }

  Widget _buildCreateScheduleForm(ScheduleProvider scheduleProvider) {
    return CreateScheduleForm(
      onCancel: _hideCreateScheduleForm,
      onSuccess: () {
        _hideCreateScheduleForm();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Schedule created successfully')),
        );
      },
    );
  }
}
