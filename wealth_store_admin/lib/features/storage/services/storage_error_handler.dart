import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../models/storage_error.dart';

/// Centralized error handling service for storage operations
class StorageErrorHandler {
  static final StorageErrorHandler _instance = StorageErrorHandler._internal();
  factory StorageErrorHandler() => _instance;
  StorageErrorHandler._internal();

  final List<StorageError> _errorHistory = [];
  final StreamController<StorageError> _errorStreamController = 
      StreamController<StorageError>.broadcast();

  /// Stream of storage errors for UI components to listen to
  Stream<StorageError> get errorStream => _errorStreamController.stream;

  /// Get recent error history
  List<StorageError> get errorHistory => List.unmodifiable(_errorHistory);

  /// Handle and process a storage error
  Future<void> handleError(StorageError error) async {
    // Add to history (keep last 100 errors)
    _errorHistory.add(error);
    if (_errorHistory.length > 100) {
      _errorHistory.removeAt(0);
    }

    // Log error based on severity
    await _logError(error);

    // Emit error to stream for UI handling
    _errorStreamController.add(error);

    // Perform automatic recovery if applicable
    await _attemptRecovery(error);
  }

  /// Handle exceptions and convert to StorageError
  Future<void> handleException(
    Exception exception, {
    String? context,
    Map<String, dynamic>? metadata,
  }) async {
    final storageError = StorageError.fromException(
      exception,
      context: context,
      metadata: metadata,
    );
    await handleError(storageError);
  }

  /// Log error with appropriate level
  Future<void> _logError(StorageError error) async {
    final logMessage = _formatLogMessage(error);

    switch (error.severity) {
      case StorageErrorSeverity.info:
        developer.log(logMessage, name: 'StorageInfo');
        break;
      case StorageErrorSeverity.warning:
        developer.log(logMessage, name: 'StorageWarning');
        break;
      case StorageErrorSeverity.error:
        developer.log(logMessage, name: 'StorageError', error: error.originalException);
        break;
      case StorageErrorSeverity.critical:
        developer.log(logMessage, name: 'StorageCritical', error: error.originalException);
        // In production, you might want to send critical errors to a logging service
        if (kReleaseMode) {
          await _sendToLoggingService(error);
        }
        break;
    }
  }

  /// Format error message for logging
  String _formatLogMessage(StorageError error) {
    final buffer = StringBuffer();
    buffer.writeln('Storage Error: ${error.type.name}');
    buffer.writeln('Message: ${error.message}');
    if (error.context != null) {
      buffer.writeln('Context: ${error.context}');
    }
    if (error.technicalDetails != null) {
      buffer.writeln('Technical: ${error.technicalDetails}');
    }
    if (error.metadata != null && error.metadata!.isNotEmpty) {
      buffer.writeln('Metadata: ${error.metadata}');
    }
    buffer.writeln('Timestamp: ${error.timestamp}');
    buffer.writeln('Retryable: ${error.isRetryable}');
    return buffer.toString();
  }

  /// Attempt automatic recovery for certain error types
  Future<void> _attemptRecovery(StorageError error) async {
    switch (error.type) {
      case StorageErrorType.sessionExpired:
        // Trigger re-authentication
        await _triggerReAuthentication();
        break;
      
      case StorageErrorType.networkTimeout:
      case StorageErrorType.networkUnavailable:
        // Start network monitoring
        _startNetworkMonitoring();
        break;
      
      case StorageErrorType.rateLimitExceeded:
        // Implement backoff strategy
        await _implementBackoff(error);
        break;
      
      default:
        // No automatic recovery for other error types
        break;
    }
  }

  /// Trigger re-authentication process
  Future<void> _triggerReAuthentication() async {
    // This would integrate with your auth system
    developer.log('Triggering re-authentication due to session expiry', name: 'StorageRecovery');
    // Implementation depends on your auth setup
  }

  /// Start monitoring network connectivity
  void _startNetworkMonitoring() {
    developer.log('Starting network connectivity monitoring', name: 'StorageRecovery');
    // Implementation would use connectivity_plus package or similar
  }

