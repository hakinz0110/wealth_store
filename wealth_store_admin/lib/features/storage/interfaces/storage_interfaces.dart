import 'dart:io';
import 'dart:typed_data';
import '../models/storage_models.dart';

/// Abstract interface for storage operations
abstract class IStorageRepository {
  /// Get all available storage buckets
  Future<List<StorageBucket>> getBuckets();

  /// Get files and folders in a specific bucket and path
  Future<List<StorageFile>> getFiles(String bucketId, {String? path});

  /// Upload a file to storage
  Future<StorageOperationResult> uploadFile({
    required String bucketId,
    required String fileName,
    required Uint8List fileBytes,
    String? path,
    String? mimeType,
    Map<String, dynamic>? metadata,
  });

  /// Upload a file from File object
  Future<StorageOperationResult> uploadFileFromPath({
    required String bucketId,
    required String fileName,
    required File file,
    String? path,
    Map<String, dynamic>? metadata,
  });

  /// Delete a file from storage
  Future<StorageOperationResult> deleteFile(String bucketId, String filePath);

  /// Rename a file in storage
  Future<StorageOperationResult> renameFile(
    String bucketId,
    String oldPath,
    String newPath,
  );

  /// Move a file to a different path
  Future<StorageOperationResult> moveFile(
    String bucketId,
    String fromPath,
    String toPath,
  );

  /// Create a folder in storage
  Future<StorageOperationResult> createFolder(
    String bucketId,
    String folderPath,
  );

  /// Get public URL for a file
  String getPublicUrl(String bucketId, String filePath);

  /// Get storage statistics for a bucket
  Future<StorageStats> getBucketStats(String bucketId);

  /// Search files across buckets
  Future<List<StorageFile>> searchFiles(
    StorageFilters filters, {
    String? bucketId,
  });

  /// List files with pagination support
  Future<List<StorageFile>> listFiles({
    required String bucketId,
    required String path,
    int? limit,
    int? offset,
  });

  /// Get file information without downloading
  Future<StorageFile> getFileInfo({
    required String bucketId,
    required String filePath,
  });

  /// Upload a chunk for chunked upload
  Future<void> uploadChunk({
    required String uploadId,
    required int chunkIndex,
    required Uint8List chunkData,
  });

  /// Finalize a chunked upload
  Future<StorageFile> finalizeChunkedUpload({
    required String uploadId,
    required String bucketId,
    required String path,
    required String fileName,
    required String mimeType,
    Map<String, String>? metadata,
  });

  /// Download a chunk of a file
  Future<Uint8List> downloadChunk({
    required String bucketId,
    required String filePath,
    required int start,
    required int length,
  });
}

/// Abstract interface for file validation
abstract class IFileValidator {
  /// Validate file type against allowed types
  bool validateFileType(String fileName, List<String>? allowedTypes);

  /// Validate file size against limits
  bool validateFileSize(int fileSize, int? maxSize);

  /// Validate file name for storage
  bool validateFileName(String fileName);

  /// Sanitize file name for safe storage
  String sanitizeFileName(String fileName);

  /// Get file type from extension or mime type
  StorageFileType getFileType(String fileName, String? mimeType);
}

/// Abstract interface for thumbnail generation
abstract class IThumbnailGenerator {
  /// Generate thumbnail for an image file
  Future<Uint8List?> generateImageThumbnail(
    Uint8List imageBytes, {
    int width = 200,
    int height = 200,
  });

  /// Generate thumbnail for a video file
  Future<Uint8List?> generateVideoThumbnail(
    Uint8List videoBytes, {
    int width = 200,
    int height = 200,
  });

  /// Check if thumbnail generation is supported for file type
  bool supportsThumbnail(StorageFileType fileType);
}

/// Abstract interface for storage caching
abstract class IStorageCache {
  /// Cache bucket list
  Future<void> cacheBuckets(List<StorageBucket> buckets);

  /// Get cached bucket list
  Future<List<StorageBucket>?> getCachedBuckets();

  /// Cache files for a bucket path
  Future<void> cacheFiles(
    String bucketId,
    String path,
    List<StorageFile> files,
  );

  /// Get cached files for a bucket path
  Future<List<StorageFile>?> getCachedFiles(String bucketId, String path);

  /// Cache storage statistics
  Future<void> cacheStats(String bucketId, StorageStats stats);

  /// Get cached storage statistics
  Future<StorageStats?> getCachedStats(String bucketId);

  /// Clear cache for a specific bucket
  Future<void> clearBucketCache(String bucketId);

  /// Clear all storage cache
  Future<void> clearAllCache();

  /// Check if cache is valid (not expired)
  bool isCacheValid(String key, Duration maxAge);
}

/// Abstract interface for upload progress tracking
abstract class IUploadProgressTracker {
  /// Start tracking upload progress
  void startTracking(String fileName);

  /// Update upload progress
  void updateProgress(String fileName, double progress, {int? uploadedBytes, int? totalBytes});

  /// Mark upload as complete
  void completeUpload(String fileName, {StorageFile? file});

  /// Mark upload as failed
  void failUpload(String fileName, String error);

  /// Get current progress for a file
  StorageUploadProgress? getProgress(String fileName);

  /// Get all active uploads
  List<StorageUploadProgress> getActiveUploads();

  /// Cancel upload tracking
  void cancelUpload(String fileName);

  /// Clear completed uploads
  void clearCompleted();
}

/// Abstract interface for storage events
abstract class IStorageEventHandler {
  /// Handle file uploaded event
  void onFileUploaded(StorageFile file);

  /// Handle file deleted event
  void onFileDeleted(String bucketId, String filePath);

  /// Handle file renamed event
  void onFileRenamed(String bucketId, String oldPath, String newPath);

  /// Handle file moved event
  void onFileMoved(String bucketId, String fromPath, String toPath);

  /// Handle folder created event
  void onFolderCreated(String bucketId, String folderPath);

  /// Handle upload progress event
  void onUploadProgress(String fileName, double progress);

  /// Handle upload error event
  void onUploadError(String fileName, String error);
}

/// Abstract interface for storage permissions
abstract class IStoragePermissions {
  /// Check if user can read from bucket
  Future<bool> canRead(String bucketId);

  /// Check if user can write to bucket
  Future<bool> canWrite(String bucketId);

  /// Check if user can delete from bucket
  Future<bool> canDelete(String bucketId);

  /// Check if user can create folders in bucket
  Future<bool> canCreateFolders(String bucketId);

  /// Check if user can manage bucket settings
  Future<bool> canManageBucket(String bucketId);

  /// Get allowed file types for bucket
  Future<List<String>?> getAllowedFileTypes(String bucketId);

  /// Get maximum file size for bucket
  Future<int?> getMaxFileSize(String bucketId);
}