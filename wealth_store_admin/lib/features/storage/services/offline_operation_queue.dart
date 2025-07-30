import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../models/storage_error.dart';
import 'network_error_handler.dart';
import 'storage_error_handler.dart';

/// Manages queuing and execution of operations when offline
class OfflineOperationQueue {
  static final OfflineOperationQueue _instance = OfflineOperationQueue._internal();
  factory OfflineOperationQueue() => _instance;
  OfflineOperationQueue._internal();

  final List<QueuedOperation> _queue = [];
  final StreamController<QueuedOperation> _operationController = 
      StreamController<QueuedOperation>.broadcast();
  final StreamController<QueueStatus> _statusController = 
      StreamController<QueueStatus>.broadcast();

  late final StreamSubscription<NetworkStatus> _networkSubscription;
  Timer? _processingTimer;
  bool _isProcessing = false;

  /// Stream of queued operations
  Stream<QueuedOperation> get operationStream => _operationController.stream;

  /// Stream of queue status changes
  Stream<QueueStatus> get statusStream => _statusController.stream;

  /// Current queue status
  QueueStatus get currentStatus => QueueStatus(
    totalOperations: _queue.length,
    pendingOperations: _queue.where((op) => op.status == OperationStatus.pending).length,
    failedOperations: _queue.where((op) => op.status == OperationStatus.failed).length,
    isProcessing: _isProcessing,
  );

