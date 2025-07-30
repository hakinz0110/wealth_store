import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:async';
import '../providers/statistics_providers.dart';
import '../services/storage_statistics_service.dart';
import '../../../shared/utils/logger.dart';

/// Widget that provides statistics refresh and caching controls
class StatisticsRefreshController extends ConsumerStatefulWidget {
  final Widget child;
  final bool enableAutoRefresh;
  final Duration autoRefreshInterval;
  final List<String>? specificBuckets;

  const StatisticsRefreshController({
    super.key,
    required this.child,
    this.enableAutoRefresh = false,
    this.autoRefreshInterval = const Duration(minutes: 5),
    this.specificBuckets,
  });

  @override
  ConsumerState<StatisticsRefreshController> createState() => _StatisticsRefreshControllerState();
}

class _StatisticsRefreshControllerState extends ConsumerState<StatisticsRefreshController> {
  Timer? _autoRefreshTimer;
  bool _isRefreshing = false;
  DateTime? _lastRefreshTime;
  StreamSubscription? _statisticsStreamSubscription;

  @override
  void initState() {
    super.initState();
    _initializeRefreshController();
  }

  @override
  void didUpdateWidget(StatisticsRefreshController oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Restart auto-refresh if settings changed
    if (oldWidget.enableAutoRefresh != widget.enableAutoRefresh ||
        oldWidget.autoRefreshInterval != widget.autoRefreshInterval) {
      _stopAutoRefresh();
      if (widget.enableAutoRefresh) {
        _startAutoRefresh();
      }
    }
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    _statisticsStreamSubscription?.cancel();
    super.dispose();
  }

  void _initializeRefreshController() {
    try {
      Logger.info('Initializing statistics refresh controller');
      
      // Set up real-time statistics updates
      _setupRealTimeUpdates();
      
      // Start auto-refresh if enabled
      if (widget.enableAutoRefresh) {
        _startAutoRefresh();
      }
      
      // Set initial refresh state
      ref.read(autoRefreshEnabledProvider.notifier).state = widget.enableAutoRefresh;
      ref.read(autoRefreshIntervalProvider.notifier).state = widget.autoRefreshInterval;
      
      Logger.info('Statistics refresh controller initialized');
    } catch (e) {
      Logger.error('Failed to initialize statistics refresh controller', e);
    }
  }

  void _setupRealTimeUpdates() {
    try {
      Logger.info('Setting up real-time statistics updates');
      
      final statisticsService = ref.read(storageStatisticsServiceProvider);
      _statisticsStreamSubscription = statisticsService.statisticsStream.listen(
        (updatedStats) {
          Logger.debug('Received real-time statistics update for ${updatedStats.length} buckets');
          
          // Invalidate relevant providers to trigger UI updates
          for (final bucketId in updatedStats.keys) {
            ref.invalidate(bucketStatsProvider(bucketId));
          }
          
          // Invalidate overall statistics
          ref.invalidate(overallStorageStatsProvider);
          ref.invalidate(allBucketStatsProvider);
          ref.invalidate(dashboardSummaryProvider);
          
          // Update last refresh time
          setState(() {
            _lastRefreshTime = DateTime.now();
          });
        },
        onError: (error) {
          Logger.error('Error in real-time statistics stream', error);
        },
      );
      
      Logger.info('Real-time statistics updates configured');
    } catch (e) {
      Logger.error('Failed to setup real-time statistics updates', e);
    }
  }

  void _startAutoRefresh() {
    try {
      Logger.info('Starting auto-refresh with interval: ${widget.autoRefreshInterval.inMinutes} minutes');
      
      _autoRefreshTimer = Timer.periodic(widget.autoRefreshInterval, (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        
        _performAutoRefresh();
      });
      
      // Update provider state
      ref.read(autoRefreshEnabledProvider.notifier).state = true;
      
      Logger.info('Auto-refresh started');
    } catch (e) {
      Logger.error('Failed to start auto-refresh', e);
    }
  }

  void _stopAutoRefresh() {
    try {
      Logger.info('Stopping auto-refresh');
      
      _autoRefreshTimer?.cancel();
      _autoRefreshTimer = null;
      
      // Update provider state
      if (mounted) {
        ref.read(autoRefreshEnabledProvider.notifier).state = false;
      }
      
      Logger.info('Auto-refresh stopped');
    } catch (e) {
      Logger.error('Failed to stop auto-refresh', e);
    }
  }

