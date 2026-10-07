import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/appointment_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/appointment_model.dart';
import '../../widgets/appointment_card.dart';
import 'create_appointment_screen.dart';
import 'appointment_detail_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Appointments'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
            Tab(text: 'Completed'),
          ],
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: Theme.of(context).colorScheme.primary,
        ),
        actions: [
          IconButton(
            onPressed: _showSearchDialog,
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Consumer2<AppointmentProvider, AuthProvider>(
        builder: (context, appointmentProvider, authProvider, child) {
          return Column(
            children: [
              // Search Bar (if searching)
              if (_searchController.text.isNotEmpty) _buildSearchBar(),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAppointmentsList(appointmentProvider.appointments),
                    _buildAppointmentsList(appointmentProvider.pendingAppointments),
                    _buildAppointmentsList(appointmentProvider.acceptedAppointments),
                    _buildAppointmentsList(
                      appointmentProvider.appointments
                          .where((apt) => apt.isCompleted)
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Only show FAB for staff members
          if (authProvider.isStaff) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateAppointmentScreen(),
                  ),
                );
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surface,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search appointments...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            onPressed: () {
              _searchController.clear();
              _performSearch('');
            },
            icon: const Icon(Icons.clear),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: _performSearch,
      ),
    );
  }

  Widget _buildAppointmentsList(List<AppointmentModel> appointments) {
    if (appointments.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return AppointmentCard(
            appointment: appointment,
            showActions: Provider.of<AuthProvider>(context, listen: false).isPrincipal,
            onTap: () => _navigateToDetail(appointment),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No appointments found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your appointments will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Appointments'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Enter search term...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
            Navigator.of(context).pop();
            _performSearch(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performSearch(_searchController.text);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    
    if (query.isEmpty) {
      appointmentProvider.clearFilter();
    } else {
      appointmentProvider.filterAppointments(searchQuery: query);
    }
    
    setState(() {});
  }

  Future<void> _refreshAppointments() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      await appointmentProvider.loadAppointments(
        authProvider.currentUser!.id,
        authProvider.currentUser!.role,
      );
    }
  }

  void _navigateToDetail(AppointmentModel appointment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AppointmentDetailScreen(appointment: appointment),
      ),
    );
  }
}