import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/appointment_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/appointment_model.dart';
import '../../widgets/appointment_card.dart';
import '../appointments/appointment_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<AppointmentModel>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<AppointmentModel> _getEventsForDay(DateTime day) {
    final appointments = Provider.of<AppointmentProvider>(context, listen: false).appointments;
    return appointments.where((appointment) {
      return isSameDay(appointment.scheduledDateTime, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
                _selectedEvents.value = _getEventsForDay(_selectedDay!);
              });
            },
            icon: const Icon(Icons.today),
            tooltip: 'Today',
          ),
        ],
      ),
      body: Consumer2<AppointmentProvider, AuthProvider>(
        builder: (context, appointmentProvider, authProvider, child) {
          return Column(
            children: [
              // Calendar Widget
              Card(
                margin: const EdgeInsets.all(16),
                child: TableCalendar<AppointmentModel>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  eventLoader: _getEventsForDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: _onDaySelected,
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    holidayTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                    formatButtonDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    formatButtonTextStyle: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              // Selected Day Header
              if (_selectedDay != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Appointments for ${DateFormat('EEEE, MMMM dd').format(_selectedDay!)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              
              // Events List
              Expanded(
                child: ValueListenableBuilder<List<AppointmentModel>>(
                  valueListenable: _selectedEvents,
                  builder: (context, value, _) {
                    if (value.isEmpty) {
                      return _buildEmptyState();
                    }
                    
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        final appointment = value[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AppointmentCard(
                            appointment: appointment,
                            showActions: authProvider.isPrincipal && appointment.isPending,
                            onTap: () => _navigateToDetail(appointment),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
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
            'No appointments',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No appointments scheduled for this day',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      
      _selectedEvents.value = _getEventsForDay(selectedDay);
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