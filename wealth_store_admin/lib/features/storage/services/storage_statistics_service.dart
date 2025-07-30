import 'dart:async';
import '../interfaces/storage_interfaces.dart';
import '../models/storage_models.dart';
import '../utils/storage_utils.dart';
import '../constants/storage_constants.dart';
import '../../../shared/utils/logger.dart';

/// Service for calculating and managing storage statistics
class StorageStatisticsService {
  final IStorageRepository _repository;
  final IStorageCache? _cache;
  final Map<String, Timer> _refreshTimers = {};
  final StreamController<Map<String, StorageStats>> _statsController = 
      StreamController<Map<String, StorageStats>>.broadcast();

  StorageStatisticsService({
    required IStorageRepository repository,
    IStorageCache? cache,
  }) : _repository = repository,
       _cache = cache;

  /// Stream of statistics updates
  Stream<Map<String, StorageStats>> get statisticsStream => _statsController.stream;

  /// Calculate comprehensive statistics for a bucket
  Future<StorageStats> calculateBucketStatistics(String bucketId) async {
    try {
      Logger.info('Calculating statistics for bucket: $bucketId');
      
      // Check cache first
      if (_cache != null) {
        final cachedStats = await _cache!.getCachedStats(bucketId);
        if (cachedStats != null && 
            _cache!.isCacheValid('stats_$bucketId', StorageConstants.statsRefreshInterval)) {
          Logger.debug('Returning cached statistics for bucket: $bucketId');
          return cachedStats;
        }
      }
      
      // Get all files in the bucket recursively
      final allFiles = await _getAllFilesRecursively(bucketId);
      
      // Filter out folders for size calculations
      final files = allFiles.where((f) => !f.isFolder).toList();
      
      // Calculate basic statistics
      final totalFiles = files.length;
      final totalSize = files.fold<int>(0, (sum, file) => sum + file.size);
      final averageFileSize = totalFiles > 0 ? (totalSize / totalFiles).round() : 0;
      
      // Calculate file type breakdown
      final typeBreakdown = <StorageFileType, int>{};
      for (final file in files) {
        typeBreakdown[file.fileType] = (typeBreakdown[file.fileType] ?? 0) + 1;
      }
      
      final stats = StorageStats(
        bucketId: bucketId,
        totalFiles: totalFiles,
        totalSize: totalSize,
        averageFileSize: averageFileSize,
        fileTypeBreakdown: typeBreakdown,
        lastUpdated: DateTime.now(),
      );
      
      // Cache the results
      if (_cache != null) {
        await _cache!.cacheStats(bucketId, stats);
      }
      
      Logger.info('Calculated statistics for bucket $bucketId: $totalFiles files, ${StorageUtils.formatFileSize(totalSize)}');
      return stats;
    } catch (e, stackTrace) {
      Logger.error('Failed to calculate statistics for bucket $bucketId', e, stackTrace);
      
      // Return empty stats on error
      return StorageStats(
        bucketId: bucketId,
        totalFiles: 0,
        totalSize: 0,
        averageFileSize: 0,
        fileTypeBreakdown: {},
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Calculate statistics for all buckets
  Future<Map<String, StorageStats>> calculateAllBucketStatistics() async {
    try {
      Logger.info('Calculating statistics for all buckets');
      
      final buckets = await _repository.getBuckets();
      final allStats = <String, StorageStats>{};
      
      // Calculate stats for each bucket in parallel
      final futures = buckets.map((bucket) async {
        try {
          final stats = await calculateBucketStatistics(bucket.id);
          return MapEntry(bucket.id, stats);
        } catch (e) {
          Logger.warning('Failed to calculate stats for bucket ${bucket.id}', e);
          return MapEntry(bucket.id, StorageStats(
            bucketId: bucket.id,
            totalFiles: 0,
            totalSize: 0,
            averageFileSize: 0,
            fileTypeBreakdown: {},
            lastUpdated: DateTime.now(),
          ));
        }
      });
      
      final results = await Future.wait(futures);
      for (final result in results) {
        allStats[result.key] = result.value;
      }
      
      // Notify listeners
      _notifyStatsUpdate(allStats);
      
      Logger.info('Calculated statistics for ${allStats.length} buckets');
      return allStats;
    } catch (e, stackTrace) {
      Logger.error('Failed to calculate statistics for all buckets', e, stackTrace);
      return {};
    }
  }

  /// Get overall storage statistics across all buckets
  Future<StorageStats> calculateOverallStatistics() async {
    try {
      Logger.info('Calculating overall storage statistics');
      
      final allBucketStats = await calculateAllBucketStatistics();
      
      int totalFiles = 0;
      int totalSize = 0;
      final combinedTypeBreakdown = <StorageFileType, int>{};
      
      for (final stats in allBucketStats.values) {
        totalFiles += stats.totalFiles;
        totalSize += stats.totalSize;
        
        // Combine type breakdowns
        for (final entry in stats.fileTypeBreakdown.entries) {
          combinedTypeBreakdown[entry.key] = 
              (combinedTypeBreakdown[entry.key] ?? 0) + entry.value;
        }
      }
      
      final averageFileSize = totalFiles > 0 ? (totalSize / totalFiles).round() : 0;
      
      final overallStats = StorageStats(
        bucketId: 'overall',
        totalFiles: totalFiles,
        totalSize: totalSize,
        averageFileSize: averageFileSize,
        fileTypeBreakdown: combinedTypeBreakdown,
        lastUpdated: DateTime.now(),
      );
      
      Logger.info('Overall statistics: $totalFiles files, ${StorageUtils.formatFileSize(totalSize)}');
      return overallStats;
    } catch (e, stackTrace) {
      Logger.error('Failed to calculate overall statistics', e, stackTrace);
      return StorageStats(
        bucketId: 'overall',
        totalFiles: 0,
        totalSize: 0,
        averageFileSize: 0,
        fileTypeBreakdown: {},
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Get detailed file type analysis for a bucket
  Future<Map<String, dynamic>> getFileTypeAnalysis(String bucketId) async {
    try {
      Logger.info('Analyzing file types for bucket: $bucketId');
      
      final allFiles = await _getAllFilesRecursively(bucketId);
      final files = allFiles.where((f) => !f.isFolder).toList();
      
      final analysis = <String, dynamic>{};
      final typeStats = <StorageFileType, Map<String, dynamic>>{};
      
      for (final file in files) {
        final type = file.fileType;
        
        if (!typeStats.containsKey(type)) {
          typeStats[type] = {
            'count': 0,
            'totalSize': 0,
            'averageSize': 0,
            'largestFile': null,
            'smallestFile': null,
            'extensions': <String, int>{},
          };
        }
        
        final stats = typeStats[type]!;
        stats['count'] = (stats['count'] as int) + 1;
        stats['totalSize'] = (stats['totalSize'] as int) + file.size;
        
        // Track largest and smallest files
        if (stats['largestFile'] == null || file.size > (stats['largestFile'] as StorageFile).size) {
          stats['largestFile'] = file;
        }
        if (stats['smallestFile'] == null || file.size < (stats['smallestFile'] as StorageFile).size) {
          stats['smallestFile'] = file;
        }
        
        // Track file extensions
        final extension = StorageUtils.getFileExtension(file.name);
        if (extension.isNotEmpty) {
          final extensions = stats['extensions'] as Map<String, int>;
          extensions[extension] = (extensions[extension] ?? 0) + 1;
        }
      }
      
      // Calculate averages
      for (final entry in typeStats.entries) {
        final stats = entry.value;
        final count = stats['count'] as int;
        final totalSize = stats['totalSize'] as int;
        stats['averageSize'] = count > 0 ? (totalSize / count).round() : 0;
      }
      
      analysis['typeStats'] = typeStats;
      analysis['totalFiles'] = files.length;
      analysis['totalSize'] = files.fold<int>(0, (sum, file) => sum + file.size);
      analysis['lastAnalyzed'] = DateTime.now().toIso8601String();
      
      Logger.info('File type analysis completed for bucket $bucketId');
      return analysis;
    } catch (e, stackTrace) {
      Logger.error('Failed to analyze file types for bucket $bucketId', e, stackTrace);
      return {};
    }
  }

  /// Get storage usage trends (requires historical data)
  Future<Map<String, dynamic>> getUsageTrends(String bucketId, {Duration? period}) async {
    try {
      Logger.info('Analyzing usage trends for bucket: $bucketId');
      
      // For now, return current snapshot
      // In a real implementation, this would analyze historical data
      final currentStats = await calculateBucketStatistics(bucketId);
      
      return {
        'bucketId': bucketId,
        'period': period?.inDays ?? 30,
        'currentStats': {
          'totalFiles': currentStats.totalFiles,
          'totalSize': currentStats.totalSize,
          'averageFileSize': currentStats.averageFileSize,
        },
        'trends': {
          'filesGrowthRate': 0.0, // Would be calculated from historical data
          'sizeGrowthRate': 0.0,  // Would be calculated from historical data
          'mostActiveFileType': _getMostActiveFileType(currentStats),
        },
        'projections': {
          'estimatedFilesIn30Days': currentStats.totalFiles,
          'estimatedSizeIn30Days': currentStats.totalSize,
        },
        'lastAnalyzed': DateTime.now().toIso8601String(),
      };
    } catch (e, stackTrace) {
      Logger.error('Failed to analyze usage trends for bucket $bucketId', e, stackTrace);
      return {};
    }
  }

  /// Get storage quota monitoring information
  Future<Map<String, dynamic>> getQuotaMonitoring(String bucketId) async {
    try {
      Logger.info('Monitoring quota for bucket: $bucketId');
      
      final stats = await calculateBucketStatistics(bucketId);
      final bucket = await _repository.getBuckets()
          .then((buckets) => buckets.firstWhere((b) => b.id == bucketId));
      
      final quotaInfo = <String, dynamic>{
        'bucketId': bucketId,
        'currentUsage': {
          'files': stats.totalFiles,
          'size': stats.totalSize,
          'formattedSize': stats.formattedTotalSize,
        },
        'limits': {
          'maxFileSize': bucket.fileSizeLimit,
          'formattedMaxFileSize': bucket.formattedSizeLimit,
          'allowedMimeTypes': bucket.allowedMimeTypes,
        },
        'utilization': {
          'sizePercentage': bucket.fileSizeLimit != null 
              ? (stats.totalSize / bucket.fileSizeLimit! * 100).clamp(0, 100)
              : 0.0,
        },
        'warnings': <String>[],
        'lastChecked': DateTime.now().toIso8601String(),
      };
      
      // Add warnings based on usage
      final sizePercentage = quotaInfo['utilization']['sizePercentage'] as double;
      if (sizePercentage > 90) {
        (quotaInfo['warnings'] as List<String>).add('Storage usage is above 90%');
      } else if (sizePercentage > 75) {
        (quotaInfo['warnings'] as List<String>).add('Storage usage is above 75%');
      }
      
      if (stats.totalFiles > 10000) {
        (quotaInfo['warnings'] as List<String>).add('Large number of files may impact performance');
      }
      
      Logger.info('Quota monitoring completed for bucket $bucketId');
      return quotaInfo;
    } catch (e, stackTrace) {
      Logger.error('Failed to monitor quota for bucket $bucketId', e, stackTrace);
      return {};
    }
  }

  /// Start automatic statistics refresh for a bucket
  void startAutoRefresh(String bucketId, {Duration? interval}) {
    try {
      final refreshInterval = interval ?? StorageConstants.statsRefreshInterval;
      
      // Cancel existing timer if any
      _refreshTimers[bucketId]?.cancel();
      
      // Start new timer
      _refreshTimers[bucketId] = Timer.periodic(refreshInterval, (timer) async {
        try {
          Logger.debug('Auto-refreshing statistics for bucket: $bucketId');
          await calculateBucketStatistics(bucketId);
        } catch (e) {
          Logger.warning('Auto-refresh failed for bucket $bucketId', e);
        }
      });
      
      Logger.info('Started auto-refresh for bucket $bucketId with interval ${refreshInterval.inMinutes} minutes');
    } catch (e) {
      Logger.error('Failed to start auto-refresh for bucket $bucketId', e);
    }
  }

  /// Stop automatic statistics refresh for a bucket
  void stopAutoRefresh(String bucketId) {
    try {
      _refreshTimers[bucketId]?.cancel();
      _refreshTimers.remove(bucketId);
      Logger.info('Stopped auto-refresh for bucket: $bucketId');
    } catch (e) {
      Logger.error('Failed to stop auto-refresh for bucket $bucketId', e);
    }
  }

  /// Start auto-refresh for all buckets
  Future<void> startAutoRefreshAll({Duration? interval}) async {
    try {
      final buckets = await _repository.getBuckets();
      for (final bucket in buckets) {
        startAutoRefresh(bucket.id, interval: interval);
      }
      Logger.info('Started auto-refresh for all ${buckets.length} buckets');
    } catch (e) {
      Logger.error('Failed to start auto-refresh for all buckets', e);
    }
  }

  /// Stop auto-refresh for all buckets
  void stopAutoRefreshAll() {
    try {
      final bucketIds = List<String>.from(_refreshTimers.keys);
      for (final bucketId in bucketIds) {
        stopAutoRefresh(bucketId);
      }
      Logger.info('Stopped auto-refresh for all buckets');
    } catch (e) {
      Logger.error('Failed to stop auto-refresh for all buckets', e);
    }
  }

  /// Get statistics summary for dashboard
  Future<Map<String, dynamic>> getDashboardSummary() async {
    try {
      Logger.info('Generating dashboard summary');
      
      final overallStats = await calculateOverallStatistics();
      final allBucketStats = await calculateAllBucketStatistics();
      
      // Find top buckets by size and file count
      final bucketsBySize = allBucketStats.entries.toList()
        ..sort((a, b) => b.value.totalSize.compareTo(a.value.totalSize));
      
      final bucketsByFiles = allBucketStats.entries.toList()
        ..sort((a, b) => b.value.totalFiles.compareTo(a.value.totalFiles));
      
      final summary = {
        'overall': {
          'totalBuckets': allBucketStats.length,
          'totalFiles': overallStats.totalFiles,
          'totalSize': overallStats.totalSize,
          'formattedTotalSize': overallStats.formattedTotalSize,
          'averageFileSize': overallStats.averageFileSize,
          'formattedAverageSize': overallStats.formattedAverageSize,
        },
        'fileTypeBreakdown': overallStats.fileTypeBreakdown.map(
          (key, value) => MapEntry(key.name, value),
        ),
        'topBucketsBySize': bucketsBySize.take(5).map((entry) => {
          'bucketId': entry.key,
          'totalSize': entry.value.totalSize,
          'formattedSize': entry.value.formattedTotalSize,
          'fileCount': entry.value.totalFiles,
        }).toList(),
        'topBucketsByFiles': bucketsByFiles.take(5).map((entry) => {
          'bucketId': entry.key,
          'fileCount': entry.value.totalFiles,
          'totalSize': entry.value.totalSize,
          'formattedSize': entry.value.formattedTotalSize,
        }).toList(),
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      Logger.info('Dashboard summary generated successfully');
      return summary;
    } catch (e, stackTrace) {
      Logger.error('Failed to generate dashboard summary', e, stackTrace);
      return {};
    }
  }

  /// Helper method to get all files recursively
  Future<List<StorageFile>> _getAllFilesRecursively(String bucketId, {String? path}) async {
    final allFiles = <StorageFile>[];
    
    try {
      final files = await _repository.getFiles(bucketId, path: path);
      
      for (final file in files) {
        if (file.isFolder) {
          // Recursively get files from subdirectories
          final subFiles = await _getAllFilesRecursively(bucketId, path: file.path);
          allFiles.addAll(subFiles);
        } else {
          allFiles.add(file);
        }
      }
    } catch (e) {
      Logger.warning('Failed to get files recursively from $bucketId/$path', e);
    }
    
    return allFiles;
  }

  /// Helper method to get the most active file type
  String _getMostActiveFileType(StorageStats stats) {
    if (stats.fileTypeBreakdown.isEmpty) return 'none';
    
    final sortedTypes = stats.fileTypeBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedTypes.first.key.name;
  }

  /// Notify listeners of statistics updates
  void _notifyStatsUpdate(Map<String, StorageStats> stats) {
    if (!_statsController.isClosed) {
      _statsController.add(stats);
    }
  }

  /// Dispose of resources
  void dispose() {
    try {
      stopAutoRefreshAll();
      _statsController.close();
      Logger.info('Storage statistics service disposed');
    } catch (e) {
      Logger.error('Failed to dispose storage statistics service', e);
    }
  }
}