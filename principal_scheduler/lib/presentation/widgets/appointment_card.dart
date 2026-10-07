import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/models/appointment_model.dart';
import '../../core/providers/appointment_provider.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final bool showActions;
  final VoidCallback? onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.showActions = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(context),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Date and Time
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(appointment.scheduledDateTime),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              // Duration
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${appointment.durationMinutes} minutes',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              
              // Location (if available)
              if (appointment.location != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      appointment.location!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
              
              // Audio message indicator
              if (appointment.hasAudioMessage) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.audiotrack,
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Audio message attached',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Actions for principal
              if (showActions && appointment.isPending) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showRejectDialog(context),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _acceptAppointment(context),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
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

  Widget _buildStatusChip(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (appointment.status) {
      case AppointmentStatus.pending:
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange.shade700;
        statusText = 'Pending';
        break;
      case AppointmentStatus.accepted:
        backgroundColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green.shade700;
        statusText = 'Accepted';
        break;
      case AppointmentStatus.rejected:
        backgroundColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red.shade700;
        statusText = 'Rejected';
        break;
      case AppointmentStatus.cancelled:
        backgroundColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey.shade700;
        statusText = 'Cancelled';
        break;
      case AppointmentStatus.completed:
        backgroundColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue.shade700;
        statusText = 'Completed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _acceptAppointment(BuildContext context) async {
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    
    final success = await appointmentProvider.acceptAppointment(appointment.id);
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment accepted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showRejectDialog(BuildContext context) {
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
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                _rejectAppointment(context, reasonController.text.trim());
                Navigator.of(context).pop();
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

  void _rejectAppointment(BuildContext context, String reason) async {
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    
    final success = await appointmentProvider.rejectAppointment(appointment.id, reason);
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment rejected'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}