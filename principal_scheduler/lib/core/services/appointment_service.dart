import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/appointment_model.dart';
import '../models/user_model.dart';
import '../utils/exceptions.dart';
import '../config/app_config.dart';
import 'notification_service.dart';

class AppointmentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create new appointment
  static Future<AppointmentModel> createAppointment(AppointmentModel appointment) async {
    try {
      // Check daily appointment limit
      await _checkDailyAppointmentLimit(appointment.staffId);
      
      // Check for conflicts
      await _checkAppointmentConflicts(appointment);
      
      // Create appointment document
      final docRef = await _firestore.collection('appointments').add(appointment.toFirestore());
      
      // Get created appointment
      final doc = await docRef.get();
      final createdAppointment = AppointmentModel.fromFirestore(doc);
      
      // Send notification to principal
      await _sendAppointmentNotification(
        createdAppointment,
        'New Appointment Request',
        'You have a new appointment request from ${appointment.staffId}',
      );
      
      return createdAppointment;
    } catch (e) {
      throw AppointmentException('Failed to create appointment: ${e.toString()}');
    }
  }

  // Update appointment
  static Future<AppointmentModel> updateAppointment(AppointmentModel appointment) async {
    try {
      final updatedData = appointment.copyWith(updatedAt: DateTime.now()).toFirestore();
      
      await _firestore
          .collection('appointments')
          .doc(appointment.id)
          .update(updatedData);
      
      final doc = await _firestore.collection('appointments').doc(appointment.id).get();
      return AppointmentModel.fromFirestore(doc);
    } catch (e) {
      throw AppointmentException('Failed to update appointment: ${e.toString()}');
    }
  }

  // Update appointment status
  static Future<void> updateAppointmentStatus(String appointmentId, AppointmentStatus status) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': status.name,
        'updatedAt': Timestamp.now(),
      });
      
      // Send status update notification
      final appointment = await getAppointmentById(appointmentId);
      if (appointment != null) {
        await _sendStatusUpdateNotification(appointment, status);
      }
    } catch (e) {
      throw AppointmentException('Failed to update appointment status: ${e.toString()}');
    }
  }

  // Accept appointment
  static Future<void> acceptAppointment(String appointmentId) async {
    await updateAppointmentStatus(appointmentId, AppointmentStatus.accepted);
  }

  // Reject appointment
  static Future<void> rejectAppointment(String appointmentId, String reason) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': AppointmentStatus.rejected.name,
        'rejectionReason': reason,
        'updatedAt': Timestamp.now(),
      });
      
      final appointment = await getAppointmentById(appointmentId);
      if (appointment != null) {
        await _sendRejectionNotification(appointment, reason);
      }
    } catch (e) {
      throw AppointmentException('Failed to reject appointment: ${e.toString()}');
    }
  }

  // Get user appointments
  static Future<List<AppointmentModel>> getUserAppointments(String userId, UserRole userRole) async {
    try {
      Query query;
      
      if (userRole == UserRole.staff) {
        query = _firestore
            .collection('appointments')
            .where('staffId', isEqualTo: userId)
            .orderBy('scheduledDateTime', descending: true);
      } else {
        query = _firestore
            .collection('appointments')
            .where('principalId', isEqualTo: userId)
            .orderBy('scheduledDateTime', descending: true);
      }
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw AppointmentException('Failed to get user appointments: ${e.toString()}');
    }
  }

  // Get appointment by ID
  static Future<AppointmentModel?> getAppointmentById(String appointmentId) async {
    try {
      final doc = await _firestore.collection('appointments').doc(appointmentId).get();
      if (doc.exists) {
        return AppointmentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw AppointmentException('Failed to get appointment: ${e.toString()}');
    }
  }

  // Get appointments by date range
  static Future<List<AppointmentModel>> getAppointmentsByDateRange(
    String userId,
    UserRole userRole,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      Query query;
      
      if (userRole == UserRole.staff) {
        query = _firestore
            .collection('appointments')
            .where('staffId', isEqualTo: userId);
      } else {
        query = _firestore
            .collection('appointments')
            .where('principalId', isEqualTo: userId);
      }
      
      query = query
          .where('scheduledDateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('scheduledDateTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('scheduledDateTime');
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw AppointmentException('Failed to get appointments by date range: ${e.toString()}');
    }
  }

  // Get pending appointments
  static Future<List<AppointmentModel>> getPendingAppointments(String principalId) async {
    try {
      final snapshot = await _firestore
          .collection('appointments')
          .where('principalId', isEqualTo: principalId)
          .where('status', isEqualTo: AppointmentStatus.pending.name)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw AppointmentException('Failed to get pending appointments: ${e.toString()}');
    }
  }

  // Stream appointments for real-time updates
  static Stream<List<AppointmentModel>> streamUserAppointments(String userId, UserRole userRole) {
    try {
      Query query;
      
      if (userRole == UserRole.staff) {
        query = _firestore
            .collection('appointments')
            .where('staffId', isEqualTo: userId)
            .orderBy('scheduledDateTime', descending: true);
      } else {
        query = _firestore
            .collection('appointments')
            .where('principalId', isEqualTo: userId)
            .orderBy('scheduledDateTime', descending: true);
      }
      
      return query.snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList());
    } catch (e) {
      throw AppointmentException('Failed to stream appointments: ${e.toString()}');
    }
  }

  // Delete appointment
  static Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).delete();
    } catch (e) {
      throw AppointmentException('Failed to delete appointment: ${e.toString()}');
    }
  }

  // Check daily appointment limit
  static Future<void> _checkDailyAppointmentLimit(String staffId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final snapshot = await _firestore
        .collection('appointments')
        .where('staffId', isEqualTo: staffId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
        .get();
    
    if (snapshot.docs.length >= AppConfig.maxAppointmentsPerDay) {
      throw AppointmentException('Daily appointment limit reached');
    }
  }

  // Check for appointment conflicts
  static Future<void> _checkAppointmentConflicts(AppointmentModel appointment) async {
    final startTime = appointment.scheduledDateTime;
    final endTime = appointment.endDateTime;
    
    // Check principal conflicts
    final principalConflicts = await _firestore
        .collection('appointments')
        .where('principalId', isEqualTo: appointment.principalId)
        .where('status', whereIn: [AppointmentStatus.accepted.name, AppointmentStatus.pending.name])
        .get();
    
    for (final doc in principalConflicts.docs) {
      final existingAppointment = AppointmentModel.fromFirestore(doc);
      final existingStart = existingAppointment.scheduledDateTime;
      final existingEnd = existingAppointment.endDateTime;
      
      if (_hasTimeConflict(startTime, endTime, existingStart, existingEnd)) {
        throw AppointmentException('Principal has a conflicting appointment at this time');
      }
    }
    
    // Check staff conflicts
    final staffConflicts = await _firestore
        .collection('appointments')
        .where('staffId', isEqualTo: appointment.staffId)
        .where('status', whereIn: [AppointmentStatus.accepted.name, AppointmentStatus.pending.name])
        .get();
    
    for (final doc in staffConflicts.docs) {
      final existingAppointment = AppointmentModel.fromFirestore(doc);
      final existingStart = existingAppointment.scheduledDateTime;
      final existingEnd = existingAppointment.endDateTime;
      
      if (_hasTimeConflict(startTime, endTime, existingStart, existingEnd)) {
        throw AppointmentException('You have a conflicting appointment at this time');
      }
    }
  }

  // Check if two time ranges conflict
  static bool _hasTimeConflict(DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
    return start1.isBefore(end2) && end1.isAfter(start2);
  }

  // Send appointment notification
  static Future<void> _sendAppointmentNotification(
    AppointmentModel appointment,
    String title,
    String body,
  ) async {
    try {
      await NotificationService.showAppointmentNotification(
        title: title,
        body: body,
        payload: appointment.id,
      );
    } catch (e) {
      // Log error but don't throw - notification failure shouldn't break appointment creation
      print('Failed to send notification: $e');
    }
  }

  // Send status update notification
  static Future<void> _sendStatusUpdateNotification(
    AppointmentModel appointment,
    AppointmentStatus status,
  ) async {
    String title = 'Appointment Update';
    String body = '';
    
    switch (status) {
      case AppointmentStatus.accepted:
        body = 'Your appointment "${appointment.title}" has been accepted';
        break;
      case AppointmentStatus.rejected:
        body = 'Your appointment "${appointment.title}" has been rejected';
        break;
      case AppointmentStatus.cancelled:
        body = 'Appointment "${appointment.title}" has been cancelled';
        break;
      case AppointmentStatus.completed:
        body = 'Appointment "${appointment.title}" has been completed';
        break;
      default:
        body = 'Appointment "${appointment.title}" status updated';
    }
    
    await _sendAppointmentNotification(appointment, title, body);
  }

  // Send rejection notification
  static Future<void> _sendRejectionNotification(
    AppointmentModel appointment,
    String reason,
  ) async {
    await _sendAppointmentNotification(
      appointment,
      'Appointment Rejected',
      'Your appointment "${appointment.title}" was rejected. Reason: $reason',
    );
  }
}