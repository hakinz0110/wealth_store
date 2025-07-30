import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/storage_models.dart';
import '../services/storage_repository.dart';
import '../services/file_validator.dart';
import '../services/upload_progress_tracker.dart';
import '../services/storage_cache.dart';
import '../services/storage_statistics_service.dart';
import '../interfaces/storage_interfaces.dart';
import '../../../shared/utils/logger.dart';

// Core service providers
final fileValidatorProvider = Provider<IFileValidator>((ref) {
  return StorageFileValidator.createWithBucketRules();
});

final storageCacheProvider = Provider<IStorageCache>((ref) {
  return InMemoryStorageCache();
});

final uploadProgressTrackerProvider = Provider<IUploadProgressTracker>((ref) {
  return StorageUploadProgressTracker();
});

final storageRepositoryProvider = Provider<IStorageRepository>((ref) {
  return SupabaseStorageRepository(
    fileValidator: ref.read(fileValidatorProvider),
    cache: ref.read(storageCacheProvider),
    progressTracker: ref.read(uploadProgressTrackerProvider),
  );
});

final storageStatisticsServiceProvider = Provider<StorageStatisticsService>((ref) {
  return StorageStatisticsService(
    repository: ref.read(storageRepositoryProvider),
    cache: ref.read(storageCacheProvider),
  );
});

// Bucket management providers
final storageBucketsProvider = FutureProvider<List<StorageBucket>>((ref) async {
  try {
    Logger.info('Loading storage buckets');
    final repository = ref.read(storageRepositoryProvider);
    final buckets = await repository.getBuckets();
    Logger.info('Loaded ${buckets.length} storage buckets');
    return buckets;
  } catch (e, stackTrace) {
    Logger.error('Failed to load storage buckets', e, stackTrace);
    rethrow;
  }
});

final selectedBucketProvider = StateProvider<String?>((ref) => null);

final selectedBucketDetailsProvider = Provider<StorageBucket?>((ref) {
  final selectedBucketId = ref.watch(selectedBucketProvider);
  if (selectedBucketId == null) return null;
  
  final bucketsAsync = ref.watch(storageBucketsProvider);
  return bucketsAsync.when(
    data: (buckets) => buckets.firstWhere(
      (bucket) => bucket.id == selectedBucketId,
      orElse: () => throw StateError('Bucket not found: $selectedBucketId'),
    ),
    loading: () => null,
    error: (_, __) => null,
  );
});

// Bucket contents provider with path support
final bucketContentsProvider = FutureProvider.family<List<StorageFile>, BucketPathParams>((ref, params) async {
  try {
    Logger.info('Loading files for bucket: ${params.bucketId}, path: ${params.path}');
    final repository = ref.read(storageRepositoryProvider);
    final files = await repository.getFiles(params.bucketId, path: params.path);
    Logger.info('Loaded ${files.length} files for bucket: ${params.bucketId}');
    return files;
  } catch (e, stackTrace) {
    Logger.error('Failed to load files for bucket: ${params.bucketId}', e, stackTrace);
    rethrow;
  }
});

// Current path provider for navigation
final currentPathProvider = StateProvider.family<String, String>((ref, bucketId) => '');

// Current bucket files provider (combines selected bucket and path)
final currentBucketFilesProvider = FutureProvider<List<StorageFile>>((ref) async {
  final selectedBucketId = ref.watch(selectedBucketProvider);
  if (selectedBucketId == null) return <StorageFile>[];
  
  final currentPath = ref.watch(currentPathProvider(selectedBucketId));
  final params = BucketPathParams(bucketId: selectedBucketId, path: currentPath);
  
  return ref.watch(bucketContentsProvider(params).future);
});

// Loading states
final bucketsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(storageBucketsProvider).isLoading;
});

final bucketFilesLoadingProvider = Provider<bool>((ref) {
  return ref.watch(currentBucketFilesProvider).isLoading;
});

