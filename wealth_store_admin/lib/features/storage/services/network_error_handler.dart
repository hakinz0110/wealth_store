import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../models/storage_error.dart';
import 'storage_error_handler.dart';

/// Network-specific error handling and connectivity management
class NetworkErrorHandler {
  static final NetworkErrorHandler _instance = NetworkErrorHandler._internal();
  factory NetworkErrorHandler() => _instance;
  NetworkErrorHandler._internal();

  final StreamController<NetworkStatus> _statusController = 
      StreamController<NetworkStatus>.broadcast();
  final List<PendingOperation> _pendingOperations = [];
  
  NetworkStatus _currentStatus = NetworkStatus.unknown;
  Timer? _connectivityTimer;
  Timer? _retryTimer;

  /// Stream of network status changes
  Stream<NetworkStatus> get statusStream => _statusController.stream;

  /// Current network status
  NetworkStatus get currentStatus => _currentStatus;

  /// Check if currently online
  bool get isOnline => _currentStatus == NetworkStatus.online;

  /// Check if currently offline
  bool get isOffline => _currentStatus == NetworkStatus.offline;

  /// Initialize network monitoring
  void initialize() {
    _startConnectivityMonitoring();
    _startRetryTimer();
  }

  /// Start monitoring network connectivity
  void _startConnectivityMonitoring() {
    _connectivityTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkConnectivity(),
    );
    
    // Initial check
    _checkConnectivity();
  }

  /// Check network connectivity
  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _updateStatus(NetworkStatus.online);
      } else {
        _updateStatus(NetworkStatus.offline);
      }
    } catch (e) {
      _updateStatus(NetworkStatus.offline);
    }
  }

  /// Update network status
  void _updateStatus(NetworkStatus newStatus) {
    if (_currentStatus != newStatus) {
      final previousStatus = _currentStatus;
      _currentStatus = newStatus;
      _statusController.add(newStatus);
      
      developer.log(
        'Network status changed: ${previousStatus.name} -> ${newStatus.name}',
        name: 'NetworkHandler',
      );

      // Process pending operations when coming back online
      if (newStatus == NetworkStatus.online && previousStatus == NetworkStatus.offline) {
        _processPendingOperations();
      }
    }
  }

  /// Handle network-related errors with retry logic
  Future<T> handleNetworkOperation<T>(
    Future<T> Function() operation, {
    String? operationName,
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    bool queueWhenOffline = true,
    Map<String, dynamic>? metadata,
  }) async {
    int attemptCount = 0;
    Duration currentDelay = initialDelay;

    while (attemptCount < maxRetries) {
      try {
        // Check if we're offline and should queue the operation
        if (isOffline && queueWhenOffline) {
          return await _queueOperation(
            operation,
            operationName: operationName,
            metadata: metadata,
          );
        }

        // Attempt the operation
        final result = await operation();
        
        // Success - clear any previous network errors for this operation
        if (attemptCount > 0) {
          developer.log(
            'Network operation succeeded after $attemptCount retries: $operationName',
            name: 'NetworkHandler',
          );
        }
        
        return result;

      } catch (e) {
        attemptCount++;
        
        final isNetworkError = _isNetworkError(e);
        
        if (!isNetworkError || attemptCount >= maxRetries) {
          // Not a network error or max retries reached
          final storageError = isNetworkError
              ? _createNetworkError(e, operationName, metadata)
              : StorageError.fromException(
                  e is Exception ? e : Exception(e.toString()),
                  context: operationName,
                  metadata: metadata,
                );
          
          await StorageErrorHandler().handleError(storageError);
          rethrow;
        }

        // Network error - implement retry with backoff
        developer.log(
          'Network error on attempt $attemptCount/$maxRetries for $operationName: $e',
          name: 'NetworkHandler',
        );

        if (attemptCount < maxRetries) {
          await Future.delayed(currentDelay);
          currentDelay = Duration(
            milliseconds: (currentDelay.inMilliseconds * 1.5).round(),
          );
        }
      }
    }

    throw StateError('Should not reach here');
  }

  /// Queue operation for when network comes back online
  Future<T> _queueOperation<T>(
    Future<T> Function() operation, {
    String? operationName,
    Map<String, dynamic>? metadata,
  }) async {
    final completer = Completer<T>();
    final pendingOp = PendingOperation<T>(
      operation: operation,
      completer: completer,
      operationName: operationName ?? 'Unknown Operation',
      queuedAt: DateTime.now(),
      metadata: metadata ?? {},
    );

    _pendingOperations.add(pendingOp);
    
    developer.log(
      'Queued operation for offline execution: ${pendingOp.operationName}',
      name: 'NetworkHandler',
    );

    // Create offline error to notify user
    final offlineError = StorageError(
      type: StorageErrorType.networkUnavailable,
      message: 'Operation queued - will execute when connection is restored',
      context: operationName,
      timestamp: DateTime.now(),
      isRetryable: true,
      metadata: {
        ...?metadata,
        'queued': true,
        'queuedAt': DateTime.now().toIso8601String(),
      },
    );

    await StorageErrorHandler().handleError(offlineError);

    return completer.future;
  }

  /// Process pending operations when network comes back online
  Future<void> _processPendingOperations() async {
    if (_pendingOperations.isEmpty) return;

    developer.log(
      'Processing ${_pendingOperations.length} pending operations',
      name: 'NetworkHandler',
    );

    final operations = List<PendingOperation>.from(_pendingOperations);
    _pendingOperations.clear();

    for (final pendingOp in operations) {
      try {
        final result = await pendingOp.operation();
        pendingOp.completer.complete(result);
        
        developer.log(
          'Successfully executed queued operation: ${pendingOp.operationName}',
          name: 'NetworkHandler',
        );
      } catch (e) {
        pendingOp.completer.completeError(e);
        
        developer.log(
          'Failed to execute queued operation: ${pendingOp.operationName} - $e',
          name: 'NetworkHandler',
        );
      }
    }
  }

  /// Start retry timer for failed operations
  void _startRetryTimer() {
    _retryTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _retryFailedOperations(),
    );
  }

  /// Retry operations that failed due to network issues
  Future<void> _retryFailedOperations() async {
    if (isOffline) return;

    // This would integrate with your storage service to retry failed operations
    developer.log('Checking for failed operations to retry', name: 'NetworkHandler');
  }

  /// Check if an error is network-related
  bool _isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    return errorString.contains('socketexception') ||
           errorString.contains('timeout') ||
           errorString.contains('network') ||
           errorString.contains('connection') ||
           errorString.contains('unreachable') ||
           errorString.contains('no internet') ||
           error is SocketException ||
           error is TimeoutException;
  }

  /// Create appropriate network error
  StorageError _createNetworkError(
    dynamic error,
    String? operationName,
    Map<String, dynamic>? metadata,
  ) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('timeout')) {
      return StorageError.networkTimeout(
        context: operationName,
        metadata: metadata,
      );
    }
    
    return StorageError.networkUnavailable(
      context: operationName,
      metadata: metadata,
    );
  }

  /// Get network statistics
  NetworkStats getNetworkStats() {
    return NetworkStats(
      currentStatus: _currentStatus,
      pendingOperationsCount: _pendingOperations.length,
      oldestPendingOperation: _pendingOperations.isNotEmpty
          ? _pendingOperations.first.queuedAt
          : null,
    );
  }

  /// Clear pending operations (useful for cleanup)
  void clearPendingOperations() {
    for (final op in _pendingOperations) {
      op.completer.completeError(
        StorageError(
          type: StorageErrorType.uploadCancelled,
          message: 'Operation cancelled due to app restart or cleanup',
          timestamp: DateTime.now(),
        ),
      );
    }
    _pendingOperations.clear();
  }

  /// Dispose resources
  void dispose() {
    _connectivityTimer?.cancel();
    _retryTimer?.cancel();
    _statusController.close();
    clearPendingOperations();
  }
}

