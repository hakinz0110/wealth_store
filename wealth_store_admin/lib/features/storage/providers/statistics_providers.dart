import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/storage_models.dart';
import '../services/storage_statistics_service.dart';
import 'storage_providers.dart';
import '../../../shared/utils/logger.dart';

// Statistics service provider (already defined in storage_providers.dart)
// We'll use the existing storageStatisticsServiceProvider

// Overall storage statistics provider
final overallStorageStatsProvider = FutureProvider<StorageStats>((ref) async {
  try {
    Logger.info('Loading overall storage statistics');
    final statisticsService = ref.read(storageStatisticsServiceProvider);
    final stats = await statisticsService.calculateOverallStatistics();
    Logger.info('Loaded overall storage statistics: ${stats.totalFiles} files, ${stats.formattedTotalSize}');
    return stats;
  } catch (e, stackTrace) {
    Logger.error('Failed to load overall storage statistics', e, stackTrace);
    rethrow;
  }
});

// All bucket statistics provider
final allBucketStatsProvider = FutureProvider<Map<String, StorageStats>>((ref) async {
  try {
    Logger.info('Loading statistics for all buckets');
    final statisticsService = ref.read(storageStatisticsServiceProvider);
    final stats = await statisticsService.calculateAllBucketStatistics();
    Logger.info('Loaded statistics for ${stats.length} buckets');
    return stats;
  } catch (e, stackTrace) {
    Logger.error('Failed to load all bucket statistics', e, stackTrace);
    rethrow;
  }
});

// Individual bucket statistics provider
final bucketStatsProvider = FutureProvider.family<StorageStats, String>((ref, bucketId) async {
  try {
    Logger.info('Loading statistics for bucket: $bucketId');
    final statisticsService = ref.read(storageStatisticsServiceProvider);
    final stats = await statisticsService.calculateBucketStatistics(bucketId);
    Logger.info('Loaded statistics for bucket $bucketId: ${stats.totalFiles} files, ${stats.formattedTotalSize}');
    return stats;
  } catch (e, stackTrace) {
    Logger.error('Failed to load statistics for bucket: $bucketId', e, stackTrace);
    rethrow;
  }
});

// Current bucket statistics provider (based on selected bucket)
final currentBucketStatsProvider = FutureProvider<StorageStats?>((ref) async {
  final selectedBucketId = ref.watch(selectedBucketProvider);
  if (selectedBucketId == null) return null;
  
  return ref.watch(bucketStatsProvider(selectedBucketId).future);
});

// Dashboard summary provider
final dashboardSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    Logger.info('Loading dashboard summary');
    final statisticsService = ref.read(storageStatisticsServiceProvider);
    final summary = await statisticsService.getDashboardSummary();
    Logger.info('Loaded dashboard summary');
    return summary;
  } catch (e, stackTrace) {
    Logger.error('Failed to load dashboard summary', e, stackTrace);
    rethrow;
  }
});

// File type analysis provider
final fileTypeAnalysisProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, bucketId) async {
  try {
    Logger.info('Loading file type analysis for bucket: $bucketId');
    final statisticsService = ref.read(storageStatisticsServiceProvider);
    final analysis = await statisticsService.getFileTypeAnalysis(bucketId);
    Logger.info('Loaded file type analysis for bucket: $bucketId');
    return analysis;
  } catch (e, stackTrace) {
    Logger.error('Failed to load file type analysis for bucket: $bucketId', e, stackTrace);
    rethrow;
  }
});

// Usage trends provider
final usageTrendsProvider = FutureProvider.family<Map<String, dynamic>, UsageTrendsParams>((ref, params) async {
  try {
    Logger.info('Loading usage trends for bucket: ${params.bucketId}');
    final statisticsService = ref.read(storageStatisticsServiceProvider);
    final trends = await statisticsService.getUsageTrends(params.bucketId, period: params.period);
    Logger.info('Loaded usage trends for bucket: ${params.bucketId}');
    return trends;
  } catch (e, stackTrace) {
    Logger.error('Failed to load usage trends for bucket: ${params.bucketId}', e, stackTrace);
    rethrow;
  }
});

// Quota monitoring provider
final quotaMonitoringProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, bucketId) async {
  try {
    Logger.info('Loading quota monitoring for bucket: $bucketId');
    final statisticsService = ref.read(storageStatisticsServiceProvider);
    final quota = await statisticsService.getQuotaMonitoring(bucketId);
    Logger.info('Loaded quota monitoring for bucket: $bucketId');
    return quota;
  } catch (e, stackTrace) {
    Logger.error('Failed to load quota monitoring for bucket: $bucketId', e, stackTrace);
    rethrow;
  }
});

