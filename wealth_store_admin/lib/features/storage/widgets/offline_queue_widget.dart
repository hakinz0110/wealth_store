import 'dart:async';
import 'package:flutter/material.dart';
import '../services/offline_operation_queue.dart';

/// Widget to display and manage offline operation queue
class OfflineQueuePanel extends StatefulWidget {
  const OfflineQueuePanel({super.key});

  @override
  State<OfflineQueuePanel> createState() => _OfflineQueuePanelState();
}

class _OfflineQueuePanelState extends State<OfflineQueuePanel> {
  late final OfflineOperationQueue _queue;
  late final StreamSubscription<QueuedOperation> _operationSubscription;
  late final StreamSubscription<QueueStatus> _statusSubscription;
  
  QueueStatus _status = const QueueStatus(
    totalOperations: 0,
    pendingOperations: 0,
    failedOperations: 0,
    isProcessing: false,
  );
  
  List<QueuedOperation> _operations = [];

  @override
  void initState() {
    super.initState();
    _queue = OfflineOperationQueue();
    _status = _queue.currentStatus;
    
    _operationSubscription = _queue.operationStream.listen((operation) {
      setState(() {
        final index = _operations.indexWhere((op) => op.id == operation.id);
        if (index >= 0) {
          _operations[index] = operation;
        } else {
          _operations.add(operation);
        }
        _operations.sort((a, b) => b.queuedAt.compareTo(a.queuedAt));
      });
    });

    _statusSubscription = _queue.statusStream.listen((status) {
      setState(() {
        _status = status;
      });
    });

    // Load initial operations
    _loadOperations();
  }

  void _loadOperations() {
    setState(() {
      _operations = [
        ..._queue.getOperationsByStatus(OperationStatus.pending),
        ..._queue.getOperationsByStatus(OperationStatus.processing),
        ..._queue.getOperationsByStatus(OperationStatus.failed),
        ..._queue.getOperationsByStatus(OperationStatus.completed),
      ];
      _operations.sort((a, b) => b.queuedAt.compareTo(a.queuedAt));
    });
  }

