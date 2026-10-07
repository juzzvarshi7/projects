import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class PerformanceService {
  static final Map<String, DateTime> _operationStartTimes = {};
  static final List<PerformanceMetric> _metrics = [];
  static Timer? _metricsTimer;

  // Initialize performance monitoring
  static void initialize() {
    if (kDebugMode) {
      _startMetricsCollection();
    }
  }

  // Start timing an operation
  static void startOperation(String operationName) {
    _operationStartTimes[operationName] = DateTime.now();
  }

  // End timing an operation
  static void endOperation(String operationName) {
    final startTime = _operationStartTimes[operationName];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _recordMetric(PerformanceMetric(
        operationName: operationName,
        duration: duration,
        timestamp: DateTime.now(),
      ));
      _operationStartTimes.remove(operationName);
    }
  }

  // Record a custom metric
  static void recordMetric(String name, Duration duration, {Map<String, dynamic>? metadata}) {
    _recordMetric(PerformanceMetric(
      operationName: name,
      duration: duration,
      timestamp: DateTime.now(),
      metadata: metadata,
    ));
  }

  // Get performance metrics
  static List<PerformanceMetric> getMetrics() {
    return List.from(_metrics);
  }

  // Clear metrics
  static void clearMetrics() {
    _metrics.clear();
  }

  // Get average duration for an operation
  static Duration? getAverageDuration(String operationName) {
    final operationMetrics = _metrics.where((m) => m.operationName == operationName).toList();
    if (operationMetrics.isEmpty) return null;

    final totalMilliseconds = operationMetrics
        .map((m) => m.duration.inMilliseconds)
        .reduce((a, b) => a + b);
    
    return Duration(milliseconds: totalMilliseconds ~/ operationMetrics.length);
  }

  // Check network performance
  static Future<NetworkPerformance> checkNetworkPerformance() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final startTime = DateTime.now();
    
    try {
      // Simple network test - you could implement a more sophisticated test
      await Future.delayed(const Duration(milliseconds: 100));
      final latency = DateTime.now().difference(startTime);
      
      return NetworkPerformance(
        isConnected: connectivityResult != ConnectivityResult.none,
        connectionType: connectivityResult,
        latency: latency,
      );
    } catch (e) {
      return NetworkPerformance(
        isConnected: false,
        connectionType: connectivityResult,
        latency: const Duration(seconds: 30), // Timeout
      );
    }
  }

  // Memory usage monitoring (simplified)
  static MemoryUsage getMemoryUsage() {
    // In a real implementation, you would use platform-specific code
    // to get actual memory usage
    return MemoryUsage(
      usedMemoryMB: 0, // Placeholder
      totalMemoryMB: 0, // Placeholder
      timestamp: DateTime.now(),
    );
  }

  // Start automatic metrics collection
  static void _startMetricsCollection() {
    _metricsTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _collectSystemMetrics();
    });
  }

  // Collect system metrics
  static void _collectSystemMetrics() {
    // Record memory usage
    final memoryUsage = getMemoryUsage();
    recordMetric(
      'memory_usage',
      Duration.zero,
      metadata: {
        'used_mb': memoryUsage.usedMemoryMB,
        'total_mb': memoryUsage.totalMemoryMB,
      },
    );

    // Clean up old metrics (keep only last 100)
    if (_metrics.length > 100) {
      _metrics.removeRange(0, _metrics.length - 100);
    }
  }

  // Record a metric
  static void _recordMetric(PerformanceMetric metric) {
    _metrics.add(metric);
    
    if (kDebugMode) {
      print('Performance: ${metric.operationName} took ${metric.duration.inMilliseconds}ms');
    }
  }

  // Dispose resources
  static void dispose() {
    _metricsTimer?.cancel();
    _metricsTimer = null;
    _operationStartTimes.clear();
    _metrics.clear();
  }
}

class PerformanceMetric {
  final String operationName;
  final Duration duration;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  PerformanceMetric({
    required this.operationName,
    required this.duration,
    required this.timestamp,
    this.metadata,
  });
}

class NetworkPerformance {
  final bool isConnected;
  final ConnectivityResult connectionType;
  final Duration latency;

  NetworkPerformance({
    required this.isConnected,
    required this.connectionType,
    required this.latency,
  });
}

class MemoryUsage {
  final double usedMemoryMB;
  final double totalMemoryMB;
  final DateTime timestamp;

  MemoryUsage({
    required this.usedMemoryMB,
    required this.totalMemoryMB,
    required this.timestamp,
  });

  double get usagePercentage => totalMemoryMB > 0 ? (usedMemoryMB / totalMemoryMB) * 100 : 0;
}