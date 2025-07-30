import 'dart:io';
import 'dart:typed_data';
import '../interfaces/storage_interfaces.dart';
import '../models/storage_models.dart';
import '../../../shared/utils/logger.dart';
import '../../../shared/utils/error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Base class for storage operations with common functionality
abstract class StorageBase implements IStorageRepository {
  final IFileValidator fileValidator;
  final IStorageCache? cache;
  final IUploadProgressTracker? progressTracker;
  final IStorageEventHandler? eventHandler;

  StorageBase({
    required this.fileValidator,
    this.cache,
    this.progressTracker,
    this.eventHandler,
  });

  /// Validate file before upload
  void validateFileForUpload({
    required String fileName,
    required int fileSize,
    List<String>? allowedTypes,
    int? maxSize,
  }) {
    // Validate file name
    if (!fileValidator.validateFileName(fileName)) {
      throw StorageException('Invalid file name: $fileName');
    }

    // Validate file type
    if (!fileValidator.validateFileType(fileName, allowedTypes)) {
      throw StorageException(
        'File type not allowed. Allowed types: ${allowedTypes?.join(', ') ?? 'any'}',
      );
    }

    // Validate file size
    if (!fileValidator.validateFileSize(fileSize, maxSize)) {
      final maxSizeMB = maxSize != null ? (maxSize / (1024 * 1024)).toStringAsFixed(1) : 'unlimited';
      final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(1);
      throw StorageException(
        'File size ${fileSizeMB}MB exceeds maximum allowed size of ${maxSizeMB}MB',
      );
    }
  }

  /// Log storage operation
  void logOperation(String operation, String details) {
    Logger.info('Storage Operation: $operation - $details');
  }

  /// Handle storage error
  StorageOperationResult handleError(String operation, dynamic error, [StackTrace? stackTrace]) {
    final errorMessage = 'Storage $operation failed: ${error.toString()}';
    ErrorHandler.logError(operation, error, stackTrace);
    return StorageOperationResult.error(errorMessage);
  }

  /// Get sanitized file path
  String getSanitizedPath(String? path, String fileName) {
    final sanitizedFileName = fileValidator.sanitizeFileName(fileName);
    if (path == null || path.isEmpty) {
      return sanitizedFileName;
    }
    
    // Ensure path doesn't start with / and ends with /
    String cleanPath = path.trim();
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    if (!cleanPath.endsWith('/')) {
      cleanPath += '/';
    }
    
    return '$cleanPath$sanitizedFileName';
  }

  /// Update cache after operation
  Future<void> updateCacheAfterOperation(
    String operation,
    String bucketId, {
    String? path,
    StorageFile? file,
  }) async {
    if (cache == null) return;

    try {
      switch (operation) {
        case 'upload':
        case 'delete':
        case 'rename':
        case 'move':
          // Clear cache for the affected path
          final cachePath = path ?? '';
          await cache!.clearBucketCache(bucketId);
          break;
        case 'createFolder':
          // Clear cache for parent path
          await cache!.clearBucketCache(bucketId);
          break;
      }
    } catch (e) {
      Logger.warning('Failed to update cache after $operation', e);
    }
  }

  /// Notify event handlers
  void notifyEventHandlers(
    String event,
    String bucketId, {
    String? filePath,
    String? oldPath,
    String? newPath,
    StorageFile? file,
    String? fileName,
    double? progress,
    String? error,
  }) {
    if (eventHandler == null) return;

    try {
      switch (event) {
        case 'fileUploaded':
          if (file != null) eventHandler!.onFileUploaded(file);
          break;
        case 'fileDeleted':
          if (filePath != null) eventHandler!.onFileDeleted(bucketId, filePath);
          break;
        case 'fileRenamed':
          if (oldPath != null && newPath != null) {
            eventHandler!.onFileRenamed(bucketId, oldPath, newPath);
          }
          break;
        case 'fileMoved':
          if (oldPath != null && newPath != null) {
            eventHandler!.onFileMoved(bucketId, oldPath, newPath);
          }
          break;
        case 'folderCreated':
          if (filePath != null) eventHandler!.onFolderCreated(bucketId, filePath);
          break;
        case 'uploadProgress':
          if (fileName != null && progress != null) {
            eventHandler!.onUploadProgress(fileName, progress);
          }
          break;
        case 'uploadError':
          if (fileName != null && error != null) {
            eventHandler!.onUploadError(fileName, error);
          }
          break;
      }
    } catch (e) {
      Logger.warning('Failed to notify event handlers for $event', e);
    }
  }

  /// Track upload progress
  void trackUploadProgress(String fileName, double progress, {int? uploadedBytes, int? totalBytes}) {
    progressTracker?.updateProgress(
      fileName,
      progress,
      uploadedBytes: uploadedBytes,
      totalBytes: totalBytes,
    );
    notifyEventHandlers(
      'uploadProgress',
      '',
      fileName: fileName,
      progress: progress,
    );
  }

