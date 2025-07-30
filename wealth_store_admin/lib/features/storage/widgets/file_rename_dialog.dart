import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../models/storage_models.dart';
import '../providers/file_operation_providers.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/utils/logger.dart';

/// Dialog for renaming files with validation and conflict resolution
class FileRenameDialog extends HookConsumerWidget {
  final StorageFile file;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const FileRenameDialog({
    super.key,
    required this.file,
    this.onSuccess,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController(text: _getFileNameWithoutExtension(file.name));
    final isRenaming = useState<bool>(false);
    final validationError = useState<String?>(null);
    final fileOperations = ref.read(fileOperationMethodsProvider);
    
    final fileExtension = _getFileExtension(file.name);
    final hasExtension = fileExtension.isNotEmpty;

    // Validate name on change
    useEffect(() {
      void validateName() {
        final newName = hasExtension 
          ? '${nameController.text}.$fileExtension'
          : nameController.text;
        
        final error = _validateFileName(newName, file);
        validationError.value = error;
      }
      
      nameController.addListener(validateName);
      return () => nameController.removeListener(validateName);
    }, [nameController]);

    // Handle rename
    Future<void> handleRename() async {
      if (isRenaming.value || validationError.value != null) return;
      
      final newName = hasExtension 
        ? '${nameController.text}.$fileExtension'
        : nameController.text;
      
      if (newName == file.name) {
        Navigator.of(context).pop();
        return;
      }
      
      try {
        isRenaming.value = true;
        Logger.info('Renaming file: ${file.name} to: $newName');
        
        final result = await fileOperations.renameFile(file, newName);
        
        if (context.mounted) {
          Navigator.of(context).pop();
          
          if (result.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File renamed to "$newName"'),
                backgroundColor: AppColors.success,
              ),
            );
            onSuccess?.call();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to rename file: ${result.error}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } catch (e) {
        Logger.error('Failed to rename file', e);
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to rename file: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        isRenaming.value = false;
      }
    }

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            file.isFolder ? Icons.folder : Icons.edit,
            color: file.isFolder ? AppColors.warning : AppColors.primaryBlue,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Rename ${file.isFolder ? 'Folder' : 'File'}',
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
            // Current name display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Icon(
                    file.isFolder ? Icons.folder : _getFileIcon(file),
                    size: 20,
                    color: file.isFolder ? AppColors.warning : _getFileIconColor(file),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current name:',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          file.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // New name input
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'New name:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Enter new name',
                          border: const OutlineInputBorder(),
                          errorText: validationError.value,
                          suffixText: hasExtension ? '.$fileExtension' : null,
                          suffixStyle: const TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onSubmitted: (_) => handleRename(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // File info
            if (!file.isFolder) ...[
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
                    Expanded(
                      child: Text(
                        hasExtension 
                          ? 'File extension ".$fileExtension" will be preserved'
                          : 'This file has no extension',
                        style: const TextStyle(
                          color: AppColors.info,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
          onPressed: isRenaming.value || validationError.value != null 
            ? null 
            : handleRename,
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
            : const Text('Rename'),
        ),
      ],
    );
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

  String? _validateFileName(String newName, StorageFile file) {
    // Check if name is empty
    if (newName.trim().isEmpty) {
      return 'Name cannot be empty';
    }
    
    // Check if name is the same
    if (newName == file.name) {
      return null; // No error, but no change needed
    }
    
    // Check for invalid characters
    final invalidChars = ['/', '\\', ':', '*', '?', '"', '<', '>', '|'];
    for (final char in invalidChars) {
      if (newName.contains(char)) {
        return 'Name cannot contain: $char';
      }
    }
    
    // Check length
    if (newName.length > 255) {
      return 'Name is too long (max 255 characters)';
    }
    
    // Check for reserved names (Windows)
    final reservedNames = [
      'CON', 'PRN', 'AUX', 'NUL',
      'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9',
      'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9'
    ];
    
    final nameWithoutExt = _getFileNameWithoutExtension(newName).toUpperCase();
    if (reservedNames.contains(nameWithoutExt)) {
      return 'Name is reserved and cannot be used';
    }
    
    // Check if name starts or ends with space/dot
    if (newName.startsWith(' ') || newName.endsWith(' ') || 
        newName.startsWith('.') || newName.endsWith('.')) {
      return 'Name cannot start or end with space or dot';
    }
    
    return null;
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