import 'dart:convert';
import '../interfaces/storage_interfaces.dart';
import '../models/storage_models.dart';
import '../constants/storage_constants.dart';
import '../../../shared/utils/logger.dart';

/// In-memory storage cache implementation with LRU eviction
class InMemoryStorageCache implements IStorageCache {
  final Map<String, _CacheEntry<List<StorageBucket>>> _bucketCache = {};
  final Map<String, _CacheEntry<List<StorageFile>>> _fileCache = {};
  final Map<String, _CacheEntry<StorageStats>> _statsCache = {};
  
  // LRU tracking
  final Map<String, DateTime> _accessTimes = {};
  
  // Cache size limits
  static const int maxFileCacheEntries = 100;
  static const int maxBucketCacheEntries = 10;
  static const int maxStatsCacheEntries = 50;
  
  @override
  Future<void> cacheBuckets(List<StorageBucket> buckets) async {
    try {
      _bucketCache['buckets'] = _CacheEntry(
        data: buckets,
        timestamp: DateTime.now(),
      );
      Logger.debug('Cached ${buckets.length} buckets');
    } catch (e) {
      Logger.error('Failed to cache buckets', e);
    }
  }

  @override
  Future<List<StorageBucket>?> getCachedBuckets() async {
    try {
      final entry = _bucketCache['buckets'];
      if (entry != null && isCacheValid('buckets', StorageConstants.cacheExpiration)) {
        Logger.debug('Retrieved ${entry.data.length} buckets from cache');
        return entry.data;
      }
      return null;
    } catch (e) {
      Logger.error('Failed to get cached buckets', e);
      return null;
    }
  }

  @override
  Future<void> cacheFiles(
    String bucketId,
    String path,
    List<StorageFile> files,
  ) async {
    try {
      final key = _getFilesCacheKey(bucketId, path);
      
      // Evict old entries if cache is full
      _evictIfNeeded(_fileCache, maxFileCacheEntries);
      
      _fileCache[key] = _CacheEntry(
        data: files,
        timestamp: DateTime.now(),
      );
      _accessTimes[key] = DateTime.now();
      
      Logger.debug('Cached ${files.length} files for $bucketId/$path');
    } catch (e) {
      Logger.error('Failed to cache files for $bucketId/$path', e);
    }
  }

  @override
  Future<List<StorageFile>?> getCachedFiles(String bucketId, String path) async {
    try {
      final key = _getFilesCacheKey(bucketId, path);
      final entry = _fileCache[key];
      if (entry != null && isCacheValid(key, StorageConstants.cacheExpiration)) {
        // Update access time for LRU
        _accessTimes[key] = DateTime.now();
        Logger.debug('Retrieved ${entry.data.length} files from cache for $bucketId/$path');
        return entry.data;
      }
      return null;
    } catch (e) {
      Logger.error('Failed to get cached files for $bucketId/$path', e);
      return null;
    }
  }

  @override
  Future<void> cacheStats(String bucketId, StorageStats stats) async {
    try {
      final key = _getStatsCacheKey(bucketId);
      _statsCache[key] = _CacheEntry(
        data: stats,
        timestamp: DateTime.now(),
      );
      Logger.debug('Cached stats for bucket $bucketId');
    } catch (e) {
      Logger.error('Failed to cache stats for bucket $bucketId', e);
    }
  }

  @override
  Future<StorageStats?> getCachedStats(String bucketId) async {
    try {
      final key = _getStatsCacheKey(bucketId);
      final entry = _statsCache[key];
      if (entry != null && isCacheValid(key, StorageConstants.statsRefreshInterval)) {
        Logger.debug('Retrieved stats from cache for bucket $bucketId');
        return entry.data;
      }
      return null;
    } catch (e) {
      Logger.error('Failed to get cached stats for bucket $bucketId', e);
      return null;
    }
  }

  @override
  Future<void> clearBucketCache(String bucketId) async {
    try {
      // Clear files cache for this bucket
      final keysToRemove = _fileCache.keys
          .where((key) => key.startsWith('files_$bucketId'))
          .toList();
      
      for (final key in keysToRemove) {
        _fileCache.remove(key);
      }
      
      // Clear stats cache for this bucket
      final statsKey = _getStatsCacheKey(bucketId);
      _statsCache.remove(statsKey);
      
      // Clear buckets cache (since bucket stats might have changed)
      _bucketCache.remove('buckets');
      
      Logger.debug('Cleared cache for bucket $bucketId');
    } catch (e) {
      Logger.error('Failed to clear cache for bucket $bucketId', e);
    }
  }