  /// Start upload tracking
  void startUploadTracking(String fileName) {
    progressTracker?.startTracking(fileName);
  }

  /// Complete upload tracking
  void completeUploadTracking(String fileName, {StorageFile? file}) {
    progressTracker?.completeUpload(fileName, file: file);
  }

  /// Fail upload tracking
  void failUploadTracking(String fileName, String error) {
    progressTracker?.failUpload(fileName, error);
    notifyEventHandlers(
      'uploadError',
      '',
      fileName: fileName,
      error: error,
    );
  }
}

/// Base class for file validation with common rules
abstract class FileValidatorBase implements IFileValidator {
  @override
  bool validateFileName(String fileName) {
    if (fileName.isEmpty) return false;
    if (fileName.length > 255) return false;
    
    // Check for invalid characters
    const invalidChars = ['/', '\\', ':', '*', '?', '"', '<', '>', '|'];
    for (final char in invalidChars) {
      if (fileName.contains(char)) return false;
    }
    
    // Check for reserved names (Windows)
    const reservedNames = [
      'CON', 'PRN', 'AUX', 'NUL',
      'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9',
      'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9'
    ];
    
    final nameWithoutExt = fileName.split('.').first.toUpperCase();
    if (reservedNames.contains(nameWithoutExt)) return false;
    
    return true;
  }

  @override
  String sanitizeFileName(String fileName) {
    // Replace invalid characters with underscores
    String sanitized = fileName;
    const invalidChars = ['/', '\\', ':', '*', '?', '"', '<', '>', '|'];
    for (final char in invalidChars) {
      sanitized = sanitized.replaceAll(char, '_');
    }
    
    // Trim whitespace and dots
    sanitized = sanitized.trim().replaceAll(RegExp(r'^\.+|\.+$'), '');
    
    // Ensure not empty
    if (sanitized.isEmpty) {
      sanitized = 'file_${DateTime.now().millisecondsSinceEpoch}';
    }
    
    // Limit length
    if (sanitized.length > 255) {
      final extension = sanitized.split('.').last;
      final nameWithoutExt = sanitized.substring(0, sanitized.lastIndexOf('.'));
      final maxNameLength = 255 - extension.length - 1;
      sanitized = '${nameWithoutExt.substring(0, maxNameLength)}.$extension';
    }
    
    return sanitized;
  }

  @override
  bool validateFileType(String fileName, List<String>? allowedTypes) {
    if (allowedTypes == null || allowedTypes.isEmpty) return true;
    
    final extension = fileName.split('.').last.toLowerCase();
    return allowedTypes.any((type) => type.toLowerCase() == extension);
  }

  @override
  bool validateFileSize(int fileSize, int? maxSize) {
    if (maxSize == null) return true;
    return fileSize <= maxSize;
  }

  @override
  StorageFileType getFileType(String fileName, String? mimeType) {
    // Check by MIME type first
    if (mimeType != null) {
      if (mimeType.startsWith('image/')) return StorageFileType.image;
      if (mimeType.startsWith('video/')) return StorageFileType.video;
      if (mimeType.startsWith('application/pdf') || 
          mimeType.contains('document') || 
          mimeType.startsWith('text/')) {
        return StorageFileType.document;
      }
    }
    
    // Check by file extension
    final extension = fileName.split('.').last.toLowerCase();
    
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg', 'bmp', 'tiff'];
    if (imageExtensions.contains(extension)) return StorageFileType.image;
    
    const videoExtensions = ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm', 'mkv', '3gp'];
    if (videoExtensions.contains(extension)) return StorageFileType.video;
    
    const documentExtensions = ['pdf', 'doc', 'docx', 'txt', 'rtf', 'odt', 'xls', 'xlsx', 'ppt', 'pptx'];
    if (documentExtensions.contains(extension)) return StorageFileType.document;
    
    return StorageFileType.other;
  }
}



/// Storage operation types for logging and events
enum StorageOperationType {
  upload,
  delete,
  rename,
  move,
  createFolder,
  getBuckets,
  getFiles,
  getStats,
  search,
}

/// Storage operation context for tracking and logging
class StorageOperationContext {
  final StorageOperationType type;
  final String bucketId;
  final String? path;
  final String? fileName;
  final DateTime startTime;
  final Map<String, dynamic> metadata;

  StorageOperationContext({
    required this.type,
    required this.bucketId,
    this.path,
    this.fileName,
    DateTime? startTime,
    this.metadata = const {},
  }) : startTime = startTime ?? DateTime.now();

  Duration get duration => DateTime.now().difference(startTime);

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'bucketId': bucketId,
      'path': path,
      'fileName': fileName,
      'startTime': startTime.toIso8601String(),
      'duration': duration.inMilliseconds,
      'metadata': metadata,
    };
  }
}