import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/storage_error.dart';
import '../services/storage_error_handler.dart';

/// Widget to display storage errors with user-friendly messages and actions
class StorageErrorDisplay extends StatelessWidget {
  final StorageError error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool showTechnicalDetails;
  final bool compact;

  const StorageErrorDisplay({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
    this.showTechnicalDetails = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactError(context);
    }
    return _buildFullError(context);
  }

  Widget _buildCompactError(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getErrorColor(context).withOpacity(0.1),
        border: Border.left(
          width: 4,
          color: _getErrorColor(context),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(
            _getErrorIcon(),
            color: _getErrorColor(context),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error.message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (error.isRetryable && onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
          if (onDismiss != null) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close, size: 18),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFullError(BuildContext context) {
    return Card(
      color: _getErrorColor(context).withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getErrorIcon(),
                  color: _getErrorColor(context),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  error.severity.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _getErrorColor(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (onDismiss != null)
                  IconButton(
                    onPressed: onDismiss,
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              error.userMessage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (error.context != null) ...[
              const SizedBox(height: 8),
              Text(
                'Context: ${error.context}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
            if (showTechnicalDetails && error.technicalDetails != null) ...[
              const SizedBox(height: 8),
              ExpansionTile(
                title: const Text('Technical Details'),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          error.technicalDetails!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Timestamp: ${error.timestamp}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        if (error.metadata != null && error.metadata!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Metadata: ${error.metadata}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (showTechnicalDetails) ...[
                  TextButton.icon(
                    onPressed: () => _copyErrorDetails(context),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy Details'),
                  ),
                  const SizedBox(width: 8),
                ],
                if (error.isRetryable && onRetry != null) ...[
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Retry'),
                  ),
                  const SizedBox(width: 8),
                ],
                TextButton(
                  onPressed: onDismiss ?? () {},
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getErrorColor(BuildContext context) {
    switch (error.severity) {
      case StorageErrorSeverity.info:
        return Colors.blue;
      case StorageErrorSeverity.warning:
        return Colors.orange;
      case StorageErrorSeverity.error:
        return Colors.red;
      case StorageErrorSeverity.critical:
        return Colors.red[800]!;
    }
  }

  IconData _getErrorIcon() {
    switch (error.severity) {
      case StorageErrorSeverity.info:
        return Icons.info_outline;
      case StorageErrorSeverity.warning:
        return Icons.warning_amber_outlined;
      case StorageErrorSeverity.error:
        return Icons.error_outline;
      case StorageErrorSeverity.critical:
        return Icons.dangerous_outlined;
    }
  }

  void _copyErrorDetails(BuildContext context) {
    final details = StringBuffer();
    details.writeln('Error Type: ${error.type.name}');
    details.writeln('Message: ${error.message}');
    if (error.context != null) {
      details.writeln('Context: ${error.context}');
    }
    if (error.technicalDetails != null) {
      details.writeln('Technical Details: ${error.technicalDetails}');
    }
    details.writeln('Timestamp: ${error.timestamp}');
    details.writeln('Retryable: ${error.isRetryable}');
    if (error.metadata != null) {
      details.writeln('Metadata: ${error.metadata}');
    }

    Clipboard.setData(ClipboardData(text: details.toString()));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error details copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Toast-style error notification
class StorageErrorToast extends StatelessWidget {
  final StorageError error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const StorageErrorToast({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getErrorColor(context).withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getErrorIcon(),
              color: _getErrorColor(context),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    error.severity.displayName,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: _getErrorColor(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    error.message,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (error.isRetryable && onRetry != null)
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  minimumSize: const Size(60, 32),
                ),
                child: const Text('Retry'),
              ),
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close, size: 18),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }

  Color _getErrorColor(BuildContext context) {
    switch (error.severity) {
      case StorageErrorSeverity.info:
        return Colors.blue;
      case StorageErrorSeverity.warning:
        return Colors.orange;
      case StorageErrorSeverity.error:
        return Colors.red;
      case StorageErrorSeverity.critical:
        return Colors.red[800]!;
    }
  }

  IconData _getErrorIcon() {
    switch (error.severity) {
      case StorageErrorSeverity.info:
        return Icons.info_outline;
      case StorageErrorSeverity.warning:
        return Icons.warning_amber_outlined;
      case StorageErrorSeverity.error:
        return Icons.error_outline;
      case StorageErrorSeverity.critical:
        return Icons.dangerous_outlined;
    }
  }
}

/// Error boundary widget that catches and displays errors
class StorageErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(StorageError error)? errorBuilder;

  const StorageErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<StorageErrorBoundary> createState() => _StorageErrorBoundaryState();
}

class _StorageErrorBoundaryState extends State<StorageErrorBoundary> {
  StorageError? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ?? 
          StorageErrorDisplay(
            error: _error!,
            onRetry: () => setState(() => _error = null),
            showTechnicalDetails: true,
          );
    }

    return widget.child;
  }

  void _handleError(StorageError error) {
    setState(() {
      _error = error;
    });
  }
}

/// Global error overlay manager
class StorageErrorOverlay {
  static OverlayEntry? _currentOverlay;

  /// Show error toast overlay
  static void showErrorToast(
    BuildContext context,
    StorageError error, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onRetry,
  }) {
    _removeCurrentOverlay();

    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: StorageErrorToast(
          error: error,
          onRetry: onRetry,
          onDismiss: _removeCurrentOverlay,
        ),
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);

    // Auto-dismiss after duration
    Timer(duration, _removeCurrentOverlay);
  }

  /// Remove current overlay
  static void _removeCurrentOverlay() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

/// Extension to easily show error toasts
extension StorageErrorContext on BuildContext {
  void showStorageError(
    StorageError error, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onRetry,
  }) {
    StorageErrorOverlay.showErrorToast(
      this,
      error,
      duration: duration,
      onRetry: onRetry,
    );
  }
}