import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString('theme_mode') ?? 'system';
    if (s == 'light') _mode = ThemeMode.light;
    else if (s == 'dark') _mode = ThemeMode.dark;
    else _mode = ThemeMode.system;
    notifyListeners();
  }

  Future<void> setMode(ThemeMode m) async {
    _mode = m;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('theme_mode', m == ThemeMode.dark ? 'dark' : (m == ThemeMode.light ? 'light' : 'system'));
    notifyListeners();
  }
}
