import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../models/storage_models.dart';
import '../providers/file_operation_providers.dart';
import '../providers/storage_providers.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/utils/logger.dart';

/// Dialog for moving files between folders with folder navigation
class FileMoveDialog extends HookConsumerWidget {
  final List<StorageFile> files;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const FileMoveDialog({
    super.key,
    required this.files,
    this.onSuccess,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMoving = useState<bool>(false);
    final selectedPath = useState<String>('');
    final currentBucketId = ref.watch(selectedBucketProvider);
    final fileOperations = ref.read(fileOperationMethodsProvider);
    // final bucketMethods = ref.read(bucketMethodsProvider); // TODO: Use for navigation if needed
    
    final isMultipleFiles = files.length > 1;

    // Get available folders for the current bucket
    final foldersAsync = ref.watch(currentBucketFilesProvider);

    // Handle move
    Future<void> handleMove() async {
      if (isMoving.value || currentBucketId == null) return;
      
      try {
        isMoving.value = true;
        Logger.info('Moving ${files.length} files to: ${selectedPath.value}');
        
        final results = <StorageOperationResult>[];
        
        for (final file in files) {
          final newPath = selectedPath.value.isEmpty 
            ? file.name
            : '${selectedPath.value}/${file.name}';
          
          final result = await fileOperations.moveFile(file, newPath);
          results.add(result);
        }
        
        final successCount = results.where((r) => r.success).length;
        
        if (context.mounted) {
          Navigator.of(context).pop();
          
          if (successCount == files.length) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isMultipleFiles 
                    ? 'Successfully moved $successCount files'
                    : 'File "${files.first.name}" moved successfully',
                ),
                backgroundColor: AppColors.success,
              ),
            );
            onSuccess?.call();
          } else {
            final failedCount = files.length - successCount;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Moved $successCount files, $failedCount failed',
                ),
                backgroundColor: AppColors.warning,
              ),
            );
          }
        }
      } catch (e) {
        Logger.error('Failed to move files', e);
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to move files: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        isMoving.value = false;
      }
    }

    return AlertDialog(
      title: Row(
        children: [
          const Icon(
            Icons.drive_file_move,
            color: AppColors.primaryBlue,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Move ${isMultipleFiles ? 'Files' : 'File'}',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      
      content: SizedBox(
        width: 500,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Files to move
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMultipleFiles 
                      ? 'Moving ${files.length} files:'
                      : 'Moving file:',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isMultipleFiles) ...[
                    Text(
                      files.map((f) => f.name).join(', '),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Icon(
                          files.first.isFolder ? Icons.folder : _getFileIcon(files.first),
                          size: 16,
                          color: files.first.isFolder 
                            ? AppColors.warning 
                            : _getFileIconColor(files.first),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            files.first.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Destination selection
            const Text(
              'Select destination folder:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Current path display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.primaryBlue, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.primaryBlue,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedPath.value.isEmpty 
                        ? 'Root folder'
                        : selectedPath.value,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Folder list
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderLight),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: foldersAsync.when(
                  data: (allFiles) {
                    final folders = allFiles
                        .where((file) => file.isFolder)
                        .where((folder) => !files.any((f) => f.id == folder.id)) // Exclude files being moved
                        .toList();
                    
                    return Column(
                      children: [
                        // Root folder option
                        ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.home,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                          title: const Text(
                            'Root folder',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          selected: selectedPath.value.isEmpty,
                          onTap: () => selectedPath.value = '',
                        ),
                        
                        if (folders.isNotEmpty) ...[
                          const Divider(height: 1),
                          
                          Expanded(
                            child: ListView.builder(
                              itemCount: folders.length,
                              itemBuilder: (context, index) {
                                final folder = folders[index];
                                final isSelected = selectedPath.value == folder.path;
                                
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(
                                    Icons.folder,
                                    color: AppColors.warning,
                                    size: 20,
                                  ),
                                  title: Text(folder.name),
                                  subtitle: folder.path.isNotEmpty 
                                    ? Text(
                                        folder.path,
                                        style: const TextStyle(fontSize: 11),
                                      )
                                    : null,
                                  selected: isSelected,
                                  onTap: () => selectedPath.value = folder.path,
                                );
                              },
                            ),
                          ),
                        ] else ...[
                          const Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.folder_open,
                                    color: AppColors.textMuted,
                                    size: 48,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'No folders available',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load folders',
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      
      actions: [
        // Cancel button
        TextButton(
          onPressed: isMoving.value ? null : () {
            Navigator.of(context).pop();
            onCancel?.call();
          },
          child: const Text('Cancel'),
        ),
        
        // Move button
        ElevatedButton(
          onPressed: isMoving.value ? null : handleMove,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
          ),
          child: isMoving.value
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Move'),
        ),
      ],
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