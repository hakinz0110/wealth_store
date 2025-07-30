import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:async';
import '../models/storage_models.dart';
import '../services/storage_search_service.dart';
import 'storage_providers.dart';
import '../../../shared/utils/logger.dart';

// Search service provider
final storageSearchServiceProvider = Provider<StorageSearchService>((ref) {
  return StorageSearchService(
    repository: ref.read(storageRepositoryProvider),
  );
});

// Search query state provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Search filters state provider
final searchFiltersProvider = StateProvider<StorageFilters>((ref) => const StorageFilters());

// Debounced search query provider
final debouncedSearchQueryProvider = Provider<String>((ref) {
  final query = ref.watch(searchQueryProvider);
  
  // Create a timer to debounce the search
  Timer? debounceTimer;
  final completer = Completer<String>();
  
  debounceTimer?.cancel();
  debounceTimer = Timer(const Duration(milliseconds: 300), () {
    if (!completer.isCompleted) {
      completer.complete(query);
    }
  });
  
  ref.onDispose(() {
    debounceTimer?.cancel();
  });
  
  return query;
});

// Search results provider
final searchResultsProvider = FutureProvider<List<StorageFile>>((ref) async {
  try {
    final searchService = ref.read(storageSearchServiceProvider);
    final query = ref.watch(debouncedSearchQueryProvider);
    final filters = ref.watch(searchFiltersProvider);
    
    // If no search query and no filters, return empty results
    if (query.trim().isEmpty && !filters.hasActiveFilters) {
      return <StorageFile>[];
    }
    
    Logger.info('Performing search with query: "$query"');
    
    // Combine query with filters
    final searchFilters = filters.copyWith(searchQuery: query.trim().isEmpty ? null : query.trim());
    
    final results = await searchService.searchFiles(searchFilters);
    Logger.info('Search completed with ${results.length} results');
    
    return results;
  } catch (e, stackTrace) {
    Logger.error('Search failed', e, stackTrace);
    rethrow;
  }
});

// Search across all buckets provider
final globalSearchResultsProvider = FutureProvider<Map<String, List<StorageFile>>>((ref) async {
  try {
    final searchService = ref.read(storageSearchServiceProvider);
    final query = ref.watch(debouncedSearchQueryProvider);
    final filters = ref.watch(searchFiltersProvider);
    
    // If no search query and no filters, return empty results
    if (query.trim().isEmpty && !filters.hasActiveFilters) {
      return <String, List<StorageFile>>{};
    }
    
    Logger.info('Performing global search with query: "$query"');
    
    // Combine query with filters
    final searchFilters = filters.copyWith(searchQuery: query.trim().isEmpty ? null : query.trim());
    
    final results = await searchService.searchFilesAcrossBuckets(searchFilters);
    Logger.info('Global search completed with results from ${results.keys.length} buckets');
    
    return results;
  } catch (e, stackTrace) {
    Logger.error('Global search failed', e, stackTrace);
    rethrow;
  }
});

// Current bucket search results provider
final currentBucketSearchResultsProvider = FutureProvider<List<StorageFile>>((ref) async {
  try {
    final selectedBucketId = ref.watch(selectedBucketProvider);
    if (selectedBucketId == null) return <StorageFile>[];
    
    final searchService = ref.read(storageSearchServiceProvider);
    final query = ref.watch(debouncedSearchQueryProvider);
    final filters = ref.watch(searchFiltersProvider);
    
    // If no search query and no filters, return current bucket files
    if (query.trim().isEmpty && !filters.hasActiveFilters) {
      return ref.watch(currentBucketFilesProvider.future);
    }
    
    Logger.info('Performing search in bucket: $selectedBucketId with query: "$query"');
    
    // Combine query with filters and bucket ID
    final searchFilters = filters.copyWith(
      searchQuery: query.trim().isEmpty ? null : query.trim(),
      bucketId: selectedBucketId,
    );
    
    final results = await searchService.searchFiles(searchFilters);
    Logger.info('Bucket search completed with ${results.length} results');
    
    return results;
  } catch (e, stackTrace) {
    Logger.error('Bucket search failed', e, stackTrace);
    rethrow;
  }
});

// Search loading states
final searchLoadingProvider = Provider<bool>((ref) {
  return ref.watch(searchResultsProvider).isLoading;
});

final globalSearchLoadingProvider = Provider<bool>((ref) {
  return ref.watch(globalSearchResultsProvider).isLoading;
});

final currentBucketSearchLoadingProvider = Provider<bool>((ref) {
  return ref.watch(currentBucketSearchResultsProvider).isLoading;
});

