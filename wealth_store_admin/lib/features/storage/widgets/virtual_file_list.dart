import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../models/storage_models.dart';
import '../constants/storage_constants.dart';
import '../../../shared/constants/app_colors.dart';
import 'mobile_gesture_handler.dart';

/// Virtual scrolling widget for efficient rendering of large file lists
class VirtualFileList extends HookConsumerWidget {
  final List<StorageFile> files;
  final ViewMode viewMode;
  final Set<String> selectedFileIds;
  final Function(StorageFile, {bool isCtrlPressed}) onFileSelection;
  final Function(StorageFile) onFileDoubleClick;
  final Function(StorageFile, Offset) onContextMenu;
  final Function(StorageFile, SwipeDirection)? onSwipeGesture;
  final bool isMobile;
  final bool isTablet;
  final double itemHeight;
  final int? crossAxisCount;

  const VirtualFileList({
    super.key,
    required this.files,
    required this.viewMode,
    required this.selectedFileIds,
    required this.onFileSelection,
    required this.onFileDoubleClick,
    required this.onContextMenu,
    this.onSwipeGesture,
    required this.isMobile,
    required this.isTablet,
    required this.itemHeight,
    this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final viewportHeight = useState<double>(0);
    final scrollOffset = useState<double>(0);

    // Listen to scroll changes
    useEffect(() {
      void onScroll() {
        scrollOffset.value = scrollController.offset;
      }
      
      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    return LayoutBuilder(
      builder: (context, constraints) {
        viewportHeight.value = constraints.maxHeight;
        
        if (viewMode == ViewMode.grid) {
          return _buildVirtualGridView(
            context,
            constraints,
            scrollController,
            scrollOffset.value,
            viewportHeight.value,
          );
        } else {
          return _buildVirtualListView(
            context,
            constraints,
            scrollController,
            scrollOffset.value,
            viewportHeight.value,
          );
        }
      },
    );
  }

  Widget _buildVirtualGridView(
    BuildContext context,
    BoxConstraints constraints,
    ScrollController scrollController,
    double scrollOffset,
    double viewportHeight,
  ) {
    final crossAxisCount = this.crossAxisCount ?? _getGridCrossAxisCount(context);
    final itemsPerRow = crossAxisCount;
    final totalRows = (files.length / itemsPerRow).ceil();
    final totalHeight = totalRows * itemHeight;
    
    // Calculate visible range
    final startRow = (scrollOffset / itemHeight).floor().clamp(0, totalRows - 1);
    final endRow = ((scrollOffset + viewportHeight) / itemHeight).ceil().clamp(0, totalRows);
    
    // Add buffer for smooth scrolling
    final bufferRows = 2;
    final visibleStartRow = (startRow - bufferRows).clamp(0, totalRows);
    final visibleEndRow = (endRow + bufferRows).clamp(0, totalRows);
    
    final visibleItems = <Widget>[];
    
    for (int row = visibleStartRow; row < visibleEndRow; row++) {
      final startIndex = row * itemsPerRow;
      final endIndex = (startIndex + itemsPerRow).clamp(0, files.length);
      
      if (startIndex < files.length) {
        final rowItems = <Widget>[];
        
        for (int i = startIndex; i < endIndex; i++) {
          final file = files[i];
          final isSelected = selectedFileIds.contains(file.id);
          
          rowItems.add(
            _buildGridItem(context, file, isSelected),
          );
        }
        
        // Fill remaining slots with empty containers
        while (rowItems.length < itemsPerRow) {
          rowItems.add(const SizedBox.shrink());
        }
        
        visibleItems.add(
          Positioned(
            top: row * itemHeight,
            left: 0,
            right: 0,
            height: itemHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: rowItems.map((item) => Expanded(child: item)).toList(),
              ),
            ),
          ),
        );
      }
    }

    return SingleChildScrollView(
      controller: scrollController,
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          children: visibleItems,
        ),
      ),
    );
  }

  Widget _buildVirtualListView(
    BuildContext context,
    BoxConstraints constraints,
    ScrollController scrollController,
    double scrollOffset,
    double viewportHeight,
  ) {
    final totalHeight = files.length * itemHeight;
    
    // Calculate visible range
    final startIndex = (scrollOffset / itemHeight).floor().clamp(0, files.length - 1);
    final endIndex = ((scrollOffset + viewportHeight) / itemHeight).ceil().clamp(0, files.length);
    
    // Add buffer for smooth scrolling
    final bufferSize = 5;
    final visibleStartIndex = (startIndex - bufferSize).clamp(0, files.length);
    final visibleEndIndex = (endIndex + bufferSize).clamp(0, files.length);
    
    final visibleItems = <Widget>[];
    
    for (int i = visibleStartIndex; i < visibleEndIndex; i++) {
      final file = files[i];
      final isSelected = selectedFileIds.contains(file.id);
      
      visibleItems.add(
        Positioned(
          top: i * itemHeight,
          left: 0,
          right: 0,
          height: itemHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildListItem(context, file, isSelected),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      controller: scrollController,
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          children: visibleItems,
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, StorageFile file, bool isSelected) {
    Widget gridItemContent = Container(
      margin: const EdgeInsets.all(6),
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

    if (isMobile && onSwipeGesture != null) {
      return MobileGestureHandler(
        file: file,
        onTap: (file) => onFileSelection(file),
        onDoubleTap: onFileDoubleClick,
        onLongPress: onContextMenu,
        onSwipe: onSwipeGesture!,
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

  Widget _buildListItem(BuildContext context, StorageFile file, bool isSelected) {
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
            const Icon(
              Icons.more_vert,
              size: 16,
              color: AppColors.textMuted,
            ),
        ],
      ),
    );

    if (isMobile && onSwipeGesture != null) {
      return MobileGestureHandler(
        file: file,
        onTap: (file) => onFileSelection(file),
        onDoubleTap: onFileDoubleClick,
        onLongPress: onContextMenu,
        onSwipe: onSwipeGesture!,
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

  int _getGridCrossAxisCount(BuildContext context) {
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
}