import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/models/appointment_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/appointment_provider.dart';
import '../../../core/providers/audio_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/audio_player_widget.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final AppointmentModel appointment;

  const AppointmentDetailScreen({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Appointment Details'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              if (appointment.isPending || appointment.isAccepted)
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
              if (appointment.isPending || appointment.isAccepted)
                const PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Cancel'),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Consumer3<AuthProvider, AppointmentProvider, AudioProvider>(
        builder: (context, authProvider, appointmentProvider, audioProvider, child) {
          final isStaff = authProvider.isStaff;
          final isPrincipal = authProvider.isPrincipal;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card
                _buildStatusCard(context),
                
                const SizedBox(height: 16),
                
                // Basic Information
                _buildBasicInfo(context),
                
                const SizedBox(height: 16),
                
                // Date and Time Information
                _buildDateTimeInfo(context),
                
                const SizedBox(height: 16),
                
                // Location (if available)
                if (appointment.location != null) ...[
                  _buildLocationInfo(context),
                  const SizedBox(height: 16),
                ],
                
                // Audio Message (if available)
                if (appointment.hasAudioMessage) ...[
                  _buildAudioSection(context, audioProvider),
                  const SizedBox(height: 16),
                ],
                
                // Rejection Reason (if rejected)
                if (appointment.isRejected && appointment.rejectionReason != null) ...[
                  _buildRejectionReason(context),
                  const SizedBox(height: 16),
                ],
                
                // Action Buttons
                if (isPrincipal && appointment.isPending) ...[
                  _buildPrincipalActions(context, appointmentProvider),
                  const SizedBox(height: 16),
                ],
                
                // Staff Actions
                if (isStaff && (appointment.isPending || appointment.isAccepted)) ...[
                  _buildStaffActions(context),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String statusText;

    switch (appointment.status) {
      case AppointmentStatus.pending:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange.shade700;
        icon = Icons.pending_actions;
        statusText = 'Pending Approval';
        break;
      case AppointmentStatus.accepted:
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green.shade700;
        icon = Icons.check_circle;
        statusText = 'Accepted';
        break;
      case AppointmentStatus.rejected:
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red.shade700;
        icon = Icons.cancel;
        statusText = 'Rejected';
        break;
      case AppointmentStatus.cancelled:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey.shade700;
        icon = Icons.event_busy;
        statusText = 'Cancelled';
        break;
      case AppointmentStatus.completed:
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue.shade700;
        icon = Icons.event_available;
        statusText = 'Completed';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Priority: ${appointment.priority.name.toUpperCase()}',
                  style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appointment Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Title
            _buildInfoRow(
              context,
              'Title',
              appointment.title,
              Icons.title,
            ),
            
            const SizedBox(height: 12),
            
            // Description
            _buildInfoRow(
              context,
              'Description',
              appointment.description,
              Icons.description,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Schedule',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Date
            _buildInfoRow(
              context,
              'Date',
              DateFormat('EEEE, MMMM dd, yyyy').format(appointment.scheduledDateTime),
              Icons.calendar_today,
            ),
            
            const SizedBox(height: 12),
            
            // Time
            _buildInfoRow(
              context,
              'Time',
              DateFormat('hh:mm a').format(appointment.scheduledDateTime),
              Icons.access_time,
            ),
            
            const SizedBox(height: 12),
            
            // Duration
            _buildInfoRow(
              context,
              'Duration',
              '${appointment.durationMinutes} minutes',
              Icons.timer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              'Meeting Location',
              appointment.location!,
              Icons.location_on,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioSection(BuildContext context, AudioProvider audioProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Audio Message',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            AudioPlayerWidget(
              audioUrl: appointment.audioMessageUrl!,
              audioId: appointment.audioMessageId!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectionReason(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rejection Reason',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                ),
              ),
              child: Text(
                appointment.rejectionReason!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrincipalActions(BuildContext context, AppointmentProvider appointmentProvider) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showRejectDialog(context, appointmentProvider),
            icon: const Icon(Icons.close),
            label: const Text('Reject'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _acceptAppointment(context, appointmentProvider),
            icon: const Icon(Icons.check),
            label: const Text('Accept'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStaffActions(BuildContext context) {
    return CustomButton(
      text: 'Cancel Appointment',
      onPressed: () => _showCancelDialog(context),
      backgroundColor: Theme.of(context).colorScheme.error,
      icon: Icons.cancel,
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        // Navigate to edit screen
        break;
      case 'cancel':
        _showCancelDialog(context);
        break;
    }
  }

  void _acceptAppointment(BuildContext context, AppointmentProvider appointmentProvider) async {
    final success = await appointmentProvider.acceptAppointment(appointment.id);
    
    if (success && context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment accepted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showRejectDialog(BuildContext context, AppointmentProvider appointmentProvider) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejecting this appointment:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.of(context).pop();
                final success = await appointmentProvider.rejectAppointment(
                  appointment.id,
                  reasonController.text.trim(),
                );
                
                if (success && context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Appointment rejected'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
              final success = await appointmentProvider.cancelAppointment(appointment.id);
              
              if (success && context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Appointment cancelled'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}