import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/storage_models.dart';
import '../providers/statistics_providers.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/utils/logger.dart';

/// Widget that displays storage usage overview with total usage, bucket breakdown,
/// usage trends, and quota warnings
class StorageUsageOverview extends ConsumerWidget {
  const StorageUsageOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overallStatsAsync = ref.watch(overallStorageStatsProvider);
    final allBucketStatsAsync = ref.watch(allBucketStatsProvider);
    final dashboardSummaryAsync = ref.watch(dashboardSummaryProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Storage Usage Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _refreshStats(ref),
                  tooltip: 'Refresh Statistics',
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Overall statistics section
            _buildOverallStats(context, overallStatsAsync),
            
            const SizedBox(height: 24),
            
            // Bucket breakdown section
            _buildBucketBreakdown(context, allBucketStatsAsync, dashboardSummaryAsync),
            
            const SizedBox(height: 24),
            
            // Usage trends section
            _buildUsageTrends(context, overallStatsAsync),
            
            const SizedBox(height: 24),
            
            // Quota warnings section
            _buildQuotaWarnings(context, allBucketStatsAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStats(BuildContext context, AsyncValue<StorageStats> overallStatsAsync) {
    return overallStatsAsync.when(
      data: (stats) => _buildOverallStatsContent(context, stats),
      loading: () => const LoadingWidget(message: 'Loading overall statistics...'),
      error: (error, stackTrace) {
        Logger.error('Error loading overall statistics', error, stackTrace);
        return ErrorDisplayWidget(
          error: 'Failed to load overall statistics: $error',
          onRetry: () => _refreshStats,
        );
      },
    );
  }

  Widget _buildOverallStatsContent(BuildContext context, StorageStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Storage Usage',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Files',
                  stats.totalFiles.toString(),
                  Icons.description,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Size',
                  stats.formattedTotalSize,
                  Icons.storage,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Average File Size',
                  stats.formattedAverageSize,
                  Icons.analytics,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Last Updated: ${_formatDateTime(stats.lastUpdated)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
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
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBucketBreakdown(
    BuildContext context,
    AsyncValue<Map<String, StorageStats>> allBucketStatsAsync,
    AsyncValue<Map<String, dynamic>> dashboardSummaryAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bucket-Specific Usage Breakdown',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        allBucketStatsAsync.when(
          data: (bucketStats) => _buildBucketBreakdownContent(context, bucketStats),
          loading: () => const LoadingWidget(message: 'Loading bucket statistics...'),
          error: (error, stackTrace) {
            Logger.error('Error loading bucket statistics', error, stackTrace);
            return ErrorDisplayWidget(
              error: 'Failed to load bucket statistics: $error',
              onRetry: () => _refreshStats,
            );
          },
        ),
      ],
    );
  }

  Widget _buildBucketBreakdownContent(
    BuildContext context,
    Map<String, StorageStats> bucketStats,
  ) {
    if (bucketStats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.folder_open,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                'No buckets found',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Sort buckets by size for better visualization
    final sortedBuckets = bucketStats.entries.toList()
      ..sort((a, b) => b.value.totalSize.compareTo(a.value.totalSize));

    return Column(
      children: [
        // Pie chart for size distribution
        SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildBucketSizePieChart(context, sortedBuckets),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: _buildBucketLegend(context, sortedBuckets),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Bucket list with details
        _buildBucketList(context, sortedBuckets),
      ],
    );
  }

  Widget _buildBucketSizePieChart(
    BuildContext context,
    List<MapEntry<String, StorageStats>> sortedBuckets,
  ) {
    final totalSize = sortedBuckets.fold<int>(0, (sum, entry) => sum + entry.value.totalSize);
    
    if (totalSize == 0) {
      return Center(
        child: Text(
          'No data to display',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];

    final sections = sortedBuckets.take(8).map((entry) {
      final index = sortedBuckets.indexOf(entry);
      final percentage = (entry.value.totalSize / totalSize * 100);
      
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value.totalSize.toDouble(),
        title: percentage > 5 ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildBucketLegend(
    BuildContext context,
    List<MapEntry<String, StorageStats>> sortedBuckets,
  ) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedBuckets.take(8).map((entry) {
        final index = sortedBuckets.indexOf(entry);
        final color = colors[index % colors.length];
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.key,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBucketList(
    BuildContext context,
    List<MapEntry<String, StorageStats>> sortedBuckets,
  ) {
    return Column(
      children: sortedBuckets.map((entry) {
        final bucketId = entry.key;
        final stats = entry.value;
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.folder),
            title: Text(bucketId),
            subtitle: Text('${stats.totalFiles} files'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  stats.formattedTotalSize,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Avg: ${stats.formattedAverageSize}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUsageTrends(BuildContext context, AsyncValue<StorageStats> overallStatsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Usage Trends',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        overallStatsAsync.when(
          data: (stats) => _buildUsageTrendsContent(context, stats),
          loading: () => const LoadingWidget(message: 'Loading usage trends...'),
          error: (error, stackTrace) {
            Logger.error('Error loading usage trends', error, stackTrace);
            return ErrorDisplayWidget(
              error: 'Failed to load usage trends: $error',
              onRetry: () => _refreshStats,
            );
          },
        ),
      ],
    );
  }

  Widget _buildUsageTrendsContent(BuildContext context, StorageStats stats) {
    // For now, show current statistics as trends
    // In a real implementation, this would show historical data
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTrendCard(
                  context,
                  'File Growth',
                  '+0%',
                  'No historical data',
                  Icons.trending_up,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTrendCard(
                  context,
                  'Size Growth',
                  '+0%',
                  'No historical data',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(6),
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
                    'Historical trend data will be available after collecting usage data over time.',
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

  Widget _buildTrendCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotaWarnings(
    BuildContext context,
    AsyncValue<Map<String, StorageStats>> allBucketStatsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Storage Quota Warnings',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        allBucketStatsAsync.when(
          data: (bucketStats) => _buildQuotaWarningsContent(context, bucketStats),
          loading: () => const LoadingWidget(message: 'Checking quota warnings...'),
          error: (error, stackTrace) {
            Logger.error('Error loading quota warnings', error, stackTrace);
            return ErrorDisplayWidget(
              error: 'Failed to load quota warnings: $error',
              onRetry: () => _refreshStats,
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuotaWarningsContent(
    BuildContext context,
    Map<String, StorageStats> bucketStats,
  ) {
    final warnings = <Widget>[];
    
    // Check for large file counts that might impact performance
    for (final entry in bucketStats.entries) {
      final bucketId = entry.key;
      final stats = entry.value;
      
      if (stats.totalFiles > 10000) {
        warnings.add(_buildWarningCard(
          context,
          'High File Count',
          'Bucket "$bucketId" has ${stats.totalFiles} files, which may impact performance.',
          Icons.warning,
          Colors.orange,
        ));
      }
      
      // Check for very large buckets (over 1GB)
      if (stats.totalSize > 1024 * 1024 * 1024) {
        warnings.add(_buildWarningCard(
          context,
          'Large Storage Usage',
          'Bucket "$bucketId" is using ${stats.formattedTotalSize} of storage.',
          Icons.storage,
          Colors.blue,
        ));
      }
    }
    
    // Check overall storage usage
    final totalSize = bucketStats.values.fold<int>(0, (sum, stats) => sum + stats.totalSize);
    final totalFiles = bucketStats.values.fold<int>(0, (sum, stats) => sum + stats.totalFiles);
    
    if (totalFiles > 50000) {
      warnings.add(_buildWarningCard(
        context,
        'High Total File Count',
        'Total file count across all buckets is $totalFiles, which may impact overall performance.',
        Icons.warning,
        Colors.red,
      ));
    }
    
    if (warnings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              'No quota warnings at this time',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(children: warnings);
  }

  Widget _buildWarningCard(
    BuildContext context,
    String title,
    String message,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _refreshStats(WidgetRef ref) {
    try {
      Logger.info('Refreshing storage usage overview statistics');
      ref.invalidate(overallStorageStatsProvider);
      ref.invalidate(allBucketStatsProvider);
      ref.invalidate(dashboardSummaryProvider);
    } catch (e) {
      Logger.error('Failed to refresh storage usage overview statistics', e);
    }
  }
}