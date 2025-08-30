// lib/screens/statistics_screen.dart

import 'package:flutter/material.dart';
import '../services/driver_service.dart';
import '../models/statistics_model.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DriverStatistics? _stats;
  final DriverService _service = DriverService();

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      _stats = await _service.getStatistics();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_stats == null) return const Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Journeys: ${_stats!.totalJourneys}'),
          Text('Total Distance: ${_stats!.totalDistance} km'),
          Text('Average Speed: ${_stats!.averageSpeed} km/h'),
          Text('Rating: ${_stats!.rating ?? 'N/A'}'),
        ],
      ),
    );
  }
}