// Statistics stream provider (for real-time updates)
final statisticsStreamProvider = StreamProvider<Map<String, StorageStats>>((ref) {
  final statisticsService = ref.read(storageStatisticsServiceProvider);
  return statisticsService.statisticsStream;
});

// Auto-refresh state provider
final autoRefreshEnabledProvider = StateProvider<bool>((ref) => false);
final autoRefreshIntervalProvider = StateProvider<Duration>((ref) => const Duration(minutes: 5));

// Loading states
final overallStatsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(overallStorageStatsProvider).isLoading;
});

final allBucketStatsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(allBucketStatsProvider).isLoading;
});

final currentBucketStatsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(currentBucketStatsProvider).isLoading;
});

final dashboardSummaryLoadingProvider = Provider<bool>((ref) {
  return ref.watch(dashboardSummaryProvider).isLoading;
});

// Error states
final overallStatsErrorProvider = Provider<String?>((ref) {
  final statsAsync = ref.watch(overallStorageStatsProvider);
  return statsAsync.when(
    data: (_) => null,
    loading: () => null,
    error: (error, _) => error.toString(),
  );
});

final allBucketStatsErrorProvider = Provider<String?>((ref) {
  final statsAsync = ref.watch(allBucketStatsProvider);
  return statsAsync.when(
    data: (_) => null,
    loading: () => null,
    error: (error, _) => error.toString(),
  );
});

final currentBucketStatsErrorProvider = Provider<String?>((ref) {
  final statsAsync = ref.watch(currentBucketStatsProvider);
  return statsAsync.when(
    data: (_) => null,
    loading: () => null,
    error: (error, _) => error.toString(),
  );
});

final dashboardSummaryErrorProvider = Provider<String?>((ref) {
  final summaryAsync = ref.watch(dashboardSummaryProvider);
  return summaryAsync.when(
    data: (_) => null,
    loading: () => null,
    error: (error, _) => error.toString(),
  );
});

// Statistics methods provider
final statisticsMethodsProvider = Provider<StatisticsMethods>((ref) {
  return StatisticsMethods(ref);
});

/// Helper class for usage trends parameters
class UsageTrendsParams {
  final String bucketId;
  final Duration? period;

