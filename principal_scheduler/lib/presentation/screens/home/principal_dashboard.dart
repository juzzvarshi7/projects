import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/appointment_provider.dart';
import '../../../core/models/appointment_model.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/appointment_card.dart';
import '../../widgets/quick_stats.dart';

class PrincipalDashboard extends StatelessWidget {
  const PrincipalDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Consumer2<AuthProvider, AppointmentProvider>(
          builder: (context, authProvider, appointmentProvider, child) {
            final user = authProvider.currentUser!;
            final appointments = appointmentProvider.appointments;
            
            return RefreshIndicator(
              onRefresh: () => appointmentProvider.loadAppointments(user.id, user.role),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(context, user.firstName),
                    
                    const SizedBox(height: 24),
                    
                    // Quick Stats
                    _buildQuickStats(appointments),
                    
                    const SizedBox(height: 24),
                    
                    // Quick Actions
                    _buildQuickActions(context),
                    
                    const SizedBox(height: 24),
                    
                    // Pending Requests
                    _buildPendingRequests(context, appointments),
                    
                    const SizedBox(height: 24),
                    
                    // Today's Appointments
                    _buildTodaysAppointments(context, appointments),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String firstName) {
    final hour = DateTime.now().hour;
    String greeting = 'Good morning';
    if (hour >= 12 && hour < 17) {
      greeting = 'Good afternoon';
    } else if (hour >= 17) {
      greeting = 'Good evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, Principal $firstName!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Review and manage appointment requests',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(List<AppointmentModel> appointments) {
    final pending = appointments.where((apt) => apt.isPending).length;
    final today = appointments.where((apt) {
      final now = DateTime.now();
      final appointmentDate = apt.scheduledDateTime;
      return appointmentDate.year == now.year &&
             appointmentDate.month == now.month &&
             appointmentDate.day == now.day &&
             apt.isAccepted;
    }).length;
    final thisWeek = appointments.where((apt) {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 7));
      return apt.scheduledDateTime.isAfter(weekStart) && 
             apt.scheduledDateTime.isBefore(weekEnd) &&
             apt.isAccepted;
    }).length;

    return QuickStats(
      stats: [
        StatItem(
          title: 'Pending',
          value: pending.toString(),
          icon: Icons.pending_actions,
          color: Colors.orange,
        ),
        StatItem(
          title: 'Today',
          value: today.toString(),
          icon: Icons.today,
          color: Colors.green,
        ),
        StatItem(
          title: 'This Week',
          value: thisWeek.toString(),
          icon: Icons.calendar_week,
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DashboardCard(
                title: 'Review Requests',
                subtitle: 'Pending appointments',
                icon: Icons.rate_review,
                color: Colors.orange,
                onTap: () {
                  // Navigate to pending appointments
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardCard(
                title: 'View Schedule',
                subtitle: 'Today\'s calendar',
                icon: Icons.schedule,
                color: Theme.of(context).colorScheme.secondary,
                onTap: () {
                  // Navigate to calendar
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPendingRequests(BuildContext context, List<AppointmentModel> appointments) {
    final pendingAppointments = appointments.where((apt) => apt.isPending).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pending Requests',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (pendingAppointments.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${pendingAppointments.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (pendingAppointments.isEmpty)
          _buildEmptyState(context, 'No pending requests')
        else
          ...pendingAppointments.take(3).map((appointment) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppointmentCard(
              appointment: appointment,
              showActions: true,
            ),
          )),
      ],
    );
  }

  Widget _buildTodaysAppointments(BuildContext context, List<AppointmentModel> appointments) {
    final today = DateTime.now();
    final todaysAppointments = appointments.where((apt) {
      final appointmentDate = apt.scheduledDateTime;
      return appointmentDate.year == today.year &&
             appointmentDate.month == today.month &&
             appointmentDate.day == today.day &&
             apt.isAccepted;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Appointments',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (todaysAppointments.isEmpty)
          _buildEmptyState(context, 'No appointments today')
        else
          ...todaysAppointments.map((appointment) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppointmentCard(appointment: appointment),
          )),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_available,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}