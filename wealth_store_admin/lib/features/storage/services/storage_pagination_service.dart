import 'dart:async';
import '../models/storage_models.dart';
import '../interfaces/storage_interfaces.dart';
import '../constants/storage_constants.dart';
import '../../../shared/utils/logger.dart';

/// Service for paginated loading of storage bucket contents
class StoragePaginationService {
  final IStorageRepository _repository;
  final IStorageCache _cache;
  
  // Pagination state
  final Map<String, _PaginationState> _paginationStates = {};
  
  // Configuration
  static const int defaultPageSize = 50;
  static const int prefetchThreshold = 10; // Load next page when this many items from end
  
  StoragePaginationService({
    required IStorageRepository repository,
    required IStorageCache cache,
  }) : _repository = repository, _cache = cache;

  /// Get paginated files for a bucket path
  Future<PaginatedResult<StorageFile>> getFiles({
    required String bucketId,
    required String path,
    int page = 0,
    int pageSize = defaultPageSize,
    bool forceRefresh = false,
  }) async {
    final stateKey = _getStateKey(bucketId, path);
    
    try {
      // Get or create pagination state
      final state = _paginationStates[stateKey] ??= _PaginationState(
        bucketId: bucketId,
        path: path,
        pageSize: pageSize,
      );
      
      // Check if we already have this page
      if (!forceRefresh && state.hasPage(page)) {
        Logger.debug('Returning cached page $page for $bucketId/$path');
        return _buildResult(state, page);
      }
      
      // Check cache first
      if (!forceRefresh && page == 0) {
        final cachedFiles = await _cache.getCachedFiles(bucketId, path);
        if (cachedFiles != null) {
          Logger.debug('Using cached files for $bucketId/$path');
          state.setAllFiles(cachedFiles);
          return _buildResult(state, page);
        }
      }
      
      // Load from repository
      Logger.debug('Loading page $page for $bucketId/$path');
      final files = await _repository.listFiles(
        bucketId: bucketId,
        path: path,
        limit: pageSize,
        offset: page * pageSize,
      );
      
      // Update state
      state.setPage(page, files);
      
      // Cache first page
      if (page == 0) {
        await _cache.cacheFiles(bucketId, path, files);
      }
      
      Logger.debug('Loaded ${files.length} files for page $page of $bucketId/$path');
      return _buildResult(state, page);
      
    } catch (e) {
      Logger.error('Failed to load files for $bucketId/$path page $page', e);
      rethrow;
    }
  }

  /// Get all loaded files for a bucket path
  List<StorageFile> getAllLoadedFiles(String bucketId, String path) {
    final stateKey = _getStateKey(bucketId, path);
    final state = _paginationStates[stateKey];
    return state?.getAllFiles() ?? [];
  }

  /// Check if more pages are available
  bool hasMorePages(String bucketId, String path) {
    final stateKey = _getStateKey(bucketId, path);
    final state = _paginationStates[stateKey];
    return state?.hasMorePages ?? true;
  }

  /// Get current page count
  int getPageCount(String bucketId, String path) {
    final stateKey = _getStateKey(bucketId, path);
    final state = _paginationStates[stateKey];
    return state?.loadedPages.length ?? 0;
  }

  /// Prefetch next page if needed
  Future<void> prefetchIfNeeded({
    required String bucketId,
    required String path,
    required int currentIndex,
  }) async {
    final stateKey = _getStateKey(bucketId, path);
    final state = _paginationStates[stateKey];
    
    if (state == null) return;
    
    final totalLoaded = state.getAllFiles().length;
    final remainingItems = totalLoaded - currentIndex;
    
    // Prefetch next page if we're close to the end
    if (remainingItems <= prefetchThreshold && state.hasMorePages) {
      final nextPage = state.loadedPages.length;
      Logger.debug('Prefetching page $nextPage for $bucketId/$path');
      
      try {
        await getFiles(
          bucketId: bucketId,
          path: path,
          page: nextPage,
          pageSize: state.pageSize,
        );
      } catch (e) {
        Logger.error('Failed to prefetch page $nextPage for $bucketId/$path', e);
      }
    }
  }

  /// Load next page
  Future<PaginatedResult<StorageFile>> loadNextPage(String bucketId, String path) async {
    final stateKey = _getStateKey(bucketId, path);
    final state = _paginationStates[stateKey];
    
    if (state == null || !state.hasMorePages) {
      return PaginatedResult<StorageFile>(
        items: [],
        page: 0,
        pageSize: defaultPageSize,
        totalItems: 0,
        hasMore: false,
      );
    }
    
    final nextPage = state.loadedPages.length;
    return await getFiles(
      bucketId: bucketId,
      path: path,
      page: nextPage,
      pageSize: state.pageSize,
    );
  }

  /// Refresh all pages
  Future<void> refresh(String bucketId, String path) async {
    final stateKey = _getStateKey(bucketId, path);
    final state = _paginationStates[stateKey];
    
    if (state == null) return;
    
    Logger.debug('Refreshing all pages for $bucketId/$path');
    
    // Clear cache
    await _cache.clearBucketCache(bucketId);
    
    // Reload all currently loaded pages
    final pagesToReload = List.from(state.loadedPages.keys);
    state.clear();
    
    for (final page in pagesToReload) {
      try {
        await getFiles(
          bucketId: bucketId,
          path: path,
          page: page,
          pageSize: state.pageSize,
          forceRefresh: true,
        );
      } catch (e) {
        Logger.error('Failed to refresh page $page for $bucketId/$path', e);
      }
    }
  }