// Search error states
final searchErrorProvider = Provider<String?>((ref) {
  final searchAsync = ref.watch(searchResultsProvider);
  return searchAsync.when(
    data: (_) => null,
    loading: () => null,
    error: (error, _) => error.toString(),
  );
});

// Search methods provider
final searchMethodsProvider = Provider<SearchMethods>((ref) {
  return SearchMethods(ref);
});

/// Search management methods
class SearchMethods {
  final Ref _ref;

  SearchMethods(this._ref);

  /// Update search query
  void updateSearchQuery(String query) {
    try {
      Logger.info('Updating search query: "$query"');
      _ref.read(searchQueryProvider.notifier).state = query;
    } catch (e) {
      Logger.error('Failed to update search query', e);
    }
  }

  /// Clear search query
  void clearSearchQuery() {
    try {
      Logger.info('Clearing search query');
      _ref.read(searchQueryProvider.notifier).state = '';
    } catch (e) {
      Logger.error('Failed to clear search query', e);
    }
  }

  /// Update search filters
  void updateFilters(StorageFilters filters) {
    try {
      Logger.info('Updating search filters');
      _ref.read(searchFiltersProvider.notifier).state = filters;
    } catch (e) {
      Logger.error('Failed to update search filters', e);
    }
  }

  /// Clear all filters
  void clearFilters() {
    try {
      Logger.info('Clearing all search filters');
      _ref.read(searchFiltersProvider.notifier).state = const StorageFilters();
    } catch (e) {
      Logger.error('Failed to clear search filters', e);
    }
  }

  /// Add file type filter
  void addFileTypeFilter(StorageFileType fileType) {
    try {
      final currentFilters = _ref.read(searchFiltersProvider);
      final updatedFilters = currentFilters.copyWith(fileType: fileType);
      updateFilters(updatedFilters);
    } catch (e) {
      Logger.error('Failed to add file type filter', e);
    }
  }

  /// Remove file type filter
  void removeFileTypeFilter() {
    try {
      final currentFilters = _ref.read(searchFiltersProvider);
      final updatedFilters = currentFilters.copyWith(fileType: null);
      updateFilters(updatedFilters);
    } catch (e) {
      Logger.error('Failed to remove file type filter', e);
    }
  }

  /// Add date range filter
  void addDateRangeFilter(DateTime? startDate, DateTime? endDate) {
    try {
      final currentFilters = _ref.read(searchFiltersProvider);
      final updatedFilters = currentFilters.copyWith(
        uploadedAfter: startDate,
        uploadedBefore: endDate,
      );
      updateFilters(updatedFilters);
    } catch (e) {
      Logger.error('Failed to add date range filter', e);
    }
  }

  /// Add size range filter
  void addSizeRangeFilter(int? minSize, int? maxSize) {
    try {
      final currentFilters = _ref.read(searchFiltersProvider);
      final updatedFilters = currentFilters.copyWith(
        minSize: minSize,
        maxSize: maxSize,
      );
      updateFilters(updatedFilters);
    } catch (e) {
      Logger.error('Failed to add size range filter', e);
    }
  }

  /// Get current search query
  String getCurrentQuery() {
    return _ref.read(searchQueryProvider);
  }

  /// Get current filters
  StorageFilters getCurrentFilters() {
    return _ref.read(searchFiltersProvider);
  }

  /// Check if search is active
  bool isSearchActive() {
    final query = _ref.read(searchQueryProvider);
    final filters = _ref.read(searchFiltersProvider);
    return query.trim().isNotEmpty || filters.hasActiveFilters;
  }

  /// Get search results count
  int getResultsCount() {
    try {
      final searchAsync = _ref.read(searchResultsProvider);
      return searchAsync.when(
        data: (results) => results.length,
        loading: () => 0,
        error: (_, __) => 0,
      );
    } catch (e) {
      Logger.error('Failed to get results count', e);
      return 0;
    }
  }

  /// Refresh search results
  Future<void> refreshSearchResults() async {
    try {
      Logger.info('Refreshing search results');
      _ref.invalidate(searchResultsProvider);
      _ref.invalidate(globalSearchResultsProvider);
      _ref.invalidate(currentBucketSearchResultsProvider);
      
      if (isSearchActive()) {
        await _ref.read(searchResultsProvider.future);
      }
      
      Logger.info('Search results refreshed');
    } catch (e) {
      Logger.error('Failed to refresh search results', e);
      rethrow;
    }
  }
}