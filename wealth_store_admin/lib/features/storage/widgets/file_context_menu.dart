import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/storage_models.dart';
import '../providers/file_operation_providers.dart';
import '../providers/storage_providers.dart';
import '../constants/storage_constants.dart';
import '../services/url_manager.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/utils/logger.dart';
import 'url_sharing_widget.dart';

/// Context menu for file operations
class FileContextMenu extends ConsumerWidget {
  final StorageFile file;
  final List<StorageFile> selectedFiles;
  final Offset position;
  final VoidCallback onClose;
  final Function(StorageFile)? onRename;
  final Function(StorageFile)? onMove;
  final Function(StorageFile)? onDetails;
  final Function(StorageFile)? onShare;
  final Function(List<StorageFile>)? onDelete;
  final Function(List<StorageFile>)? onBatchRename;
  final Function(List<StorageFile>)? onBatchMove;

  const FileContextMenu({
    super.key,
    required this.file,
    required this.selectedFiles,
    required this.position,
    required this.onClose,
    this.onRename,
    this.onMove,
    this.onDetails,
    this.onShare,
    this.onDelete,
    this.onBatchRename,
    this.onBatchMove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileOperations = ref.read(fileOperationMethodsProvider);
    final isMultipleSelection = selectedFiles.length > 1;
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < StorageConstants.mobileBreakpoint;

    // Calculate menu position to ensure it stays within screen bounds
    final menuPosition = _calculateMenuPosition(context, position, isMobile);

    return Stack(
      children: [
        // Invisible overlay to detect clicks outside
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        // Context menu
        Positioned(
          left: menuPosition.dx,
          top: menuPosition.dy,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            color: AppColors.cardBackground,
            child: Container(
              constraints: BoxConstraints(
                minWidth: isMobile ? 200 : 220,
                maxWidth: isMobile ? 250 : 280,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with file info
                  _buildMenuHeader(isMultipleSelection),
                  
                  const Divider(height: 1, color: AppColors.borderLight),
                  
                  // Menu items
                  ..._buildMenuItems(
                    context,
                    ref,
                    fileOperations,
                    isMultipleSelection,
                    isMobile,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuHeader(bool isMultipleSelection) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // File icon
          Icon(
            isMultipleSelection
                ? Icons.select_all
                : file.isFolder
                    ? Icons.folder
                    : _getFileIcon(file),
            size: 20,
            color: isMultipleSelection
                ? AppColors.primaryBlue
                : file.isFolder
                    ? AppColors.warning
                    : _getFileIconColor(file),
          ),
          
          const SizedBox(width: 8),
          
          // File name/count
          Expanded(
            child: Text(
              isMultipleSelection
                  ? '${selectedFiles.length} items selected'
                  : file.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems(
    BuildContext context,
    WidgetRef ref,
    FileOperationMethods fileOperations,
    bool isMultipleSelection,
    bool isMobile,
  ) {
    final items = <Widget>[];

    if (!isMultipleSelection) {
      // Single file operations
      
      // Open/View Details
      items.add(_buildMenuItem(
        icon: file.isFolder ? Icons.folder_open : Icons.info_outline,
        label: file.isFolder ? 'Open' : 'View Details',
        onTap: () {
          onClose();
          if (file.isFolder) {
            // Navigate into folder
            final bucketMethods = ref.read(bucketMethodsProvider);
            final selectedBucketId = ref.read(selectedBucketProvider);
            if (selectedBucketId != null) {
              bucketMethods.navigateToPath(selectedBucketId, file.path);
            }
          } else {
            onDetails?.call(file);
          }
        },
        shortcut: isMobile ? null : 'Enter',
      ));

      // Copy URL (for files only)
      if (!file.isFolder) {
        items.add(_buildMenuItem(
          icon: Icons.link,
          label: 'Copy URL',
          onTap: () async {
            onClose();
            try {
              final url = fileOperations.getPublicUrl(file);
              if (url.isNotEmpty) {
                await StorageUrlManager.copyUrlToClipboard(url);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(StorageConstants.successUrlCopied),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              }
            } catch (e) {
              Logger.error('Failed to copy URL', e);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to copy URL'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }
          },
          shortcut: isMobile ? null : 'Ctrl+C',
        ));
        
        // Share URL (for files only)
        items.add(_buildMenuItem(
          icon: Icons.share,
          label: 'Share',
          onTap: () {
            onClose();
            if (onShare != null) {
              onShare!(file);
            } else {
              // Show URL sharing dialog directly
              showDialog(
                context: context,
                builder: (context) => UrlSharingWidget(
                  file: file,
                  onClose: () => Navigator.of(context).pop(),
                ),
              );
            }
          },
          shortcut: isMobile ? null : 'Ctrl+S',
        ));
      }

      // Rename
      items.add(_buildMenuItem(
        icon: Icons.edit,
        label: 'Rename',
        onTap: () {
          onClose();
          onRename?.call(file);
        },
        shortcut: isMobile ? null : 'F2',
      ));

      // Move
      items.add(_buildMenuItem(
        icon: Icons.drive_file_move,
        label: 'Move',
        onTap: () {
          onClose();
          onMove?.call(file);
        },
        shortcut: isMobile ? null : 'Ctrl+X',
      ));

      items.add(const Divider(height: 1, color: AppColors.borderLight));
    }

    // Delete (available for both single and multiple selection)
    items.add(_buildMenuItem(
      icon: Icons.delete_outline,
      label: isMultipleSelection ? 'Delete Selected' : 'Delete',
      onTap: () {
        onClose();
        onDelete?.call(selectedFiles);
      },
      shortcut: isMobile ? null : 'Delete',
      isDestructive: true,
    ));

    if (isMultipleSelection) {
      items.add(const Divider(height: 1, color: AppColors.borderLight));
      
      // Batch Rename
      items.add(_buildMenuItem(
        icon: Icons.edit,
        label: 'Batch Rename',
        onTap: () {
          onClose();
          onBatchRename?.call(selectedFiles);
        },
      ));
      
      // Move Selected
      items.add(_buildMenuItem(
        icon: Icons.drive_file_move,
        label: 'Move Selected',
        onTap: () {
          onClose();
          onBatchMove?.call(selectedFiles);
        },
      ));
      
      items.add(const Divider(height: 1, color: AppColors.borderLight));
      
      // Clear Selection
      items.add(_buildMenuItem(
        icon: Icons.clear,
        label: 'Clear Selection',
        onTap: () {
          onClose();
          final selectionMethods = ref.read(fileSelectionMethodsProvider);
          selectionMethods.clearSelection();
        },
        shortcut: isMobile ? null : 'Esc',
      ));
    }

    return items;
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? shortcut,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isDestructive ? AppColors.error : AppColors.textSecondary,
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isDestructive ? AppColors.error : AppColors.textPrimary,
                ),
              ),
            ),
            
            if (shortcut != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppColors.borderLight,
                    width: 1,
                  ),
                ),
                child: Text(
                  shortcut,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Offset _calculateMenuPosition(BuildContext context, Offset tapPosition, bool isMobile) {
    final screenSize = MediaQuery.of(context).size;
    final menuWidth = isMobile ? 250.0 : 280.0;
    const menuHeight = 300.0; // Approximate max height
    
    double x = tapPosition.dx;
    double y = tapPosition.dy;
    
    // Adjust horizontal position
    if (x + menuWidth > screenSize.width) {
      x = screenSize.width - menuWidth - 16;
    }
    if (x < 16) {
      x = 16;
    }
    
    // Adjust vertical position
    if (y + menuHeight > screenSize.height) {
      y = screenSize.height - menuHeight - 16;
    }
    if (y < 16) {
      y = 16;
    }
    
    return Offset(x, y);
  }

  IconData _getFileIcon(StorageFile file) {
    switch (file.fileType) {
      case StorageFileType.image:
        return Icons.image;
      case StorageFileType.video:
        return Icons.video_file;
      case StorageFileType.document:
        return Icons.description;
      case StorageFileType.folder:
        return Icons.folder;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileIconColor(StorageFile file) {
    switch (file.fileType) {
      case StorageFileType.image:
        return AppColors.success;
      case StorageFileType.video:
        return AppColors.info;
      case StorageFileType.document:
        return AppColors.error;
      case StorageFileType.folder:
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }
}