/// Network connectivity status
enum NetworkStatus {
  unknown,
  online,
  offline;

  String get displayName {
    switch (this) {
      case NetworkStatus.unknown:
        return 'Checking...';
      case NetworkStatus.online:
        return 'Online';
      case NetworkStatus.offline:
        return 'Offline';
    }
  }

  bool get isConnected => this == NetworkStatus.online;
}

/// Represents an operation queued for offline execution
class PendingOperation<T> {
  final Future<T> Function() operation;
  final Completer<T> completer;
  final String operationName;
  final DateTime queuedAt;
  final Map<String, dynamic> metadata;

  PendingOperation({
    required this.operation,
    required this.completer,
    required this.operationName,
    required this.queuedAt,
    required this.metadata,
  });

  /// How long this operation has been pending
  Duration get pendingDuration => DateTime.now().difference(queuedAt);

  /// Check if this operation has been pending too long
  bool get isStale => pendingDuration > const Duration(hours: 1);
}

/// Network statistics for monitoring
class NetworkStats {
  final NetworkStatus currentStatus;
  final int pendingOperationsCount;
  final DateTime? oldestPendingOperation;

  const NetworkStats({
    required this.currentStatus,
    required this.pendingOperationsCount,
    this.oldestPendingOperation,
  });

  /// Get formatted pending duration
  String get formattedPendingDuration {
    if (oldestPendingOperation == null) return 'None';
    
    final duration = DateTime.now().difference(oldestPendingOperation!);
    if (duration.inMinutes < 1) return '${duration.inSeconds}s';
    if (duration.inHours < 1) return '${duration.inMinutes}m';
    return '${duration.inHours}h ${duration.inMinutes % 60}m';
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStatus': currentStatus.name,
      'pendingOperationsCount': pendingOperationsCount,
      'oldestPendingOperation': oldestPendingOperation?.toIso8601String(),
      'formattedPendingDuration': formattedPendingDuration,
    };
  }
}

/// Retry strategy configuration
class RetryStrategy {
  final int maxRetries;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;
  final bool Function(Exception)? shouldRetry;

  const RetryStrategy({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(minutes: 1),
    this.shouldRetry,
  });

  /// Default strategy for network operations
  static const network = RetryStrategy(
    maxRetries: 3,
    initialDelay: Duration(seconds: 2),
    backoffMultiplier: 1.5,
    maxDelay: Duration(seconds: 30),
  );

  /// Aggressive strategy for critical operations
  static const aggressive = RetryStrategy(
    maxRetries: 5,
    initialDelay: Duration(milliseconds: 500),
    backoffMultiplier: 2.0,
    maxDelay: Duration(minutes: 2),
  );

  /// Conservative strategy for non-critical operations
  static const conservative = RetryStrategy(
    maxRetries: 2,
    initialDelay: Duration(seconds: 5),
    backoffMultiplier: 3.0,
    maxDelay: Duration(minutes: 5),
  );

  /// Calculate delay for given attempt
  Duration getDelayForAttempt(int attempt) {
    final delay = Duration(
      milliseconds: (initialDelay.inMilliseconds * 
          (backoffMultiplier * attempt)).round(),
    );
    
    return delay > maxDelay ? maxDelay : delay;
  }
}