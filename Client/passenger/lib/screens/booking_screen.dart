import 'package:flutter/material.dart';
import 'package:passenger/models/schedule.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/schedule_provider.dart';
import '../models/booking.dart';

class BookingScreen extends StatefulWidget {
  final String? scheduleId;

  const BookingScreen({super.key, this.scheduleId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  String _selectedPaymentMethod = 'online';
  List<Passenger> _passengers = [];

  @override
  void initState() {
    super.initState();
    if (widget.scheduleId != null) {
      _loadScheduleDetails();
    }
  }

  void _loadScheduleDetails() async {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    await provider.getScheduleDetails(widget.scheduleId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Book Your Journey'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Consumer<ScheduleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.accentColor),
            );
          }

          final schedule = provider.selectedSchedule;
          if (schedule == null) {
            return const Center(
              child: Text('Schedule not found',
                  style: TextStyle(color: Colors.white)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScheduleCard(schedule),
                  const SizedBox(height: 20),
                  _buildPassengerDetailsSection(),
                  const SizedBox(height: 20),
                  _buildPaymentSection(),
                  const SizedBox(height: 30),
                  _buildBookButton(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleCard(Schedule schedule) {
    return Card(
      color: AppTheme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              schedule.routeName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: AppTheme.accentColor, size: 16),
                const SizedBox(width: 4),
                Text('${schedule.from} → ${schedule.to}',
                    style: const TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, color: AppTheme.accentColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${_formatTime(schedule.departureTime)} - ${_formatTime(schedule.arrivalTime)}',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Price: LKR ${schedule.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentColor,
                  ),
                ),
                Text(
                  '${schedule.availableSeats} seats available',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerDetailsSection() {
    return Card(
      color: AppTheme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Passenger Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: const TextStyle(color: AppTheme.textSecondary),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.accentColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.accentColor),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: const TextStyle(color: AppTheme.textSecondary),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.accentColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.accentColor),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email (Optional)',
                labelStyle: const TextStyle(color: AppTheme.textSecondary),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.accentColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.accentColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Card(
      color: AppTheme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ...['online', 'cash'].map((method) => RadioListTile<String>(
                  value: method,
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                  },
                  title: Text(
                    method == 'online' ? 'Pay Online' : 'Pay in Bus',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    method == 'online'
                        ? 'Pay now using card/digital wallet'
                        : 'Pay cash to conductor',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  activeColor: AppTheme.accentColor,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildBookButton(ScheduleProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: provider.isBookingLoading ? null : _handleBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: provider.isBookingLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Book Journey',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  void _handleBooking() async {
    if (!_formKey.currentState!.validate()) return;

    final passenger = Passenger(
      firstName: _nameController.text.split(' ').first,
      lastName: _nameController.text.split(' ').skip(1).join(' '),
      phone: _phoneController.text, age: 0,
    );

    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    final success = await provider.createBooking(
      scheduleId: widget.scheduleId!,
      passengers: [passenger],
    );

    if (success && mounted) {
      // Navigate to payment or success screen
      _showBookingSuccess();
    } else if (mounted) {
      _showError(provider.error ?? 'Booking failed');
    }
  }

  void _showBookingSuccess() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Booking Successful!',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Your booking has been confirmed. You will receive a ticket shortly.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/tickets');
            },
            child: Text('View Tickets',
                style: TextStyle(color: AppTheme.accentColor)),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