  /// Add a new file to the appropriate page
  void addFile(String bucketId, String path, StorageFile file) {
    final stateKey = _getStateKey(bucketId, path);
    final state = _paginationStates[stateKey];
    
    if (state != null) {
      state.addFile(file);
      Logger.debug('Added file ${file.name} to pagination state for $bucketId/$path');
    }
  }

  /// Remove a file from all pages
  void removeFile(String bucketId, String path, String fileId) {
    final stateKey = _getStateKey(bucketId, path);
    final state = _paginationStates[stateKey];
    
    if (state != null) {
      state.removeFile(fileId);
      Logger.debug('Removed file $fileId from pagination state for $bucketId/$path');
    }
  }

  /// Update a file in all pages
  void updateFile(String bucketId, String path, StorageFile updatedFile) {
    final stateKey = _getStateKey(bucketId, path);
    final state = _paginationStates[stateKey];
    
    if (state != null) {
      state.updateFile(updatedFile);
      Logger.debug('Updated file ${updatedFile.name} in pagination state for $bucketId/$path');
    }
  }

  /// Clear pagination state for a bucket path
  void clearState(String bucketId, String path) {
    final stateKey = _getStateKey(bucketId, path);
    _paginationStates.remove(stateKey);
    Logger.debug('Cleared pagination state for $bucketId/$path');
  }

  /// Clear all pagination states
  void clearAllStates() {
    _paginationStates.clear();
    Logger.debug('Cleared all pagination states');
  }

  /// Get pagination statistics
  Map<String, dynamic> getStats() {
    final stats = <String, dynamic>{};
    
    for (final entry in _paginationStates.entries) {
      final state = entry.value;
      stats[entry.key] = {
        'loadedPages': state.loadedPages.length,
        'totalFiles': state.getAllFiles().length,
        'hasMorePages': state.hasMorePages,
        'pageSize': state.pageSize,
      };
    }
    
    return {
      'totalStates': _paginationStates.length,
      'states': stats,
    };
  }

  /// Build paginated result from state
  PaginatedResult<StorageFile> _buildResult(_PaginationState state, int page) {
    final pageFiles = state.getPage(page);
    final allFiles = state.getAllFiles();
    
    return PaginatedResult<StorageFile>(
      items: pageFiles,
      page: page,
      pageSize: state.pageSize,
      totalItems: allFiles.length,
      hasMore: state.hasMorePages,
    );
  }

  /// Generate state key for bucket and path
  String _getStateKey(String bucketId, String path) {
    return '${bucketId}_${path.replaceAll('/', '_')}';
  }
}

/// Internal pagination state for a bucket path
class _PaginationState {
  final String bucketId;
  final String path;
  final int pageSize;
  
  final Map<int, List<StorageFile>> loadedPages = {};
  bool hasMorePages = true;
  
  _PaginationState({
    required this.bucketId,
    required this.path,
    required this.pageSize,
  });

  /// Check if a page is loaded
  bool hasPage(int page) {
    return loadedPages.containsKey(page);
  }

  /// Set files for a specific page
  void setPage(int page, List<StorageFile> files) {
    loadedPages[page] = files;
    
    // Update hasMorePages based on returned file count
    if (files.length < pageSize) {
      hasMorePages = false;
    }
  }

  /// Get files for a specific page
  List<StorageFile> getPage(int page) {
    return loadedPages[page] ?? [];
  }

  /// Get all loaded files in order
  List<StorageFile> getAllFiles() {
    final allFiles = <StorageFile>[];
    final sortedPages = loadedPages.keys.toList()..sort();
    
    for (final page in sortedPages) {
      allFiles.addAll(loadedPages[page]!);
    }
    
    return allFiles;
  }

  /// Set all files (used for cache loading)
  void setAllFiles(List<StorageFile> files) {
    loadedPages.clear();
    
    // Split files into pages
    for (int i = 0; i < files.length; i += pageSize) {
      final page = i ~/ pageSize;
      final endIndex = (i + pageSize).clamp(0, files.length);
      loadedPages[page] = files.sublist(i, endIndex);
    }
    
    // Determine if there might be more pages
    hasMorePages = files.length >= pageSize;
  }

  /// Add a file to the appropriate page
  void addFile(StorageFile file) {
    // Add to first page for now (in a real implementation, 
    // you might want to maintain sort order)
    if (loadedPages.containsKey(0)) {
      loadedPages[0]!.insert(0, file);
    }
  }

  /// Remove a file from all pages
  void removeFile(String fileId) {
    for (final pageFiles in loadedPages.values) {
      pageFiles.removeWhere((file) => file.id == fileId);
    }
  }

  /// Update a file in all pages
  void updateFile(StorageFile updatedFile) {
    for (final pageFiles in loadedPages.values) {
      final index = pageFiles.indexWhere((file) => file.id == updatedFile.id);
      if (index != -1) {
        pageFiles[index] = updatedFile;
      }
    }
  }

  /// Clear all loaded pages
  void clear() {
    loadedPages.clear();
    hasMorePages = true;
  }
}

/// Paginated result data class
class PaginatedResult<T> {
  final List<T> items;
  final int page;
  final int pageSize;
  final int totalItems;
  final bool hasMore;

  const PaginatedResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.hasMore,
  });

  @override
  String toString() {
    return 'PaginatedResult(page: $page, items: ${items.length}, total: $totalItems, hasMore: $hasMore)';
  }
}