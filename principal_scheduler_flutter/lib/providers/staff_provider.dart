import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/db_service_json.dart';

class StaffProvider with ChangeNotifier {
  final DBServiceJson _db = DBServiceJson();

  List<Appointment> _appointments = [];
  List<Appointment> get appointments => _appointments;

  Future<void> loadAppointments(int staffId) async {
    await _db.load();
    _appointments = _db.getAppointmentsByStaff(staffId);
    notifyListeners();
  }

  Future<void> sendRequest({
    required int staffId,
    required int principalId,
    required String title,
    required String details,
    required String requestedIso,
  }) async {
    await _db.addAppointment(
      staffId: staffId,
      principalId: principalId,
      title: title,
      details: details,
      requested: requestedIso,
    );
    await loadAppointments(staffId);
  }
}
