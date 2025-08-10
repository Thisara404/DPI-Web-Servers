import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme.dart';
import '../providers/journey_provider.dart';
import '../services/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoading = true;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(6.9271, 79.8612), // Colombo, Sri Lanka
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() async {
    await _getCurrentLocation();
    await _loadMapData();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _loadMapData() async {
    final journeyProvider =
        Provider.of<JourneyProvider>(context, listen: false);
    await journeyProvider.loadLiveBusLocations();
    _updateMarkers();
  }

  void _updateMarkers() {
    final journeyProvider =
        Provider.of<JourneyProvider>(context, listen: false);
    final Set<Marker> markers = {};

    // Add live bus markers
    for (final busLocation in journeyProvider.liveBusLocations) {
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

    // Add bus stops (example data)
    final busStops = [
      {'name': 'Colombo Fort', 'lat': 6.9344, 'lng': 79.8511},
      {'name': 'Pettah', 'lat': 6.9395, 'lng': 79.8578},
      {'name': 'Maradana', 'lat': 6.9292, 'lng': 79.8606},
      {'name': 'Dematagoda', 'lat': 6.9155, 'lng': 79.8731},
    ];

    for (int i = 0; i < busStops.length; i++) {
      final stop = busStops[i];
      markers.add(
        Marker(
          markerId: MarkerId('stop_$i'),
          position: LatLng(stop['lat'] as double, stop['lng'] as double),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: stop['name'] as String,
            snippet: 'Bus Stop',
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Map'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMapData,
          ),
        ],
      ),
      body: Consumer<JourneyProvider>(
        builder: (context, provider, child) {
          if (_isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.accentColor),
            );
          }

          return Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _initialPosition,
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                  _getCurrentLocation();
                },
                markers: _markers,
                polylines: _polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: true,
                trafficEnabled: false,
              ),
              _buildMapOverlay(),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "zoom_in",
            mini: true,
            backgroundColor: AppTheme.cardColor,
            onPressed: () {
              _mapController?.animateCamera(CameraUpdate.zoomIn());
            },
            child: const Icon(Icons.zoom_in, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "zoom_out",
            mini: true,
            backgroundColor: AppTheme.cardColor,
            onPressed: () {
              _mapController?.animateCamera(CameraUpdate.zoomOut());
            },
            child: const Icon(Icons.zoom_out, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "my_location",
            backgroundColor: AppTheme.accentColor,
            onPressed: _getCurrentLocation,
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMapOverlay() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Card(
        color: AppTheme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  _buildLegendItem(
                    color: Colors.blue,
                    label: 'Live Buses',
                    count: Provider.of<JourneyProvider>(context)
                        .liveBusLocations
                        .length,
                  ),
                  const SizedBox(width: 16),
                  _buildLegendItem(
                    color: Colors.green,
                    label: 'Bus Stops',
                    count: 4, // Example count
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required int count,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($count)',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
