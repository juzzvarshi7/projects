import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/appointment_provider.dart';
import '../../../core/models/user_model.dart';
import 'staff_dashboard.dart';
import 'principal_dashboard.dart';
import '../appointments/appointments_screen.dart';
import '../calendar/calendar_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      await appointmentProvider.loadAppointments(
        authProvider.currentUser!.id,
        authProvider.currentUser!.role,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.currentUser == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = authProvider.currentUser!;
        final isStaff = user.role == UserRole.staff;

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: [
              // Dashboard
              isStaff ? const StaffDashboard() : const PrincipalDashboard(),
              
              // Appointments
              const AppointmentsScreen(),
              
              // Calendar
              const CalendarScreen(),
              
              // Profile
              const ProfileScreen(),
            ],
          ),
          bottomNavigationBar: _buildBottomNavigationBar(isStaff),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(bool isStaff) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 8,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard_outlined),
          activeIcon: const Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.event_note_outlined),
          activeIcon: const Icon(Icons.event_note),
          label: 'Appointments',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.calendar_today_outlined),
          activeIcon: const Icon(Icons.calendar_today),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outlined),
          activeIcon: const Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}