  Future<void> _performAutoRefresh() async {
    if (_isRefreshing) {
      Logger.debug('Auto-refresh skipped - already refreshing');
      return;
    }

    try {
      Logger.debug('Performing auto-refresh');
      
      setState(() {
        _isRefreshing = true;
      });

      final statisticsService = ref.read(storageStatisticsServiceProvider);
      
      if (widget.specificBuckets != null && widget.specificBuckets!.isNotEmpty) {
        // Refresh specific buckets
        for (final bucketId in widget.specificBuckets!) {
          await statisticsService.calculateBucketStatistics(bucketId);
        }
      } else {
        // Refresh all statistics
        await statisticsService.calculateAllBucketStatistics();
      }
      
      setState(() {
        _lastRefreshTime = DateTime.now();
      });
      
      Logger.debug('Auto-refresh completed');
    } catch (e) {
      Logger.error('Auto-refresh failed', e);
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _performManualRefresh() async {
    if (_isRefreshing) {
      Logger.debug('Manual refresh skipped - already refreshing');
      return;
    }

    try {
      Logger.info('Performing manual refresh');
      
      setState(() {
        _isRefreshing = true;
      });

      final statisticsMethods = ref.read(statisticsMethodsProvider);
      
      if (widget.specificBuckets != null && widget.specificBuckets!.isNotEmpty) {
        // Refresh specific buckets
        for (final bucketId in widget.specificBuckets!) {
          await statisticsMethods.refreshBucketStats(bucketId);
        }
      } else {
        // Refresh all statistics
        await statisticsMethods.refreshAllStats();
      }
      
      setState(() {
        _lastRefreshTime = DateTime.now();
      });
      
      Logger.info('Manual refresh completed');
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Statistics refreshed successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      Logger.error('Manual refresh failed', e);
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh statistics: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void _toggleAutoRefresh() {
    try {
      final isCurrentlyEnabled = ref.read(autoRefreshEnabledProvider);
      
      if (isCurrentlyEnabled) {
        _stopAutoRefresh();
        Logger.info('Auto-refresh disabled by user');
      } else {
        _startAutoRefresh();
        Logger.info('Auto-refresh enabled by user');
      }
    } catch (e) {
      Logger.error('Failed to toggle auto-refresh', e);
    }
  }

  void _updateAutoRefreshInterval(Duration newInterval) {
    try {
      Logger.info('Updating auto-refresh interval to: ${newInterval.inMinutes} minutes');
      
      ref.read(autoRefreshIntervalProvider.notifier).state = newInterval;
      
      // Restart auto-refresh with new interval if currently enabled
      if (ref.read(autoRefreshEnabledProvider)) {
        _stopAutoRefresh();
        _startAutoRefresh();
      }
      
      Logger.info('Auto-refresh interval updated');
    } catch (e) {
      Logger.error('Failed to update auto-refresh interval', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAutoRefreshEnabled = ref.watch(autoRefreshEnabledProvider);
    final autoRefreshInterval = ref.watch(autoRefreshIntervalProvider);

    return Column(
      children: [
        // Refresh controls
        _buildRefreshControls(context, isAutoRefreshEnabled, autoRefreshInterval),
        
        // Main content
        Expanded(child: widget.child),
      ],
    );
  }

  Widget _buildRefreshControls(
    BuildContext context,
    bool isAutoRefreshEnabled,
    Duration autoRefreshInterval,
  ) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.refresh,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Statistics Refresh',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                
                // Manual refresh button
                IconButton(
                  icon: _isRefreshing
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : const Icon(Icons.refresh),
                  onPressed: _isRefreshing ? null : _performManualRefresh,
                  tooltip: 'Manual Refresh',
                ),
                
                // Auto-refresh toggle
                Switch(
                  value: isAutoRefreshEnabled,
                  onChanged: (_) => _toggleAutoRefresh(),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Status and controls row
            Row(
              children: [
                // Last refresh time
                if (_lastRefreshTime != null)
                  Expanded(
                    child: Text(
                      'Last updated: ${_formatDateTime(_lastRefreshTime!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                
                // Auto-refresh interval selector
                if (isAutoRefreshEnabled) ...[
                  const SizedBox(width: 16),
                  Text(
                    'Interval:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<Duration>(
                    value: autoRefreshInterval,
                    isDense: true,
                    items: const [
                      DropdownMenuItem(
                        value: Duration(minutes: 1),
                        child: Text('1 min'),
                      ),
                      DropdownMenuItem(
                        value: Duration(minutes: 5),
                        child: Text('5 min'),
                      ),
                      DropdownMenuItem(
                        value: Duration(minutes: 10),
                        child: Text('10 min'),
                      ),
                      DropdownMenuItem(
                        value: Duration(minutes: 30),
                        child: Text('30 min'),
                      ),
                      DropdownMenuItem(
                        value: Duration(hours: 1),
                        child: Text('1 hour'),
                      ),
                    ],
                    onChanged: (Duration? newInterval) {
                      if (newInterval != null) {
                        _updateAutoRefreshInterval(newInterval);
                      }
                    },
                  ),
                ],
              ],
            ),
            
            // Cache status indicator
            _buildCacheStatusIndicator(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheStatusIndicator(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cached,
            size: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            'Statistics cached for performance',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// Provider for refresh controller state
final refreshControllerStateProvider = StateProvider<RefreshControllerState>((ref) {
  return RefreshControllerState();
});

/// State class for refresh controller
class RefreshControllerState {
  final bool isRefreshing;
  final DateTime? lastRefreshTime;
  final String? lastError;

  const RefreshControllerState({
    this.isRefreshing = false,
    this.lastRefreshTime,
    this.lastError,
  });

  RefreshControllerState copyWith({
    bool? isRefreshing,
    DateTime? lastRefreshTime,
    String? lastError,
  }) {
    return RefreshControllerState(
      isRefreshing: isRefreshing ?? this.isRefreshing,
      lastRefreshTime: lastRefreshTime ?? this.lastRefreshTime,
      lastError: lastError ?? this.lastError,
    );
  }
}

/// Widget for displaying cache statistics and controls
class CacheStatisticsWidget extends ConsumerWidget {
  const CacheStatisticsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cached,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cache Statistics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Cache'),
                  onPressed: () => _clearCache(context, ref),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _buildCacheMetrics(context),
            
            const SizedBox(height: 16),
            
            _buildCacheControls(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheMetrics(BuildContext context) {
    // In a real implementation, these would come from the cache service
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildCacheMetric(
                  context,
                  'Cached Items',
                  'N/A',
                  Icons.storage,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCacheMetric(
                  context,
                  'Cache Hit Rate',
                  'N/A',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCacheMetric(
                  context,
                  'Cache Size',
                  'N/A',
                  Icons.memory,
                  Colors.orange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cache metrics will be available after implementing detailed cache tracking.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCacheMetric(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCacheControls(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Cache'),
            onPressed: () => _refreshCache(context, ref),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.settings),
            label: const Text('Cache Settings'),
            onPressed: () => _showCacheSettings(context, ref),
          ),
        ),
      ],
    );
  }

  void _clearCache(BuildContext context, WidgetRef ref) {
    try {
      Logger.info('Clearing statistics cache');
      
      // Invalidate all cached providers
      ref.invalidate(overallStorageStatsProvider);
      ref.invalidate(allBucketStatsProvider);
      ref.invalidate(dashboardSummaryProvider);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache cleared successfully'),
          duration: Duration(seconds: 2),
        ),
      );
      
      Logger.info('Statistics cache cleared');
    } catch (e) {
      Logger.error('Failed to clear cache', e);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to clear cache: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _refreshCache(BuildContext context, WidgetRef ref) {
    try {
      Logger.info('Refreshing statistics cache');
      
      final statisticsMethods = ref.read(statisticsMethodsProvider);
      statisticsMethods.refreshAllStats();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache refresh initiated'),
          duration: Duration(seconds: 2),
        ),
      );
      
      Logger.info('Statistics cache refresh initiated');
    } catch (e) {
      Logger.error('Failed to refresh cache', e);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh cache: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showCacheSettings(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cache Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Cache Duration'),
              subtitle: const Text('5 minutes'),
              trailing: const Icon(Icons.edit),
              onTap: () {
                // TODO: Implement cache duration settings
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.memory),
              title: const Text('Max Cache Size'),
              subtitle: const Text('100 MB'),
              trailing: const Icon(Icons.edit),
              onTap: () {
                // TODO: Implement cache size settings
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_delete),
              title: const Text('Auto-Clear Cache'),
              subtitle: const Text('Daily'),
              trailing: const Icon(Icons.edit),
              onTap: () {
                // TODO: Implement auto-clear settings
                Navigator.of(context).pop();
              },
            ),
          ],
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
}