// Error states
final bucketsErrorProvider = Provider<String?>((ref) {
  final bucketsAsync = ref.watch(storageBucketsProvider);
  return bucketsAsync.when(
    data: (_) => null,
    loading: () => null,
    error: (error, _) => error.toString(),
  );
});

final bucketFilesErrorProvider = Provider<String?>((ref) {
  final filesAsync = ref.watch(currentBucketFilesProvider);
  return filesAsync.when(
    data: (_) => null,
    loading: () => null,
    error: (error, _) => error.toString(),
  );
});

// Bucket methods provider
final bucketMethodsProvider = Provider<BucketMethods>((ref) {
  return BucketMethods(ref);
});

/// Helper class for bucket path parameters
class BucketPathParams {
  final String bucketId;
  final String? path;

  const BucketPathParams({
    required this.bucketId,
    this.path,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BucketPathParams &&
          runtimeType == other.runtimeType &&
          bucketId == other.bucketId &&
          path == other.path;

  @override
  int get hashCode => bucketId.hashCode ^ path.hashCode;

  @override
  String toString() => 'BucketPathParams(bucketId: $bucketId, path: $path)';
}

/// Bucket management methods
class BucketMethods {
  final Ref _ref;

  BucketMethods(this._ref);

  /// Select a bucket and reset path
  void selectBucket(String bucketId) {
    try {
      Logger.info('Selecting bucket: $bucketId');
      _ref.read(selectedBucketProvider.notifier).state = bucketId;
      _ref.read(currentPathProvider(bucketId).notifier).state = '';
      Logger.info('Selected bucket: $bucketId');
    } catch (e) {
      Logger.error('Failed to select bucket: $bucketId', e);
    }
  }

  /// Navigate to a specific path within the current bucket
  void navigateToPath(String bucketId, String path) {
    try {
      Logger.info('Navigating to path: $path in bucket: $bucketId');
      _ref.read(currentPathProvider(bucketId).notifier).state = path;
      
      // Invalidate the bucket contents to force refresh
      final params = BucketPathParams(bucketId: bucketId, path: path);
      _ref.invalidate(bucketContentsProvider(params));
      
      Logger.info('Navigated to path: $path');
    } catch (e) {
      Logger.error('Failed to navigate to path: $path', e);
    }
  }

  /// Go back to parent directory
  void navigateUp(String bucketId) {
    try {
      final currentPath = _ref.read(currentPathProvider(bucketId));
      if (currentPath.isEmpty) return;
      
      final pathParts = currentPath.split('/');
      pathParts.removeLast();
      final parentPath = pathParts.join('/');
      
      Logger.info('Navigating up from: $currentPath to: $parentPath');
      navigateToPath(bucketId, parentPath);
    } catch (e) {
      Logger.error('Failed to navigate up', e);
    }
  }

  /// Go to bucket root
  void navigateToRoot(String bucketId) {
    try {
      Logger.info('Navigating to root of bucket: $bucketId');
      navigateToPath(bucketId, '');
    } catch (e) {
      Logger.error('Failed to navigate to root', e);
    }
  }

  /// Refresh bucket list
  Future<void> refreshBuckets() async {
    try {
      Logger.info('Refreshing bucket list');
      _ref.invalidate(storageBucketsProvider);
      await _ref.read(storageBucketsProvider.future);
      Logger.info('Bucket list refreshed');
    } catch (e) {
      Logger.error('Failed to refresh bucket list', e);
      rethrow;
    }
  }

  /// Refresh current bucket contents
  Future<void> refreshCurrentBucket() async {
    try {
      final selectedBucketId = _ref.read(selectedBucketProvider);
      if (selectedBucketId == null) return;
      
      Logger.info('Refreshing contents for bucket: $selectedBucketId');
      
      final currentPath = _ref.read(currentPathProvider(selectedBucketId));
      final params = BucketPathParams(bucketId: selectedBucketId, path: currentPath);
      
      _ref.invalidate(bucketContentsProvider(params));
      await _ref.read(bucketContentsProvider(params).future);
      
      Logger.info('Bucket contents refreshed');
    } catch (e) {
      Logger.error('Failed to refresh bucket contents', e);
      rethrow;
    }
  }

  /// Get bucket by ID
  StorageBucket? getBucket(String bucketId) {
    try {
      final bucketsAsync = _ref.read(storageBucketsProvider);
      return bucketsAsync.when(
        data: (buckets) => buckets.firstWhere(
          (bucket) => bucket.id == bucketId,
          orElse: () => throw StateError('Bucket not found: $bucketId'),
        ),
        loading: () => null,
        error: (_, __) => null,
      );
    } catch (e) {
      Logger.error('Failed to get bucket: $bucketId', e);
      return null;
    }
  }

  /// Check if bucket exists
  bool bucketExists(String bucketId) {
    try {
      return getBucket(bucketId) != null;
    } catch (e) {
      Logger.error('Failed to check if bucket exists: $bucketId', e);
      return false;
    }
  }

  /// Get current breadcrumbs
  List<Map<String, String>> getCurrentBreadcrumbs() {
    try {
      final selectedBucketId = _ref.read(selectedBucketProvider);
      if (selectedBucketId == null) return [];
      
      final currentPath = _ref.read(currentPathProvider(selectedBucketId));
      final breadcrumbs = <Map<String, String>>[];
      
      // Add bucket root
      breadcrumbs.add({
        'name': selectedBucketId,
        'path': '',
        'isBucket': 'true',
      });
      
      if (currentPath.isNotEmpty) {
        final pathParts = currentPath.split('/');
        String buildPath = '';
        
        for (int i = 0; i < pathParts.length; i++) {
          if (pathParts[i].isEmpty) continue;
          
          buildPath = buildPath.isEmpty ? pathParts[i] : '$buildPath/${pathParts[i]}';
          breadcrumbs.add({
            'name': pathParts[i],
            'path': buildPath,
            'isBucket': 'false',
          });
        }
      }
      
      return breadcrumbs;
    } catch (e) {
      Logger.error('Failed to get current breadcrumbs', e);
      return [];
    }
  }

  /// Get current path for selected bucket
  String getCurrentPath() {
    try {
      final selectedBucketId = _ref.read(selectedBucketProvider);
      if (selectedBucketId == null) return '';
      
      return _ref.read(currentPathProvider(selectedBucketId));
    } catch (e) {
      Logger.error('Failed to get current path', e);
      return '';
    }
  }

  /// Clear cache for a bucket
  Future<void> clearBucketCache(String bucketId) async {
    try {
      Logger.info('Clearing cache for bucket: $bucketId');
      final cache = _ref.read(storageCacheProvider);
      await cache.clearBucketCache(bucketId);
      
      // Invalidate related providers
      _ref.invalidate(storageBucketsProvider);
      
      // Invalidate all bucket contents for this bucket
      final currentPath = _ref.read(currentPathProvider(bucketId));
      final params = BucketPathParams(bucketId: bucketId, path: currentPath);
      _ref.invalidate(bucketContentsProvider(params));
      
      Logger.info('Cache cleared for bucket: $bucketId');
    } catch (e) {
      Logger.error('Failed to clear cache for bucket: $bucketId', e);
    }
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    try {
      Logger.info('Clearing all storage cache');
      final cache = _ref.read(storageCacheProvider);
      await cache.clearAllCache();
      
      // Invalidate all providers
      _ref.invalidate(storageBucketsProvider);
      _ref.invalidate(bucketContentsProvider);
      
      Logger.info('All storage cache cleared');
    } catch (e) {
      Logger.error('Failed to clear all cache', e);
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    try {
      final cache = _ref.read(storageCacheProvider);
      if (cache is InMemoryStorageCache) {
        return cache.getCacheStats();
      }
      return {};
    } catch (e) {
      Logger.error('Failed to get cache stats', e);
      return {};
    }
  }
}