  @override
  Future<void> clearAllCache() async {
    try {
      final totalEntries = _bucketCache.length + _fileCache.length + _statsCache.length;
      
      _bucketCache.clear();
      _fileCache.clear();
      _statsCache.clear();
      
      Logger.info('Cleared all cache entries: $totalEntries items');
    } catch (e) {
      Logger.error('Failed to clear all cache', e);
    }
  }

  @override
  bool isCacheValid(String key, Duration maxAge) {
    try {
      // Check in all cache maps
      _CacheEntry? entry;
      
      if (_bucketCache.containsKey(key)) {
        entry = _bucketCache[key];
      } else if (_fileCache.containsKey(key)) {
        entry = _fileCache[key];
      } else if (_statsCache.containsKey(key)) {
        entry = _statsCache[key];
      }
      
      if (entry == null) return false;
      
      final age = DateTime.now().difference(entry.timestamp);
      return age <= maxAge;
    } catch (e) {
      Logger.error('Failed to check cache validity for key $key', e);
      return false;
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'bucketCacheSize': _bucketCache.length,
      'fileCacheSize': _fileCache.length,
      'statsCacheSize': _statsCache.length,
      'totalCacheSize': _bucketCache.length + _fileCache.length + _statsCache.length,
      'oldestEntry': _getOldestEntryAge(),
      'newestEntry': _getNewestEntryAge(),
    };
  }

  /// Get memory usage estimate (rough)
  int getEstimatedMemoryUsage() {
    int totalSize = 0;
    
    // Estimate bucket cache size
    for (final entry in _bucketCache.values) {
      totalSize += entry.data.length * 500; // Rough estimate per bucket
    }
    
    // Estimate file cache size
    for (final entry in _fileCache.values) {
      totalSize += entry.data.length * 300; // Rough estimate per file
    }
    
    // Estimate stats cache size
    totalSize += _statsCache.length * 200; // Rough estimate per stats entry
    
    return totalSize;
  }

  /// Clean up expired cache entries
  Future<void> cleanupExpiredEntries() async {
    try {
      int removedCount = 0;
      
      // Clean bucket cache
      final expiredBucketKeys = _bucketCache.keys
          .where((key) => !isCacheValid(key, StorageConstants.cacheExpiration))
          .toList();
      
      for (final key in expiredBucketKeys) {
        _bucketCache.remove(key);
        removedCount++;
      }
      
      // Clean file cache
      final expiredFileKeys = _fileCache.keys
          .where((key) => !isCacheValid(key, StorageConstants.cacheExpiration))
          .toList();
      
      for (final key in expiredFileKeys) {
        _fileCache.remove(key);
        removedCount++;
      }
      
      // Clean stats cache
      final expiredStatsKeys = _statsCache.keys
          .where((key) => !isCacheValid(key, StorageConstants.statsRefreshInterval))
          .toList();
      
      for (final key in expiredStatsKeys) {
        _statsCache.remove(key);
        removedCount++;
      }
      
      if (removedCount > 0) {
        Logger.info('Cleaned up $removedCount expired cache entries');
      }
    } catch (e) {
      Logger.error('Failed to cleanup expired cache entries', e);
    }
  }

  /// Preload cache with commonly accessed data
  Future<void> preloadCache(List<String> bucketIds) async {
    try {
      Logger.info('Preloading cache for ${bucketIds.length} buckets');
      // This would be implemented by the storage repository
      // to proactively load frequently accessed data
    } catch (e) {
      Logger.error('Failed to preload cache', e);
    }
  }

  /// Get cache hit rate (for monitoring)
  double getCacheHitRate() {
    // This would require tracking hits and misses
    // For now, return a placeholder
    return 0.0;
  }

  /// Evict least recently used entries if cache is full
  void _evictIfNeeded<T>(Map<String, _CacheEntry<T>> cache, int maxEntries) {
    if (cache.length >= maxEntries) {
      // Find least recently used entries
      final sortedKeys = cache.keys.toList()
        ..sort((a, b) {
          final aTime = _accessTimes[a] ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = _accessTimes[b] ?? DateTime.fromMillisecondsSinceEpoch(0);
          return aTime.compareTo(bTime);
        });
      
      // Remove oldest entries
      final entriesToRemove = cache.length - maxEntries + 1;
      for (int i = 0; i < entriesToRemove && i < sortedKeys.length; i++) {
        final key = sortedKeys[i];
        cache.remove(key);
        _accessTimes.remove(key);
      }
      
      Logger.debug('Evicted $entriesToRemove cache entries');
    }
  }

