import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/schedule_provider.dart';
import '../models/schedule.dart';

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({super.key});

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  void _loadSchedules() {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    provider.loadSchedules();
    provider.loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Bus Schedules'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer<ScheduleProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildSearchBar(provider),
              _buildFilterChips(provider),
              Expanded(
                child: provider.isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.accentColor),
                      )
                    : _buildSchedulesList(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(ScheduleProvider provider) {
    return Container(
      color: AppTheme.primaryColor,
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search routes, locations...',
          hintStyle: const TextStyle(color: AppTheme.textSecondary),
          prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    provider.updateSearchQuery('');
                  },
                )
              : null,
          filled: true,
          fillColor: AppTheme.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) => provider.updateSearchQuery(value),
      ),
    );
  }

  Widget _buildFilterChips(ScheduleProvider provider) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (provider.fromFilter != null)
            _buildFilterChip(
              'From: ${provider.fromFilter}',
              () => provider.updateFromFilter(null),
            ),
          if (provider.toFilter != null)
            _buildFilterChip(
              'To: ${provider.toFilter}',
              () => provider.updateToFilter(null),
            ),
          if (provider.dateFilter != null)
            _buildFilterChip(
              'Date: ${_formatDate(provider.dateFilter!)}',
              () => provider.updateDateFilter(null),
            ),
          ActionChip(
            label: const Text('Add Filters'),
            onPressed: _showFilterDialog,
            backgroundColor: AppTheme.accentColor.withOpacity(0.2),
            labelStyle: TextStyle(color: AppTheme.accentColor),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        onDeleted: onDeleted,
        backgroundColor: AppTheme.accentColor.withOpacity(0.2),
        labelStyle: TextStyle(color: AppTheme.accentColor),
        deleteIconColor: AppTheme.accentColor,
      ),
    );
  }

  Widget _buildSchedulesList(ScheduleProvider provider) {
    final schedules = provider.schedules;

    if (provider.error != null) {
      return _buildErrorState(provider.error!, () => _loadSchedules());
    }

    if (schedules.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async => _loadSchedules(),
      color: AppTheme.accentColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final schedule = schedules[index];
          return _buildScheduleCard(schedule, provider);
        },
      ),
    );
  }

  Widget _buildScheduleCard(Schedule schedule, ScheduleProvider provider) {
    final isFavorite = provider.favorites.any((fav) => fav.id == schedule.id);

    return Card(
      color: AppTheme.cardColor,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showScheduleDetails(schedule),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : AppTheme.textSecondary,
                    ),
                    onPressed: () =>
                        _toggleFavorite(schedule, provider, isFavorite),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on,
                      color: AppTheme.accentColor, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${schedule.from} → ${schedule.to}',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time,
                      color: AppTheme.accentColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatTime(schedule.departureTime)} - ${_formatTime(schedule.arrivalTime)}',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  const Spacer(),
                  Text(
                    'Duration: ${schedule.journeyDuration.inHours}h ${schedule.journeyDuration.inMinutes % 60}m',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.directions_bus,
                      color: AppTheme.accentColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Bus: ${schedule.busNumber}',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  const Spacer(),
                  Text(
                    '${schedule.availableSeats}/${schedule.totalSeats} seats',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LKR ${schedule.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentColor,
                    ),
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => _showScheduleDetails(schedule),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.accentColor),
                        ),
                        child: const Text('Details'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: schedule.isAvailable
                            ? () => _bookSchedule(schedule)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                        ),
                        child: const Text('Book Now'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_bus_outlined,
            size: 64,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          const Text(
            'No schedules found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              final provider =
                  Provider.of<ScheduleProvider>(context, listen: false);
              provider.clearFilters();
              _loadSchedules();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
            ),
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Filter Schedules',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _fromController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'From Location',
                labelStyle: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            TextField(
              controller: _toController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'To Location',
                labelStyle: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                _selectedDate == null
                    ? 'Select Date'
                    : 'Date: ${_formatDate(_selectedDate!)}',
                style: const TextStyle(color: Colors.white),
              ),
              trailing:
                  Icon(Icons.calendar_today, color: AppTheme.accentColor),
              onTap: _selectDate,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _applyFilters,
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.accentColor,
              surface: AppTheme.cardColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _applyFilters() {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);

    if (_fromController.text.isNotEmpty) {
      provider.updateFromFilter(_fromController.text);
    }

    if (_toController.text.isNotEmpty) {
      provider.updateToFilter(_toController.text);
    }

    if (_selectedDate != null) {
      provider.updateDateFilter(_selectedDate);
    }

    Navigator.of(context).pop();
  }

  void _showScheduleDetails(Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(schedule.routeName,
            style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Route', '${schedule.from} → ${schedule.to}'),
              _buildDetailRow('Bus Number', schedule.busNumber),
              _buildDetailRow('Departure', _formatTime(schedule.departureTime)),
              _buildDetailRow('Arrival', _formatTime(schedule.arrivalTime)),
              _buildDetailRow('Duration',
                  '${schedule.journeyDuration.inHours}h ${schedule.journeyDuration.inMinutes % 60}m'),
              _buildDetailRow(
                  'Price', 'LKR ${schedule.price.toStringAsFixed(2)}'),
              _buildDetailRow('Available Seats',
                  '${schedule.availableSeats}/${schedule.totalSeats}'),
              if (schedule.driverName != null)
                _buildDetailRow('Driver', schedule.driverName!),
              if (schedule.driverPhone != null)
                _buildDetailRow('Driver Phone', schedule.driverPhone!),
              const SizedBox(height: 16),
              const Text(
                'Bus Stops:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...schedule.stops.map((stop) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '• ${stop.name}',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _bookSchedule(schedule);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
            ),
            child: const Text('Book Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(
      Schedule schedule, ScheduleProvider provider, bool isFavorite) async {
    if (isFavorite) {
      await provider.removeFromFavorites(schedule.routeId);
    } else {
      await provider.addToFavorites(schedule.routeId);
    }

    if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _bookSchedule(Schedule schedule) {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    provider.selectSchedule(schedule);
    Navigator.of(context)
        .pushNamed('/booking', arguments: {'scheduleId': schedule.id});
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }
}
