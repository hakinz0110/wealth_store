import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import '../models/storage_models.dart';
import '../providers/file_operation_providers.dart';
import '../providers/storage_providers.dart';
import '../services/file_validator.dart';
import '../constants/storage_constants.dart';
import '../utils/storage_utils.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/utils/logger.dart';
import 'mobile_upload_interface.dart';

/// Modal for uploading files with drag-and-drop support
class StorageUploadModal extends HookConsumerWidget {
  final String bucketId;
  final String? currentPath;
  final VoidCallback? onUploadComplete;
  final VoidCallback? onClose;

  const StorageUploadModal({
    super.key,
    required this.bucketId,
    this.currentPath,
    this.onUploadComplete,
    this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // State hooks
    final selectedFiles = useState<List<PlatformFile>>([]);
    final isDragOver = useState<bool>(false);
    final isUploading = useState<bool>(false);
    final uploadError = useState<String?>(null);
    final validationErrors = useState<Map<String, List<String>>>({});
    final showFolderOptions = useState<bool>(false);
    final targetFolder = useState<String?>(null);
    final createNewFolder = useState<bool>(false);
    final newFolderName = useState<String>('');
    
    // Controllers
    final dropzoneController = useState<DropzoneViewController?>(null);
    
    // Providers
    final fileOperations = ref.read(fileOperationMethodsProvider);
    final selectedBucket = ref.watch(selectedBucketDetailsProvider);
    final validator = StorageFileValidator.createWithBucketRules();
    final progressTracker = ref.read(uploadProgressTrackerProvider);
    
    // Screen size
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < StorageConstants.mobileBreakpoint;
    
    // Handle file selection from file picker
    Future<void> handleFilePicker() async {
      try {
        final result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.any,
          withData: true,
        );
        
        if (result != null && result.files.isNotEmpty) {
          selectedFiles.value = [...selectedFiles.value, ...result.files];
          _validateFiles(selectedFiles.value, validator, validationErrors);
        }
      } catch (e) {
        Logger.error('File picker error', e);
        uploadError.value = 'Failed to select files: ${e.toString()}';
      }
    }
    
    // Handle drag and drop files
    void handleDroppedFiles(List<dynamic> files) {
      try {
        final droppedFiles = <PlatformFile>[];
        
        for (final file in files) {
          if (file is File) {
            final bytes = file.readAsBytesSync();
            final platformFile = PlatformFile(
              name: file.path.split('/').last,
              size: bytes.length,
              bytes: bytes,
            );
            droppedFiles.add(platformFile);
          }
        }
        
        if (droppedFiles.isNotEmpty) {
          selectedFiles.value = [...selectedFiles.value, ...droppedFiles];
          _validateFiles(selectedFiles.value, validator, validationErrors);
        }
      } catch (e) {
        Logger.error('Drop files error', e);
        uploadError.value = 'Failed to process dropped files: ${e.toString()}';
      }
    }
    
    // Remove file from selection
    void removeFile(int index) {
      final newFiles = List<PlatformFile>.from(selectedFiles.value);
      newFiles.removeAt(index);
      selectedFiles.value = newFiles;
      _validateFiles(selectedFiles.value, validator, validationErrors);
    }
    
    // Clear all selected files
    void clearFiles() {
      selectedFiles.value = [];
      validationErrors.value = {};
      uploadError.value = null;
    }
    
    // Upload files
    Future<void> uploadFiles() async {
      if (selectedFiles.value.isEmpty) return;
      
      try {
        isUploading.value = true;
        uploadError.value = null;
        
        // Start tracking progress for all files
        for (final file in selectedFiles.value) {
          progressTracker.startTracking(file.name);
        }
        
        // Handle folder creation if needed
        String uploadPath = currentPath ?? '';
        if (createNewFolder.value && newFolderName.value.isNotEmpty) {
          // Create new folder first
          final folderResult = await fileOperations.createFolder(
            bucketId,
            newFolderName.value,
            parentPath: currentPath,
          );
          
          if (!folderResult.success) {
            uploadError.value = 'Failed to create folder: ${folderResult.error}';
            return;
          }
          
          uploadPath = currentPath != null && currentPath!.isNotEmpty
              ? '$currentPath/${newFolderName.value}'
              : newFolderName.value;
        } else if (targetFolder.value != null) {
          uploadPath = targetFolder.value!;
        }
        
        // Create upload tasks
        final tasks = selectedFiles.value.map((file) {
          final fileName = file.name;
          final fileBytes = file.bytes!;
          final mimeType = StorageUtils.getMimeType(fileName);
          final filePath = uploadPath.isNotEmpty
              ? '$uploadPath/$fileName'
              : fileName;
          
          return UploadTask(
            fileName: fileName,
            fileBytes: fileBytes,
            bucketId: bucketId,
            path: filePath,
            mimeType: mimeType,
          );
        }).toList();
        
        // Upload files with progress tracking
        final results = await _uploadFilesWithProgress(tasks, progressTracker, fileOperations);
        
        // Check results
        final failedUploads = results.where((r) => !r.success).toList();
        if (failedUploads.isNotEmpty) {
          final errorMessages = failedUploads
              .map((r) => r.error ?? 'Unknown error')
              .join('\n');
          uploadError.value = 'Some uploads failed:\n$errorMessages';
        } else {
          // All uploads successful
          onUploadComplete?.call();
          onClose?.call();
        }
      } catch (e) {
        Logger.error('Upload error', e);
        uploadError.value = 'Upload failed: ${e.toString()}';
        
        // Mark all uploads as failed
        for (final file in selectedFiles.value) {
          progressTracker.failUpload(file.name, e.toString());
        }
      } finally {
        isUploading.value = false;
      }
    }
    
    // Use mobile-optimized interface on mobile devices
    if (isMobile) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: MobileUploadInterface(
              bucketId: bucketId,
              currentPath: currentPath ?? '',
              onFilesSelected: (files) {
                // Handle mobile file selection
                // TODO: Convert file paths to PlatformFile objects
                print('Mobile files selected: $files');
              },
              onClose: onClose,
            ),
          ),
        ),
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        height: 500,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(context, onClose),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Bucket info
                    _buildBucketInfo(selectedBucket),
                    
                    const SizedBox(height: 16),
                    
                    // Drop zone or file list
                    Expanded(
                      child: selectedFiles.value.isEmpty
                          ? _buildDropZone(
                              context,
                              isDragOver.value,
                              handleFilePicker,
                              handleDroppedFiles,
                              dropzoneController,
                              isDragOver,
                            )
                          : _buildFileList(
                              context,
                              selectedFiles.value,
                              validationErrors.value,
                              removeFile,
                              clearFiles,
                              isMobile,
                            ),
                    ),
                    
                    // Folder organization options
                    if (selectedFiles.value.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildFolderOptions(
                        context,
                        showFolderOptions.value,
                        targetFolder.value,
                        createNewFolder.value,
                        newFolderName.value,
                        () => showFolderOptions.value = !showFolderOptions.value,
                        (folder) => targetFolder.value = folder,
                        (create) => createNewFolder.value = create,
                        (name) => newFolderName.value = name,
                        isMobile,
                      ),
                    ],
                    
                    // Error display
                    if (uploadError.value != null) ...[
                      const SizedBox(height: 16),
                      _buildErrorDisplay(uploadError.value!),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // Actions
                    _buildActions(
                      context,
                      selectedFiles.value,
                      validationErrors.value,
                      isUploading.value,
                      handleFilePicker,
                      clearFiles,
                      uploadFiles,
                      onClose,
                      isMobile,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context, VoidCallback? onClose) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.upload,
            color: AppColors.primaryBlue,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Text(
            'Upload Files',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onClose,
            icon: const Icon(
              Icons.close,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }
  
  Widget _buildBucketInfo(StorageBucket? bucket) {
    if (bucket == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(
            bucket.isPublic ? Icons.public : Icons.lock,
            size: 16,
            color: bucket.isPublic ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 8),
          Text(
            'Uploading to: ${bucket.name}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          if (currentPath != null && currentPath!.isNotEmpty) ...[
            const Text(
              ' / ',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
            Text(
              currentPath!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const Spacer(),
          if (bucket.fileSizeLimit != null)
            Text(
              'Max: ${bucket.formattedSizeLimit}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildDropZone(
    BuildContext context,
    bool isDragOver,
    VoidCallback onFilePicker,
    Function(List<dynamic>) onDroppedFiles,
    ValueNotifier<DropzoneViewController?> dropzoneController,
    ValueNotifier<bool> isDragOverNotifier,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: isDragOver ? AppColors.primaryBlue : AppColors.borderLight,
          width: isDragOver ? 2 : 1,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isDragOver 
            ? AppColors.primaryBlue.withValues(alpha: 0.05)
            : AppColors.backgroundLight,
      ),
      child: Stack(
        children: [
          // Web dropzone
          if (kIsWeb)
            DropzoneView(
              operation: DragOperation.copy,
              cursor: CursorType.pointer,
              onCreated: (controller) => dropzoneController.value = controller,
              onLoaded: () => Logger.debug('Dropzone loaded'),
              onError: (error) => Logger.error('Dropzone error: $error'),
              onHover: () => isDragOverNotifier.value = true,
              onLeave: () => isDragOverNotifier.value = false,
              onDropFile: (file) => onDroppedFiles([file]),
            ),
          
          // Drop zone content
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isDragOver ? Icons.file_download : Icons.cloud_upload_outlined,
                  size: 64,
                  color: isDragOver ? AppColors.primaryBlue : AppColors.textMuted,
                ),
                const SizedBox(height: 16),
                Text(
                  isDragOver 
                      ? 'Drop files here to upload'
                      : 'Drag and drop files here',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: isDragOver ? AppColors.primaryBlue : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'or',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onFilePicker,
                  icon: const Icon(Icons.folder_open, size: 18),
                  label: const Text('Browse Files'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Supported formats: Images, Videos, Documents, Audio',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFileList(
    BuildContext context,
    List<PlatformFile> files,
    Map<String, List<String>> validationErrors,
    Function(int) onRemove,
    VoidCallback onClearFiles,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Text(
              '${files.length} file${files.length == 1 ? '' : 's'} selected',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onClearFiles,
              icon: const Icon(Icons.clear_all, size: 16),
              label: const Text('Clear All'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // File list
        Expanded(
          child: ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              final errors = validationErrors[file.name] ?? [];
              final hasErrors = errors.isNotEmpty;
              
              return _buildFileItem(
                context,
                file,
                errors,
                hasErrors,
                () => onRemove(index),
                isMobile,
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildFileItem(
    BuildContext context,
    PlatformFile file,
    List<String> errors,
    bool hasErrors,
    VoidCallback onRemove,
    bool isMobile,
  ) {
    final fileType = StorageUtils.getFileType(file.name);
    final formattedSize = StorageUtils.formatFileSize(file.size);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasErrors 
            ? AppColors.error.withValues(alpha: 0.05)
            : AppColors.backgroundLight,
        border: Border.all(
          color: hasErrors ? AppColors.error : AppColors.borderLight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // File icon
              Icon(
                _getFileIcon(fileType),
                size: 20,
                color: hasErrors ? AppColors.error : AppColors.primaryBlue,
              ),
              const SizedBox(width: 12),
              
              // File info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: hasErrors ? AppColors.error : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$formattedSize • ${fileType.displayName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Remove button
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close, size: 18),
                color: AppColors.textSecondary,
                tooltip: 'Remove file',
                splashRadius: 16,
              ),
            ],
          ),
          
          // Error messages
          if (hasErrors) ...[
            const SizedBox(height: 8),
            ...errors.map((error) => Padding(
              padding: const EdgeInsets.only(left: 32, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 14,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      error,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }
  
  Widget _buildErrorDisplay(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.error),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActions(
    BuildContext context,
    List<PlatformFile> files,
    Map<String, List<String>> validationErrors,
    bool isUploading,
    VoidCallback onAddMore,
    VoidCallback onClear,
    VoidCallback onUpload,
    VoidCallback? onClose,
    bool isMobile,
  ) {
    final hasValidFiles = files.isNotEmpty && 
        !validationErrors.values.any((errors) => errors.isNotEmpty);
    
    return Row(
      children: [
        // Add more files button
        if (files.isNotEmpty)
          TextButton.icon(
            onPressed: isUploading ? null : onAddMore,
            icon: const Icon(Icons.add, size: 16),
            label: Text(isMobile ? 'Add' : 'Add More'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
            ),
          ),
        
        const Spacer(),
        
        // Cancel button
        TextButton(
          onPressed: isUploading ? null : onClose,
          child: const Text('Cancel'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Upload button
        ElevatedButton.icon(
          onPressed: hasValidFiles && !isUploading ? onUpload : null,
          icon: isUploading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.upload, size: 16),
          label: Text(
            isUploading 
                ? 'Uploading...' 
                : 'Upload ${files.length} file${files.length == 1 ? '' : 's'}',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 20,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
  
  IconData _getFileIcon(StorageFileType fileType) {
    switch (fileType) {
      case StorageFileType.image:
        return Icons.image;
      case StorageFileType.video:
        return Icons.video_file;
      case StorageFileType.document:
        return Icons.description;
      case StorageFileType.folder:
        return Icons.folder;
      case StorageFileType.other:
        return Icons.insert_drive_file;
    }
  }
  
  void _validateFiles(
    List<PlatformFile> files,
    StorageFileValidator validator,
    ValueNotifier<Map<String, List<String>>> validationErrors,
  ) {
    final errors = <String, List<String>>{};
    
    for (final file in files) {
      final fileErrors = validator.getValidationErrors(
        file.name,
        file.size,
        bucketId: bucketId,
      );
      
      if (fileErrors.isNotEmpty) {
        errors[file.name] = fileErrors;
      }
    }
    
    validationErrors.value = errors;
  }
  
  Future<List<StorageOperationResult>> _uploadFilesWithProgress(
    List<UploadTask> tasks,
    dynamic progressTracker,
    FileOperationMethods fileOperations,
  ) async {
    final results = <StorageOperationResult>[];
    
    // Upload files sequentially to better track progress
    for (final task in tasks) {
      try {
        // Simulate progress updates during upload
        _simulateUploadProgress(task.fileName, progressTracker);
        
        // Perform actual upload
        final result = await fileOperations.uploadFile(task);
        results.add(result);
        
        if (result.success) {
          progressTracker.completeUpload(task.fileName, file: result.file);
        } else {
          progressTracker.failUpload(task.fileName, result.error ?? 'Upload failed');
        }
      } catch (e) {
        Logger.error('Upload failed for: ${task.fileName}', e);
        progressTracker.failUpload(task.fileName, e.toString());
        results.add(StorageOperationResult.error('Upload failed: ${e.toString()}'));
      }
    }
    
    return results;
  }
  
  void _simulateUploadProgress(String fileName, dynamic progressTracker) {
    // This is a simplified progress simulation
    // In a real implementation, you would get actual progress from the upload operation
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final currentProgress = progressTracker.getProgress(fileName);
      if (currentProgress == null) {
        timer.cancel();
        return;
      }
      
      if (currentProgress.progress >= 1.0 || currentProgress.isComplete || currentProgress.error != null) {
        timer.cancel();
        return;
      }
      
      // Simulate progress increment
      final newProgress = (currentProgress.progress + 0.1).clamp(0.0, 0.95);
      progressTracker.updateProgress(fileName, newProgress);
    });
  }
  
  Widget _buildFolderOptions(
    BuildContext context,
    bool showOptions,
    String? targetFolder,
    bool createNewFolder,
    String newFolderName,
    VoidCallback onToggleOptions,
    Function(String?) onTargetFolderChanged,
    Function(bool) onCreateNewFolderChanged,
    Function(String) onNewFolderNameChanged,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle button
        InkWell(
          onTap: onToggleOptions,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Icon(
                  showOptions ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.folder_outlined,
                  size: 18,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Organize into folders',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Options panel
        if (showOptions) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Upload to current location
                RadioListTile<String?>(
                  title: Text(
                    currentPath != null && currentPath!.isNotEmpty
                        ? 'Upload to current folder ($currentPath)'
                        : 'Upload to bucket root',
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  value: null,
                  groupValue: createNewFolder ? 'new' : targetFolder,
                  onChanged: (value) {
                    onCreateNewFolderChanged(false);
                    onTargetFolderChanged(null);
                  },
                  activeColor: AppColors.primaryBlue,
                  contentPadding: EdgeInsets.zero,
                ),
                
                // Create new folder
                RadioListTile<String>(
                  title: Text(
                    'Create new folder',
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  value: 'new',
                  groupValue: createNewFolder ? 'new' : targetFolder,
                  onChanged: (value) {
                    onCreateNewFolderChanged(true);
                    onTargetFolderChanged(null);
                  },
                  activeColor: AppColors.primaryBlue,
                  contentPadding: EdgeInsets.zero,
                ),
                
                // New folder name input
                if (createNewFolder) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter folder name',
                        hintStyle: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: isMobile ? 13 : 14,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
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
                        fillColor: AppColors.cardBackground,
                      ),
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        color: AppColors.textPrimary,
                      ),
                      onChanged: onNewFolderNameChanged,
                    ),
                  ),
                ],
                
                // Folder naming hint
                if (createNewFolder) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Text(
                      'Use "/" to create nested folders (e.g., "docs/images")',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}