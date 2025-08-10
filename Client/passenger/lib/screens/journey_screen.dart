import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme.dart';
import '../providers/journey_provider.dart';
import '../providers/auth_provider.dart';
import '../models/journey.dart';

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  GoogleMapController? _mapController;
  String? _selectedScheduleId;

  @override
  void initState() {
    super.initState();
    _initializeJourneyTracking();
  }

  void _initializeJourneyTracking() {
    final journeyProvider =
        Provider.of<JourneyProvider>(context, listen: false);
    journeyProvider.initializeSocket();
    journeyProvider.loadLiveBusLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Journey Tracking'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final provider =
                  Provider.of<JourneyProvider>(context, listen: false);
              provider.loadLiveBusLocations();
            },
          ),
        ],
      ),
      body: Consumer<JourneyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accentColor),
            );
          }

          return Column(
            children: [
              if (provider.activeJourney != null)
                _buildActiveJourneyCard(provider.activeJourney!),
              _buildTrackingControls(provider),
              Expanded(
                child: _buildMapView(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActiveJourneyCard(Journey journey) {
    return Card(
      color: AppTheme.cardColor,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active Journey',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildJourneyStatusBadge(journey.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, color: AppTheme.accentColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Started: ${_formatTime(journey.startTime)}',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
            if (journey.estimatedTimeToArrival != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.timer, color: AppTheme.accentColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'ETA: ${_formatDuration(journey.estimatedTimeToArrival!)}',
                    style: const TextStyle(color: AppTheme.accentColor),
                  ),
                ],
              ),
            ],
            if (journey.nextStop != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on,
                      color: AppTheme.accentColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Next Stop: ${journey.nextStop!.name}',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: _calculateJourneyProgress(journey),
              backgroundColor: AppTheme.textSecondary.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyStatusBadge(JourneyStatus status) {
    Color color;
    String text;

    switch (status) {
      case JourneyStatus.scheduled:
        color = Colors.blue;
        text = 'Scheduled';
        break;
      case JourneyStatus.boarding:
        color = Colors.orange;
        text = 'Boarding';
        break;
      case JourneyStatus.inTransit:
        color = Colors.green;
        text = 'In Transit';
        break;
      case JourneyStatus.completed:
        color = Colors.grey;
        text = 'Completed';
        break;
      case JourneyStatus.cancelled:
        color = Colors.red;
        text = 'Cancelled';
        break;
      case JourneyStatus.delayed:
        color = Colors.red;
        text = 'Delayed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildTrackingControls(JourneyProvider provider) {
    return Container(
      color: AppTheme.primaryColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (provider.activeJourney == null) ...[
            const Text(
              'Track a bus by entering the schedule ID',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter Schedule ID',
                      hintStyle: const TextStyle(color: AppTheme.textSecondary),
                      filled: true,
                      fillColor: AppTheme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => _selectedScheduleId = value,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _selectedScheduleId?.isNotEmpty == true
                      ? () => _startTracking(provider)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                  ),
                  child: const Text('Track'),
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _stopTracking(provider),
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop Tracking'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _refreshTracking(provider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                provider.isSocketConnected ? Icons.wifi : Icons.wifi_off,
                color: provider.isSocketConnected ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                provider.isSocketConnected ? 'Connected' : 'Disconnected',
                style: TextStyle(
                  color: provider.isSocketConnected ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapView(JourneyProvider provider) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: const CameraPosition(
        target: LatLng(6.9271, 79.8612), // Colombo, Sri Lanka
        zoom: 12,
      ),
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
      markers: _buildMapMarkers(provider),
      polylines: _buildRoutePolylines(provider),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      compassEnabled: true,
      trafficEnabled: false,
    );
  }

  Set<Marker> _buildMapMarkers(JourneyProvider provider) {
    final markers = <Marker>{};

    // Add live bus locations
    for (final busLocation in provider.liveBusLocations) {
      markers.add(
        Marker(
          markerId: MarkerId('bus_${busLocation.scheduleId}'),
          position: LatLng(busLocation.latitude, busLocation.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: 'Bus',
            snippet:
                'Speed: ${busLocation.speed?.toStringAsFixed(1) ?? 'N/A'} km/h',
          ),
        ),
      );
    }

    // Add bus stops for active journey
    if (provider.activeJourney != null) {
      final journey = provider.activeJourney!;

      // Add completed stops
      for (int i = 0; i < journey.completedStops.length; i++) {
        final stop = journey.completedStops[i];
        markers.add(
          Marker(
            markerId: MarkerId('stop_completed_$i'),
            position: LatLng(stop.latitude, stop.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              title: stop.name,
              snippet: 'Completed',
            ),
          ),
        );
      }

      // Add next stop
      if (journey.nextStop != null) {
        markers.add(
          Marker(
            markerId: const MarkerId('next_stop'),
            position:
                LatLng(journey.nextStop!.latitude, journey.nextStop!.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange),
            infoWindow: InfoWindow(
              title: journey.nextStop!.name,
              snippet: 'Next Stop',
            ),
          ),
        );
      }

      // Add current bus location
      if (journey.currentLocation != null) {
        markers.add(
          Marker(
            markerId: const MarkerId('current_bus'),
            position: LatLng(
              journey.currentLocation!.latitude,
              journey.currentLocation!.longitude,
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: const InfoWindow(
              title: 'Your Bus',
              snippet: 'Current Location',
            ),
          ),
        );
      }
    }

    return markers;
  }

  Set<Polyline> _buildRoutePolylines(JourneyProvider provider) {
    final polylines = <Polyline>{};

    if (provider.activeJourney != null) {
      // You can add route polylines here if you have route path data
      // This would typically come from the backend or Google Directions API
    }

    return polylines;
  }

  void _startTracking(JourneyProvider provider) async {
    if (_selectedScheduleId == null || _selectedScheduleId!.isEmpty) return;

    final success = await provider.subscribeToTracking(_selectedScheduleId!);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Started tracking bus'),
          backgroundColor: Colors.green,
        ),
      );

      // Zoom to bus location if available
      final journey = provider.activeJourney;
      if (journey?.currentLocation != null && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(
              journey!.currentLocation!.latitude,
              journey.currentLocation!.longitude,
            ),
            15,
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to start tracking'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _stopTracking(JourneyProvider provider) {
    if (provider.activeJourney != null) {
      provider.unsubscribeFromTracking(provider.activeJourney!.scheduleId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stopped tracking bus'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _refreshTracking(JourneyProvider provider) {
    if (provider.activeJourney != null) {
      provider.getTrackingStatus(provider.activeJourney!.scheduleId);
      provider.loadLiveBusLocations();
    }
  }

  double _calculateJourneyProgress(Journey journey) {
    final totalStops =
        journey.completedStops.length + (journey.nextStop != null ? 1 : 0);

    if (totalStops == 0) return 0.0;

    return journey.completedStops.length / totalStops;
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  @override
  void dispose() {
    final provider = Provider.of<JourneyProvider>(context, listen: false);
    provider.disconnectSocket();
    super.dispose();
  }
}