  const UsageTrendsParams({
    required this.bucketId,
    this.period,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsageTrendsParams &&
          runtimeType == other.runtimeType &&
          bucketId == other.bucketId &&
          period == other.period;

  @override
  int get hashCode => bucketId.hashCode ^ period.hashCode;

  @override
  String toString() => 'UsageTrendsParams(bucketId: $bucketId, period: $period)';
}

/// Statistics management methods
class StatisticsMethods {
  final Ref _ref;

  StatisticsMethods(this._ref);

  /// Refresh overall statistics
  Future<void> refreshOverallStats() async {
    try {
      Logger.info('Refreshing overall statistics');
      _ref.invalidate(overallStorageStatsProvider);
      await _ref.read(overallStorageStatsProvider.future);
      Logger.info('Overall statistics refreshed');
    } catch (e) {
      Logger.error('Failed to refresh overall statistics', e);
      rethrow;
    }
  }

  /// Refresh all bucket statistics
  Future<void> refreshAllBucketStats() async {
    try {
      Logger.info('Refreshing all bucket statistics');
      _ref.invalidate(allBucketStatsProvider);
      await _ref.read(allBucketStatsProvider.future);
      Logger.info('All bucket statistics refreshed');
    } catch (e) {
      Logger.error('Failed to refresh all bucket statistics', e);
      rethrow;
    }
  }

  /// Refresh statistics for specific bucket
  Future<void> refreshBucketStats(String bucketId) async {
    try {
      Logger.info('Refreshing statistics for bucket: $bucketId');
      _ref.invalidate(bucketStatsProvider(bucketId));
      await _ref.read(bucketStatsProvider(bucketId).future);
      Logger.info('Statistics refreshed for bucket: $bucketId');
    } catch (e) {
      Logger.error('Failed to refresh statistics for bucket: $bucketId', e);
      rethrow;
    }
  }

  /// Refresh current bucket statistics
  Future<void> refreshCurrentBucketStats() async {
    try {
      final selectedBucketId = _ref.read(selectedBucketProvider);
      if (selectedBucketId == null) return;
      
      await refreshBucketStats(selectedBucketId);
    } catch (e) {
      Logger.error('Failed to refresh current bucket statistics', e);
      rethrow;
    }
  }

  /// Refresh dashboard summary
  Future<void> refreshDashboardSummary() async {
    try {
      Logger.info('Refreshing dashboard summary');
      _ref.invalidate(dashboardSummaryProvider);
      await _ref.read(dashboardSummaryProvider.future);
      Logger.info('Dashboard summary refreshed');
    } catch (e) {
      Logger.error('Failed to refresh dashboard summary', e);
      rethrow;
    }
  }

  /// Refresh file type analysis
  Future<void> refreshFileTypeAnalysis(String bucketId) async {
    try {
      Logger.info('Refreshing file type analysis for bucket: $bucketId');
      _ref.invalidate(fileTypeAnalysisProvider(bucketId));
      await _ref.read(fileTypeAnalysisProvider(bucketId).future);
      Logger.info('File type analysis refreshed for bucket: $bucketId');
    } catch (e) {
      Logger.error('Failed to refresh file type analysis for bucket: $bucketId', e);
      rethrow;
    }
  }

  /// Refresh usage trends
  Future<void> refreshUsageTrends(String bucketId, {Duration? period}) async {
    try {
      Logger.info('Refreshing usage trends for bucket: $bucketId');
      final params = UsageTrendsParams(bucketId: bucketId, period: period);
      _ref.invalidate(usageTrendsProvider(params));
      await _ref.read(usageTrendsProvider(params).future);
      Logger.info('Usage trends refreshed for bucket: $bucketId');
    } catch (e) {
      Logger.error('Failed to refresh usage trends for bucket: $bucketId', e);
      rethrow;
    }
  }

  /// Refresh quota monitoring
  Future<void> refreshQuotaMonitoring(String bucketId) async {
    try {
      Logger.info('Refreshing quota monitoring for bucket: $bucketId');
      _ref.invalidate(quotaMonitoringProvider(bucketId));
      await _ref.read(quotaMonitoringProvider(bucketId).future);
      Logger.info('Quota monitoring refreshed for bucket: $bucketId');
    } catch (e) {
      Logger.error('Failed to refresh quota monitoring for bucket: $bucketId', e);
      rethrow;
    }
  }

  /// Refresh all statistics
  Future<void> refreshAllStats() async {
    try {
      Logger.info('Refreshing all statistics');
      
      // Refresh in parallel for better performance
      await Future.wait([
        refreshOverallStats(),
        refreshAllBucketStats(),
        refreshDashboardSummary(),
      ]);
      
      Logger.info('All statistics refreshed');
    } catch (e) {
      Logger.error('Failed to refresh all statistics', e);
      rethrow;
    }
  }

  /// Start auto-refresh for all statistics
  Future<void> startAutoRefresh({Duration? interval}) async {
    try {
      Logger.info('Starting auto-refresh for statistics');
      
      final statisticsService = _ref.read(storageStatisticsServiceProvider);
      await statisticsService.startAutoRefreshAll(interval: interval);
      
      _ref.read(autoRefreshEnabledProvider.notifier).state = true;
      if (interval != null) {
        _ref.read(autoRefreshIntervalProvider.notifier).state = interval;
      }
      
      Logger.info('Auto-refresh started for all statistics');
    } catch (e) {
      Logger.error('Failed to start auto-refresh', e);
      rethrow;
    }
  }

  /// Stop auto-refresh for all statistics
  void stopAutoRefresh() {
    try {
      Logger.info('Stopping auto-refresh for statistics');
      
      final statisticsService = _ref.read(storageStatisticsServiceProvider);
      statisticsService.stopAutoRefreshAll();
      
      _ref.read(autoRefreshEnabledProvider.notifier).state = false;
      
      Logger.info('Auto-refresh stopped for all statistics');
    } catch (e) {
      Logger.error('Failed to stop auto-refresh', e);
    }
  }

  /// Start auto-refresh for specific bucket
  void startBucketAutoRefresh(String bucketId, {Duration? interval}) {
    try {
      Logger.info('Starting auto-refresh for bucket: $bucketId');
      
      final statisticsService = _ref.read(storageStatisticsServiceProvider);
      statisticsService.startAutoRefresh(bucketId, interval: interval);
      
      Logger.info('Auto-refresh started for bucket: $bucketId');
    } catch (e) {
      Logger.error('Failed to start auto-refresh for bucket: $bucketId', e);
    }
  }

  /// Stop auto-refresh for specific bucket
  void stopBucketAutoRefresh(String bucketId) {
    try {
      Logger.info('Stopping auto-refresh for bucket: $bucketId');
      
      final statisticsService = _ref.read(storageStatisticsServiceProvider);
      statisticsService.stopAutoRefresh(bucketId);
      
      Logger.info('Auto-refresh stopped for bucket: $bucketId');
    } catch (e) {
      Logger.error('Failed to stop auto-refresh for bucket: $bucketId', e);
    }
  }

  /// Get statistics for comparison
  Future<Map<String, dynamic>> getStatsComparison(List<String> bucketIds) async {
    try {
      Logger.info('Getting statistics comparison for ${bucketIds.length} buckets');
      
      final allStats = await _ref.read(allBucketStatsProvider.future);
      final comparison = <String, dynamic>{};
      
      for (final bucketId in bucketIds) {
        final stats = allStats[bucketId];
        if (stats != null) {
          comparison[bucketId] = {
            'totalFiles': stats.totalFiles,
            'totalSize': stats.totalSize,
            'formattedSize': stats.formattedTotalSize,
            'averageFileSize': stats.averageFileSize,
            'fileTypeBreakdown': stats.fileTypeBreakdown.map(
              (key, value) => MapEntry(key.name, value),
            ),
          };
        }
      }
      
      Logger.info('Statistics comparison generated for ${comparison.length} buckets');
      return comparison;
    } catch (e) {
      Logger.error('Failed to get statistics comparison', e);
      return {};
    }
  }

  /// Get top buckets by size
  Future<List<Map<String, dynamic>>> getTopBucketsBySize({int limit = 5}) async {
    try {
      final allStats = await _ref.read(allBucketStatsProvider.future);
      
      final sortedBuckets = allStats.entries.toList()
        ..sort((a, b) => b.value.totalSize.compareTo(a.value.totalSize));
      
      return sortedBuckets.take(limit).map((entry) => {
        'bucketId': entry.key,
        'totalSize': entry.value.totalSize,
        'formattedSize': entry.value.formattedTotalSize,
        'fileCount': entry.value.totalFiles,
      }).toList();
    } catch (e) {
      Logger.error('Failed to get top buckets by size', e);
      return [];
    }
  }

  /// Get top buckets by file count
  Future<List<Map<String, dynamic>>> getTopBucketsByFileCount({int limit = 5}) async {
    try {
      final allStats = await _ref.read(allBucketStatsProvider.future);
      
      final sortedBuckets = allStats.entries.toList()
        ..sort((a, b) => b.value.totalFiles.compareTo(a.value.totalFiles));
      
      return sortedBuckets.take(limit).map((entry) => {
        'bucketId': entry.key,
        'fileCount': entry.value.totalFiles,
        'totalSize': entry.value.totalSize,
        'formattedSize': entry.value.formattedTotalSize,
      }).toList();
    } catch (e) {
      Logger.error('Failed to get top buckets by file count', e);
      return [];
    }
  }

  /// Check if auto-refresh is enabled
  bool get isAutoRefreshEnabled => _ref.read(autoRefreshEnabledProvider);

  /// Get auto-refresh interval
  Duration get autoRefreshInterval => _ref.read(autoRefreshIntervalProvider);

  /// Update auto-refresh interval
  void updateAutoRefreshInterval(Duration interval) {
    try {
      _ref.read(autoRefreshIntervalProvider.notifier).state = interval;
      
      // Restart auto-refresh with new interval if currently enabled
      if (isAutoRefreshEnabled) {
        stopAutoRefresh();
        startAutoRefresh(interval: interval);
      }
      
      Logger.info('Auto-refresh interval updated to: ${interval.inMinutes} minutes');
    } catch (e) {
      Logger.error('Failed to update auto-refresh interval', e);
    }
  }

  /// Get current statistics summary
  Map<String, dynamic> getCurrentStatsSummary() {
    try {
      final overallStatsAsync = _ref.read(overallStorageStatsProvider);
      final allBucketStatsAsync = _ref.read(allBucketStatsProvider);
      
      return {
        'overallStats': overallStatsAsync.when(
          data: (stats) => {
            'totalFiles': stats.totalFiles,
            'totalSize': stats.totalSize,
            'formattedSize': stats.formattedTotalSize,
            'averageFileSize': stats.averageFileSize,
          },
          loading: () => {'loading': true},
          error: (error, _) => {'error': error.toString()},
        ),
        'bucketCount': allBucketStatsAsync.when(
          data: (stats) => stats.length,
          loading: () => 0,
          error: (_, __) => 0,
        ),
        'autoRefreshEnabled': isAutoRefreshEnabled,
        'autoRefreshInterval': autoRefreshInterval.inMinutes,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      Logger.error('Failed to get current statistics summary', e);
      return {'error': 'Failed to get statistics summary'};
    }
  }
}