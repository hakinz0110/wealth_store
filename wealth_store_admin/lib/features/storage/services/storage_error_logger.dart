import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../models/storage_error.dart';

/// Comprehensive logging service for storage errors
class StorageErrorLogger {
  static final StorageErrorLogger _instance = StorageErrorLogger._internal();
  factory StorageErrorLogger() => _instance;
  StorageErrorLogger._internal();

  final List<StorageErrorLogEntry> _logs = [];
  final StreamController<StorageErrorLogEntry> _logStreamController = 
      StreamController<StorageErrorLogEntry>.broadcast();

  /// Stream of error logs
  Stream<StorageErrorLogEntry> get logStream => _logStreamController.stream;

  /// Get all logs
  List<StorageErrorLogEntry> get logs => List.unmodifiable(_logs);

  /// Log a storage error
  Future<void> logError(StorageError error, {
    String? userId,
    String? sessionId,
    Map<String, dynamic>? additionalContext,
  }) async {
    final logEntry = StorageErrorLogEntry(
      error: error,
      userId: userId,
      sessionId: sessionId,
      additionalContext: additionalContext ?? {},
      logLevel: _getLogLevel(error.severity),
    );

    // Add to local logs
    _logs.add(logEntry);
    
    // Keep only last 1000 logs to prevent memory issues
    if (_logs.length > 1000) {
      _logs.removeAt(0);
    }

    // Emit to stream
    _logStreamController.add(logEntry);

    // Log to console/debug output
    await _logToConsole(logEntry);

    // Send to external logging service if in production
    if (kReleaseMode) {
      await _sendToExternalService(logEntry);
    }

    // Store locally for offline analysis
    await _storeLocally(logEntry);
  }

  /// Log to console with appropriate level
  Future<void> _logToConsole(StorageErrorLogEntry logEntry) async {
    final message = _formatConsoleMessage(logEntry);
    
    switch (logEntry.logLevel) {
      case LogLevel.debug:
        developer.log(message, name: 'StorageDebug');
        break;
      case LogLevel.info:
        developer.log(message, name: 'StorageInfo');
        break;
      case LogLevel.warning:
        developer.log(message, name: 'StorageWarning');
        break;
      case LogLevel.error:
        developer.log(
          message, 
          name: 'StorageError',
          error: logEntry.error.originalException,
        );
        break;
      case LogLevel.critical:
        developer.log(
          message, 
          name: 'StorageCritical',
          error: logEntry.error.originalException,
        );
        break;
    }
  }

  /// Format message for console output
  String _formatConsoleMessage(StorageErrorLogEntry logEntry) {
    final buffer = StringBuffer();
    buffer.writeln('=== Storage Error Log ===');
    buffer.writeln('ID: ${logEntry.id}');
    buffer.writeln('Timestamp: ${logEntry.timestamp}');
    buffer.writeln('Level: ${logEntry.logLevel.name.toUpperCase()}');
    buffer.writeln('Type: ${logEntry.error.type.name}');
    buffer.writeln('Message: ${logEntry.error.message}');
    
    if (logEntry.error.context != null) {
      buffer.writeln('Context: ${logEntry.error.context}');
    }
    
    if (logEntry.error.technicalDetails != null) {
      buffer.writeln('Technical: ${logEntry.error.technicalDetails}');
    }
    
    if (logEntry.userId != null) {
      buffer.writeln('User ID: ${logEntry.userId}');
    }
    
    if (logEntry.sessionId != null) {
      buffer.writeln('Session ID: ${logEntry.sessionId}');
    }
    
    if (logEntry.additionalContext.isNotEmpty) {
      buffer.writeln('Additional Context: ${logEntry.additionalContext}');
    }
    
    buffer.writeln('Retryable: ${logEntry.error.isRetryable}');
    buffer.writeln('========================');
    
    return buffer.toString();
  }

  /// Send error to external logging service
  Future<void> _sendToExternalService(StorageErrorLogEntry logEntry) async {
    try {
      // This would integrate with your logging service (Sentry, Firebase, etc.)
      final payload = logEntry.toJson();
      
      // Example: Send to your logging endpoint
      // await http.post(
      //   Uri.parse('https://your-logging-service.com/api/logs'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode(payload),
      // );
      
      developer.log('Sent error to external logging service', name: 'StorageLogger');
    } catch (e) {
      developer.log('Failed to send error to external service: $e', name: 'StorageLogger');
    }
  }

  /// Store error log locally for offline analysis
  Future<void> _storeLocally(StorageErrorLogEntry logEntry) async {
    try {
      // This would use shared_preferences or a local database
      // For now, just log that we would store it
      developer.log('Storing error log locally: ${logEntry.id}', name: 'StorageLogger');
    } catch (e) {
      developer.log('Failed to store error log locally: $e', name: 'StorageLogger');
    }
  }

  /// Get log level from error severity
  LogLevel _getLogLevel(StorageErrorSeverity severity) {
    switch (severity) {
      case StorageErrorSeverity.info:
        return LogLevel.info;
      case StorageErrorSeverity.warning:
        return LogLevel.warning;
      case StorageErrorSeverity.error:
        return LogLevel.error;
      case StorageErrorSeverity.critical:
        return LogLevel.critical;
    }
  }

  /// Get logs by level
  List<StorageErrorLogEntry> getLogsByLevel(LogLevel level) {
    return _logs.where((log) => log.logLevel == level).toList();
  }

  /// Get logs by error type
  List<StorageErrorLogEntry> getLogsByType(StorageErrorType type) {
    return _logs.where((log) => log.error.type == type).toList();
  }

