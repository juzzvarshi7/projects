import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsService {
  static SharedPreferences? _prefs;
  static final List<AnalyticsEvent> _eventQueue = [];
  static const String _eventsKey = 'analytics_events';

  // Initialize analytics service
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadStoredEvents();
  }

  // Track user action
  static Future<void> trackEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    final event = AnalyticsEvent(
      name: eventName,
      parameters: parameters ?? {},
      timestamp: DateTime.now(),
    );

    _eventQueue.add(event);
    await _saveEvents();

    // In a real implementation, you would send events to your analytics service
    print('Analytics: $eventName - ${parameters ?? {}}');
  }

  // Track screen view
  static Future<void> trackScreenView(String screenName) async {
    await trackEvent('screen_view', parameters: {'screen_name': screenName});
  }

  // Track user login
  static Future<void> trackLogin(String method) async {
    await trackEvent('login', parameters: {'method': method});
  }

  // Track appointment creation
  static Future<void> trackAppointmentCreated() async {
    await trackEvent('appointment_created');
  }

  // Track appointment status change
  static Future<void> trackAppointmentStatusChanged(String status) async {
    await trackEvent('appointment_status_changed', parameters: {'status': status});
  }

  // Track audio message sent
  static Future<void> trackAudioMessageSent() async {
    await trackEvent('audio_message_sent');
  }

  // Track error
  static Future<void> trackError(String error, {String? context}) async {
    await trackEvent('error', parameters: {
      'error_message': error,
      'context': context,
    });
  }

  // Track performance metric
  static Future<void> trackPerformance(String operation, Duration duration) async {
    await trackEvent('performance', parameters: {
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
    });
  }

  // Get stored events
  static List<AnalyticsEvent> getEvents() {
    return List.from(_eventQueue);
  }

  // Clear events
  static Future<void> clearEvents() async {
    _eventQueue.clear();
    await _prefs?.remove(_eventsKey);
  }

  // Get event count by name
  static int getEventCount(String eventName) {
    return _eventQueue.where((event) => event.name == eventName).length;
  }

  // Get events by date range
  static List<AnalyticsEvent> getEventsByDateRange(DateTime start, DateTime end) {
    return _eventQueue.where((event) {
      return event.timestamp.isAfter(start) && event.timestamp.isBefore(end);
    }).toList();
  }

  // Load stored events from preferences
  static Future<void> _loadStoredEvents() async {
    final eventsJson = _prefs?.getString(_eventsKey);
    if (eventsJson != null) {
      try {
        final eventsList = json.decode(eventsJson) as List;
        _eventQueue.clear();
        _eventQueue.addAll(
          eventsList.map((eventJson) => AnalyticsEvent.fromJson(eventJson)),
        );
      } catch (e) {
        print('Failed to load analytics events: $e');
      }
    }
  }

  // Save events to preferences
  static Future<void> _saveEvents() async {
    try {
      final eventsJson = json.encode(_eventQueue.map((event) => event.toJson()).toList());
      await _prefs?.setString(_eventsKey, eventsJson);
    } catch (e) {
      print('Failed to save analytics events: $e');
    }
  }

  // Generate analytics report
  static AnalyticsReport generateReport({DateTime? startDate, DateTime? endDate}) {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 7));
    final end = endDate ?? DateTime.now();
    
    final events = getEventsByDateRange(start, end);
    final eventCounts = <String, int>{};
    
    for (final event in events) {
      eventCounts[event.name] = (eventCounts[event.name] ?? 0) + 1;
    }

    return AnalyticsReport(
      startDate: start,
      endDate: end,
      totalEvents: events.length,
      eventCounts: eventCounts,
      events: events,
    );
  }
}

class AnalyticsEvent {
  final String name;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;

  AnalyticsEvent({
    required this.name,
    required this.parameters,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'parameters': parameters,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return AnalyticsEvent(
      name: json['name'],
      parameters: Map<String, dynamic>.from(json['parameters']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class AnalyticsReport {
  final DateTime startDate;
  final DateTime endDate;
  final int totalEvents;
  final Map<String, int> eventCounts;
  final List<AnalyticsEvent> events;

  AnalyticsReport({
    required this.startDate,
    required this.endDate,
    required this.totalEvents,
    required this.eventCounts,
    required this.events,
  });

  String get summary {
    final buffer = StringBuffer();
    buffer.writeln('Analytics Report');
    buffer.writeln('Period: ${startDate.toLocal()} - ${endDate.toLocal()}');
    buffer.writeln('Total Events: $totalEvents');
    buffer.writeln('\nEvent Breakdown:');
    
    eventCounts.entries.forEach((entry) {
      buffer.writeln('  ${entry.key}: ${entry.value}');
    });
    
    return buffer.toString();
  }
}