import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../models/storage_models.dart';
import '../providers/file_operation_providers.dart';
import '../constants/storage_constants.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/utils/logger.dart';

/// Dialog for confirming file deletion with options for soft/permanent delete
class FileDeletionDialog extends HookConsumerWidget {
  final List<StorageFile> files;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool allowPermanentDelete;
  final bool showUndoOption;

  const FileDeletionDialog({
    super.key,
    required this.files,
    this.onConfirm,
    this.onCancel,
    this.allowPermanentDelete = false,
    this.showUndoOption = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPermanentDelete = useState<bool>(false);
    final isDeleting = useState<bool>(false);
    final fileOperations = ref.read(fileOperationMethodsProvider);
    
    final isMultipleFiles = files.length > 1;
    final hasImportantFiles = files.any((file) => 
      file.name.toLowerCase().contains('important') ||
      file.name.toLowerCase().contains('backup') ||
      file.size > StorageConstants.maxGeneralFileSize
    );

    // Handle deletion
    Future<void> handleDelete() async {
      if (isDeleting.value) return;
      
      try {
        isDeleting.value = true;
        Logger.info('Starting deletion of ${files.length} files');
        
        final results = await fileOperations.deleteFiles(files);
        final successCount = results.where((r) => r.success).length;
        
        if (context.mounted) {
          Navigator.of(context).pop();
          
          if (successCount == files.length) {
            // All files deleted successfully
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isMultipleFiles 
                    ? 'Successfully deleted $successCount files'
                    : 'File "${files.first.name}" deleted successfully',
                ),
                backgroundColor: AppColors.success,
                action: showUndoOption && !isPermanentDelete.value
                  ? SnackBarAction(
                      label: 'Undo',
                      textColor: Colors.white,
                      onPressed: () => _handleUndo(context, ref),
                    )
                  : null,
              ),
            );
          } else {
            // Some files failed to delete
            final failedCount = files.length - successCount;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Deleted $successCount files, $failedCount failed',
                ),
                backgroundColor: AppColors.warning,
              ),
            );
          }
          
          onConfirm?.call();
        }
      } catch (e) {
        Logger.error('Failed to delete files', e);
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete files: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        isDeleting.value = false;
      }
    }

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            isPermanentDelete.value ? Icons.delete_forever : Icons.delete_outline,
            color: isPermanentDelete.value ? AppColors.error : AppColors.warning,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isPermanentDelete.value 
                ? 'Permanently Delete ${isMultipleFiles ? 'Files' : 'File'}'
                : 'Delete ${isMultipleFiles ? 'Files' : 'File'}',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isPermanentDelete.value ? AppColors.error : AppColors.warning)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isPermanentDelete.value ? AppColors.error : AppColors.warning,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isPermanentDelete.value ? Icons.warning : Icons.info_outline,
                    color: isPermanentDelete.value ? AppColors.error : AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isPermanentDelete.value
                        ? 'This action cannot be undone. Files will be permanently deleted.'
                        : isMultipleFiles
                          ? 'Are you sure you want to delete these ${files.length} files?'
                          : 'Are you sure you want to delete "${files.first.name}"?',
                      style: TextStyle(
                        color: isPermanentDelete.value ? AppColors.error : AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // File list (for multiple files)
            if (isMultipleFiles) ...[
              const Text(
                'Files to be deleted:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderLight),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        file.isFolder ? Icons.folder : _getFileIcon(file),
                        size: 16,
                        color: file.isFolder ? AppColors.warning : _getFileIconColor(file),
                      ),
                      title: Text(
                        file.name,
                        style: const TextStyle(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: file.isFolder ? null : Text(
                        file.formattedSize,
                        style: const TextStyle(fontSize: 11),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Important files warning
            if (hasImportantFiles) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.priority_high,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Some files appear to be important or large. Please review carefully.',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Deletion options
            if (allowPermanentDelete) ...[
              CheckboxListTile(
                value: isPermanentDelete.value,
                onChanged: (value) => isPermanentDelete.value = value ?? false,
                title: const Text(
                  'Permanently delete (cannot be undone)',
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: const Text(
                  'Files will be immediately removed from storage',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),
            ],
          ],
        ),
      ),
      
      actions: [
        // Cancel button
        TextButton(
          onPressed: isDeleting.value ? null : () {
            Navigator.of(context).pop();
            onCancel?.call();
          },
          child: const Text('Cancel'),
        ),
        
        // Delete button
        ElevatedButton(
          onPressed: isDeleting.value ? null : handleDelete,
          style: ElevatedButton.styleFrom(
            backgroundColor: isPermanentDelete.value ? AppColors.error : AppColors.warning,
            foregroundColor: Colors.white,
          ),
          child: isDeleting.value
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                isPermanentDelete.value 
                  ? 'Delete Permanently'
                  : 'Delete',
              ),
        ),
      ],
    );
  }

  void _handleUndo(BuildContext context, WidgetRef ref) {
    // TODO: Implement undo functionality
    // This would require implementing a soft delete mechanism
    // where files are marked as deleted but not actually removed
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Undo functionality will be implemented in a future update'),
        backgroundColor: AppColors.info,
      ),
    );
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