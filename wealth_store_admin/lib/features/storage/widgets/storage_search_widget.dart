import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:async';
import '../models/storage_models.dart';
import '../providers/search_providers.dart';
import '../providers/storage_providers.dart';
import '../services/storage_search_service.dart';
import '../constants/storage_constants.dart';
import '../../../shared/constants/app_colors.dart';

/// Enhanced search widget with real-time search and suggestions
class StorageSearchWidget extends HookConsumerWidget {
  final bool showSuggestions;
  final bool showGlobalSearch;
  final Function(List<StorageFile>)? onSearchResults;
  final VoidCallback? onSearchFocus;
  final VoidCallback? onSearchBlur;

  const StorageSearchWidget({
    super.key,
    this.showSuggestions = true,
    this.showGlobalSearch = false,
    this.onSearchResults,
    this.onSearchFocus,
    this.onSearchBlur,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();
    final showSuggestionsOverlay = useState<bool>(false);
    final suggestions = useState<List<String>>([]);
    final isLoading = useState<bool>(false);
    
    // Watch providers
    final searchMethods = ref.read(searchMethodsProvider);
    final searchService = ref.read(storageSearchServiceProvider);
    final selectedBucketId = ref.watch(selectedBucketProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final searchResults = ref.watch(showGlobalSearch 
        ? globalSearchResultsProvider 
        : currentBucketSearchResultsProvider);
    
    // Sync controller with provider
    useEffect(() {
      if (searchController.text != searchQuery) {
        searchController.text = searchQuery;
      }
      return null;
    }, [searchQuery]);
    
    // Handle search input changes with debouncing
    useEffect(() {
      Timer? debounceTimer;
      
      void onSearchChanged() {
        final query = searchController.text;
        searchMethods.updateSearchQuery(query);
        
        // Handle suggestions
        if (showSuggestions && query.length >= 2) {
          debounceTimer?.cancel();
          debounceTimer = Timer(const Duration(milliseconds: 500), () async {
            try {
              isLoading.value = true;
              final newSuggestions = await searchService.getSearchSuggestions(
                query,
                bucketId: showGlobalSearch ? null : selectedBucketId,
              );
              suggestions.value = newSuggestions;
              showSuggestionsOverlay.value = newSuggestions.isNotEmpty && searchFocusNode.hasFocus;
            } catch (e) {
              suggestions.value = [];
              showSuggestionsOverlay.value = false;
            } finally {
              isLoading.value = false;
            }
          });
        } else {
          showSuggestionsOverlay.value = false;
          suggestions.value = [];
        }
      }
      
      searchController.addListener(onSearchChanged);
      return () {
        searchController.removeListener(onSearchChanged);
        debounceTimer?.cancel();
      };
    }, [searchController, showSuggestions, selectedBucketId, showGlobalSearch]);
    
    // Handle focus changes
    useEffect(() {
      void onFocusChanged() {
        if (searchFocusNode.hasFocus) {
          onSearchFocus?.call();
          if (suggestions.value.isNotEmpty && searchController.text.length >= 2) {
            showSuggestionsOverlay.value = true;
          }
        } else {
          onSearchBlur?.call();
          // Delay hiding suggestions to allow for selection
          Timer(const Duration(milliseconds: 200), () {
            showSuggestionsOverlay.value = false;
          });
        }
      }
      
      searchFocusNode.addListener(onFocusChanged);
      return () => searchFocusNode.removeListener(onFocusChanged);
    }, [searchFocusNode]);
    
    // Handle search results
    useEffect(() {
      searchResults.when(
        data: (results) {
          if (showGlobalSearch) {
            // For global search, flatten the results
            final flatResults = <StorageFile>[];
            if (results is Map<String, List<StorageFile>>) {
              for (final bucketFiles in results.values) {
                flatResults.addAll(bucketFiles);
              }
            }
            onSearchResults?.call(flatResults);
          } else {
            if (results is List<StorageFile>) {
              onSearchResults?.call(results);
            }
          }
        },
        loading: () {},
        error: (_, __) => onSearchResults?.call([]),
      );
      return null;
    }, [searchResults]);
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < StorageConstants.mobileBreakpoint;
    
    return Stack(
      children: [
        // Main search input
        TextField(
          controller: searchController,
          focusNode: searchFocusNode,
          decoration: InputDecoration(
            hintText: showGlobalSearch 
                ? 'Search across all buckets...' 
                : 'Search files and folders...',
            hintStyle: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
            prefixIcon: searchResults.isLoading || isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                      ),
                    ),
                  )
                : const Icon(
                    Icons.search,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Global search toggle
                if (!isMobile) ...[
                  Tooltip(
                    message: showGlobalSearch 
                        ? 'Search current bucket only' 
                        : 'Search all buckets',
                    child: IconButton(
                      onPressed: () {
                        // This would be handled by parent widget
                      },
                      icon: Icon(
                        showGlobalSearch ? Icons.folder : Icons.public,
                        color: showGlobalSearch 
                            ? AppColors.primaryBlue 
                            : AppColors.textMuted,
                        size: 18,
                      ),
                      splashRadius: 16,
                    ),
                  ),
                ],
                
                // Clear button
                if (searchController.text.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      searchController.clear();
                      searchMethods.clearSearchQuery();
                      showSuggestionsOverlay.value = false;
                    },
                    icon: const Icon(
                      Icons.clear,
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                    splashRadius: 16,
                  ),
              ],
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
            filled: true,
            fillColor: AppColors.backgroundLight,
          ),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          onSubmitted: (value) {
            showSuggestionsOverlay.value = false;
          },
        ),
        
        // Suggestions overlay
        if (showSuggestionsOverlay.value && suggestions.value.isNotEmpty)
          Positioned(
            top: 48,
            left: 0,
            right: 0,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: suggestions.value.length,
                  itemBuilder: (context, index) {
                    final suggestion = suggestions.value[index];
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        _getSuggestionIcon(suggestion),
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      title: RichText(
                        text: TextSpan(
                          children: searchService.highlightSearchTerms(
                            suggestion,
                            searchController.text,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      onTap: () {
                        searchController.text = suggestion;
                        searchMethods.updateSearchQuery(suggestion);
                        showSuggestionsOverlay.value = false;
                        searchFocusNode.unfocus();
                      },
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  IconData _getSuggestionIcon(String suggestion) {
    if (suggestion.startsWith('.')) {
      return Icons.extension;
    } else if (suggestion.contains('/')) {
      return Icons.category;
    } else {
      return Icons.insert_drive_file;
    }
  }
}

/// Search results display widget
class SearchResultsWidget extends HookConsumerWidget {
  final bool showGlobalResults;
  final Function(StorageFile)? onFileSelected;
  final Function(StorageFile)? onFileAction;

  const SearchResultsWidget({
    super.key,
    this.showGlobalResults = false,
    this.onFileSelected,
    this.onFileAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);
    final searchFilters = ref.watch(searchFiltersProvider);
    final searchMethods = ref.read(searchMethodsProvider);
    
    if (!searchMethods.isSearchActive()) {
      return const SizedBox.shrink();
    }
    
    if (showGlobalResults) {
      return _buildGlobalResults(context, ref);
    } else {
      return _buildBucketResults(context, ref);
    }
  }
  
  Widget _buildGlobalResults(BuildContext context, WidgetRef ref) {
    final globalResults = ref.watch(globalSearchResultsProvider);
    final searchService = ref.read(storageSearchServiceProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    
    return globalResults.when(
      data: (results) {
        if (results.isEmpty) {
          return _buildEmptyState(context, 'No files found across all buckets');
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Results summary
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Found results in ${results.keys.length} bucket(s)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            
            // Results by bucket
            Expanded(
              child: ListView.builder(
                itemCount: results.keys.length,
                itemBuilder: (context, index) {
                  final bucketId = results.keys.elementAt(index);
                  final bucketFiles = results[bucketId]!;
                  
                  return ExpansionTile(
                    title: Text(
                      '$bucketId (${bucketFiles.length} files)',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    leading: const Icon(
                      Icons.folder,
                      color: AppColors.primaryBlue,
                    ),
                    children: bucketFiles.map((file) {
                      return _buildFileListTile(
                        context,
                        file,
                        searchQuery,
                        searchService,
                        showBucket: false,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, _) => _buildErrorState(context, error.toString()),
    );
  }
  
  Widget _buildBucketResults(BuildContext context, WidgetRef ref) {
    final bucketResults = ref.watch(currentBucketSearchResultsProvider);
    final searchService = ref.read(storageSearchServiceProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    
    return bucketResults.when(
      data: (results) {
        if (results.isEmpty) {
          return _buildEmptyState(context, 'No files found in current bucket');
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Results summary
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Found ${results.length} file(s)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            
            // Results list
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final file = results[index];
                  return _buildFileListTile(
                    context,
                    file,
                    searchQuery,
                    searchService,
                    showBucket: false,
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, _) => _buildErrorState(context, error.toString()),
    );
  }
  
  Widget _buildFileListTile(
    BuildContext context,
    StorageFile file,
    String searchQuery,
    StorageSearchService searchService,
    {bool showBucket = true}
  ) {
    return ListTile(
      leading: Icon(
        _getFileIcon(file),
        color: _getFileIconColor(file),
      ),
      title: RichText(
        text: TextSpan(
          children: searchService.highlightSearchTerms(file.name, searchQuery),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showBucket)
            Text(
              'Bucket: ${file.bucketId}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          Text(
            '${file.formattedSize} • ${_formatDate(file.createdAt)}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
      trailing: IconButton(
        onPressed: () => onFileAction?.call(file),
        icon: const Icon(
          Icons.more_vert,
          color: AppColors.textMuted,
        ),
        splashRadius: 16,
      ),
      onTap: () => onFileSelected?.call(file),
    );
  }
  
  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.errorRed,
          ),
          const SizedBox(height: 16),
          Text(
            'Search failed: $error',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.errorRed,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  IconData _getFileIcon(StorageFile file) {
    switch (file.fileType) {
      case StorageFileType.folder:
        return Icons.folder;
      case StorageFileType.image:
        return Icons.image;
      case StorageFileType.video:
        return Icons.video_file;
      case StorageFileType.document:
        return Icons.description;
      case StorageFileType.other:
        return Icons.insert_drive_file;
    }
  }
  
  Color _getFileIconColor(StorageFile file) {
    switch (file.fileType) {
      case StorageFileType.folder:
        return AppColors.primaryBlue;
      case StorageFileType.image:
        return Colors.green;
      case StorageFileType.video:
        return Colors.purple;
      case StorageFileType.document:
        return Colors.orange;
      case StorageFileType.other:
        return AppColors.textMuted;
    }
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}