  /// Initialize the queue system
  void initialize() {
    final networkHandler = NetworkErrorHandler();
    
    _networkSubscription = networkHandler.statusStream.listen((status) {
      if (status == NetworkStatus.online && !_isProcessing) {
        _processQueue();
      }
    });

    // Start periodic processing
    _processingTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _processQueue(),
    );
  }

  /// Add operation to queue
  Future<String> queueOperation({
    required String type,
    required String description,
    required Map<String, dynamic> data,
    required Future<dynamic> Function() operation,
    int priority = 0,
    Duration? timeout,
    Map<String, dynamic>? metadata,
  }) async {
    final queuedOp = QueuedOperation(
      type: type,
      description: description,
      data: data,
      operation: operation,
      priority: priority,
      timeout: timeout,
      metadata: metadata ?? {},
    );

    _queue.add(queuedOp);
    _sortQueueByPriority();
    
    _operationController.add(queuedOp);
    _statusController.add(currentStatus);

    developer.log(
      'Queued operation: ${queuedOp.description} (ID: ${queuedOp.id})',
      name: 'OfflineQueue',
    );

    // Try to process immediately if online
    if (NetworkErrorHandler().isOnline) {
      _processQueue();
    }

    return queuedOp.id;
  }

  /// Process the queue
  Future<void> _processQueue() async {
    if (_isProcessing || _queue.isEmpty) return;
    if (!NetworkErrorHandler().isOnline) return;

    _isProcessing = true;
    _statusController.add(currentStatus);

    developer.log('Processing offline operation queue', name: 'OfflineQueue');

    final pendingOperations = _queue
        .where((op) => op.status == OperationStatus.pending)
        .toList();

    for (final operation in pendingOperations) {
      await _processOperation(operation);
      
      // Small delay between operations to prevent overwhelming the server
      await Future.delayed(const Duration(milliseconds: 500));
    }

    _isProcessing = false;
    _statusController.add(currentStatus);

    // Clean up completed operations older than 1 hour
    _cleanupOldOperations();
  }

  /// Process a single operation
  Future<void> _processOperation(QueuedOperation operation) async {
    try {
      operation._updateStatus(OperationStatus.processing);
      _operationController.add(operation);

      developer.log(
        'Processing operation: ${operation.description}',
        name: 'OfflineQueue',
      );

      // Execute the operation with timeout
      final result = operation.timeout != null
          ? await operation.operation().timeout(operation.timeout!)
          : await operation.operation();

      operation._updateStatus(OperationStatus.completed, result: result);
      _operationController.add(operation);

      developer.log(
        'Completed operation: ${operation.description}',
        name: 'OfflineQueue',
      );

    } catch (e) {
      operation._updateStatus(
        OperationStatus.failed,
        error: e.toString(),
      );
      _operationController.add(operation);

      developer.log(
        'Failed operation: ${operation.description} - $e',
        name: 'OfflineQueue',
      );

      // Handle the error through the error handler
      final storageError = StorageError.fromException(
        e is Exception ? e : Exception(e.toString()),
        context: 'Offline Queue: ${operation.description}',
        metadata: {
          'operationId': operation.id,
          'operationType': operation.type,
          'queuedAt': operation.queuedAt.toIso8601String(),
          ...operation.metadata,
        },
      );

      await StorageErrorHandler().handleError(storageError);
    }
  }

  /// Sort queue by priority (higher priority first)
  void _sortQueueByPriority() {
    _queue.sort((a, b) => b.priority.compareTo(a.priority));
  }

  /// Clean up old completed operations
  void _cleanupOldOperations() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 1));
    
    _queue.removeWhere((op) => 
        (op.status == OperationStatus.completed || 
         op.status == OperationStatus.failed) &&
        op.completedAt != null &&
        op.completedAt!.isBefore(cutoff)
    );
  }

  /// Retry failed operation
  Future<void> retryOperation(String operationId) async {
    final operation = _queue.firstWhere(
      (op) => op.id == operationId,
      orElse: () => throw ArgumentError('Operation not found: $operationId'),
    );

    if (operation.status != OperationStatus.failed) {
      throw StateError('Operation is not in failed state');
    }

    operation._updateStatus(OperationStatus.pending);
    operation._incrementRetryCount();
    _operationController.add(operation);

    developer.log(
      'Retrying operation: ${operation.description} (attempt ${operation.retryCount})',
      name: 'OfflineQueue',
    );

    if (NetworkErrorHandler().isOnline) {
      _processQueue();
    }
  }

  /// Cancel operation
  void cancelOperation(String operationId) {
    final operation = _queue.firstWhere(
      (op) => op.id == operationId,
      orElse: () => throw ArgumentError('Operation not found: $operationId'),
    );

    if (operation.status == OperationStatus.processing) {
      throw StateError('Cannot cancel operation that is currently processing');
    }

    operation._updateStatus(OperationStatus.cancelled);
    _operationController.add(operation);

    developer.log(
      'Cancelled operation: ${operation.description}',
      name: 'OfflineQueue',
    );
  }

  /// Remove operation from queue
  void removeOperation(String operationId) {
    _queue.removeWhere((op) => op.id == operationId);
    _statusController.add(currentStatus);
  }

  /// Clear all operations
  void clearQueue({bool onlyCompleted = false}) {
    if (onlyCompleted) {
      _queue.removeWhere((op) => 
          op.status == OperationStatus.completed ||
          op.status == OperationStatus.cancelled
      );
    } else {
      _queue.clear();
    }
    
    _statusController.add(currentStatus);
    
    developer.log(
      onlyCompleted ? 'Cleared completed operations' : 'Cleared all operations',
      name: 'OfflineQueue',
    );
  }

  /// Get operations by status
  List<QueuedOperation> getOperationsByStatus(OperationStatus status) {
    return _queue.where((op) => op.status == status).toList();
  }

  /// Get operations by type
  List<QueuedOperation> getOperationsByType(String type) {
    return _queue.where((op) => op.type == type).toList();
  }

  /// Export queue state for debugging
  Map<String, dynamic> exportQueueState() {
    return {
      'totalOperations': _queue.length,
      'isProcessing': _isProcessing,
      'operations': _queue.map((op) => op.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Import queue state (for testing or recovery)
  void importQueueState(Map<String, dynamic> state) {
    _queue.clear();
    
    final operations = state['operations'] as List<dynamic>;
    for (final opData in operations) {
      // Note: This would need to reconstruct the operation functions
      // In practice, you'd need a registry of operation types
      developer.log('Would import operation: ${opData['description']}', name: 'OfflineQueue');
    }
  }

  /// Dispose resources
  void dispose() {
    _networkSubscription.cancel();
    _processingTimer?.cancel();
    _operationController.close();
    _statusController.close();
    _queue.clear();
  }
}

/// Represents a queued operation
class QueuedOperation {
  final String id;
  final String type;
  final String description;
  final Map<String, dynamic> data;
  final Future<dynamic> Function() operation;
  final int priority;
  final Duration? timeout;
  final Map<String, dynamic> metadata;
  final DateTime queuedAt;

  OperationStatus _status = OperationStatus.pending;
  DateTime? _completedAt;
  dynamic _result;
  String? _error;
  int _retryCount = 0;

  QueuedOperation({
    String? id,
    required this.type,
    required this.description,
    required this.data,
    required this.operation,
    this.priority = 0,
    this.timeout,
    this.metadata = const {},
    DateTime? queuedAt,
  }) : id = id ?? _generateId(),
       queuedAt = queuedAt ?? DateTime.now();

  static String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  /// Current status
  OperationStatus get status => _status;

  /// Completion time
  DateTime? get completedAt => _completedAt;

  /// Operation result
  dynamic get result => _result;

  /// Error message if failed
  String? get error => _error;

  /// Number of retry attempts
  int get retryCount => _retryCount;

  /// How long this operation has been queued
  Duration get queuedDuration => DateTime.now().difference(queuedAt);

  /// Update operation status
  void _updateStatus(
    OperationStatus newStatus, {
    dynamic result,
    String? error,
  }) {
    _status = newStatus;
    
    if (newStatus == OperationStatus.completed || 
        newStatus == OperationStatus.failed ||
        newStatus == OperationStatus.cancelled) {
      _completedAt = DateTime.now();
    }
    
    if (result != null) {
      _result = result;
    }
    
    if (error != null) {
      _error = error;
    }
  }

  /// Increment retry count
  void _incrementRetryCount() {
    _retryCount++;
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'data': data,
      'priority': priority,
      'timeout': timeout?.inMilliseconds,
      'metadata': metadata,
      'queuedAt': queuedAt.toIso8601String(),
      'status': _status.name,
      'completedAt': _completedAt?.toIso8601String(),
      'error': _error,
      'retryCount': _retryCount,
    };
  }
}

/// Operation status enum
enum OperationStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled;

  String get displayName {
    switch (this) {
      case OperationStatus.pending:
        return 'Pending';
      case OperationStatus.processing:
        return 'Processing';
      case OperationStatus.completed:
        return 'Completed';
      case OperationStatus.failed:
        return 'Failed';
      case OperationStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isActive => this == OperationStatus.pending || this == OperationStatus.processing;
  bool get isComplete => this == OperationStatus.completed;
  bool get isFailed => this == OperationStatus.failed;
}

/// Queue status information
class QueueStatus {
  final int totalOperations;
  final int pendingOperations;
  final int failedOperations;
  final bool isProcessing;

  const QueueStatus({
    required this.totalOperations,
    required this.pendingOperations,
    required this.failedOperations,
    required this.isProcessing,
  });

  int get completedOperations => totalOperations - pendingOperations - failedOperations;
  
  bool get hasOperations => totalOperations > 0;
  bool get hasPendingOperations => pendingOperations > 0;
  bool get hasFailedOperations => failedOperations > 0;

  Map<String, dynamic> toJson() {
    return {
      'totalOperations': totalOperations,
      'pendingOperations': pendingOperations,
      'failedOperations': failedOperations,
      'completedOperations': completedOperations,
      'isProcessing': isProcessing,
    };
  }
}