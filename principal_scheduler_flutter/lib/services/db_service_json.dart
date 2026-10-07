import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import '../models/appointment.dart';

class DBServiceJson {
  static final DBServiceJson _instance = DBServiceJson._internal();
  factory DBServiceJson() => _instance;
  DBServiceJson._internal();

  late File jsonFile;
  Map<String, dynamic> data = {};

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    jsonFile = File('\${dir.path}/data.json');

    if (!await jsonFile.exists()) {
      final String content = await rootBundle.loadString('assets/data.json');
      await jsonFile.writeAsString(content);
    }
    await load();
  }

  Future<void> load() async {
    final raw = await jsonFile.readAsString();
    data = jsonDecode(raw);
  }

  Future<void> save() async {
    await jsonFile.writeAsString(jsonEncode(data));
  }

  // USER FUNCTIONS
  User? login(String username, String password) {
    for (var u in data['users']) {
      if ((u['email'] == username || u['name'] == username) &&
          u['password'] == password) {
        return User.fromJson(u);
      }
    }
    return null;
  }

  List<User> getPrincipals() {
    return (data['users'] as List)
        .where((u) => u['role'] == 'principal')
        .map((u) => User.fromJson(u))
        .toList();
  }

  // STAFF FUNCTIONS
  List<Appointment> getAppointmentsByStaff(int staffId) {
    return (data['appointments'] as List)
        .where((a) => a['staff_id'] == staffId)
        .map((a) => Appointment.fromJson(a))
        .toList()
        .reversed
        .toList();
  }

  // PRINCIPAL FUNCTIONS
  List<Appointment> getPendingByPrincipal(int principalId) {
    return (data['appointments'] as List)
        .where((a) =>
            a['principal_id'] == principalId &&
            a['status'] == 'pending')
        .map((a) => Appointment.fromJson(a))
        .toList();
  }

  List<Appointment> getHistoryByPrincipal(int principalId) {
    return (data['appointments'] as List)
        .where((a) =>
            a['principal_id'] == principalId &&
            a['status'] != 'pending')
        .map((a) => Appointment.fromJson(a))
        .toList()
        .reversed
        .toList();
  }

  Future<void> addAppointment({
    required int staffId,
    required int principalId,
    required String title,
    required String details,
    required String requested,
  }) async {
    final users = {for (var u in data['users']) u['id']: u['name']};

    final appts = data['appointments'] as List;

    int newId = appts.isEmpty ? 1 : appts.last['id'] + 1;

    final appt = {
      'id': newId,
      'staff_id': staffId,
      'staff_name': users[staffId],
      'principal_id': principalId,
      'principal_name': users[principalId],
      'title': title,
      'details': details,
      'requested_datetime': requested,
      'status': 'pending',
      'suggested_datetime': null,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    appts.add(appt);
    await save();
  }

  Future<void> respond({
    required int id,
    required String action,
    String? suggested,
  }) async {
    final appts = data['appointments'] as List;

    for (var a in appts) {
      if (a['id'] == id) {
        if (action == 'accept') a['status'] = 'accepted';
        if (action == 'decline') a['status'] = 'declined';
        if (action == 'suggest') {
          a['status'] = 'suggested';
          a['suggested_datetime'] = suggested;
        }
        a['updated_at'] = DateTime.now().toIso8601String();
      }
    }

    await save();
  }
}
