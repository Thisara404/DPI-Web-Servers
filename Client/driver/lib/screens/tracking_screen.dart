// lib/screens/tracking_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Change to Google Maps
import '../providers/tracking_provider.dart';
import '../providers/schedule_provider.dart';
import '../config/theme.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    final trackingProvider = Provider.of<TrackingProvider>(context);
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    // Fix: Use selectedSchedule instead of currentSchedule
    final selectedSchedule = scheduleProvider.selectedSchedule;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(
        children: [
          // Status Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppTheme.surfaceDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedSchedule != null
                      ? 'Route ${selectedSchedule.routeId}'
                      : 'No Active Route',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      trackingProvider.isTracking
                          ? Icons.gps_fixed
                          : Icons.gps_off,
                      color: trackingProvider.isTracking
                          ? AppTheme.successGreen
                          : AppTheme.errorRed,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tracking: ${trackingProvider.isTracking ? 'Active' : 'Inactive'}',
                      style: TextStyle(
                        color: trackingProvider.isTracking
                            ? AppTheme.successGreen
                            : AppTheme.errorRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Map View
          Expanded(
            child: trackingProvider.currentPosition != null
                ? GoogleMap(
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        trackingProvider.currentPosition!.latitude,
                        trackingProvider.currentPosition!.longitude,
                      ),
                      zoom: 15.0,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('current_location'),
                        position: LatLng(
                          trackingProvider.currentPosition!.latitude,
                          trackingProvider.currentPosition!.longitude,
                        ),
                        infoWindow: const InfoWindow(title: 'Your Location'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed),
                      ),
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Getting your location...'),
                      ],
                    ),
                  ),
          ),

          // Control Buttons
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surfaceDark,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        selectedSchedule != null && !trackingProvider.isTracking
                            ? () => trackingProvider.startTracking(
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
                    onPressed: trackingProvider.isTracking
                        ? trackingProvider.stopTracking
                        : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop Tracking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorRed,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