  @override
  void dispose() {
    _operationSubscription.cancel();
    _statusSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_status.hasOperations) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No queued operations'),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Divider(height: 1),
          _buildOperationsList(),
          if (_status.hasOperations) ...[
            const Divider(height: 1),
            _buildActions(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            _status.isProcessing ? Icons.sync : Icons.queue,
            color: _status.isProcessing ? Colors.blue : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            'Operation Queue',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (_status.isProcessing)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildOperationsList() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: _operations.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final operation = _operations[index];
          return _buildOperationTile(operation);
        },
      ),
    );
  }

  Widget _buildOperationTile(QueuedOperation operation) {
    return ListTile(
      leading: _buildStatusIcon(operation.status),
      title: Text(
        operation.description,
        style: TextStyle(
          decoration: operation.status == OperationStatus.cancelled
              ? TextDecoration.lineThrough
              : null,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Type: ${operation.type} • Priority: ${operation.priority}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            'Queued: ${_formatDuration(operation.queuedDuration)} ago',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (operation.retryCount > 0)
            Text(
              'Retries: ${operation.retryCount}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.orange,
              ),
            ),
          if (operation.error != null)
            Text(
              'Error: ${operation.error}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.red,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      trailing: _buildOperationActions(operation),
      isThreeLine: true,
    );
  }

  Widget _buildStatusIcon(OperationStatus status) {
    switch (status) {
      case OperationStatus.pending:
        return const Icon(Icons.schedule, color: Colors.orange);
      case OperationStatus.processing:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case OperationStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.green);
      case OperationStatus.failed:
        return const Icon(Icons.error, color: Colors.red);
      case OperationStatus.cancelled:
        return const Icon(Icons.cancel, color: Colors.grey);
    }
  }

  Widget _buildOperationActions(QueuedOperation operation) {
    return PopupMenuButton<String>(
      onSelected: (action) => _handleOperationAction(operation, action),
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[];
        
        if (operation.status == OperationStatus.failed) {
          items.add(const PopupMenuItem(
            value: 'retry',
            child: Row(
              children: [
                Icon(Icons.refresh, size: 16),
                SizedBox(width: 8),
                Text('Retry'),
              ],
            ),
          ));
        }
        
        if (operation.status == OperationStatus.pending) {
          items.add(const PopupMenuItem(
            value: 'cancel',
            child: Row(
              children: [
                Icon(Icons.cancel, size: 16),
                SizedBox(width: 8),
                Text('Cancel'),
              ],
            ),
          ));
        }
        
        if (operation.status == OperationStatus.completed ||
            operation.status == OperationStatus.cancelled) {
          items.add(const PopupMenuItem(
            value: 'remove',
            child: Row(
              children: [
                Icon(Icons.delete, size: 16),
                SizedBox(width: 8),
                Text('Remove'),
              ],
            ),
          ));
        }
        
        items.add(const PopupMenuItem(
          value: 'details',
          child: Row(
            children: [
              Icon(Icons.info, size: 16),
              SizedBox(width: 8),
              Text('Details'),
            ],
          ),
        ));
        
        return items;
      },
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            '${_status.totalOperations} operations • '
            '${_status.pendingOperations} pending • '
            '${_status.failedOperations} failed',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          if (_status.hasFailedOperations)
            TextButton.icon(
              onPressed: _retryAllFailed,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry Failed'),
            ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _clearCompleted,
            icon: const Icon(Icons.clear, size: 16),
            label: const Text('Clear Completed'),
          ),
        ],
      ),
    );
  }

  void _handleOperationAction(QueuedOperation operation, String action) {
    switch (action) {
      case 'retry':
        _queue.retryOperation(operation.id);
        break;
      case 'cancel':
        _queue.cancelOperation(operation.id);
        break;
      case 'remove':
        _queue.removeOperation(operation.id);
        _loadOperations();
        break;
      case 'details':
        _showOperationDetails(operation);
        break;
    }
  }

  void _retryAllFailed() {
    final failedOperations = _queue.getOperationsByStatus(OperationStatus.failed);
    for (final operation in failedOperations) {
      _queue.retryOperation(operation.id);
    }
  }

  void _clearCompleted() {
    _queue.clearQueue(onlyCompleted: true);
    _loadOperations();
  }

  void _showOperationDetails(QueuedOperation operation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Operation Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', operation.id),
              _buildDetailRow('Type', operation.type),
              _buildDetailRow('Description', operation.description),
              _buildDetailRow('Status', operation.status.displayName),
              _buildDetailRow('Priority', operation.priority.toString()),
              _buildDetailRow('Queued At', operation.queuedAt.toString()),
              if (operation.completedAt != null)
                _buildDetailRow('Completed At', operation.completedAt.toString()),
              _buildDetailRow('Retry Count', operation.retryCount.toString()),
              if (operation.timeout != null)
                _buildDetailRow('Timeout', '${operation.timeout!.inSeconds}s'),
              if (operation.error != null)
                _buildDetailRow('Error', operation.error!),
              if (operation.metadata.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Metadata:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...operation.metadata.entries.map(
                  (entry) => _buildDetailRow(entry.key, entry.value.toString()),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 1) return '${duration.inSeconds}s';
    if (duration.inHours < 1) return '${duration.inMinutes}m';
    return '${duration.inHours}h ${duration.inMinutes % 60}m';
  }
}

/// Compact queue status indicator
class QueueStatusIndicator extends StatefulWidget {
  const QueueStatusIndicator({super.key});

  @override
  State<QueueStatusIndicator> createState() => _QueueStatusIndicatorState();
}

class _QueueStatusIndicatorState extends State<QueueStatusIndicator> {
  late final OfflineOperationQueue _queue;
  late final StreamSubscription<QueueStatus> _statusSubscription;
  
  QueueStatus _status = const QueueStatus(
    totalOperations: 0,
    pendingOperations: 0,
    failedOperations: 0,
    isProcessing: false,
  );

  @override
  void initState() {
    super.initState();
    _queue = OfflineOperationQueue();
    _status = _queue.currentStatus;
    
    _statusSubscription = _queue.statusStream.listen((status) {
      setState(() {
        _status = status;
      });
    });
  }

  @override
  void dispose() {
    _statusSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_status.hasOperations) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_status.isProcessing)
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            )
          else
            Icon(
              Icons.queue,
              size: 12,
              color: _getStatusColor(),
            ),
          const SizedBox(width: 4),
          Text(
            '${_status.pendingOperations}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _getStatusColor(),
            ),
          ),
          if (_status.hasFailedOperations) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.error,
              size: 10,
              color: Colors.red,
            ),
            Text(
              '${_status.failedOperations}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (_status.hasFailedOperations) return Colors.red;
    if (_status.isProcessing) return Colors.blue;
    return Colors.orange;
  }
}