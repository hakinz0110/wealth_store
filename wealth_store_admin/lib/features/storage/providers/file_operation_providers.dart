import 'dart:typed_data';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/storage_models.dart';
import '../services/upload_progress_tracker.dart';
import '../utils/storage_utils.dart';
import '../constants/storage_constants.dart';
import '../interfaces/storage_interfaces.dart';
import 'storage_providers.dart';
import '../../../shared/utils/logger.dart';

// Selected files state
final selectedFilesProvider = StateProvider<Set<StorageFile>>((ref) => <StorageFile>{});

// File selection methods
final fileSelectionMethodsProvider = Provider<FileSelectionMethods>((ref) {
  return FileSelectionMethods(ref);
});

// Upload state providers
final uploadQueueProvider = StateProvider<List<UploadTask>>((ref) => []);
final isUploadingProvider = StateProvider<bool>((ref) => false);
final uploadErrorProvider = StateProvider<String?>((ref) => null);

// Upload progress stream provider
final uploadProgressStreamProvider = StreamProvider<Map<String, StorageUploadProgress>>((ref) {
  final tracker = ref.read(uploadProgressTrackerProvider);
  if (tracker is StorageUploadProgressTracker) {
    return tracker.progressStream;
  }
  return Stream.value({});
});

// Active uploads provider
final activeUploadsProvider = Provider<List<StorageUploadProgress>>((ref) {
  final progressMap = ref.watch(uploadProgressStreamProvider);
  return progressMap.when(
    data: (progress) => progress.values.where((p) => !p.isComplete && p.error == null).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Completed uploads provider
final completedUploadsProvider = Provider<List<StorageUploadProgress>>((ref) {
  final progressMap = ref.watch(uploadProgressStreamProvider);
  return progressMap.when(
    data: (progress) => progress.values.where((p) => p.isComplete && p.error == null).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Failed uploads provider
final failedUploadsProvider = Provider<List<StorageUploadProgress>>((ref) {
  final progressMap = ref.watch(uploadProgressStreamProvider);
  return progressMap.when(
    data: (progress) => progress.values.where((p) => p.error != null).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// File operation methods provider
final fileOperationMethodsProvider = Provider<FileOperationMethods>((ref) {
  return FileOperationMethods(ref);
});

// Search and filter providers
final searchQueryProvider = StateProvider<String>((ref) => '');
final fileFiltersProvider = StateProvider<StorageFilters>((ref) => const StorageFilters());

// Filtered files provider
final filteredFilesProvider = Provider<List<StorageFile>>((ref) {
  final filesAsync = ref.watch(currentBucketFilesProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final filters = ref.watch(fileFiltersProvider);
  
  return filesAsync.when(
    data: (files) {
      var filteredFiles = files;
      
      // Apply search query
      if (searchQuery.isNotEmpty) {
        filteredFiles = filteredFiles.where((file) =>
          file.name.toLowerCase().contains(searchQuery.toLowerCase())
        ).toList();
      }
      
      // Apply filters
      filteredFiles = StorageUtils.filterFiles(filteredFiles, filters);
      
      return filteredFiles;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Sort providers
final sortByProvider = StateProvider<SortBy>((ref) => SortBy.name);
final sortOrderProvider = StateProvider<SortOrder>((ref) => SortOrder.ascending);

// Sorted files provider
final sortedFilesProvider = Provider<List<StorageFile>>((ref) {
  final files = ref.watch(filteredFilesProvider);
  final sortBy = ref.watch(sortByProvider);
  final sortOrder = ref.watch(sortOrderProvider);
  
  return StorageUtils.sortFiles(files, sortBy, sortOrder);
});

/// Upload task model
class UploadTask {
  final String fileName;
  final Uint8List fileBytes;
  final String bucketId;
  final String? path;
  final String? mimeType;
  final Map<String, dynamic>? metadata;

  const UploadTask({
    required this.fileName,
    required this.fileBytes,
    required this.bucketId,
    this.path,
    this.mimeType,
    this.metadata,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadTask &&
          runtimeType == other.runtimeType &&
          fileName == other.fileName &&
          bucketId == other.bucketId &&
          path == other.path;

  @override
  int get hashCode => fileName.hashCode ^ bucketId.hashCode ^ path.hashCode;
}

/// File selection methods
class FileSelectionMethods {
  final Ref _ref;

  FileSelectionMethods(this._ref);

  /// Select a file
  void selectFile(StorageFile file) {
    try {
      final currentSelection = _ref.read(selectedFilesProvider);
      final newSelection = Set<StorageFile>.from(currentSelection)..add(file);
      _ref.read(selectedFilesProvider.notifier).state = newSelection;
      Logger.debug('Selected file: ${file.name}');
    } catch (e) {
      Logger.error('Failed to select file: ${file.name}', e);
    }
  }

  /// Deselect a file
  void deselectFile(StorageFile file) {
    try {
      final currentSelection = _ref.read(selectedFilesProvider);
      final newSelection = Set<StorageFile>.from(currentSelection)..remove(file);
      _ref.read(selectedFilesProvider.notifier).state = newSelection;
      Logger.debug('Deselected file: ${file.name}');
    } catch (e) {
      Logger.error('Failed to deselect file: ${file.name}', e);
    }
  }

  /// Toggle file selection
  void toggleFileSelection(StorageFile file) {
    try {
      final currentSelection = _ref.read(selectedFilesProvider);
      if (currentSelection.contains(file)) {
        deselectFile(file);
      } else {
        selectFile(file);
      }
    } catch (e) {
      Logger.error('Failed to toggle file selection: ${file.name}', e);
    }
  }

  /// Select multiple files
  void selectFiles(List<StorageFile> files) {
    try {
      final currentSelection = _ref.read(selectedFilesProvider);
      final newSelection = Set<StorageFile>.from(currentSelection)..addAll(files);
      _ref.read(selectedFilesProvider.notifier).state = newSelection;
      Logger.debug('Selected ${files.length} files');
    } catch (e) {
      Logger.error('Failed to select multiple files', e);
    }
  }

  /// Select all files
  void selectAll() {
    try {
      final files = _ref.read(sortedFilesProvider);
      _ref.read(selectedFilesProvider.notifier).state = Set<StorageFile>.from(files);
      Logger.debug('Selected all ${files.length} files');
    } catch (e) {
      Logger.error('Failed to select all files', e);
    }
  }

  /// Clear selection
  void clearSelection() {
    try {
      _ref.read(selectedFilesProvider.notifier).state = <StorageFile>{};
      Logger.debug('Cleared file selection');
    } catch (e) {
      Logger.error('Failed to clear file selection', e);
    }
  }

  /// Check if file is selected
  bool isFileSelected(StorageFile file) {
    final selection = _ref.read(selectedFilesProvider);
    return selection.contains(file);
  }

  /// Get selected files count
  int get selectedCount => _ref.read(selectedFilesProvider).length;

  /// Check if any files are selected
  bool get hasSelection => selectedCount > 0;

  /// Get selected files as list
  List<StorageFile> get selectedFiles => _ref.read(selectedFilesProvider).toList();
}

/// File operation methods
class FileOperationMethods {
  final Ref _ref;

  FileOperationMethods(this._ref);

  /// Upload files
  Future<List<StorageOperationResult>> uploadFiles(List<UploadTask> tasks) async {
    if (tasks.isEmpty) return [];

    try {
      Logger.info('Starting upload of ${tasks.length} files');
      _ref.read(isUploadingProvider.notifier).state = true;
      _ref.read(uploadErrorProvider.notifier).state = null;

      final repository = _ref.read(storageRepositoryProvider);
      final results = <StorageOperationResult>[];

      // Process uploads sequentially to avoid overwhelming the server
      for (final task in tasks) {
        try {
          final result = await repository.uploadFile(
            bucketId: task.bucketId,
            fileName: task.fileName,
            fileBytes: task.fileBytes,
            path: task.path,
            mimeType: task.mimeType,
            metadata: task.metadata,
          );
          results.add(result);

          if (result.success) {
            Logger.info('Successfully uploaded: ${task.fileName}');
          } else {
            Logger.warning('Failed to upload: ${task.fileName} - ${result.error}');
          }
        } catch (e) {
          Logger.error('Upload failed for: ${task.fileName}', e);
          results.add(StorageOperationResult.error('Upload failed: ${e.toString()}'));
        }
      }

      // Refresh current bucket contents
      await _refreshCurrentBucket();

      final successCount = results.where((r) => r.success).length;
      Logger.info('Upload completed: $successCount/${tasks.length} successful');

      return results;
    } catch (e) {
      Logger.error('Batch upload failed', e);
      _ref.read(uploadErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(isUploadingProvider.notifier).state = false;
    }
  }

  /// Upload single file
  Future<StorageOperationResult> uploadFile(UploadTask task) async {
    final results = await uploadFiles([task]);
    return results.isNotEmpty ? results.first : StorageOperationResult.error('Upload failed');
  }

  /// Delete selected files
  Future<List<StorageOperationResult>> deleteSelectedFiles() async {
    final selectedFiles = _ref.read(selectedFilesProvider).toList();
    if (selectedFiles.isEmpty) return [];

    return await deleteFiles(selectedFiles);
  }

  /// Delete files with validation and security checks
  Future<List<StorageOperationResult>> deleteFiles(List<StorageFile> files, {bool permanent = false}) async {
    if (files.isEmpty) return [];

    try {
      Logger.info('Deleting ${files.length} files (permanent: $permanent)');
      
      // Validate files before deletion
      final validationResults = _validateFilesForDeletion(files);
      if (validationResults.isNotEmpty) {
        Logger.warning('File validation failed: ${validationResults.join(', ')}');
        return validationResults.map((error) => StorageOperationResult.error(error)).toList();
      }

      final repository = _ref.read(storageRepositoryProvider);
      final results = <StorageOperationResult>[];

      // Process deletions with concurrency control
      const maxConcurrentDeletes = 5;
      final batches = <List<StorageFile>>[];
      
      for (int i = 0; i < files.length; i += maxConcurrentDeletes) {
        final end = (i + maxConcurrentDeletes < files.length) ? i + maxConcurrentDeletes : files.length;
        batches.add(files.sublist(i, end));
      }

      for (final batch in batches) {
        final batchResults = await Future.wait(
          batch.map((file) => _deleteFileWithRetry(repository, file, permanent)),
        );
        results.addAll(batchResults);
      }

      // Clear selection and refresh
      _ref.read(selectedFilesProvider.notifier).state = <StorageFile>{};
      await _refreshCurrentBucket();

      final successCount = results.where((r) => r.success).length;
      Logger.info('Delete completed: $successCount/${files.length} successful');

      return results;
    } catch (e) {
      Logger.error('Batch delete failed', e);
      rethrow;
    }
  }

  /// Validate files before deletion
  List<String> _validateFilesForDeletion(List<StorageFile> files) {
    final errors = <String>[];
    
    for (final file in files) {
      // Check if file path is valid
      if (file.path.isEmpty) {
        errors.add('Invalid file path for: ${file.name}');
        continue;
      }
      
      // Check for system files or protected paths
      if (_isProtectedFile(file)) {
        errors.add('Cannot delete protected file: ${file.name}');
        continue;
      }
      
      // Check file size for large file warning
      if (file.size > StorageConstants.maxGeneralFileSize) {
        Logger.warning('Deleting large file: ${file.name} (${file.formattedSize})');
      }
    }
    
    return errors;
  }

  /// Check if file is protected from deletion
  bool _isProtectedFile(StorageFile file) {
    final protectedPaths = ['.system', '.config', '.backup'];
    final protectedNames = ['index.html', 'robots.txt', '.htaccess'];
    
    return protectedPaths.any((path) => file.path.startsWith(path)) ||
           protectedNames.contains(file.name.toLowerCase());
  }

  /// Delete single file with retry logic
  Future<StorageOperationResult> _deleteFileWithRetry(
    IStorageRepository repository, 
    StorageFile file, 
    bool permanent,
    {int maxRetries = 2}
  ) async {
    int attempts = 0;
    
    while (attempts <= maxRetries) {
      try {
        final result = await repository.deleteFile(file.bucketId, file.path);
        
        if (result.success) {
          Logger.info('Successfully deleted: ${file.name}');
          return result;
        } else {
          Logger.warning('Failed to delete: ${file.name} - ${result.error}');
          if (attempts == maxRetries) {
            return result;
          }
        }
      } catch (e) {
        Logger.error('Delete attempt ${attempts + 1} failed for: ${file.name}', e);
        if (attempts == maxRetries) {
          return StorageOperationResult.error('Delete failed after $maxRetries attempts: ${e.toString()}');
        }
      }
      
      attempts++;
      // Wait before retry
      await Future.delayed(Duration(milliseconds: 500 * attempts));
    }
    
    return StorageOperationResult.error('Delete failed after $maxRetries attempts');
  }

  /// Rename file with validation and conflict resolution
  Future<StorageOperationResult> renameFile(StorageFile file, String newName) async {
    try {
      Logger.info('Renaming file: ${file.name} to: $newName');
      
      // Validate new name
      final pathParts = file.path.split('/');
      pathParts[pathParts.length - 1] = newName;
      final newPath = pathParts.join('/');
      
      final pathValidation = validateFilePath(newPath, file.bucketId);
      if (pathValidation != null) {
        return StorageOperationResult.error('Invalid file name: $pathValidation');
      }
      
      // Check for conflicts
      if (await fileExistsAtPath(file.bucketId, newPath)) {
        return StorageOperationResult.error('A file with this name already exists');
      }
      
      final repository = _ref.read(storageRepositoryProvider);
      final result = await repository.renameFile(file.bucketId, file.path, newPath);

      if (result.success) {
        Logger.info('Successfully renamed: ${file.name} to: $newName');
        await _refreshCurrentBucket();
      } else {
        Logger.warning('Failed to rename: ${file.name} - ${result.error}');
      }

      return result;
    } catch (e) {
      Logger.error('Rename failed for: ${file.name}', e);
      return StorageOperationResult.error('Rename failed: ${e.toString()}');
    }
  }

  /// Move file with validation and conflict resolution
  Future<StorageOperationResult> moveFile(StorageFile file, String newPath) async {
    try {
      Logger.info('Moving file: ${file.name} to: $newPath');
      
      // Validate new path
      final pathValidation = validateFilePath(newPath, file.bucketId);
      if (pathValidation != null) {
        return StorageOperationResult.error('Invalid destination path: $pathValidation');
      }
      
      // Check if source and destination are the same
      if (file.path == newPath) {
        return StorageOperationResult.success('File is already at the destination');
      }
      
      // Check for conflicts and resolve if needed
      final finalPath = await resolveNameConflict(file.bucketId, newPath);
      
      final repository = _ref.read(storageRepositoryProvider);
      final result = await repository.moveFile(file.bucketId, file.path, finalPath);

      if (result.success) {
        Logger.info('Successfully moved: ${file.name} to: $finalPath');
        await _refreshCurrentBucket();
      } else {
        Logger.warning('Failed to move: ${file.name} - ${result.error}');
      }

      return result;
    } catch (e) {
      Logger.error('Move failed for: ${file.name}', e);
      return StorageOperationResult.error('Move failed: ${e.toString()}');
    }
  }

  /// Create folder
  Future<StorageOperationResult> createFolder(String bucketId, String folderName, {String? parentPath}) async {
    try {
      Logger.info('Creating folder: $folderName in bucket: $bucketId');
      final repository = _ref.read(storageRepositoryProvider);
      
      final folderPath = parentPath != null && parentPath.isNotEmpty
          ? '$parentPath/$folderName'
          : folderName;

      final result = await repository.createFolder(bucketId, folderPath);

      if (result.success) {
        Logger.info('Successfully created folder: $folderName');
        await _refreshCurrentBucket();
      } else {
        Logger.warning('Failed to create folder: $folderName - ${result.error}');
      }

      return result;
    } catch (e) {
      Logger.error('Create folder failed: $folderName', e);
      return StorageOperationResult.error('Create folder failed: ${e.toString()}');
    }
  }

  /// Get public URL for file
  String getPublicUrl(StorageFile file) {
    try {
      final repository = _ref.read(storageRepositoryProvider);
      return repository.getPublicUrl(file.bucketId, file.path);
    } catch (e) {
      Logger.error('Failed to get public URL for: ${file.name}', e);
      return '';
    }
  }

  /// Search files
  Future<List<StorageFile>> searchFiles(StorageFilters filters, {String? bucketId}) async {
    try {
      Logger.info('Searching files with filters');
      final repository = _ref.read(storageRepositoryProvider);
      return await repository.searchFiles(filters, bucketId: bucketId);
    } catch (e) {
      Logger.error('Search failed', e);
      return [];
    }
  }

  /// Update search query
  void updateSearchQuery(String query) {
    try {
      _ref.read(searchQueryProvider.notifier).state = query;
      Logger.debug('Updated search query: $query');
    } catch (e) {
      Logger.error('Failed to update search query', e);
    }
  }

  /// Update filters
  void updateFilters(StorageFilters filters) {
    try {
      _ref.read(fileFiltersProvider.notifier).state = filters;
      Logger.debug('Updated file filters');
    } catch (e) {
      Logger.error('Failed to update filters', e);
    }
  }

  /// Clear filters
  void clearFilters() {
    try {
      _ref.read(searchQueryProvider.notifier).state = '';
      _ref.read(fileFiltersProvider.notifier).state = const StorageFilters();
      Logger.debug('Cleared all filters');
    } catch (e) {
      Logger.error('Failed to clear filters', e);
    }
  }

  /// Update sort settings
  void updateSort(SortBy sortBy, SortOrder sortOrder) {
    try {
      _ref.read(sortByProvider.notifier).state = sortBy;
      _ref.read(sortOrderProvider.notifier).state = sortOrder;
      Logger.debug('Updated sort: $sortBy, $sortOrder');
    } catch (e) {
      Logger.error('Failed to update sort settings', e);
    }
  }

  /// Clear upload queue
  void clearUploadQueue() {
    try {
      _ref.read(uploadQueueProvider.notifier).state = [];
      Logger.debug('Cleared upload queue');
    } catch (e) {
      Logger.error('Failed to clear upload queue', e);
    }
  }

  /// Add to upload queue
  void addToUploadQueue(List<UploadTask> tasks) {
    try {
      final currentQueue = _ref.read(uploadQueueProvider);
      final newQueue = [...currentQueue, ...tasks];
      _ref.read(uploadQueueProvider.notifier).state = newQueue;
      Logger.debug('Added ${tasks.length} tasks to upload queue');
    } catch (e) {
      Logger.error('Failed to add to upload queue', e);
    }
  }

  /// Remove from upload queue
  void removeFromUploadQueue(UploadTask task) {
    try {
      final currentQueue = _ref.read(uploadQueueProvider);
      final newQueue = currentQueue.where((t) => t != task).toList();
      _ref.read(uploadQueueProvider.notifier).state = newQueue;
      Logger.debug('Removed task from upload queue: ${task.fileName}');
    } catch (e) {
      Logger.error('Failed to remove from upload queue', e);
    }
  }

  /// Process upload queue
  Future<void> processUploadQueue() async {
    try {
      final queue = _ref.read(uploadQueueProvider);
      if (queue.isEmpty) return;

      Logger.info('Processing upload queue: ${queue.length} items');
      await uploadFiles(queue);
      clearUploadQueue();
    } catch (e) {
      Logger.error('Failed to process upload queue', e);
      rethrow;
    }
  }

  /// Validate file path for move/rename operations
  String? validateFilePath(String path, String bucketId) {
    try {
      // Check if path is empty
      if (path.trim().isEmpty) {
        return 'Path cannot be empty';
      }
      
      // Check for invalid characters
      final invalidChars = ['<', '>', ':', '"', '|', '?', '*'];
      for (final char in invalidChars) {
        if (path.contains(char)) {
          return 'Path cannot contain: $char';
        }
      }
      
      // Check path length
      if (path.length > 1024) {
        return 'Path is too long (max 1024 characters)';
      }
      
      // Check for double slashes
      if (path.contains('//')) {
        return 'Path cannot contain double slashes';
      }
      
      // Check for path traversal attempts
      if (path.contains('../') || path.contains('..\\')) {
        return 'Path cannot contain parent directory references';
      }
      
      return null;
    } catch (e) {
      Logger.error('Path validation failed', e);
      return 'Path validation failed: ${e.toString()}';
    }
  }

  /// Check if file exists at path
  Future<bool> fileExistsAtPath(String bucketId, String path) async {
    try {
      final repository = _ref.read(storageRepositoryProvider);
      final files = await repository.getFiles(bucketId);
      return files.any((file) => file.path == path);
    } catch (e) {
      Logger.error('Failed to check file existence', e);
      return false;
    }
  }

  /// Generate unique file name if conflict exists
  Future<String> resolveNameConflict(String bucketId, String originalPath) async {
    try {
      if (!await fileExistsAtPath(bucketId, originalPath)) {
        return originalPath;
      }
      
      final pathParts = originalPath.split('/');
      final fileName = pathParts.last;
      final directory = pathParts.length > 1 ? pathParts.sublist(0, pathParts.length - 1).join('/') : '';
      
      final nameWithoutExt = _getFileNameWithoutExtension(fileName);
      final extension = _getFileExtension(fileName);
      
      int counter = 1;
      String newPath;
      
      do {
        final newName = extension.isNotEmpty 
          ? '$nameWithoutExt ($counter).$extension'
          : '$nameWithoutExt ($counter)';
        
        newPath = directory.isNotEmpty ? '$directory/$newName' : newName;
        counter++;
      } while (await fileExistsAtPath(bucketId, newPath) && counter < 100);
      
      if (counter >= 100) {
        throw Exception('Could not resolve name conflict after 100 attempts');
      }
      
      return newPath;
    } catch (e) {
      Logger.error('Failed to resolve name conflict', e);
      rethrow;
    }
  }

  /// Get file name without extension
  String _getFileNameWithoutExtension(String fileName) {
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex == -1 || lastDotIndex == 0) {
      return fileName;
    }
    return fileName.substring(0, lastDotIndex);
  }

  /// Get file extension
  String _getFileExtension(String fileName) {
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex == -1 || lastDotIndex == 0) {
      return '';
    }
    return fileName.substring(lastDotIndex + 1);
  }

  /// Validate file path for move/rename operations
  String? validateFilePath(String path, String bucketId) {
    try {
      // Check if path is empty
      if (path.trim().isEmpty) {
        return 'Path cannot be empty';
      }
      
      // Check for invalid characters
      final invalidChars = ['<', '>', ':', '"', '|', '?', '*'];
      for (final char in invalidChars) {
        if (path.contains(char)) {
          return 'Path cannot contain: $char';
        }
      }
      
      // Check path length
      if (path.length > 1024) {
        return 'Path is too long (max 1024 characters)';
      }
      
      // Check for double slashes
      if (path.contains('//')) {
        return 'Path cannot contain double slashes';
      }
      
      // Check for path traversal attempts
      if (path.contains('../') || path.contains('..\\')) {
        return 'Path cannot contain parent directory references';
      }
      
      return null;
    } catch (e) {
      Logger.error('Path validation failed', e);
      return 'Path validation failed: ${e.toString()}';
    }
  }

  /// Check if file exists at path
  Future<bool> fileExistsAtPath(String bucketId, String path) async {
    try {
      final repository = _ref.read(storageRepositoryProvider);
      final files = await repository.getFiles(bucketId);
      return files.any((file) => file.path == path);
    } catch (e) {
      Logger.error('Failed to check file existence', e);
      return false;
    }
  }

  /// Generate unique file name if conflict exists
  Future<String> resolveNameConflict(String bucketId, String originalPath) async {
    try {
      if (!await fileExistsAtPath(bucketId, originalPath)) {
        return originalPath;
      }
      
      final pathParts = originalPath.split('/');
      final fileName = pathParts.last;
      final directory = pathParts.length > 1 ? pathParts.sublist(0, pathParts.length - 1).join('/') : '';
      
      final nameWithoutExt = _getFileNameWithoutExtension(fileName);
      final extension = _getFileExtension(fileName);
      
      int counter = 1;
      String newPath;
      
      do {
        final newName = extension.isNotEmpty 
          ? '$nameWithoutExt ($counter).$extension'
          : '$nameWithoutExt ($counter)';
        
        newPath = directory.isNotEmpty ? '$directory/$newName' : newName;
        counter++;
      } while (await fileExistsAtPath(bucketId, newPath) && counter < 100);
      
      if (counter >= 100) {
        throw Exception('Could not resolve name conflict after 100 attempts');
      }
      
      return newPath;
    } catch (e) {
      Logger.error('Failed to resolve name conflict', e);
      rethrow;
    }
  }

  /// Helper method to refresh current bucket
  Future<void> _refreshCurrentBucket() async {
    try {
      final bucketMethods = _ref.read(bucketMethodsProvider);
      await bucketMethods.refreshCurrentBucket();
    } catch (e) {
      Logger.warning('Failed to refresh current bucket', e);
    }
  }
}