  /// Batch cache operations for better performance
  Future<void> batchCacheFiles(Map<String, List<StorageFile>> filesToCache) async {
    try {
      for (final entry in filesToCache.entries) {
        final parts = entry.key.split('|');
        if (parts.length == 2) {
          await cacheFiles(parts[0], parts[1], entry.value);
        }
      }
      Logger.debug('Batch cached ${filesToCache.length} file lists');
    } catch (e) {
      Logger.error('Failed to batch cache files', e);
    }
  }

  /// Get cache entry by priority (most recently accessed first)
  List<String> getCacheKeysByPriority() {
    final keys = _accessTimes.keys.toList()
      ..sort((a, b) {
        final aTime = _accessTimes[a]!;
        final bTime = _accessTimes[b]!;
        return bTime.compareTo(aTime); // Most recent first
      });
    return keys;
  }

  /// Helper methods
  String _getFilesCacheKey(String bucketId, String path) {
    return 'files_${bucketId}_${path.replaceAll('/', '_')}';
  }

  String _getStatsCacheKey(String bucketId) {
    return 'stats_$bucketId';
  }

  Duration? _getOldestEntryAge() {
    DateTime? oldest;
    
    for (final entry in _bucketCache.values) {
      if (oldest == null || entry.timestamp.isBefore(oldest)) {
        oldest = entry.timestamp;
      }
    }
    
    for (final entry in _fileCache.values) {
      if (oldest == null || entry.timestamp.isBefore(oldest)) {
        oldest = entry.timestamp;
      }
    }
    
    for (final entry in _statsCache.values) {
      if (oldest == null || entry.timestamp.isBefore(oldest)) {
        oldest = entry.timestamp;
      }
    }
    
    return oldest != null ? DateTime.now().difference(oldest) : null;
  }

  Duration? _getNewestEntryAge() {
    DateTime? newest;
    
    for (final entry in _bucketCache.values) {
      if (newest == null || entry.timestamp.isAfter(newest)) {
        newest = entry.timestamp;
      }
    }
    
    for (final entry in _fileCache.values) {
      if (newest == null || entry.timestamp.isAfter(newest)) {
        newest = entry.timestamp;
      }
    }
    
    for (final entry in _statsCache.values) {
      if (newest == null || entry.timestamp.isAfter(newest)) {
        newest = entry.timestamp;
      }
    }
    
    return newest != null ? DateTime.now().difference(newest) : null;
  }
}

/// Cache entry wrapper with timestamp
class _CacheEntry<T> {
  final T data;
  final DateTime timestamp;

  _CacheEntry({
    required this.data,
    required this.timestamp,
  });
}

/// Persistent storage cache implementation (for future use)
class PersistentStorageCache implements IStorageCache {
  // This would implement persistent caching using shared_preferences
  // or a local database like Hive or SQLite
  
  @override
  Future<void> cacheBuckets(List<StorageBucket> buckets) async {
    // TODO: Implement persistent bucket caching
    throw UnimplementedError('Persistent cache not implemented yet');
  }

  @override
  Future<List<StorageBucket>?> getCachedBuckets() async {
    // TODO: Implement persistent bucket retrieval
    throw UnimplementedError('Persistent cache not implemented yet');
  }

  @override
  Future<void> cacheFiles(String bucketId, String path, List<StorageFile> files) async {
    // TODO: Implement persistent file caching
    throw UnimplementedError('Persistent cache not implemented yet');
  }

  @override
  Future<List<StorageFile>?> getCachedFiles(String bucketId, String path) async {
    // TODO: Implement persistent file retrieval
    throw UnimplementedError('Persistent cache not implemented yet');
  }

  @override
  Future<void> cacheStats(String bucketId, StorageStats stats) async {
    // TODO: Implement persistent stats caching
    throw UnimplementedError('Persistent cache not implemented yet');
  }

  @override
  Future<StorageStats?> getCachedStats(String bucketId) async {
    // TODO: Implement persistent stats retrieval
    throw UnimplementedError('Persistent cache not implemented yet');
  }

  @override
  Future<void> clearBucketCache(String bucketId) async {
    // TODO: Implement persistent bucket cache clearing
    throw UnimplementedError('Persistent cache not implemented yet');
  }

  @override
  Future<void> clearAllCache() async {
    // TODO: Implement persistent cache clearing
    throw UnimplementedError('Persistent cache not implemented yet');
  }

  @override
  bool isCacheValid(String key, Duration maxAge) {
    // TODO: Implement persistent cache validation
    throw UnimplementedError('Persistent cache not implemented yet');
  }
}