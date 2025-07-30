import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../models/storage_models.dart';
import '../providers/storage_providers.dart';
import '../providers/file_operation_providers.dart';
import '../providers/search_providers.dart';
import '../constants/storage_constants.dart';
import '../../../shared/constants/app_colors.dart';
import 'file_details_modal.dart';
import 'storage_search_widget.dart';
import 'mobile_gesture_handler.dart';
import 'mobile_upload_interface.dart';
import 'virtual_file_list.dart';
import '../services/lazy_thumbnail_loader.dart';
import '../services/storage_pagination_service.dart';

/// Storage content widget for displaying files and folders
class StorageContent extends HookConsumerWidget {
  final ViewMode viewMode;
  final Function(StorageFile)? onFileSelected;
  final Function(StorageFile)? onFileDoubleClick;
  final Function(List<StorageFile>)? onSelectionChanged;
  final Function(StorageFile, Offset)? onFileContextMenu;
  final bool allowMultiSelect;
  final List<StorageFile>? selectedFiles;

  const StorageContent({
    super.key,
    this.viewMode = ViewMode.grid,
    this.onFileSelected,
    this.onFileDoubleClick,
    this.onSelectionChanged,
    this.onFileContextMenu,
    this.allowMultiSelect = true,
    this.selectedFiles,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilesState = useState<Set<String>>(
      selectedFiles?.map((f) => f.id).toSet() ?? <String>{},
    );
    
    // Mobile context menu state
    final mobileContextMenuFile = useState<StorageFile?>(null);
    final mobileContextMenuPosition = useState<Offset>(Offset.zero);
    
    // Performance optimization flags
    final useVirtualScrolling = useState<bool>(true);
    final usePagination = useState<bool>(true);
    
    // Watch providers
    final searchMethods = ref.read(searchMethodsProvider);
    final isSearchActive = searchMethods.isSearchActive();
    
    // Use search results if search is active, otherwise use regular bucket files
    final filesAsync = isSearchActive 
        ? ref.watch(currentBucketSearchResultsProvider)
        : ref.watch(currentBucketFilesProvider);
    
    final selectedBucketId = ref.watch(selectedBucketProvider);
    final bucketMethods = ref.read(bucketMethodsProvider);
    
    final isLoading = isSearchActive
        ? ref.watch(currentBucketSearchLoadingProvider)
        : ref.watch(bucketFilesLoadingProvider);
    
    final error = isSearchActive
        ? ref.watch(searchErrorProvider)
        : ref.watch(bucketFilesErrorProvider);

    // Handle responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < StorageConstants.mobileBreakpoint;
    final isTablet = screenWidth < StorageConstants.tabletBreakpoint;
    
    // Lazy thumbnail loader
    final thumbnailLoader = useMemoized(() => LazyThumbnailLoader(), []);

    // Update selected files when external selection changes
    useEffect(() {
      if (selectedFiles != null) {
        selectedFilesState.value = selectedFiles!.map((f) => f.id).toSet();
      }
    }, [selectedFiles]);

    // Handle file selection
    void handleFileSelection(StorageFile file, {bool isCtrlPressed = false}) {
      if (!allowMultiSelect) {
        selectedFilesState.value = {file.id};
        onFileSelected?.call(file);
        onSelectionChanged?.call([file]);
        return;
      }

      final newSelection = Set<String>.from(selectedFilesState.value);
      
      if (isCtrlPressed) {
        if (newSelection.contains(file.id)) {
          newSelection.remove(file.id);
        } else {
          newSelection.add(file.id);
        }
      } else {
        newSelection.clear();
        newSelection.add(file.id);
      }
      
      selectedFilesState.value = newSelection;
      onFileSelected?.call(file);
      
      // Notify parent of selection change
      filesAsync.whenData((files) {
        final selectedFilesList = files
            .where((f) => newSelection.contains(f.id))
            .toList();
        onSelectionChanged?.call(selectedFilesList);
      });
    }

    // Handle file double click
    void handleFileDoubleClick(StorageFile file) {
      if (file.isFolder && selectedBucketId != null) {
        // Navigate into folder
        final newPath = file.path;
        bucketMethods.navigateToPath(selectedBucketId!, newPath);
      } else {
        // Open file details modal
        _showFileDetailsModal(context, file);
        onFileDoubleClick?.call(file);
      }
    }

    // Handle context menu
    void handleContextMenu(StorageFile file, Offset position) {
      if (!selectedFilesState.value.contains(file.id)) {
        handleFileSelection(file);
      }
      
      if (isMobile) {
        // Show mobile context menu
        mobileContextMenuFile.value = file;
        mobileContextMenuPosition.value = position;
      } else {
        onFileContextMenu?.call(file, position);
      }
    }

    // Handle mobile swipe gestures
    void handleSwipeGesture(StorageFile file, SwipeDirection direction) {
      switch (direction) {
        case SwipeDirection.left:
          // Quick delete action
          _showQuickDeleteConfirmation(context, file);
          break;
        case SwipeDirection.right:
          // Quick share/details action
          _showFileDetailsModal(context, file);
          break;
        case SwipeDirection.up:
          // Quick move action
          // TODO: Implement quick move
          break;
        case SwipeDirection.down:
          // Quick rename action
          // TODO: Implement quick rename
          break;
      }
    }

    return Container(
      color: AppColors.backgroundLight,
      child: Stack(
        children: [
          Column(
            children: [
              // Show search results widget if search is active
              if (isSearchActive)
                Expanded(
                  child: SearchResultsWidget(
                    showGlobalResults: false,
                    onFileSelected: onFileSelected,
                    onFileAction: (file) => handleContextMenu(file, Offset.zero),
                  ),
                )
              else
                Expanded(
                  child: filesAsync.when(
                    data: (files) => _buildContent(
                      context,
                      ref,
                      files,
                      selectedFilesState.value,
                      handleFileSelection,
                      handleFileDoubleClick,
                      handleContextMenu,
                      handleSwipeGesture,
                      isMobile,
                      isTablet,
                      thumbnailLoader,
                      useVirtualScrolling.value,
                    ),
                    loading: () => _buildLoadingState(context, isSearchActive),
                    error: (error, stackTrace) => _buildErrorState(
                      context,
                      error.toString(),
                      () {
                        if (isSearchActive) {
                          searchMethods.refreshSearchResults();
                        } else {
                          ref.invalidate(currentBucketFilesProvider);
                        }
                      },
                      isSearchActive,
                    ),
                  ),
                ),
            ],
          ),
          
          // Mobile context menu overlay
          if (mobileContextMenuFile.value != null && isMobile)
            MobileContextMenu(
              file: mobileContextMenuFile.value!,
              selectedFiles: filesAsync.when(
                data: (files) => files
                    .where((f) => selectedFilesState.value.contains(f.id))
                    .toList(),
                loading: () => [],
                error: (_, __) => [],
              ),
              position: mobileContextMenuPosition.value,
              onClose: () => mobileContextMenuFile.value = null,
              onDetails: (file) => _showFileDetailsModal(context, file),
              // TODO: Add other action handlers
            ),
        ],
      ),
    );
  }

  void _showFileDetailsModal(BuildContext context, StorageFile file) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => FileDetailsModal(
        file: file,
        onClose: () => Navigator.of(context).pop(),
        onFileUpdated: (updatedFile) {
          // Handle file updates if needed
          Navigator.of(context).pop();
        },
        onFileDeleted: (deletedFile) {
          // Handle file deletion if needed
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<StorageFile> files,
    Set<String> selectedFileIds,
    Function(StorageFile, {bool isCtrlPressed}) onFileSelection,
    Function(StorageFile) onFileDoubleClick,
    Function(StorageFile, Offset) onContextMenu,
    Function(StorageFile, SwipeDirection) onSwipeGesture,
    bool isMobile,
    bool isTablet,
    LazyThumbnailLoader thumbnailLoader,
    bool useVirtualScrolling,
  ) {
    if (files.isEmpty) {
      return _buildEmptyState(context);
    }

    // Preload thumbnails for visible files
    final visibleFiles = files.take(20).toList();
    thumbnailLoader.preloadThumbnails(visibleFiles, ref.read(storageRepositoryProvider));

    // Use virtual scrolling for large file lists
    if (useVirtualScrolling && files.length > StorageConstants.virtualScrollingThreshold) {
      return _buildVirtualScrollView(
        context,
        files,
        selectedFileIds,
        onFileSelection,
        onFileDoubleClick,
        onContextMenu,
        onSwipeGesture,
        isMobile,
        isTablet,
        thumbnailLoader,
      );
    }

    return viewMode == ViewMode.grid
        ? _buildGridView(
            context,
            files,
            selectedFileIds,
            onFileSelection,
            onFileDoubleClick,
            onContextMenu,
            onSwipeGesture,
            isMobile,
            isTablet,
          )
        : _buildListView(
            context,
            files,
            selectedFileIds,
            onFileSelection,
            onFileDoubleClick,
            onContextMenu,
            onSwipeGesture,
            isMobile,
          );
  }

  Widget _buildGridView(
    BuildContext context,
    List<StorageFile> files,
    Set<String> selectedFileIds,
    Function(StorageFile, {bool isCtrlPressed}) onFileSelection,
    Function(StorageFile) onFileDoubleClick,
    Function(StorageFile, Offset) onContextMenu,
    Function(StorageFile, SwipeDirection) onSwipeGesture,
    bool isMobile,
    bool isTablet,
  ) {
    final crossAxisCount = _getGridCrossAxisCount(context, isMobile, isTablet);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];
          final isSelected = selectedFileIds.contains(file.id);
          
          return _buildGridItem(
            context,
            file,
            isSelected,
            onFileSelection,
            onFileDoubleClick,
            onContextMenu,
            onSwipeGesture,
            isMobile,
          );
        },
      ),
    );
  }

  Widget _buildVirtualScrollView(
    BuildContext context,
    List<StorageFile> files,
    Set<String> selectedFileIds,
    Function(StorageFile, {bool isCtrlPressed}) onFileSelection,
    Function(StorageFile) onFileDoubleClick,
    Function(StorageFile, Offset) onContextMenu,
    Function(StorageFile, SwipeDirection) onSwipeGesture,
    bool isMobile,
    bool isTablet,
    LazyThumbnailLoader thumbnailLoader,
  ) {
    final itemHeight = viewMode == ViewMode.grid 
        ? (isMobile ? 180.0 : 160.0)
        : (isMobile ? 80.0 : 60.0);
    
    final crossAxisCount = viewMode == ViewMode.grid 
        ? _getGridCrossAxisCount(context, isMobile, isTablet)
        : 1;

    return VirtualFileList(
      files: files,
      viewMode: viewMode,
      selectedFileIds: selectedFileIds,
      onFileSelection: onFileSelection,
      onFileDoubleClick: onFileDoubleClick,
      onContextMenu: onContextMenu,
      onSwipeGesture: onSwipeGesture,
      isMobile: isMobile,
      isTablet: isTablet,
      itemHeight: itemHeight,
      crossAxisCount: crossAxisCount,
    );
  }

  Widget _buildListView(
    BuildContext context,
    List<StorageFile> files,
    Set<String> selectedFileIds,
    Function(StorageFile, {bool isCtrlPressed}) onFileSelection,
    Function(StorageFile) onFileDoubleClick,
    Function(StorageFile, Offset) onContextMenu,
    Function(StorageFile, SwipeDirection) onSwipeGesture,
    bool isMobile,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        final isSelected = selectedFileIds.contains(file.id);
        
        return _buildListItem(
          context,
          file,
          isSelected,
          onFileSelection,
          onFileDoubleClick,
          onContextMenu,
          onSwipeGesture,
          isMobile,
        );
      },
    );
  }

  Widget _buildGridItem(
    BuildContext context,
    StorageFile file,
    bool isSelected,
    Function(StorageFile, {bool isCtrlPressed}) onFileSelection,
    Function(StorageFile) onFileDoubleClick,
    Function(StorageFile, Offset) onContextMenu,
    Function(StorageFile, SwipeDirection) onSwipeGesture,
    bool isMobile,
  ) {
    Widget gridItemContent = Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(isMobile ? 12 : 8),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isMobile ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          children: [
            // File icon/thumbnail
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 20 : 16),
                child: _buildFileIcon(file, size: isMobile ? 56 : 48),
              ),
            ),
            
            // File info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 8),
                child: Column(
                  children: [
                    // File name
                    Text(
                      file.name,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: isMobile ? 6 : 4),
                    
                    // File size/type
                    if (!file.isFolder)
                      Text(
                        file.formattedSize,
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

    if (isMobile) {
      return MobileGestureHandler(
        file: file,
        onTap: (file) => onFileSelection(file),
        onDoubleTap: onFileDoubleClick,
        onLongPress: onContextMenu,
        onSwipe: onSwipeGesture,
        child: gridItemContent,
      );
    } else {
      return GestureDetector(
        onTap: () => onFileSelection(file),
        onDoubleTap: () => onFileDoubleClick(file),
        onSecondaryTapDown: (details) => onContextMenu(file, details.globalPosition),
        onLongPress: () => onContextMenu(file, Offset.zero),
        child: gridItemContent,
      );
    }
  }

  Widget _buildListItem(
    BuildContext context,
    StorageFile file,
    bool isSelected,
    Function(StorageFile, {bool isCtrlPressed}) onFileSelection,
    Function(StorageFile) onFileDoubleClick,
    Function(StorageFile, Offset) onContextMenu,
    Function(StorageFile, SwipeDirection) onSwipeGesture,
    bool isMobile,
  ) {
    Widget listItemContent = Container(
        margin: EdgeInsets.only(bottom: isMobile ? 6 : 4),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 12,
          vertical: isMobile ? 12 : 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(isMobile ? 8 : 6),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isMobile ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ] : null,
        ),
        child: Row(
          children: [
            // File icon
            _buildFileIcon(file, size: isMobile ? 28 : 24),
            
            SizedBox(width: isMobile ? 16 : 12),
            
            // File name and info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isMobile && !file.isFolder) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${file.formattedSize} • ${_formatDate(file.updatedAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            if (!isMobile) ...[
              // File size
              SizedBox(
                width: 80,
                child: Text(
                  file.isFolder ? '' : file.formattedSize,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // File type
              SizedBox(
                width: 80,
                child: Text(
                  file.fileType.displayName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Modified date
              SizedBox(
                width: 100,
                child: Text(
                  _formatDate(file.updatedAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
            
            // Mobile context menu indicator
            if (isMobile)
              Icon(
                Icons.more_vert,
                size: 16,
                color: AppColors.textMuted,
              ),
          ],
        ),
      );

    if (isMobile) {
      return MobileGestureHandler(
        file: file,
        onTap: (file) => onFileSelection(file),
        onDoubleTap: onFileDoubleClick,
        onLongPress: onContextMenu,
        onSwipe: onSwipeGesture,
        child: listItemContent,
      );
    } else {
      return GestureDetector(
        onTap: () => onFileSelection(file),
        onDoubleTap: () => onFileDoubleClick(file),
        onSecondaryTapDown: (details) => onContextMenu(file, details.globalPosition),
        onLongPress: () => onContextMenu(file, Offset.zero),
        child: listItemContent,
      );
    }
  }

  Widget _buildFileIcon(StorageFile file, {double size = 24}) {
    if (file.isFolder) {
      return Icon(
        Icons.folder,
        size: size,
        color: AppColors.warning,
      );
    }

    // Get icon based on file type
    IconData iconData;
    Color iconColor;
    
    switch (file.fileType) {
      case StorageFileType.image:
        iconData = Icons.image;
        iconColor = AppColors.success;
        break;
      case StorageFileType.video:
        iconData = Icons.video_file;
        iconColor = AppColors.info;
        break;
      case StorageFileType.document:
        iconData = Icons.description;
        iconColor = AppColors.error;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = AppColors.textSecondary;
    }

    return Icon(
      iconData,
      size: size,
      color: iconColor,
    );
  }

  Widget _buildLoadingState(BuildContext context, [bool isSearchActive = false]) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primaryBlue,
            strokeWidth: 2,
          ),
          const SizedBox(height: 16),
          Text(
            isSearchActive ? 'Searching files...' : 'Loading files...',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error, VoidCallback onRetry, [bool isSearchActive = false]) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              isSearchActive ? 'Search failed' : 'Failed to load files',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              color: AppColors.textMuted,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'This folder is empty',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Upload files or create folders to get started.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  int _getGridCrossAxisCount(BuildContext context, bool isMobile, bool isTablet) {
    if (isMobile) {
      return StorageConstants.responsiveGridColumns['mobile']!;
    } else if (isTablet) {
      return StorageConstants.responsiveGridColumns['tablet']!;
    } else {
      final screenWidth = MediaQuery.of(context).size.width;
      if (screenWidth > StorageConstants.desktopBreakpoint) {
        return StorageConstants.responsiveGridColumns['large']!;
      }
      return StorageConstants.responsiveGridColumns['desktop']!;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showQuickDeleteConfirmation(BuildContext context, StorageFile file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "${file.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement delete functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}