import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/appointment_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/appointment_model.dart';
import '../../../core/models/user_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class CreateAppointmentScreen extends StatefulWidget {
  const CreateAppointmentScreen({super.key});

  @override
  State<CreateAppointmentScreen> createState() => _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  int _duration = 30;
  AppointmentPriority _priority = AppointmentPriority.medium;
  String? _selectedPrincipalId;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('New Appointment'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Consumer2<AppointmentProvider, AuthProvider>(
        builder: (context, appointmentProvider, authProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Field
                  CustomTextField(
                    controller: _titleController,
                    labelText: 'Appointment Title',
                    hintText: 'Enter appointment title',
                    prefixIcon: Icons.title,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter appointment title';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description Field
                  CustomTextField(
                    controller: _descriptionController,
                    labelText: 'Description',
                    hintText: 'Enter appointment description',
                    prefixIcon: Icons.description,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter appointment description';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Principal Selection
                  _buildPrincipalSelection(),
                  
                  const SizedBox(height: 16),
                  
                  // Date Selection
                  _buildDateSelection(),
                  
                  const SizedBox(height: 16),
                  
                  // Time Selection
                  _buildTimeSelection(),
                  
                  const SizedBox(height: 16),
                  
                  // Duration Selection
                  _buildDurationSelection(),
                  
                  const SizedBox(height: 16),
                  
                  // Priority Selection
                  _buildPrioritySelection(),
                  
                  const SizedBox(height: 16),
                  
                  // Location Field (Optional)
                  CustomTextField(
                    controller: _locationController,
                    labelText: 'Location (Optional)',
                    hintText: 'Enter meeting location',
                    prefixIcon: Icons.location_on,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Create Button
                  CustomButton(
                    text: 'Create Appointment',
                    onPressed: appointmentProvider.isLoading ? null : _createAppointment,
                    isLoading: appointmentProvider.isLoading,
                    icon: Icons.event,
                  ),
                  
                  // Error Message
                  if (appointmentProvider.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorMessage(appointmentProvider.errorMessage!),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrincipalSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Principal',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPrincipalId,
              hint: const Text('Choose a principal'),
              isExpanded: true,
              items: [
                // In a real app, you would fetch principals from a service
                const DropdownMenuItem(
                  value: 'principal1',
                  child: Text('Dr. Smith - Principal'),
                ),
                const DropdownMenuItem(
                  value: 'principal2',
                  child: Text('Ms. Johnson - Vice Principal'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPrincipalId = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectTime,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedTime.format(context),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _duration,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 15, child: Text('15 minutes')),
                DropdownMenuItem(value: 30, child: Text('30 minutes')),
                DropdownMenuItem(value: 45, child: Text('45 minutes')),
                DropdownMenuItem(value: 60, child: Text('1 hour')),
                DropdownMenuItem(value: 90, child: Text('1.5 hours')),
                DropdownMenuItem(value: 120, child: Text('2 hours')),
              ],
              onChanged: (value) {
                setState(() {
                  _duration = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: AppointmentPriority.values.map((priority) {
            final isSelected = _priority == priority;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _priority = priority;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    priority.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _createAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedPrincipalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a principal'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    
    final scheduledDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final appointment = AppointmentModel(
      id: '', // Will be set by Firestore
      staffId: authProvider.currentUser!.id,
      principalId: _selectedPrincipalId!,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      scheduledDateTime: scheduledDateTime,
      durationMinutes: _duration,
      priority: _priority,
      location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      createdAt: DateTime.now(),
    );

    final success = await appointmentProvider.createAppointment(appointment);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment created successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}