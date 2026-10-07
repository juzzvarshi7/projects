import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/appointment_model.dart';
import '../models/user_model.dart';
import '../models/audio_message_model.dart';

class CacheService {
  static SharedPreferences? _prefs;
  static const String _appointmentsKey = 'cached_appointments';
  static const String _userProfileKey = 'cached_user_profile';
  static const String _audioMessagesKey = 'cached_audio_messages';
  static const String _lastSyncKey = 'last_sync_timestamp';

  // Initialize cache service
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Check network connectivity
  static Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Cache appointments
  static Future<void> cacheAppointments(List<AppointmentModel> appointments) async {
    try {
      final appointmentsJson = appointments.map((apt) => apt.toFirestore()).toList();
      await _prefs?.setString(_appointmentsKey, json.encode(appointmentsJson));
      await _updateLastSyncTime();
    } catch (e) {
      print('Failed to cache appointments: $e');
    }
  }

  // Get cached appointments
  static Future<List<AppointmentModel>> getCachedAppointments() async {
    try {
      final appointmentsString = _prefs?.getString(_appointmentsKey);
      if (appointmentsString != null) {
        final appointmentsList = json.decode(appointmentsString) as List;
        return appointmentsList.map((json) {
          // Create a mock document for fromFirestore
          final mockDoc = MockDocumentSnapshot(json['id'] ?? '', json);
          return AppointmentModel.fromFirestore(mockDoc);
        }).toList();
      }
    } catch (e) {
      print('Failed to get cached appointments: $e');
    }
    return [];
  }

  // Cache user profile
  static Future<void> cacheUserProfile(UserModel user) async {
    try {
      await _prefs?.setString(_userProfileKey, json.encode(user.toFirestore()));
    } catch (e) {
      print('Failed to cache user profile: $e');
    }
  }

  // Get cached user profile
  static Future<UserModel?> getCachedUserProfile() async {
    try {
      final userString = _prefs?.getString(_userProfileKey);
      if (userString != null) {
        final userJson = json.decode(userString);
        final mockDoc = MockDocumentSnapshot(userJson['id'] ?? '', userJson);
        return UserModel.fromFirestore(mockDoc);
      }
    } catch (e) {
      print('Failed to get cached user profile: $e');
    }
    return null;
  }

  // Cache audio messages
  static Future<void> cacheAudioMessages(String appointmentId, List<AudioMessageModel> messages) async {
    try {
      final messagesJson = messages.map((msg) => msg.toFirestore()).toList();
      await _prefs?.setString('${_audioMessagesKey}_$appointmentId', json.encode(messagesJson));
    } catch (e) {
      print('Failed to cache audio messages: $e');
    }
  }

  // Get cached audio messages
  static Future<List<AudioMessageModel>> getCachedAudioMessages(String appointmentId) async {
    try {
      final messagesString = _prefs?.getString('${_audioMessagesKey}_$appointmentId');
      if (messagesString != null) {
        final messagesList = json.decode(messagesString) as List;
        return messagesList.map((json) {
          final mockDoc = MockDocumentSnapshot(json['id'] ?? '', json);
          return AudioMessageModel.fromFirestore(mockDoc);
        }).toList();
      }
    } catch (e) {
      print('Failed to get cached audio messages: $e');
    }
    return [];
  }

  // Update last sync time
  static Future<void> _updateLastSyncTime() async {
    await _prefs?.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Get last sync time
  static DateTime? getLastSyncTime() {
    final timestamp = _prefs?.getInt(_lastSyncKey);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  // Clear all cache
  static Future<void> clearCache() async {
    await _prefs?.remove(_appointmentsKey);
    await _prefs?.remove(_userProfileKey);
    await _prefs?.remove(_lastSyncKey);
    
    // Clear audio message caches
    final keys = _prefs?.getKeys() ?? <String>{};
    for (final key in keys) {
      if (key.startsWith(_audioMessagesKey)) {
        await _prefs?.remove(key);
      }
    }
  }

  // Cache settings
  static Future<void> cacheSetting(String key, dynamic value) async {
    if (value is String) {
      await _prefs?.setString(key, value);
    } else if (value is int) {
      await _prefs?.setInt(key, value);
    } else if (value is double) {
      await _prefs?.setDouble(key, value);
    } else if (value is bool) {
      await _prefs?.setBool(key, value);
    } else {
      await _prefs?.setString(key, json.encode(value));
    }
  }

  // Get cached setting
  static T? getCachedSetting<T>(String key) {
    return _prefs?.get(key) as T?;
  }

  // Check if cache is stale
  static bool isCacheStale({Duration maxAge = const Duration(hours: 1)}) {
    final lastSync = getLastSyncTime();
    if (lastSync == null) return true;
    
    return DateTime.now().difference(lastSync) > maxAge;
  }
}

// Mock DocumentSnapshot for offline data
class MockDocumentSnapshot {
  final String _id;
  final Map<String, dynamic> _data;

  MockDocumentSnapshot(this._id, this._data);

  String get id => _id;
  Map<String, dynamic> data() => _data;
  bool get exists => _data.isNotEmpty;
}