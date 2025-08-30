import 'dart:async';
import 'package:bus_driver_app/screens/home/schedule_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/journey_provider.dart';
import '../../providers/location_provider.dart';
import '../../models/schedule_model.dart';

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  GoogleMapController? _mapController;
  Timer? _locationUpdateTimer;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    // Delay until first frame to access providers safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only attempt auto-start if a schedule is already selected
      final scheduleProvider =
          Provider.of<ScheduleProvider>(context, listen: false);
      if (scheduleProvider.selectedSchedule != null) {
        _startLocationTracking();
      }
    });
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    try {
      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);
      final scheduleProvider =
          Provider.of<ScheduleProvider>(context, listen: false);

      final selectedSchedule = scheduleProvider.selectedSchedule;
      if (selectedSchedule != null) {
        await locationProvider.startTracking(
            selectedSchedule.id, selectedSchedule.journeyId ?? '');
        print(
            '✅ Location tracking started for schedule: ${selectedSchedule.id}');
      } else {
        print('❌ No selected schedule for tracking');
        // FIX: Show user-friendly message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a schedule first')),
          );
        }
      }
    } catch (e) {
      print('❌ Failed to start location tracking: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to start location tracking: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _endJourney() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Journey'),
        content: const Text('Are you sure you want to end this journey?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
            child: const Text('End Journey'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
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
              Text('Ending journey...'),
            ],
          ),
        ),
      );

      try {
        final journeyProvider =
            Provider.of<JourneyProvider>(context, listen: false);
        final locationProvider =
            Provider.of<LocationProvider>(context, listen: false);
        final scheduleProvider =
            Provider.of<ScheduleProvider>(context, listen: false);

        final selectedSchedule = scheduleProvider.selectedSchedule;
        if (selectedSchedule != null) {
          await locationProvider.stopTracking(selectedSchedule.id);
        }

        final success = await journeyProvider.endJourney();

        // Close loading dialog
        if (mounted) Navigator.pop(context);

        if (success && mounted) {
          scheduleProvider.clearSelectedSchedule();
          Navigator.pop(context);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(journeyProvider.error ?? 'Failed to end journey'),
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
              content: Text('Error ending journey: ${e.toString()}'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer3<ScheduleProvider, JourneyProvider, LocationProvider>(
        builder: (context, scheduleProvider, journeyProvider, locationProvider,
            child) {
          final selectedSchedule = scheduleProvider.selectedSchedule;
          final currentPosition = locationProvider.currentPosition;
          final locationError = locationProvider.error;

          print(
              '🔍 Journey Screen - Current Position: $currentPosition, Error: $locationError');

          return Column(
            children: [
              // Journey Info Card
              if (selectedSchedule != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: AppTheme.surfaceDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedSchedule.routeName != null &&
                                selectedSchedule.routeName!.isNotEmpty
                            ? selectedSchedule.routeName!
                            : (selectedSchedule.routeId.isNotEmpty
                                ? 'Route ${selectedSchedule.routeId}'
                                : 'Route'),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              color: AppTheme.successGreen, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${_getStartLocation(selectedSchedule)} → ${_getEndLocation(selectedSchedule)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else
                // No selected schedule -> show friendly prompt instead of spinner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: AppTheme.surfaceDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'No schedule selected',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please select a schedule from the Schedules tab before starting a journey.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to schedules screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ScheduleSelectionScreen(),
                            ),
                          );
                        },
                        child: const Text('View Schedules'),
                      ),
                    ],
                  ),
                ),

              // Map View with improved handling
              Expanded(
                child: selectedSchedule == null
                    ? const SizedBox.shrink()
                    : locationError != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 64, color: AppTheme.errorRed),
                                const SizedBox(height: 16),
                                Text(
                                  locationError,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () => _startLocationTracking(),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : currentPosition != null
                            ? GoogleMap(
                                onMapCreated: (controller) {
                                  _mapController = controller;
                                  setState(() => _mapReady = true);
                                  _mapController?.animateCamera(
                                    CameraUpdate.newLatLngZoom(
                                      LatLng(currentPosition.latitude,
                                          currentPosition.longitude),
                                      16,
                                    ),
                                  );
                                },
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(currentPosition.latitude,
                                      currentPosition.longitude),
                                  zoom: 16,
                                ),
                                markers: {
                                  Marker(
                                    markerId:
                                        const MarkerId('current_location'),
                                    position: LatLng(currentPosition.latitude,
                                        currentPosition.longitude),
                                    infoWindow: const InfoWindow(
                                        title: 'Your Location'),
                                    icon: BitmapDescriptor.defaultMarkerWithHue(
                                        BitmapDescriptor.hueGreen),
                                  ),
                                },
                                myLocationEnabled: true,
                                myLocationButtonEnabled: true,
                                mapType: MapType.normal,
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                    Text('Getting your location...'),
                                  ],
                                ),
                              ),
              ),

              // Bottom Controls
              Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.surfaceDark,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: (selectedSchedule != null &&
                                    !locationProvider.isTracking)
                                ? () => locationProvider.startTracking(
                                    selectedSchedule.id,
                                    selectedSchedule.journeyId ?? '')
                                : null,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start Tracking'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.successGreen,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _endJourney,
                            icon: const Icon(Icons.stop),
                            label: const Text('End Journey'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.errorRed,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (locationProvider.error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        locationProvider.error!,
                        style: const TextStyle(color: AppTheme.errorRed),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
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
}
