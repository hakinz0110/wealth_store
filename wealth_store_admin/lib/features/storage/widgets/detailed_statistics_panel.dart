import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/storage_models.dart';
import '../providers/statistics_providers.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/utils/logger.dart';

/// Widget that displays detailed statistics panels including file count/size statistics,
/// file type breakdown charts, upload activity tracking, and storage optimization suggestions
class DetailedStatisticsPanel extends ConsumerWidget {
  final String? bucketId;
  final bool showAllBuckets;

  const DetailedStatisticsPanel({
    super.key,
    this.bucketId,
    this.showAllBuckets = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (showAllBuckets) {
      return _buildAllBucketsView(context, ref);
    } else if (bucketId != null) {
      return _buildSingleBucketView(context, ref, bucketId!);
    } else {
      return _buildEmptyState(context);
    }
  }

  Widget _buildAllBucketsView(BuildContext context, WidgetRef ref) {
    final allBucketStatsAsync = ref.watch(allBucketStatsProvider);
    final overallStatsAsync = ref.watch(overallStorageStatsProvider);

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
                  'Detailed Statistics - All Buckets',
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
            
            // File count and size statistics
            _buildFileCountSizeStats(context, overallStatsAsync, allBucketStatsAsync),
            
            const SizedBox(height: 24),
            
            // File type breakdown
            _buildFileTypeBreakdown(context, overallStatsAsync),
            
            const SizedBox(height: 24),
            
            // Upload activity tracking
            _buildUploadActivityTracking(context, allBucketStatsAsync),
            
            const SizedBox(height: 24),
            
            // Storage optimization suggestions
            _buildStorageOptimizationSuggestions(context, allBucketStatsAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleBucketView(BuildContext context, WidgetRef ref, String bucketId) {
    final bucketStatsAsync = ref.watch(bucketStatsProvider(bucketId));
    final fileTypeAnalysisAsync = ref.watch(fileTypeAnalysisProvider(bucketId));

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
                  'Detailed Statistics - $bucketId',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _refreshBucketStats(ref, bucketId),
                  tooltip: 'Refresh Statistics',
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Single bucket statistics
            _buildSingleBucketStats(context, bucketStatsAsync),
            
            const SizedBox(height: 24),
            
            // File type analysis
            _buildFileTypeAnalysis(context, fileTypeAnalysisAsync),
            
            const SizedBox(height: 24),
            
            // Single bucket optimization suggestions
            _buildSingleBucketOptimization(context, bucketStatsAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Select a bucket to view detailed statistics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a bucket from the sidebar or enable "Show All Buckets" to see comprehensive statistics.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileCountSizeStats(
    BuildContext context,
    AsyncValue<StorageStats> overallStatsAsync,
    AsyncValue<Map<String, StorageStats>> allBucketStatsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'File Count & Size Statistics',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        overallStatsAsync.when(
          data: (overallStats) => allBucketStatsAsync.when(
            data: (bucketStats) => _buildFileCountSizeContent(context, overallStats, bucketStats),
            loading: () => const LoadingWidget(message: 'Loading bucket statistics...'),
            error: (error, stackTrace) => ErrorDisplayWidget(
              error: 'Failed to load bucket statistics: $error',
              onRetry: () => _refreshStats,
            ),
          ),
          loading: () => const LoadingWidget(message: 'Loading overall statistics...'),
          error: (error, stackTrace) => ErrorDisplayWidget(
            error: 'Failed to load overall statistics: $error',
            onRetry: () => _refreshStats,
          ),
        ),
      ],
    );
  }

  Widget _buildFileCountSizeContent(
    BuildContext context,
    StorageStats overallStats,
    Map<String, StorageStats> bucketStats,
  ) {
    // Calculate additional statistics
    final bucketCount = bucketStats.length;
    final averageFilesPerBucket = bucketCount > 0 ? (overallStats.totalFiles / bucketCount).round() : 0;
    final averageSizePerBucket = bucketCount > 0 ? (overallStats.totalSize / bucketCount).round() : 0;
    
    // Find largest and smallest buckets
    final sortedBySize = bucketStats.entries.toList()
      ..sort((a, b) => b.value.totalSize.compareTo(a.value.totalSize));
    final sortedByFiles = bucketStats.entries.toList()
      ..sort((a, b) => b.value.totalFiles.compareTo(a.value.totalFiles));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Summary statistics
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Buckets',
                  bucketCount.toString(),
                  Icons.folder,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Avg Files/Bucket',
                  averageFilesPerBucket.toString(),
                  Icons.description,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Avg Size/Bucket',
                  _formatFileSize(averageSizePerBucket),
                  Icons.storage,
                  Colors.orange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Top buckets by size and files
          Row(
            children: [
              Expanded(
                child: _buildTopBucketsCard(
                  context,
                  'Largest Buckets by Size',
                  sortedBySize.take(3).toList(),
                  (stats) => stats.formattedTotalSize,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTopBucketsCard(
                  context,
                  'Most Files',
                  sortedByFiles.take(3).toList(),
                  (stats) => '${stats.totalFiles} files',
                  Colors.teal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSingleBucketStats(BuildContext context, AsyncValue<StorageStats> bucketStatsAsync) {
    return bucketStatsAsync.when(
      data: (stats) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bucket Statistics',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                    'Average Size',
                    stats.formattedAverageSize,
                    Icons.analytics,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      loading: () => const LoadingWidget(message: 'Loading bucket statistics...'),
      error: (error, stackTrace) => ErrorDisplayWidget(
        error: 'Failed to load bucket statistics: $error',
        onRetry: () => _refreshStats,
      ),
    );
  }

  Widget _buildFileTypeBreakdown(BuildContext context, AsyncValue<StorageStats> overallStatsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'File Type Breakdown',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        overallStatsAsync.when(
          data: (stats) => _buildFileTypeBreakdownContent(context, stats),
          loading: () => const LoadingWidget(message: 'Loading file type breakdown...'),
          error: (error, stackTrace) => ErrorDisplayWidget(
            error: 'Failed to load file type breakdown: $error',
            onRetry: () => _refreshStats,
          ),
        ),
      ],
    );
  }

  Widget _buildFileTypeBreakdownContent(BuildContext context, StorageStats stats) {
    if (stats.fileTypeBreakdown.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No files to analyze',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final totalFiles = stats.fileTypeBreakdown.values.fold<int>(0, (sum, count) => sum + count);
    final sortedTypes = stats.fileTypeBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Bar chart for file types
          SizedBox(
            height: 200,
            child: _buildFileTypeBarChart(context, sortedTypes, totalFiles),
          ),
          
          const SizedBox(height: 16),
          
          // File type list with percentages
          ...sortedTypes.map((entry) {
            final percentage = (entry.value / totalFiles * 100);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _getFileTypeColor(entry.key),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.key.displayName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    '${entry.value} files',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFileTypeAnalysis(BuildContext context, AsyncValue<Map<String, dynamic>> analysisAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'File Type Analysis',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        analysisAsync.when(
          data: (analysis) => _buildFileTypeAnalysisContent(context, analysis),
          loading: () => const LoadingWidget(message: 'Analyzing file types...'),
          error: (error, stackTrace) => ErrorDisplayWidget(
            error: 'Failed to analyze file types: $error',
            onRetry: () => _refreshStats,
          ),
        ),
      ],
    );
  }

  Widget _buildFileTypeAnalysisContent(BuildContext context, Map<String, dynamic> analysis) {
    if (analysis.isEmpty || analysis['typeStats'] == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No file type analysis available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final typeStats = analysis['typeStats'] as Map<String, dynamic>;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: typeStats.entries.map((entry) {
          final typeName = entry.key;
          final stats = entry.value as Map<String, dynamic>;
          final count = stats['count'] as int;
          final totalSize = stats['totalSize'] as int;
          final averageSize = stats['averageSize'] as int;
          
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getFileTypeColorByName(typeName),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        typeName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildAnalysisMetric(context, 'Files', count.toString()),
                      ),
                      Expanded(
                        child: _buildAnalysisMetric(context, 'Total Size', _formatFileSize(totalSize)),
                      ),
                      Expanded(
                        child: _buildAnalysisMetric(context, 'Avg Size', _formatFileSize(averageSize)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUploadActivityTracking(
    BuildContext context,
    AsyncValue<Map<String, StorageStats>> allBucketStatsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Activity Tracking',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        allBucketStatsAsync.when(
          data: (bucketStats) => _buildUploadActivityContent(context, bucketStats),
          loading: () => const LoadingWidget(message: 'Loading upload activity...'),
          error: (error, stackTrace) => ErrorDisplayWidget(
            error: 'Failed to load upload activity: $error',
            onRetry: () => _refreshStats,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadActivityContent(BuildContext context, Map<String, StorageStats> bucketStats) {
    // For now, show current statistics as activity tracking
    // In a real implementation, this would show historical upload data
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
                child: _buildActivityCard(
                  context,
                  'Recent Uploads',
                  'N/A',
                  'No historical data',
                  Icons.upload,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActivityCard(
                  context,
                  'Upload Rate',
                  'N/A',
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
                    'Upload activity tracking will be available after implementing historical data collection.',
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

  Widget _buildStorageOptimizationSuggestions(
    BuildContext context,
    AsyncValue<Map<String, StorageStats>> allBucketStatsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Storage Optimization Suggestions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        allBucketStatsAsync.when(
          data: (bucketStats) => _buildOptimizationSuggestionsContent(context, bucketStats),
          loading: () => const LoadingWidget(message: 'Analyzing optimization opportunities...'),
          error: (error, stackTrace) => ErrorDisplayWidget(
            error: 'Failed to analyze optimization opportunities: $error',
            onRetry: () => _refreshStats,
          ),
        ),
      ],
    );
  }

  Widget _buildSingleBucketOptimization(BuildContext context, AsyncValue<StorageStats> bucketStatsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Optimization Suggestions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        bucketStatsAsync.when(
          data: (stats) => _buildSingleBucketOptimizationContent(context, stats),
          loading: () => const LoadingWidget(message: 'Analyzing optimization opportunities...'),
          error: (error, stackTrace) => ErrorDisplayWidget(
            error: 'Failed to analyze optimization opportunities: $error',
            onRetry: () => _refreshStats,
          ),
        ),
      ],
    );
  }

  Widget _buildOptimizationSuggestionsContent(BuildContext context, Map<String, StorageStats> bucketStats) {
    final suggestions = <Widget>[];
    
    // Analyze for optimization opportunities
    final totalSize = bucketStats.values.fold<int>(0, (sum, stats) => sum + stats.totalSize);
    final totalFiles = bucketStats.values.fold<int>(0, (sum, stats) => sum + stats.totalFiles);
    
    // Check for buckets with many small files
    for (final entry in bucketStats.entries) {
      final bucketId = entry.key;
      final stats = entry.value;
      
      if (stats.totalFiles > 1000 && stats.averageFileSize < 10240) { // Less than 10KB average
        suggestions.add(_buildSuggestionCard(
          context,
          'Consider File Consolidation',
          'Bucket "$bucketId" has ${stats.totalFiles} files with an average size of ${stats.formattedAverageSize}. Consider consolidating small files.',
          Icons.merge_type,
          Colors.orange,
        ));
      }
      
      // Check for buckets with very large files
      if (stats.averageFileSize > 50 * 1024 * 1024) { // More than 50MB average
        suggestions.add(_buildSuggestionCard(
          context,
          'Large File Optimization',
          'Bucket "$bucketId" has large files (avg: ${stats.formattedAverageSize}). Consider compression or chunking.',
          Icons.compress,
          Colors.blue,
        ));
      }
    }
    
    // Check for uneven distribution
    if (bucketStats.length > 1) {
      final sortedBySize = bucketStats.entries.toList()
        ..sort((a, b) => b.value.totalSize.compareTo(a.value.totalSize));
      
      final largestBucket = sortedBySize.first;
      final smallestBucket = sortedBySize.last;
      
      if (largestBucket.value.totalSize > smallestBucket.value.totalSize * 10) {
        suggestions.add(_buildSuggestionCard(
          context,
          'Uneven Distribution',
          'Storage is unevenly distributed. Consider redistributing files from "${largestBucket.key}" to other buckets.',
          Icons.balance,
          Colors.purple,
        ));
      }
    }
    
    // General suggestions
    if (totalFiles > 50000) {
      suggestions.add(_buildSuggestionCard(
        context,
        'Performance Optimization',
        'High file count ($totalFiles) may impact performance. Consider archiving old files or implementing pagination.',
        Icons.speed,
        Colors.red,
      ));
    }
    
    if (suggestions.isEmpty) {
      suggestions.add(Container(
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
              'Storage is well optimized',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ));
    }
    
    return Column(children: suggestions);
  }

  Widget _buildSingleBucketOptimizationContent(BuildContext context, StorageStats stats) {
    final suggestions = <Widget>[];
    
    // Analyze single bucket for optimization
    if (stats.totalFiles > 1000 && stats.averageFileSize < 10240) {
      suggestions.add(_buildSuggestionCard(
        context,
        'Consider File Consolidation',
        'This bucket has ${stats.totalFiles} files with an average size of ${stats.formattedAverageSize}. Consider consolidating small files.',
        Icons.merge_type,
        Colors.orange,
      ));
    }
    
    if (stats.averageFileSize > 50 * 1024 * 1024) {
      suggestions.add(_buildSuggestionCard(
        context,
        'Large File Optimization',
        'This bucket has large files (avg: ${stats.formattedAverageSize}). Consider compression or chunking.',
        Icons.compress,
        Colors.blue,
      ));
    }
    
    if (stats.totalFiles > 10000) {
      suggestions.add(_buildSuggestionCard(
        context,
        'Performance Optimization',
        'High file count (${stats.totalFiles}) may impact performance. Consider organizing files into subfolders.',
        Icons.folder_open,
        Colors.purple,
      ));
    }
    
    if (suggestions.isEmpty) {
      suggestions.add(Container(
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
              'Bucket storage is well optimized',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ));
    }
    
    return Column(children: suggestions);
  }

  // Helper widgets
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

  Widget _buildTopBucketsCard(
    BuildContext context,
    String title,
    List<MapEntry<String, StorageStats>> buckets,
    String Function(StorageStats) valueFormatter,
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
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ...buckets.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    entry.key,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  valueFormatter(entry.value),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildFileTypeBarChart(
    BuildContext context,
    List<MapEntry<StorageFileType, int>> sortedTypes,
    int totalFiles,
  ) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: sortedTypes.first.value.toDouble() * 1.1,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < sortedTypes.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      sortedTypes[index].key.displayName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: sortedTypes.asMap().entries.map((entry) {
          final index = entry.key;
          final typeEntry = entry.value;
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: typeEntry.value.toDouble(),
                color: _getFileTypeColor(typeEntry.key),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAnalysisMetric(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(
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

  Widget _buildSuggestionCard(
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

  // Helper methods
  Color _getFileTypeColor(StorageFileType type) {
    switch (type) {
      case StorageFileType.image:
        return Colors.green;
      case StorageFileType.video:
        return Colors.red;
      case StorageFileType.document:
        return Colors.blue;
      case StorageFileType.folder:
        return Colors.orange;
      case StorageFileType.other:
        return Colors.grey;
    }
  }

  Color _getFileTypeColorByName(String typeName) {
    switch (typeName.toLowerCase()) {
      case 'image':
        return Colors.green;
      case 'video':
        return Colors.red;
      case 'document':
        return Colors.blue;
      case 'folder':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  void _refreshStats(WidgetRef ref) {
    try {
      Logger.info('Refreshing detailed statistics');
      ref.invalidate(overallStorageStatsProvider);
      ref.invalidate(allBucketStatsProvider);
    } catch (e) {
      Logger.error('Failed to refresh detailed statistics', e);
    }
  }

  void _refreshBucketStats(WidgetRef ref, String bucketId) {
    try {
      Logger.info('Refreshing statistics for bucket: $bucketId');
      ref.invalidate(bucketStatsProvider(bucketId));
      ref.invalidate(fileTypeAnalysisProvider(bucketId));
    } catch (e) {
      Logger.error('Failed to refresh bucket statistics', e);
    }
  }
}