  /// Implement exponential backoff for rate limiting
  Future<void> _implementBackoff(StorageError error) async {
    final retryCount = error.metadata?['retryCount'] ?? 0;
    final backoffDelay = Duration(seconds: (2 << retryCount).clamp(1, 60));
    
    developer.log('Implementing backoff delay: ${backoffDelay.inSeconds}s', name: 'StorageRecovery');
    
    // You could store this delay information for retry mechanisms
    await Future.delayed(backoffDelay);
  }

  /// Send critical errors to external logging service
  Future<void> _sendToLoggingService(StorageError error) async {
    try {
      // Implementation would send to your logging service (e.g., Sentry, Firebase Crashlytics)
      developer.log('Sending critical error to logging service', name: 'StorageLogging');
    } catch (e) {
      developer.log('Failed to send error to logging service: $e', name: 'StorageLogging');
    }
  }

  /// Clear error history
  void clearErrorHistory() {
    _errorHistory.clear();
  }

  /// Get errors by type
  List<StorageError> getErrorsByType(StorageErrorType type) {
    return _errorHistory.where((error) => error.type == type).toList();
  }

  /// Get errors by severity
  List<StorageError> getErrorsBySeverity(StorageErrorSeverity severity) {
    return _errorHistory.where((error) => error.severity == severity).toList();
  }

  /// Get recent errors (last N errors)
  List<StorageError> getRecentErrors(int count) {
    if (_errorHistory.length <= count) {
      return List.from(_errorHistory);
    }
    return _errorHistory.sublist(_errorHistory.length - count);
  }

  /// Check if there are any critical errors in recent history
  bool hasCriticalErrors({Duration? within}) {
    final cutoff = within != null ? DateTime.now().subtract(within) : null;
    
    return _errorHistory.any((error) => 
        error.severity == StorageErrorSeverity.critical &&
        (cutoff == null || error.timestamp.isAfter(cutoff))
    );
  }

  /// Dispose resources
  void dispose() {
    _errorStreamController.close();
    _errorHistory.clear();
  }
}

/// Error recovery strategies
class StorageErrorRecovery {
  /// Retry operation with exponential backoff
  static Future<T> retryWithBackoff<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
    bool Function(Exception)? shouldRetry,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        
        if (attempt >= maxRetries) {
          rethrow;
        }

        if (shouldRetry != null && e is Exception && !shouldRetry(e)) {
          rethrow;
        }

        developer.log('Retry attempt $attempt after ${delay.inMilliseconds}ms', name: 'StorageRetry');
        await Future.delayed(delay);
        delay = Duration(milliseconds: (delay.inMilliseconds * backoffMultiplier).round());
      }
    }

    throw StateError('Should not reach here');
  }

  /// Check if error is retryable
  static bool isRetryable(StorageError error) {
    return error.isRetryable;
  }

  /// Get suggested retry delay based on error type
  static Duration getRetryDelay(StorageError error, int attemptCount) {
    switch (error.type) {
      case StorageErrorType.networkTimeout:
      case StorageErrorType.networkUnavailable:
        return Duration(seconds: (2 << attemptCount).clamp(1, 30));
      
      case StorageErrorType.rateLimitExceeded:
        return Duration(seconds: (5 << attemptCount).clamp(5, 120));
      
      case StorageErrorType.serverError:
        return Duration(seconds: (3 << attemptCount).clamp(3, 60));
      
      default:
        return Duration(seconds: (1 << attemptCount).clamp(1, 10));
    }
  }
}

/// Mixin for widgets that need error handling
mixin StorageErrorHandlerMixin {
  late final StreamSubscription<StorageError> _errorSubscription;
  final StorageErrorHandler _errorHandler = StorageErrorHandler();

  /// Initialize error handling
  void initErrorHandling() {
    _errorSubscription = _errorHandler.errorStream.listen(onStorageError);
  }

  /// Handle storage errors - override in implementing classes
  void onStorageError(StorageError error) {
    // Default implementation - can be overridden
    developer.log('Storage error in ${runtimeType}: ${error.message}', name: 'StorageUI');
  }

  /// Dispose error handling
  void disposeErrorHandling() {
    _errorSubscription.cancel();
  }

  /// Handle operation with error catching
  Future<T?> handleStorageOperation<T>(
    Future<T> Function() operation, {
    String? context,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      return await operation();
    } catch (e) {
      await _errorHandler.handleException(
        e is Exception ? e : Exception(e.toString()),
        context: context ?? runtimeType.toString(),
        metadata: metadata,
      );
      return null;
    }
  }
}