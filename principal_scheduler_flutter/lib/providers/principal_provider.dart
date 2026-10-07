import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/db_service_json.dart';

class PrincipalProvider with ChangeNotifier {
  final DBServiceJson _db = DBServiceJson();

  List<Appointment> _pending = [];
  List<Appointment> _history = [];

  List<Appointment> get pending => _pending;
  List<Appointment> get history => _history;

  Future<void> loadAll(int principalId) async {
    await _db.load();
    _pending = _db.getPendingByPrincipal(principalId);
    _history = _db.getHistoryByPrincipal(principalId);
    notifyListeners();
  }

  Future<void> respond(int apptId, String action, {String? suggested}) async {
    await _db.respond(id: apptId, action: action, suggested: suggested);
    await loadAll(1); // caller should reload with actual principal id; simplified here
    notifyListeners();
  }
}
