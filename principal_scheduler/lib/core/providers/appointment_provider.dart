import 'package:flutter/foundation.dart';

import '../models/appointment_model.dart';
import '../models/user_model.dart';
import '../services/appointment_service.dart';
import '../utils/exceptions.dart';

class AppointmentProvider with ChangeNotifier {
  List<AppointmentModel> _appointments = [];
  List<AppointmentModel> _filteredAppointments = [];
  bool _isLoading = false;
  String? _errorMessage;
  AppointmentModel? _selectedAppointment;

  List<AppointmentModel> get appointments => _filteredAppointments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AppointmentModel? get selectedAppointment => _selectedAppointment;

  // Filter appointments by status
  List<AppointmentModel> get pendingAppointments =>
      _appointments.where((apt) => apt.isPending).toList();
  
  List<AppointmentModel> get acceptedAppointments =>
      _appointments.where((apt) => apt.isAccepted).toList();
  
  List<AppointmentModel> get rejectedAppointments =>
      _appointments.where((apt) => apt.isRejected).toList();

  Future<void> loadAppointments(String userId, UserRole userRole) async {
    _setLoading(true);
    _clearError();

    try {
      _appointments = await AppointmentService.getUserAppointments(userId, userRole);
      _filteredAppointments = List.from(_appointments);
      notifyListeners();
    } on AppointmentException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to load appointments');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createAppointment(AppointmentModel appointment) async {
    _setLoading(true);
    _clearError();

    try {
      final createdAppointment = await AppointmentService.createAppointment(appointment);
      _appointments.add(createdAppointment);
      _applyCurrentFilter();
      notifyListeners();
      return true;
    } on AppointmentException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to create appointment');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateAppointment(AppointmentModel appointment) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedAppointment = await AppointmentService.updateAppointment(appointment);
      final index = _appointments.indexWhere((apt) => apt.id == appointment.id);
      if (index != -1) {
        _appointments[index] = updatedAppointment;
        _applyCurrentFilter();
        notifyListeners();
      }
      return true;
    } on AppointmentException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to update appointment');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> acceptAppointment(String appointmentId) async {
    return await _updateAppointmentStatus(appointmentId, AppointmentStatus.accepted);
  }

  Future<bool> rejectAppointment(String appointmentId, String reason) async {
    _setLoading(true);
    _clearError();

    try {
      await AppointmentService.rejectAppointment(appointmentId, reason);
      final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
      if (index != -1) {
        _appointments[index] = _appointments[index].copyWith(
          status: AppointmentStatus.rejected,
          rejectionReason: reason,
          updatedAt: DateTime.now(),
        );
        _applyCurrentFilter();
        notifyListeners();
      }
      return true;
    } on AppointmentException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to reject appointment');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> cancelAppointment(String appointmentId) async {
    return await _updateAppointmentStatus(appointmentId, AppointmentStatus.cancelled);
  }

  Future<bool> _updateAppointmentStatus(String appointmentId, AppointmentStatus status) async {
    _setLoading(true);
    _clearError();

    try {
      await AppointmentService.updateAppointmentStatus(appointmentId, status);
      final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
      if (index != -1) {
        _appointments[index] = _appointments[index].copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
        _applyCurrentFilter();
        notifyListeners();
      }
      return true;
    } on AppointmentException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to update appointment status');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void filterAppointments({
    AppointmentStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) {
    _filteredAppointments = _appointments.where((appointment) {
      // Filter by status
      if (status != null && appointment.status != status) {
        return false;
      }

      // Filter by date range
      if (startDate != null && appointment.scheduledDateTime.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && appointment.scheduledDateTime.isAfter(endDate)) {
        return false;
      }

      // Filter by search query
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        return appointment.title.toLowerCase().contains(query) ||
               appointment.description.toLowerCase().contains(query);
      }

      return true;
    }).toList();

    notifyListeners();
  }

  void clearFilter() {
    _filteredAppointments = List.from(_appointments);
    notifyListeners();
  }

  void _applyCurrentFilter() {
    // This would reapply the current filter after data changes
    // For now, just show all appointments
    _filteredAppointments = List.from(_appointments);
  }

  void selectAppointment(AppointmentModel appointment) {
    _selectedAppointment = appointment;
    notifyListeners();
  }

  void clearSelectedAppointment() {
    _selectedAppointment = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}