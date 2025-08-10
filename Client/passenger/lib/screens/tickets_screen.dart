import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme.dart';
import '../providers/schedule_provider.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTickets();
  }

  void _loadTickets() {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    provider.loadTickets();
    provider.loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Tickets'),
        backgroundColor: AppTheme.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentColor,
          labelColor: AppTheme.accentColor,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'Active Tickets'),
            Tab(text: 'Past Tickets'),
          ],
        ),
      ),
      body: Consumer<ScheduleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accentColor),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildActiveTickets(provider),
              _buildPastTickets(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActiveTickets(ScheduleProvider provider) {
    final activeTickets = provider.tickets.where((ticket) => 
        ticket.status == TicketStatus.active && ticket.isValid).toList();

    if (activeTickets.isEmpty) {
      return _buildEmptyState('No active tickets', 'Book a journey to get started!');
    }

    return RefreshIndicator(
      onRefresh: () async => _loadTickets(),
      color: AppTheme.accentColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activeTickets.length,
        itemBuilder: (context, index) {
          final ticket = activeTickets[index];
          return _buildTicketCard(ticket, isActive: true);
        },
      ),
    );
  }

  Widget _buildPastTickets(ScheduleProvider provider) {
    final pastTickets = provider.tickets.where((ticket) => 
        ticket.status == TicketStatus.used || ticket.status == TicketStatus.expired).toList();

    if (pastTickets.isEmpty) {
      return _buildEmptyState('No past tickets', 'Your travel history will appear here');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pastTickets.length,
      itemBuilder: (context, index) {
        final ticket = pastTickets[index];
        return _buildTicketCard(ticket, isActive: false);
      },
    );
  }

  Widget _buildTicketCard(Ticket ticket, {required bool isActive}) {
    return Card(
      color: AppTheme.cardColor,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showTicketDetails(ticket),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ticket ID: ${ticket.id.substring(0, 8)}...',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bus Journey',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(ticket.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule, color: AppTheme.accentColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Valid: ${_formatDateTime(ticket.validFrom)} - ${_formatDateTime(ticket.validUntil)}',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
              if (isActive) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showQRCode(ticket),
                        icon: const Icon(Icons.qr_code, size: 20),
                        label: const Text('Show QR Code'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _shareTicket(ticket),
                      icon: const Icon(Icons.share, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TicketStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case TicketStatus.active:
        color = Colors.green;
        text = 'Active';
        break;
      case TicketStatus.used:
        color = Colors.blue;
        text = 'Used';
        break;
      case TicketStatus.expired:
        color = Colors.orange;
        text = 'Expired';
        break;
      case TicketStatus.cancelled:
        color = Colors.red;
        text = 'Cancelled';
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

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: 64,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed('/schedules'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
            ),
            child: const Text('Browse Schedules'),
          ),
        ],
      ),
    );
  }

  void _showQRCode(Ticket ticket) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Show this QR code to the conductor',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: QrImageView(
                  data: ticket.qrCode,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Ticket ID: ${ticket.id}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTicketDetails(Ticket ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Ticket Details', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Ticket ID', ticket.id),
            _buildDetailRow('Schedule ID', ticket.scheduleId),
            _buildDetailRow('Valid From', _formatDateTime(ticket.validFrom)),
            _buildDetailRow('Valid Until', _formatDateTime(ticket.validUntil)),
            _buildDetailRow('Status', ticket.status.toString().split('.').last),
            if (ticket.usedAt != null)
              _buildDetailRow('Used At', _formatDateTime(ticket.usedAt!)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
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
            width: 80,
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

  void _shareTicket(Ticket ticket) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}