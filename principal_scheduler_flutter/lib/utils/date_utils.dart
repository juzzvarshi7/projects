import 'package:intl/intl.dart';

class DateUtilsLocal {
  static DateTime? parseLocal(String text) {
    try {
      return DateTime.parse(text.contains('T') ? text : text.replaceFirst(' ', 'T'));
    } catch (e) {
      try {
        return DateFormat('yyyy-MM-dd HH:mm').parseStrict(text);
      } catch (_) {
        return null;
      }
    }
  }

  static String toIsoNoMicro(DateTime dt) {
    final d = dt.toUtc().toIso8601String();
    final parts = d.split('.');
    return parts[0];
  }

  static String prettyDateTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('yyyy-MM-dd HH:mm').format(dt);
    } catch (e) {
      return iso;
    }
  }
}
