import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final performanceServiceProvider = Provider<PerformanceService>((ref) {
  return PerformanceService();
});

/// Service for monitoring and optimizing admin app performance
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
        'Slow admin operation: $operation took ${duration.inMilliseconds}ms',
        name: 'AdminPerformance',
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
        'Admin Performance Summary: $summary',
        name: 'AdminPerformance',
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
  
  /// Monitor CRUD operation performance
  void monitorCrudOperation(String entity, String operation, Future<dynamic> request) {
    if (!kDebugMode) return;
    
    final operationKey = '${entity}_$operation';
    startTimer(operationKey);
    incrementCounter('crud_operations');
    incrementCounter('${entity}_operations');
    
    request.then((_) {
      stopTimer(operationKey);
      incrementCounter('crud_success');
      incrementCounter('${entity}_success');
    }).catchError((error) {
      stopTimer(operationKey);
      incrementCounter('crud_errors');
      incrementCounter('${entity}_errors');
      developer.log(
        'CRUD error for $entity.$operation: $error',
        name: 'AdminCRUD',
        level: 1000, // Error level
      );
    });
  }
  
  /// Monitor data table performance
  void monitorDataTableRender(String tableName, int rowCount) {
    if (!kDebugMode) return;
    
    startTimer('table_render_$tableName');
    incrementCounter('table_renders');
    
    // Use a timer to measure render completion
    Timer(Duration.zero, () {
      stopTimer('table_render_$tableName');
      
      if (rowCount > 100) {
        developer.log(
          'Large table rendered: $tableName with $rowCount rows',
          name: 'AdminTable',
          level: 800,
        );
      }
    });
  }
  
  /// Monitor file upload performance
  void monitorFileUpload(String fileName, int fileSize, Future<dynamic> upload) {
    if (!kDebugMode) return;
    
    startTimer('file_upload_$fileName');
    incrementCounter('file_uploads');
    
    upload.then((_) {
      final duration = stopTimer('file_upload_$fileName');
      incrementCounter('file_upload_success');
      
      if (duration != null && fileSize > 0) {
        final speedMBps = (fileSize / 1024 / 1024) / (duration.inMilliseconds / 1000);
        developer.log(
          'File upload completed: $fileName (${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB) at ${speedMBps.toStringAsFixed(2)}MB/s',
          name: 'AdminUpload',
          level: 800,
        );
      }
    }).catchError((error) {
      stopTimer('file_upload_$fileName');
      incrementCounter('file_upload_errors');
      developer.log(
        'File upload error for $fileName: $error',
        name: 'AdminUpload',
        level: 1000,
      );
    });
  }
  
  /// Monitor search performance
  void monitorSearch(String searchType, String query, Future<dynamic> search) {
    if (!kDebugMode) return;
    
    startTimer('search_${searchType}_${query.length}');
    incrementCounter('searches');
    incrementCounter('${searchType}_searches');
    
    search.then((results) {
      stopTimer('search_${searchType}_${query.length}');
      incrementCounter('search_success');
      
      // Log slow searches
      final duration = _metrics['search_${searchType}_${query.length}']?.last;
      if (duration != null && duration.inMilliseconds > 2000) {
        developer.log(
          'Slow search detected: $searchType search for "$query" took ${duration.inMilliseconds}ms',
          name: 'AdminSearch',
          level: 900,
        );
      }
    }).catchError((error) {
      stopTimer('search_${searchType}_${query.length}');
      incrementCounter('search_errors');
      developer.log(
        'Search error for $searchType: $error',
        name: 'AdminSearch',
        level: 1000,
      );
    });
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
        name: 'AdminAsync',
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

/// Performance monitoring mixin for admin widgets
mixin AdminPerformanceMonitorMixin {
  PerformanceService get performanceService => PerformanceService();
  
  /// Monitor CRUD operation
  void monitorCrud(String entity, String operation, Future<dynamic> request) {
    performanceService.monitorCrudOperation(entity, operation, request);
  }
  
  /// Monitor data table render
  void monitorTable(String tableName, int rowCount) {
    performanceService.monitorDataTableRender(tableName, rowCount);
  }
}