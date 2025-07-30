import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'performance_service.g.dart';

@riverpod
PerformanceService performanceService(Ref ref) {
  return PerformanceService();
}

/// Service for monitoring and optimizing app performance
class PerformanceService {
  final Map<String, Stopwatch> _timers = {};
  final Map<String, List<Duration>> _metrics = {};
  final Map<String, int> _counters = {};
  
  static const int _maxMetricsHistory = 100;
  
  /// Start timing an operation
  void startTimer(String operation) {
    if (kDebugMode) {
      _timers[operation] = Stopwatch()..start();
    }
  }
  
  /// Stop timing an operation and record the duration
  Duration? stopTimer(String operation) {
    if (!kDebugMode) return null;
    
    final timer = _timers[operation];
    if (timer == null) return null;
    
    timer.stop();
    final duration = timer.elapsed;
    
    // Record metric
    _recordMetric(operation, duration);
    
    // Clean up timer
    _timers.remove(operation);
    
    // Log if operation took too long
    if (duration.inMilliseconds > 1000) {
      developer.log(
        'Slow operation detected: $operation took ${duration.inMilliseconds}ms',
        name: 'Performance',
        level: 900, // Warning level
      );
    }
    
    return duration;
  }
  
  /// Record a metric without using timer
  void recordMetric(String operation, Duration duration) {
    if (kDebugMode) {
      _recordMetric(operation, duration);
    }
  }
  
  /// Increment a counter
  void incrementCounter(String counter) {
    if (kDebugMode) {
      _counters[counter] = (_counters[counter] ?? 0) + 1;
    }
  }
  
  /// Get average duration for an operation
  Duration? getAverageDuration(String operation) {
    if (!kDebugMode) return null;
    
    final metrics = _metrics[operation];
    if (metrics == null || metrics.isEmpty) return null;
    
    final totalMicroseconds = metrics
        .map((d) => d.inMicroseconds)
        .reduce((a, b) => a + b);
    
    return Duration(microseconds: totalMicroseconds ~/ metrics.length);
  }
  
  /// Get performance summary
  Map<String, dynamic> getPerformanceSummary() {
    if (!kDebugMode) return {};
    
    final summary = <String, dynamic>{};
    
    // Add timing metrics
    for (final entry in _metrics.entries) {
      final operation = entry.key;
      final durations = entry.value;
      
      if (durations.isNotEmpty) {
        final avg = getAverageDuration(operation);
        final min = durations.reduce((a, b) => a < b ? a : b);
        final max = durations.reduce((a, b) => a > b ? a : b);
        
        summary[operation] = {
          'count': durations.length,
          'average_ms': avg?.inMilliseconds ?? 0,
          'min_ms': min.inMilliseconds,
          'max_ms': max.inMilliseconds,
        };
      }
    }
    
    // Add counters
    if (_counters.isNotEmpty) {
      summary['counters'] = Map.from(_counters);
    }
    
    return summary;
  }
  
  /// Log performance summary
  void logPerformanceSummary() {
    if (!kDebugMode) return;
    
    final summary = getPerformanceSummary();
    if (summary.isNotEmpty) {
      developer.log(
        'Performance Summary: $summary',
        name: 'Performance',
        level: 800, // Info level
      );
    }
  }
  
  /// Clear all metrics
  void clearMetrics() {
    if (kDebugMode) {
      _metrics.clear();
      _counters.clear();
      _timers.clear();
    }
  }
  
  /// Monitor memory usage (basic)
  void logMemoryUsage(String context) {
    if (kDebugMode) {
      // This is a basic implementation - in production you might want more detailed memory monitoring
      developer.log(
        'Memory check at: $context',
        name: 'Memory',
        level: 800,
      );
    }
  }
  
  /// Monitor network request performance
  void monitorNetworkRequest(String endpoint, Future<dynamic> request) {
    if (!kDebugMode) return;
    
    startTimer('network_$endpoint');
    incrementCounter('network_requests');
    
    request.then((_) {
      stopTimer('network_$endpoint');
      incrementCounter('network_success');
    }).catchError((error) {
      stopTimer('network_$endpoint');
      incrementCounter('network_errors');
      developer.log(
        'Network error for $endpoint: $error',
        name: 'Network',
        level: 1000, // Error level
      );
    });
  }
  
  /// Monitor widget build performance
  T monitorWidgetBuild<T>(String widgetName, T Function() buildFunction) {
    if (!kDebugMode) return buildFunction();
    
    startTimer('widget_build_$widgetName');
    try {
      final result = buildFunction();
      stopTimer('widget_build_$widgetName');
      return result;
    } catch (error) {
      stopTimer('widget_build_$widgetName');
      developer.log(
        'Widget build error for $widgetName: $error',
        name: 'Widget',
        level: 1000,
      );
      rethrow;
    }
  }
  
  /// Monitor async operation performance
  Future<T> monitorAsyncOperation<T>(
    String operationName, 
    Future<T> Function() operation,
  ) async {
    if (!kDebugMode) return await operation();
    
    startTimer('async_$operationName');
    try {
      final result = await operation();
      stopTimer('async_$operationName');
      return result;
    } catch (error) {
      stopTimer('async_$operationName');
      developer.log(
        'Async operation error for $operationName: $error',
        name: 'Async',
        level: 1000,
      );
      rethrow;
    }
  }
  
  // Private helper methods
  
  void _recordMetric(String operation, Duration duration) {
    _metrics[operation] ??= <Duration>[];
    _metrics[operation]!.add(duration);
    
    // Keep only recent metrics to prevent memory leaks
    if (_metrics[operation]!.length > _maxMetricsHistory) {
      _metrics[operation]!.removeAt(0);
    }
  }
}

/// Performance monitoring mixin for widgets
mixin PerformanceMonitorMixin {
  PerformanceService get performanceService => PerformanceService();
  
  /// Monitor build method performance
  Widget monitorBuild(String widgetName, Widget Function() buildFunction) {
    return performanceService.monitorWidgetBuild(widgetName, buildFunction);
  }
}

/// Performance monitoring extension for Future
extension PerformanceMonitoringFuture<T> on Future<T> {
  /// Monitor this future's performance
  Future<T> monitor(String operationName, [PerformanceService? service]) {
    final perfService = service ?? PerformanceService();
    return perfService.monitorAsyncOperation(operationName, () => this);
  }
}