import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../models/storage_models.dart';
import '../providers/file_operation_providers.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/utils/logger.dart';

/// Dialog for batch renaming multiple files with pattern support
class BatchRenameDialog extends HookConsumerWidget {
  final List<StorageFile> files;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const BatchRenameDialog({
    super.key,
    required this.files,
    this.onSuccess,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patternController = useTextEditingController();
    final isRenaming = useState<bool>(false);
    final renameMode = useState<RenameMode>(RenameMode.pattern);
    final startNumber = useState<int>(1);
    final previewNames = useState<List<String>>([]);
    final fileOperations = ref.read(fileOperationMethodsProvider);

    // Update preview when pattern or mode changes
    useEffect(() {
      void updatePreview() {
        final newNames = _generatePreviewNames(
          files, 
          patternController.text, 
          renameMode.value, 
          startNumber.value
        );
        previewNames.value = newNames;
      }
      
      patternController.addListener(updatePreview);
      updatePreview(); // Initial preview
      
      return () => patternController.removeListener(updatePreview);
    }, [patternController, renameMode.value, startNumber.value]);

    // Handle batch rename
    Future<void> handleBatchRename() async {
      if (isRenaming.value || previewNames.value.isEmpty) return;
      
      try {
        isRenaming.value = true;
        Logger.info('Starting batch rename of ${files.length} files');
        
        final results = <StorageOperationResult>[];
        
        for (int i = 0; i < files.length; i++) {
          final file = files[i];
          final newName = previewNames.value[i];
          
          if (newName != file.name) {
            final result = await fileOperations.renameFile(file, newName);
            results.add(result);
          }
        }
        
        final successCount = results.where((r) => r.success).length;
        
        if (context.mounted) {
          Navigator.of(context).pop();
          
          if (successCount == results.length) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Successfully renamed $successCount files'),
                backgroundColor: AppColors.success,
              ),
            );
            onSuccess?.call();
          } else {
            final failedCount = results.length - successCount;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Renamed $successCount files, $failedCount failed',
                ),
                backgroundColor: AppColors.warning,
              ),
            );
          }
        }
      } catch (e) {
        Logger.error('Failed to batch rename files', e);
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to rename files: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        isRenaming.value = false;
      }
    }

    return AlertDialog(
      title: const Row(
        children: [
          Icon(
            Icons.edit,
            color: AppColors.primaryBlue,
            size: 24,
          ),
          SizedBox(width: 8),
          Text(
            'Batch Rename Files',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
      
      content: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File count info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Renaming ${files.length} files',
                    style: const TextStyle(
                      color: AppColors.info,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Rename mode selection
            const Text(
              'Rename Mode:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: RadioListTile<RenameMode>(
                    dense: true,
                    title: const Text('Pattern', style: TextStyle(fontSize: 13)),
                    value: RenameMode.pattern,
                    groupValue: renameMode.value,
                    onChanged: (value) => renameMode.value = value!,
                  ),
                ),
                Expanded(
                  child: RadioListTile<RenameMode>(
                    dense: true,
                    title: const Text('Sequential', style: TextStyle(fontSize: 13)),
                    value: RenameMode.sequential,
                    groupValue: renameMode.value,
                    onChanged: (value) => renameMode.value = value!,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Pattern/prefix input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: patternController,
                    decoration: InputDecoration(
                      labelText: renameMode.value == RenameMode.pattern 
                        ? 'Pattern (use {n} for number, {name} for original)'
                        : 'Prefix',
                      hintText: renameMode.value == RenameMode.pattern 
                        ? 'file_{n}' 
                        : 'new_file_',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                
                if (renameMode.value == RenameMode.sequential) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Start #',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        startNumber.value = int.tryParse(value) ?? 1;
                      },
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Preview section
            const Text(
              'Preview:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderLight),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    final newName = index < previewNames.value.length 
                      ? previewNames.value[index] 
                      : file.name;
                    final isChanged = newName != file.name;
                    
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        file.isFolder ? Icons.folder : _getFileIcon(file),
                        size: 16,
                        color: file.isFolder 
                          ? AppColors.warning 
                          : _getFileIconColor(file),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: isChanged ? AppColors.textMuted : AppColors.textPrimary,
                              decoration: isChanged ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          if (isChanged) ...[
                            const SizedBox(height: 2),
                            Text(
                              newName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.success,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: isChanged 
                        ? const Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: AppColors.success,
                          )
                        : const Icon(
                            Icons.remove,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      
      actions: [
        // Cancel button
        TextButton(
          onPressed: isRenaming.value ? null : () {
            Navigator.of(context).pop();
            onCancel?.call();
          },
          child: const Text('Cancel'),
        ),
        
        // Rename button
        ElevatedButton(
          onPressed: isRenaming.value || previewNames.value.isEmpty
            ? null 
            : handleBatchRename,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
          ),
          child: isRenaming.value
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Rename All'),
        ),
      ],
    );
  }

  List<String> _generatePreviewNames(
    List<StorageFile> files, 
    String pattern, 
    RenameMode mode, 
    int startNumber
  ) {
    if (pattern.isEmpty) return files.map((f) => f.name).toList();
    
    final names = <String>[];
    
    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      String newName;
      
      switch (mode) {
        case RenameMode.pattern:
          newName = pattern
            .replaceAll('{n}', (i + startNumber).toString())
            .replaceAll('{name}', _getFileNameWithoutExtension(file.name));
          
          // Preserve extension for files
          if (!file.isFolder) {
            final extension = _getFileExtension(file.name);
            if (extension.isNotEmpty && !newName.endsWith('.$extension')) {
              newName = '$newName.$extension';
            }
          }
          break;
          
        case RenameMode.sequential:
          final extension = file.isFolder ? '' : _getFileExtension(file.name);
          newName = '$pattern${i + startNumber}';
          if (extension.isNotEmpty) {
            newName = '$newName.$extension';
          }
          break;
      }
      
      names.add(newName);
    }
    
    return names;
  }

  String _getFileNameWithoutExtension(String fileName) {
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex == -1 || lastDotIndex == 0) {
      return fileName;
    }
    return fileName.substring(0, lastDotIndex);
  }

  String _getFileExtension(String fileName) {
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex == -1 || lastDotIndex == 0) {
      return '';
    }
    return fileName.substring(lastDotIndex + 1);
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

enum RenameMode {
  pattern,
  sequential,
}