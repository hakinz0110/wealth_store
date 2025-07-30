import 'dart:async';
import 'package:flutter/material.dart';
import '../services/network_error_handler.dart';

/// Widget that displays current network connection status
class NetworkStatusIndicator extends StatefulWidget {
  final bool showWhenOnline;
  final EdgeInsets? padding;
  final TextStyle? textStyle;

  const NetworkStatusIndicator({
    super.key,
    this.showWhenOnline = false,
    this.padding,
    this.textStyle,
  });

  @override
  State<NetworkStatusIndicator> createState() => _NetworkStatusIndicatorState();
}

class _NetworkStatusIndicatorState extends State<NetworkStatusIndicator>
    with SingleTickerProviderStateMixin {
  late final NetworkErrorHandler _networkHandler;
  late final StreamSubscription<NetworkStatus> _statusSubscription;
  late final AnimationController _animationController;
  late final Animation<double> _pulseAnimation;
  
  NetworkStatus _currentStatus = NetworkStatus.unknown;

  @override
  void initState() {
    super.initState();
    _networkHandler = NetworkErrorHandler();
    _currentStatus = _networkHandler.currentStatus;
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _statusSubscription = _networkHandler.statusStream.listen((status) {
      setState(() {
        _currentStatus = status;
      });
      
      if (status == NetworkStatus.offline) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    });

    // Start animation if already offline
    if (_currentStatus == NetworkStatus.offline) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _statusSubscription.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything if online and showWhenOnline is false
    if (_currentStatus == NetworkStatus.online && !widget.showWhenOnline) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: widget.padding ?? const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(
              _currentStatus == NetworkStatus.offline 
                  ? _pulseAnimation.value * 0.2 
                  : 0.1,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getStatusColor().withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(),
                size: 16,
                color: _getStatusColor(),
              ),
              const SizedBox(width: 6),
              Text(
                _currentStatus.displayName,
                style: widget.textStyle ?? TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getStatusColor(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor() {
    switch (_currentStatus) {
      case NetworkStatus.unknown:
        return Colors.grey;
      case NetworkStatus.online:
        return Colors.green;
      case NetworkStatus.offline:
        return Colors.red;
    }
  }

  IconData _getStatusIcon() {
    switch (_currentStatus) {
      case NetworkStatus.unknown:
        return Icons.help_outline;
      case NetworkStatus.online:
        return Icons.wifi;
      case NetworkStatus.offline:
        return Icons.wifi_off;
    }
  }
}

/// Comprehensive network status panel with statistics
class NetworkStatusPanel extends StatefulWidget {
  const NetworkStatusPanel({super.key});

  @override
  State<NetworkStatusPanel> createState() => _NetworkStatusPanelState();
}

class _NetworkStatusPanelState extends State<NetworkStatusPanel> {
  late final NetworkErrorHandler _networkHandler;
  late final StreamSubscription<NetworkStatus> _statusSubscription;
  late final Timer _statsTimer;
  
  NetworkStatus _currentStatus = NetworkStatus.unknown;
  NetworkStats _stats = const NetworkStats(
    currentStatus: NetworkStatus.unknown,
    pendingOperationsCount: 0,
  );

  @override
  void initState() {
    super.initState();
    _networkHandler = NetworkErrorHandler();
    _currentStatus = _networkHandler.currentStatus;
    _stats = _networkHandler.getNetworkStats();
    
    _statusSubscription = _networkHandler.statusStream.listen((status) {
      setState(() {
        _currentStatus = status;
        _stats = _networkHandler.getNetworkStats();
      });
    });

    // Update stats periodically
    _statsTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => setState(() {
        _stats = _networkHandler.getNetworkStats();
      }),
    );
  }

  @override
  void dispose() {
    _statusSubscription.cancel();
    _statsTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Network Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _currentStatus.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              'Connection Status',
              _currentStatus.displayName,
              _getStatusColor(),
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              'Pending Operations',
              '${_stats.pendingOperationsCount}',
              _stats.pendingOperationsCount > 0 ? Colors.orange : Colors.grey,
            ),
            if (_stats.oldestPendingOperation != null) ...[
              const SizedBox(height: 8),
              _buildStatRow(
                'Oldest Pending',
                _stats.formattedPendingDuration,
                Colors.orange,
              ),
            ],
            if (_stats.pendingOperationsCount > 0) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _currentStatus == NetworkStatus.online
                          ? () => _retryPendingOperations()
                          : null,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Retry Pending'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _clearPendingOperations(),
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Clear Queue'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (_currentStatus) {
      case NetworkStatus.unknown:
        return Colors.grey;
      case NetworkStatus.online:
        return Colors.green;
      case NetworkStatus.offline:
        return Colors.red;
    }
  }

  IconData _getStatusIcon() {
    switch (_currentStatus) {
      case NetworkStatus.unknown:
        return Icons.help_outline;
      case NetworkStatus.online:
        return Icons.wifi;
      case NetworkStatus.offline:
        return Icons.wifi_off;
    }
  }

  void _retryPendingOperations() {
    // This would trigger retry of pending operations
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Retrying pending operations...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearPendingOperations() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Pending Operations'),
        content: const Text(
          'Are you sure you want to clear all pending operations? '
          'This will cancel any queued uploads or file operations.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _networkHandler.clearPendingOperations();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pending operations cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

/// Simple connection status badge for app bars
class ConnectionStatusBadge extends StatefulWidget {
  const ConnectionStatusBadge({super.key});

  @override
  State<ConnectionStatusBadge> createState() => _ConnectionStatusBadgeState();
}

class _ConnectionStatusBadgeState extends State<ConnectionStatusBadge> {
  late final NetworkErrorHandler _networkHandler;
  late final StreamSubscription<NetworkStatus> _statusSubscription;
  
  NetworkStatus _currentStatus = NetworkStatus.unknown;

  @override
  void initState() {
    super.initState();
    _networkHandler = NetworkErrorHandler();
    _currentStatus = _networkHandler.currentStatus;
    
    _statusSubscription = _networkHandler.statusStream.listen((status) {
      setState(() {
        _currentStatus = status;
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
    if (_currentStatus == NetworkStatus.online) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: _getStatusColor(),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (_currentStatus) {
      case NetworkStatus.unknown:
        return Colors.grey;
      case NetworkStatus.online:
        return Colors.green;
      case NetworkStatus.offline:
        return Colors.red;
    }
  }
}

/// Mixin for widgets that need network status awareness
mixin NetworkStatusMixin<T extends StatefulWidget> on State<T> {
  late final NetworkErrorHandler _networkHandler;
  late final StreamSubscription<NetworkStatus> _statusSubscription;
  
  NetworkStatus _networkStatus = NetworkStatus.unknown;

  /// Current network status
  NetworkStatus get networkStatus => _networkStatus;

  /// Check if currently online
  bool get isOnline => _networkStatus == NetworkStatus.online;

  /// Check if currently offline
  bool get isOffline => _networkStatus == NetworkStatus.offline;

  /// Initialize network status monitoring
  void initNetworkStatus() {
    _networkHandler = NetworkErrorHandler();
    _networkStatus = _networkHandler.currentStatus;
    
    _statusSubscription = _networkHandler.statusStream.listen((status) {
      setState(() {
        _networkStatus = status;
      });
      onNetworkStatusChanged(status);
    });
  }

  /// Called when network status changes - override in implementing classes
  void onNetworkStatusChanged(NetworkStatus status) {
    // Default implementation - can be overridden
  }

  /// Dispose network status monitoring
  void disposeNetworkStatus() {
    _statusSubscription.cancel();
  }

  /// Execute operation with network awareness
  Future<T?> executeWithNetworkCheck<T>(
    Future<T> Function() operation, {
    String? operationName,
    bool queueWhenOffline = true,
  }) async {
    return await _networkHandler.handleNetworkOperation(
      operation,
      operationName: operationName ?? runtimeType.toString(),
      queueWhenOffline: queueWhenOffline,
    );
  }
}