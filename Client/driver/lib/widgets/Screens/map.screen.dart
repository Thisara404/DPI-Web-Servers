import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'package:transit_lanka/core/models/schedule.dart';
import 'package:transit_lanka/core/providers/map.provider.dart';
import 'package:transit_lanka/core/providers/schedule.provider.dart';
import 'package:transit_lanka/core/providers/journey.provider.dart';
import 'package:transit_lanka/core/utils/map.utils.dart';
import 'package:transit_lanka/shared/constants/colors.dart';
import 'package:transit_lanka/core/utils/route_visualizer.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Location _location = Location();
  bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;
  LocationData? _currentLocation;
  Timer? _locationTimer;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isTracking = false;
  int _currentStopIndex = 0;
  Schedule? _activeSchedule;
  bool _showSchedulePanel = false;

  // Default center on Colombo, Sri Lanka
  static const CameraPosition _defaultLocation = CameraPosition(
    target: LatLng(6.9271, 79.8612),
    zoom: 13,
  );

  @override
  void initState() {
    super.initState();
    print('MapScreen initialized');
    _checkLocationPermission();

    // Use a post-frame callback to initialize data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('Post-frame callback executing');
      _initializeMapData();
    });
  }

  Future<void> _initializeMapData() async {
    final scheduleProvider =
        Provider.of<ScheduleProvider>(context, listen: false);
    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    // Try to find an active schedule that's in progress
    final activeSchedule = scheduleProvider.schedules.firstWhere(
      (schedule) => schedule.status == 'in-progress',
      orElse: () => Schedule(
        id: '',
        routeId: '',
        routeName: '',
        dayOfWeek: [],
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        status: '',
        stopTimes: [],
        isRecurring: false,
        isToday: false,
        isPassed: false,
        formattedStartTime: '',
        formattedEndTime: '',
      ),
    );

    if (activeSchedule.id.isNotEmpty && activeSchedule.routeId.isNotEmpty) {
      print(
          'Found active schedule: ${activeSchedule.id} - ${activeSchedule.routeName}');

      setState(() {
        _activeSchedule = activeSchedule;
        _isTracking = true;
        _showSchedulePanel = true;
      });

      // Load route data and begin tracking
      final success =
          await mapProvider.loadRouteMapData(activeSchedule.routeId);

      if (success) {
        print('Successfully loaded route map data');
        await mapProvider.startTracking(activeSchedule.routeId);
        _updateMapVisualization(mapProvider);
      } else {
        print('Failed to load route map data');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load route data')),
        );
      }
    } else {
      print('No active schedule found');
    }
  }

  void _updateMapVisualization(MapProvider mapProvider) {
    setState(() {
      _markers = mapProvider.markers;
      _polylines = mapProvider.routePolylines;

      if (mapProvider.driverLocation != null) {
        _markers.add(Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(
            mapProvider.driverLocation!.latitude!,
            mapProvider.driverLocation!.longitude!,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Driver Location'),
        ));
      }
    });
  }

  // Helper method to find closest point on route to driver
  int _findClosestPointOnRoute(LatLng driverPosition, List<LatLng> routePath) {
    if (routePath.isEmpty) return 0;

    int closestPointIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < routePath.length; i++) {
      double distance = _calculateDistance(driverPosition, routePath[i]);
      if (distance < minDistance) {
        minDistance = distance;
        closestPointIndex = i;
      }
    }

    return closestPointIndex;
  }

  // Calculate distance between two coordinates (using simplified distance formula)
  double _calculateDistance(LatLng p1, LatLng p2) {
    final dx = p1.latitude - p2.latitude;
    final dy = p1.longitude - p2.longitude;
    return dx * dx +
        dy * dy; // Simplified distance (no need for square root for comparison)
  }

  Future<void> _animateToRouteBounds(MapProvider mapProvider) async {
    if (!_controller.isCompleted || mapProvider.activeRoute == null) return;

    final controller = await _controller.future;

    // Calculate bounds that include all stops and driver location
    final bounds = RouteVisualizer.calculateBounds(
      stops: mapProvider.activeRoute!.stops,
      driverLocation: mapProvider.driverLocation,
    );

    // Animate camera to show the entire route
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        bounds,
        50.0, // Padding
      ),
    );
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  // Check if location service is enabled and request permission
  Future<void> _checkLocationPermission() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _getCurrentLocation();
    _startLocationTracking();
  }

  // Get the current location
  Future<void> _getCurrentLocation() async {
    try {
      final locationData = await _location.getLocation();

      setState(() {
        _currentLocation = locationData;
      });

      // Update visualization when location changes
      final mapProvider = Provider.of<MapProvider>(context, listen: false);
      if (mapProvider.activeRoute != null && _isTracking) {
        _updateMapVisualization(mapProvider);
      } else {
        _animateToCurrentLocation();
      }

      // If we're tracking, update the location on the server
      if (_isTracking && _activeSchedule != null) {
        _updateDriverLocationOnServer();
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  // Update driver location on the server
  Future<void> _updateDriverLocationOnServer() async {
    if (_currentLocation == null || _activeSchedule == null) return;

    try {
      final mapProvider = Provider.of<MapProvider>(context, listen: false);
      final success = await mapProvider.updateDriverLocationOnServer(
          _activeSchedule!.id, _currentLocation!);

      if (!success && mounted) {
        // Only log failures, no need to show UI errors for location updates
        print('Failed to update driver location on server');
      }
    } catch (e) {
      print('Error updating driver location on server: $e');
    }
  }

  // Animate camera to current location
  Future<void> _animateToCurrentLocation() async {
    if (_currentLocation != null && _controller.isCompleted) {
      final controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            _currentLocation!.latitude!,
            _currentLocation!.longitude!,
          ),
          16, // Zoom level
        ),
      );
    }
  }

  // Start periodic location tracking
  void _startLocationTracking() {
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _getCurrentLocation();
    });
  }

  // Move to the next stop
  Future<void> _moveToNextStop() async {
    if (_activeSchedule == null ||
        _currentStopIndex >= _activeSchedule!.stopTimes.length - 1) {
      return;
    }

    // Get the mapProvider once to avoid multiple lookups
    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    // Check if current location is close to the next stop
    if (mapProvider.activeRoute != null &&
        _currentStopIndex < mapProvider.activeRoute!.stops.length &&
        _currentLocation != null) {
      final nextStop = mapProvider.activeRoute!.stops[_currentStopIndex];
      final currentLatLng = LatLng(
        _currentLocation!.latitude!,
        _currentLocation!.longitude!,
      );

      final distanceToStop = RouteVisualizer.calculateDistance(
        currentLatLng,
        nextStop.location,
      );

      // If driver is not close enough to the stop, show a warning
      if (distanceToStop > 0.0001) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Not at stop location'),
            content: Text(
                'You appear to be far from the next stop. Are you sure you want to mark it as visited?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Confirm'),
              ),
            ],
          ),
        );

        if (confirm != true) return;
      }
    }

    // Check if widget is still mounted before updating state
    if (!mounted) return;

    setState(() {
      _currentStopIndex++;
    });

    // Update the visualization but check mounting state again
    if (!mounted) return;
    _updateMapVisualization(mapProvider);

    // Get stop name before showing the snackbar
    if (_activeSchedule!.stopTimes.isNotEmpty && _currentStopIndex > 0) {
      final stopName =
          _activeSchedule!.stopTimes[_currentStopIndex - 1].stopName;

      // Show a confirmation message if still mounted
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Arrived at $stopName')),
      );
    }

    // Check if this was the last stop
    if (_currentStopIndex >= _activeSchedule!.stopTimes.length) {
      // Ask driver if they want to complete the route
      final completeNow = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Last Stop Reached'),
          content:
              Text('You have reached the last stop. Complete the route now?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Not Yet'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Complete Route'),
            ),
          ],
        ),
      );

      if (completeNow == true) {
        _completeRoute();
      }
    }
  }

  // Complete the route
  void _completeRoute() async {
    if (_activeSchedule == null) return;

    final scheduleProvider =
        Provider.of<ScheduleProvider>(context, listen: false);
    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    // Update the schedule status
    final success = await scheduleProvider.updateScheduleStatus(
        _activeSchedule!.id, 'completed');

    if (success) {
      // Stop tracking
      mapProvider.stopTracking();

      setState(() {
        _isTracking = false;
        _activeSchedule = null;
        _currentStopIndex = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Route completed successfully')),
      );

      // Navigate back to schedules screen
      Navigator.of(context).pushReplacementNamed(
        '/driver/home',
        arguments: {'selectedTab': 'schedules'},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(scheduleProvider.error ?? 'Failed to complete route')),
      );
    }
  }

  // Start a new route with a schedule
  Future<void> _startNewRoute(Schedule schedule) async {
    if (schedule.id.isEmpty || schedule.routeId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid schedule selected')),
      );
      return;
    }

    // Update schedule status
    final scheduleProvider =
        Provider.of<ScheduleProvider>(context, listen: false);
    final success =
        await scheduleProvider.updateScheduleStatus(schedule.id, 'in-progress');

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update schedule status')),
      );
      return;
    }

    // Load route data
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    final routeLoaded = await mapProvider.loadRouteMapData(schedule.routeId);

    if (!routeLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load route data')),
      );
      return;
    }

    // Start tracking
    await mapProvider.startTracking(schedule.routeId);

    setState(() {
      _activeSchedule = schedule;
      _isTracking = true;
      _currentStopIndex = 0;
      _showSchedulePanel = true;
    });

    // Update the visualization
    _updateMapVisualization(mapProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Journey started: ${schedule.routeName}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, child) {
        return Scaffold(
          body: Stack(
            children: [
              // Google Map widget
              GoogleMap(
                initialCameraPosition: _defaultLocation,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                compassEnabled: true,
                mapToolbarEnabled: false,
                zoomControlsEnabled: false,
                markers: mapProvider.markers,
                polylines:
                    mapProvider.showRoutePath ? mapProvider.routePolylines : {},
                onMapCreated: (GoogleMapController controller) {
                  if (!_controller.isCompleted) {
                    _controller.complete(controller);
                  }
                },
              ),

              // Map control buttons
              Positioned(
                right: 16,
                bottom: 200, // Position above the info panel
                child: Column(
                  children: [
                    _buildMapButton(
                      Icons.my_location,
                      'My Location',
                      _animateToCurrentLocation,
                    ),
                    const SizedBox(height: 8),
                    _buildMapButton(
                      Icons.fullscreen,
                      'Show Full Route',
                      () => _animateToRouteBounds(mapProvider),
                    ),
                  ],
                ),
              ),

              // Route info panel at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildRouteInfoPanel(mapProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapButton(
      IconData icon, String tooltip, VoidCallback onPressed) {
    return FloatingActionButton.small(
      heroTag: tooltip, // Unique hero tag to prevent navigation conflicts
      onPressed: onPressed,
      backgroundColor: Colors.white,
      child: Icon(icon, color: AppColors.primary),
      tooltip: tooltip,
    );
  }

  // Add this method to your map screen to display route info panel

  Widget _buildRouteInfoPanel(MapProvider mapProvider) {
    if (mapProvider.activeRoute == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'No route selected',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a route from the routes screen to view it on the map.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(
                  '/driver/home',
                  arguments: {'selectedTab': 'routes'},
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Go to Routes'),
            ),
          ],
        ),
      );
    }

    final routeName = mapProvider.activeRoute!.routeName;
    final stopCount = mapProvider.activeRoute!.stops.length;
    final isScheduleActive = mapProvider.selectedSchedule != null &&
        mapProvider.selectedSchedule!.status == 'in-progress';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  routeName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Toggle route path visibility
              IconButton(
                icon: Icon(
                  mapProvider.showRoutePath
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: AppColors.primary,
                ),
                onPressed: () {
                  mapProvider.toggleRoutePath();
                },
                tooltip: mapProvider.showRoutePath
                    ? 'Hide route path'
                    : 'Show route path',
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Route stats
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.location_on,
                  label: 'Stops',
                  value: stopCount.toString(),
                ),
                _buildStatItem(
                  icon: Icons.straighten,
                  label: 'Distance',
                  value:
                      '${mapProvider.activeRoute!.path.isEmpty ? "N/A" : (mapProvider.activeRoute!.path.length * 0.01).toStringAsFixed(1)} km',
                ),
                _buildStatItem(
                  icon: Icons.access_time,
                  label: 'Est. Duration',
                  value: mapProvider.selectedSchedule != null
                      ? '${mapProvider.selectedSchedule!.formattedStartTime} - ${mapProvider.selectedSchedule!.formattedEndTime}'
                      : 'N/A',
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Active schedule info
          if (isScheduleActive)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_bus, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Route in progress',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          'Schedule: ${mapProvider.selectedSchedule!.formattedStartTime} - ${mapProvider.selectedSchedule!.formattedEndTime}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Use the renamed method to handle route completion
                      _handleRouteCompletion();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Complete'),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // Show next stops if we have an active schedule
          if (isScheduleActive &&
              mapProvider.selectedSchedule!.stopTimes.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upcoming Stops',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: mapProvider.selectedSchedule!.stopTimes.length,
                    itemBuilder: (context, index) {
                      final stopTime =
                          mapProvider.selectedSchedule!.stopTimes[index];
                      final isPast = _isPastStop(stopTime);
                      final isCurrent = _isCurrentStop(stopTime);

                      return Container(
                        width: 150,
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isPast
                              ? Colors.grey.shade100
                              : isCurrent
                                  ? Colors.green.shade50
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isPast
                                ? Colors.grey.shade300
                                : isCurrent
                                    ? Colors.green
                                    : Colors.grey.shade200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stopTime.stopName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isPast
                                    ? Colors.grey
                                    : isCurrent
                                        ? Colors.green
                                        : Colors.black,
                                decoration:
                                    isPast ? TextDecoration.lineThrough : null,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Arrival: ${_formatTime(stopTime.arrivalTime)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isPast
                                    ? Colors.grey
                                    : isCurrent
                                        ? Colors.green.shade700
                                        : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (isPast)
                              const Text(
                                'Passed',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              )
                            else if (isCurrent)
                              const Text(
                                'Current Stop',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              )
                            else
                              Text(
                                'Upcoming',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
        ],
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
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Helper method to format time
  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Helper method to check if a stop is current
  bool _isCurrentStop(StopTime stopTime) {
    final now = DateTime.now();
    final isToday = now.day == stopTime.arrivalTime.day &&
        now.month == stopTime.arrivalTime.month &&
        now.year == stopTime.arrivalTime.year;

    if (!isToday) return false;

    // Check if current time is within 15 minutes of the stop time
    final diff = now.difference(stopTime.arrivalTime).inMinutes;
    return diff >= -15 && diff <= 15;
  }

  // Helper method to check if a stop is in the past
  bool _isPastStop(StopTime stopTime) {
    final now = DateTime.now();
    return now.isAfter(stopTime.arrivalTime.add(const Duration(minutes: 15)));
  }

  // Helper method to handle route completion from the UI
  void _handleRouteCompletion() async {
    if (_activeSchedule == null) return;

    final scheduleProvider =
        Provider.of<ScheduleProvider>(context, listen: false);
    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    // Update the schedule status
    final success = await scheduleProvider.updateScheduleStatus(
        _activeSchedule!.id, 'completed');

    if (success) {
      // Stop tracking
      mapProvider.stopTracking();
      mapProvider.clearSelectedSchedule();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Route completed successfully')),
      );

      // Navigate back to schedules screen
      Navigator.of(context).pushReplacementNamed(
        '/driver/home',
        arguments: {'selectedTab': 'schedules'},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(scheduleProvider.error ?? 'Failed to complete route')),
      );
    }
  }
}
