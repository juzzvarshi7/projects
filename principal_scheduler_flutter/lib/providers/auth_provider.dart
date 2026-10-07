import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/db_service_json.dart';

class AuthProvider with ChangeNotifier {
  final DBServiceJson _db = DBServiceJson();

  User? _user;
  User? get user => _user;

  bool get isLoggedIn => _user != null;

  String? login(String username, String password) {
    final u = _db.login(username.trim(), password.trim());
    if (u != null) {
      _user = u;
      notifyListeners();
      return null;
    } else {
      return "Invalid credentials";
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