  /// Get logs within time range
  List<StorageErrorLogEntry> getLogsInRange(DateTime start, DateTime end) {
    return _logs.where((log) => 
        log.timestamp.isAfter(start) && log.timestamp.isBefore(end)
    ).toList();
  }

  /// Get error statistics
  StorageErrorStats getErrorStats({Duration? period}) {
    final cutoff = period != null ? DateTime.now().subtract(period) : null;
    final relevantLogs = cutoff != null 
        ? _logs.where((log) => log.timestamp.isAfter(cutoff)).toList()
        : _logs;

    final typeCount = <StorageErrorType, int>{};
    final severityCount = <StorageErrorSeverity, int>{};
    
    for (final log in relevantLogs) {
      typeCount[log.error.type] = (typeCount[log.error.type] ?? 0) + 1;
      severityCount[log.error.severity] = (severityCount[log.error.severity] ?? 0) + 1;
    }

    return StorageErrorStats(
      totalErrors: relevantLogs.length,
      errorsByType: typeCount,
      errorsBySeverity: severityCount,
      period: period,
      generatedAt: DateTime.now(),
    );
  }

  /// Clear old logs
  void clearOldLogs({Duration? olderThan}) {
    final cutoff = olderThan != null 
        ? DateTime.now().subtract(olderThan)
        : DateTime.now().subtract(const Duration(days: 30)); // Default 30 days

    _logs.removeWhere((log) => log.timestamp.isBefore(cutoff));
  }

  /// Export logs as JSON
  String exportLogsAsJson({DateTime? since}) {
    final logsToExport = since != null
        ? _logs.where((log) => log.timestamp.isAfter(since)).toList()
        : _logs;

    final exportData = {
      'exportedAt': DateTime.now().toIso8601String(),
      'totalLogs': logsToExport.length,
      'logs': logsToExport.map((log) => log.toJson()).toList(),
    };

    return jsonEncode(exportData);
  }

  /// Dispose resources
  void dispose() {
    _logStreamController.close();
    _logs.clear();
  }
}

/// Log entry for storage errors
class StorageErrorLogEntry {
  final String id;
  final StorageError error;
  final DateTime timestamp;
  final LogLevel logLevel;
  final String? userId;
  final String? sessionId;
  final Map<String, dynamic> additionalContext;

  StorageErrorLogEntry({
    String? id,
    required this.error,
    DateTime? timestamp,
    required this.logLevel,
    this.userId,
    this.sessionId,
    this.additionalContext = const {},
  }) : id = id ?? _generateId(),
       timestamp = timestamp ?? DateTime.now();

  static String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'logLevel': logLevel.name,
      'error': {
        'type': error.type.name,
        'message': error.message,
        'technicalDetails': error.technicalDetails,
        'context': error.context,
        'severity': error.severity.name,
        'isRetryable': error.isRetryable,
        'metadata': error.metadata,
      },
      'userId': userId,
      'sessionId': sessionId,
      'additionalContext': additionalContext,
    };
  }

  factory StorageErrorLogEntry.fromJson(Map<String, dynamic> json) {
    final errorData = json['error'] as Map<String, dynamic>;
    
    return StorageErrorLogEntry(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      logLevel: LogLevel.values.firstWhere((l) => l.name == json['logLevel']),
      error: StorageError(
        type: StorageErrorType.values.firstWhere((t) => t.name == errorData['type']),
        message: errorData['message'],
        technicalDetails: errorData['technicalDetails'],
        context: errorData['context'],
        timestamp: DateTime.parse(json['timestamp']),
        isRetryable: errorData['isRetryable'] ?? false,
        metadata: errorData['metadata']?.cast<String, dynamic>(),
      ),
      userId: json['userId'],
      sessionId: json['sessionId'],
      additionalContext: json['additionalContext']?.cast<String, dynamic>() ?? {},
    );
  }
}

/// Log levels for categorization
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical;

  String get displayName {
    switch (this) {
      case LogLevel.debug:
        return 'Debug';
      case LogLevel.info:
        return 'Info';
      case LogLevel.warning:
        return 'Warning';
      case LogLevel.error:
        return 'Error';
      case LogLevel.critical:
        return 'Critical';
    }
  }
}

/// Error statistics for analysis
class StorageErrorStats {
  final int totalErrors;
  final Map<StorageErrorType, int> errorsByType;
  final Map<StorageErrorSeverity, int> errorsBySeverity;
  final Duration? period;
  final DateTime generatedAt;

  const StorageErrorStats({
    required this.totalErrors,
    required this.errorsByType,
    required this.errorsBySeverity,
    this.period,
    required this.generatedAt,
  });

  /// Get most common error type
  StorageErrorType? get mostCommonErrorType {
    if (errorsByType.isEmpty) return null;
    
    return errorsByType.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get error rate (errors per hour)
  double get errorRate {
    if (period == null || totalErrors == 0) return 0;
    return totalErrors / period!.inHours;
  }

  /// Check if error rate is concerning
  bool get isErrorRateConcerning {
    return errorRate > 10; // More than 10 errors per hour
  }

  Map<String, dynamic> toJson() {
    return {
      'totalErrors': totalErrors,
      'errorsByType': errorsByType.map((k, v) => MapEntry(k.name, v)),
      'errorsBySeverity': errorsBySeverity.map((k, v) => MapEntry(k.name, v)),
      'period': period?.inMilliseconds,
      'generatedAt': generatedAt.toIso8601String(),
      'errorRate': errorRate,
      'mostCommonErrorType': mostCommonErrorType?.name,
    };
  }
}