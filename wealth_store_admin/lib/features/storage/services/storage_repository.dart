import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/supabase_service.dart';
import '../interfaces/storage_interfaces.dart';
import '../models/storage_models.dart';
import '../core/storage_base.dart';
import '../utils/storage_utils.dart';
import '../constants/storage_constants.dart';
import '../../../shared/utils/logger.dart';
import '../../../shared/utils/error_handler.dart';

/// Concrete implementation of storage repository using Supabase
class SupabaseStorageRepository extends StorageBase {
  final SupabaseStorageClient _storage;
  
  SupabaseStorageRepository({
    required IFileValidator fileValidator,
    IStorageCache? cache,
    IUploadProgressTracker? progressTracker,
    IStorageEventHandler? eventHandler,
  }) : _storage = SupabaseService.storage,
       super(
         fileValidator: fileValidator,
         cache: cache,
         progressTracker: progressTracker,
         eventHandler: eventHandler,
       );

  @override
  Future<List<StorageBucket>> getBuckets() async {
    try {
      logOperation('getBuckets', 'Fetching all storage buckets');
      
      // Check cache first
      if (cache != null) {
        final cachedBuckets = await cache!.getCachedBuckets();
        if (cachedBuckets != null) {
          logOperation('getBuckets', 'Returning cached buckets: ${cachedBuckets.length}');
          return cachedBuckets;
        }
      }
      
      logOperation('getBuckets', 'Attempting to list buckets from Supabase...');
      final buckets = await _storage.listBuckets();
      logOperation('getBuckets', 'Raw buckets from Supabase: ${buckets.length}');
      
      final storageBuckets = <StorageBucket>[];
      
      for (final bucket in buckets) {
        try {
          logOperation('getBuckets', 'Processing bucket: ${bucket.id}');
          
          // Get basic stats for each bucket (with timeout to prevent hanging)
          final files = await _storage.from(bucket.id).list().timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              Logger.warning('Timeout listing files for bucket ${bucket.id}');
              return <FileObject>[];
            },
          );
          
          logOperation('getBuckets', 'Found ${files.length} files in bucket ${bucket.id}');
          
          final stats = StorageUtils.calculateStats(bucket.id, 
            files.map((f) => StorageFile.fromSupabaseFileObject(f, bucket.id)).toList());
          
          final storageBucket = StorageBucket.fromSupabaseBucket(bucket).copyWith(
            fileCount: stats.totalFiles,
            totalSize: stats.totalSize,
          );
          
          storageBuckets.add(storageBucket);
          logOperation('getBuckets', 'Successfully processed bucket: ${bucket.id}');
        } catch (e) {
          // If we can't get stats for a bucket, still include it with zero stats
          Logger.warning('Failed to get stats for bucket ${bucket.id}', e);
          final storageBucket = StorageBucket.fromSupabaseBucket(bucket);
          storageBuckets.add(storageBucket);
          logOperation('getBuckets', 'Added bucket ${bucket.id} with zero stats due to error');
        }
      }
      
      // Cache the results
      if (cache != null) {
        await cache!.cacheBuckets(storageBuckets);
      }
      
      logOperation('getBuckets', 'Successfully fetched ${storageBuckets.length} buckets');
      return storageBuckets;
    } catch (e, stackTrace) {
      return handleError('getBuckets', e, stackTrace).success 
          ? <StorageBucket>[] 
          : throw StorageException('Failed to fetch buckets: ${e.toString()}');
    }
  }

  @override
  Future<List<StorageFile>> getFiles(String bucketId, {String? path}) async {
    try {
      final cleanPath = path?.isEmpty == true ? null : path;
      logOperation('getFiles', 'Fetching files from bucket: $bucketId, path: $cleanPath');
      
      // Check cache first
      if (cache != null) {
        final cachedFiles = await cache!.getCachedFiles(bucketId, cleanPath ?? '');
        if (cachedFiles != null) {
          logOperation('getFiles', 'Returning cached files: ${cachedFiles.length}');
          return cachedFiles;
        }
      }
      
      final fileObjects = await _storage.from(bucketId).list(path: cleanPath);
      final storageFiles = <StorageFile>[];
      
      for (final fileObject in fileObjects) {
        try {
          String? publicUrl;
          
          // Generate public URL for files (not folders)
          if (fileObject.metadata?['mimetype'] != null) {
            final filePath = cleanPath != null 
                ? '$cleanPath/${fileObject.name}'
                : fileObject.name;
            publicUrl = _storage.from(bucketId).getPublicUrl(filePath);
          }
          
          final storageFile = StorageFile.fromSupabaseFileObject(
            fileObject, 
            bucketId,
            publicUrl: publicUrl,
          );
          
          storageFiles.add(storageFile);
        } catch (e) {
          Logger.warning('Failed to process file object: ${fileObject.name}', e);
          // Continue processing other files
        }
      }
      
      // Cache the results
      if (cache != null) {
        await cache!.cacheFiles(bucketId, cleanPath ?? '', storageFiles);
      }
      
      logOperation('getFiles', 'Successfully fetched ${storageFiles.length} files');
      return storageFiles;
    } catch (e, stackTrace) {
      return handleError('getFiles', e, stackTrace).success 
          ? <StorageFile>[] 
          : throw StorageException('Failed to fetch files: ${e.toString()}');
    }
  }

  @override
  Future<StorageOperationResult> uploadFile({
    required String bucketId,
    required String fileName,
    required Uint8List fileBytes,
    String? path,
    String? mimeType,
    Map<String, dynamic>? metadata,
  }) async {
    final context = StorageOperationContext(
      type: StorageOperationType.upload,
      bucketId: bucketId,
      path: path,
      fileName: fileName,
      metadata: metadata ?? {},
    );
    
    try {
      logOperation('uploadFile', 'Uploading file: $fileName to bucket: $bucketId');
      
      // Start progress tracking
      startUploadTracking(fileName);
      
      // Validate file
      validateFileForUpload(
        fileName: fileName,
        fileSize: fileBytes.length,
        allowedTypes: null, // Will be validated by file validator
        maxSize: StorageUtils.getMaxFileSize(fileName),
      );
      
      // Generate sanitized file path
      final sanitizedFileName = fileValidator.sanitizeFileName(fileName);
      final storagePath = getSanitizedPath(path, sanitizedFileName);
      
      // Determine MIME type if not provided
      final finalMimeType = mimeType ?? StorageUtils.getMimeType(fileName);
      
      // Track upload progress (start)
      trackUploadProgress(fileName, 0.1);
      
      // Upload file to Supabase
      await _storage.from(bucketId).uploadBinary(
        storagePath,
        fileBytes,
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: false,
          contentType: finalMimeType,
        ),
      );
      
      // Track upload progress (complete)
      trackUploadProgress(fileName, 1.0, uploadedBytes: fileBytes.length, totalBytes: fileBytes.length);
      
      // Get public URL
      final publicUrl = _storage.from(bucketId).getPublicUrl(storagePath);
      
      // Create storage file object
      final storageFile = StorageFile(
        id: storagePath,
        name: sanitizedFileName,
        bucketId: bucketId,
        path: storagePath,
        size: fileBytes.length,
        mimeType: finalMimeType,
        publicUrl: publicUrl,
        metadata: metadata ?? {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFolder: false,
      );
      
      // Complete upload tracking
      completeUploadTracking(fileName, file: storageFile);
      
      // Update cache
      await updateCacheAfterOperation('upload', bucketId, path: path, file: storageFile);
      
      // Notify event handlers
      notifyEventHandlers('fileUploaded', bucketId, file: storageFile);
      
      logOperation('uploadFile', 'Successfully uploaded file: $fileName');
      return StorageOperationResult.success(storageFile);
    } catch (e, stackTrace) {
      failUploadTracking(fileName, e.toString());
      return handleError('uploadFile', e, stackTrace);
    }
  }

  @override
  Future<StorageOperationResult> uploadFileFromPath({
    required String bucketId,
    required String fileName,
    required File file,
    String? path,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      logOperation('uploadFileFromPath', 'Uploading file from path: ${file.path}');
      
      // Read file bytes
      final fileBytes = await StorageUtils.fileToBytes(file);
      
      // Get MIME type from file extension
      final mimeType = StorageUtils.getMimeType(fileName);
      
      // Use the main upload method
      return await uploadFile(
        bucketId: bucketId,
        fileName: fileName,
        fileBytes: fileBytes,
        path: path,
        mimeType: mimeType,
        metadata: metadata,
      );
    } catch (e, stackTrace) {
      return handleError('uploadFileFromPath', e, stackTrace);
    }
  }

  @override
  Future<StorageOperationResult> deleteFile(String bucketId, String filePath) async {
    try {
      logOperation('deleteFile', 'Deleting file: $filePath from bucket: $bucketId');
      
      // Delete file from Supabase
      await _storage.from(bucketId).remove([filePath]);
      
      // Update cache
      await updateCacheAfterOperation('delete', bucketId, path: filePath);
      
      // Notify event handlers
      notifyEventHandlers('fileDeleted', bucketId, filePath: filePath);
      
      logOperation('deleteFile', 'Successfully deleted file: $filePath');
      return StorageOperationResult.success();
    } catch (e, stackTrace) {
      return handleError('deleteFile', e, stackTrace);
    }
  }

  @override
  Future<StorageOperationResult> renameFile(
    String bucketId,
    String oldPath,
    String newPath,
  ) async {
    try {
      logOperation('renameFile', 'Renaming file from $oldPath to $newPath in bucket: $bucketId');
      
      // Supabase doesn't have a direct rename operation, so we need to copy and delete
      await _storage.from(bucketId).copy(oldPath, newPath);
      await _storage.from(bucketId).remove([oldPath]);
      
      // Update cache
      await updateCacheAfterOperation('rename', bucketId, path: oldPath);
      
      // Notify event handlers
      notifyEventHandlers('fileRenamed', bucketId, oldPath: oldPath, newPath: newPath);
      
      logOperation('renameFile', 'Successfully renamed file from $oldPath to $newPath');
      return StorageOperationResult.success();
    } catch (e, stackTrace) {
      return handleError('renameFile', e, stackTrace);
    }
  }

  @override
  Future<StorageOperationResult> moveFile(
    String bucketId,
    String fromPath,
    String toPath,
  ) async {
    try {
      logOperation('moveFile', 'Moving file from $fromPath to $toPath in bucket: $bucketId');
      
      // Supabase doesn't have a direct move operation, so we need to copy and delete
      await _storage.from(bucketId).copy(fromPath, toPath);
      await _storage.from(bucketId).remove([fromPath]);
      
      // Update cache
      await updateCacheAfterOperation('move', bucketId, path: fromPath);
      
      // Notify event handlers
      notifyEventHandlers('fileMoved', bucketId, oldPath: fromPath, newPath: toPath);
      
      logOperation('moveFile', 'Successfully moved file from $fromPath to $toPath');
      return StorageOperationResult.success();
    } catch (e, stackTrace) {
      return handleError('moveFile', e, stackTrace);
    }
  }

  @override
  Future<StorageOperationResult> createFolder(
    String bucketId,
    String folderPath,
  ) async {
    try {
      logOperation('createFolder', 'Creating folder: $folderPath in bucket: $bucketId');
      
      // Supabase doesn't have explicit folder creation, but we can create a placeholder file
      // that represents the folder structure
      final placeholderPath = folderPath.endsWith('/') 
          ? '${folderPath}.gitkeep' 
          : '$folderPath/.gitkeep';
      
      await _storage.from(bucketId).uploadBinary(
        placeholderPath,
        Uint8List.fromList([]), // Empty file
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: false,
          contentType: 'text/plain',
        ),
      );
      
      // Update cache
      await updateCacheAfterOperation('createFolder', bucketId, path: folderPath);
      
      // Notify event handlers
      notifyEventHandlers('folderCreated', bucketId, filePath: folderPath);
      
      logOperation('createFolder', 'Successfully created folder: $folderPath');
      return StorageOperationResult.success();
    } catch (e, stackTrace) {
      return handleError('createFolder', e, stackTrace);
    }
  }

  @override
  String getPublicUrl(String bucketId, String filePath) {
    try {
      return _storage.from(bucketId).getPublicUrl(filePath);
    } catch (e) {
      Logger.warning('Failed to get public URL for $bucketId/$filePath', e);
      return '';
    }
  }

  @override
  Future<StorageStats> getBucketStats(String bucketId) async {
    try {
      logOperation('getBucketStats', 'Calculating stats for bucket: $bucketId');
      
      // Check cache first
      if (cache != null) {
        final cachedStats = await cache!.getCachedStats(bucketId);
        if (cachedStats != null && 
            cache!.isCacheValid('stats_$bucketId', StorageConstants.statsRefreshInterval)) {
          logOperation('getBucketStats', 'Returning cached stats for bucket: $bucketId');
          return cachedStats;
        }
      }
      
      // Get all files in the bucket (recursively)
      final files = await _getAllFilesRecursively(bucketId);
      final stats = StorageUtils.calculateStats(bucketId, files);
      
      // Cache the results
      if (cache != null) {
        await cache!.cacheStats(bucketId, stats);
      }
      
      logOperation('getBucketStats', 'Successfully calculated stats for bucket: $bucketId');
      return stats;
    } catch (e, stackTrace) {
      Logger.error('Failed to get bucket stats for $bucketId', e, stackTrace);
      // Return empty stats instead of throwing
      return StorageStats(
        bucketId: bucketId,
        totalFiles: 0,
        totalSize: 0,
        averageFileSize: 0,
        fileTypeBreakdown: {},
        lastUpdated: DateTime.now(),
      );
    }
  }

  @override
  Future<List<StorageFile>> searchFiles(
    StorageFilters filters, {
    String? bucketId,
  }) async {
    try {
      logOperation('searchFiles', 'Searching files with filters in bucket: $bucketId');
      
      final allFiles = <StorageFile>[];
      
      if (bucketId != null) {
        // Search in specific bucket
        final files = await _getAllFilesRecursively(bucketId);
        allFiles.addAll(files);
      } else {
        // Search across all buckets
        final buckets = await getBuckets();
        for (final bucket in buckets) {
          try {
            final files = await _getAllFilesRecursively(bucket.id);
            allFiles.addAll(files);
          } catch (e) {
            Logger.warning('Failed to search in bucket ${bucket.id}', e);
            // Continue with other buckets
          }
        }
      }
      
      // Apply filters
      final filteredFiles = StorageUtils.filterFiles(allFiles, filters);
      
      // Limit results to prevent performance issues
      final limitedResults = filteredFiles.take(StorageConstants.maxSearchResults).toList();
      
      logOperation('searchFiles', 'Found ${limitedResults.length} files matching filters');
      return limitedResults;
    } catch (e, stackTrace) {
      Logger.error('Failed to search files', e, stackTrace);
      return <StorageFile>[];
    }
  }

  /// Helper method to get all files recursively from a bucket
  Future<List<StorageFile>> _getAllFilesRecursively(String bucketId, {String? path}) async {
    final allFiles = <StorageFile>[];
    
    try {
      final files = await getFiles(bucketId, path: path);
      
      for (final file in files) {
        if (file.isFolder) {
          // Recursively get files from subdirectories
          final subFiles = await _getAllFilesRecursively(bucketId, path: file.path);
          allFiles.addAll(subFiles);
        } else {
          allFiles.add(file);
        }
      }
    } catch (e) {
      Logger.warning('Failed to get files recursively from $bucketId/$path', e);
    }
    
    return allFiles;
  }

  /// Check if bucket exists
  Future<bool> bucketExists(String bucketId) async {
    try {
      final buckets = await _storage.listBuckets();
      return buckets.any((bucket) => bucket.id == bucketId);
    } catch (e) {
      Logger.warning('Failed to check if bucket exists: $bucketId', e);
      return false;
    }
  }

  /// Get bucket information
  Future<StorageBucket?> getBucket(String bucketId) async {
    try {
      final buckets = await getBuckets();
      return buckets.firstWhere(
        (bucket) => bucket.id == bucketId,
        orElse: () => throw StateError('Bucket not found'),
      );
    } catch (e) {
      Logger.warning('Failed to get bucket: $bucketId', e);
      return null;
    }
  }

  /// Batch delete files
  Future<List<StorageOperationResult>> deleteFiles(
    String bucketId,
    List<String> filePaths,
  ) async {
    final results = <StorageOperationResult>[];
    
    try {
      // Supabase supports batch delete
      await _storage.from(bucketId).remove(filePaths);
      
      // Create success results for all files
      for (final filePath in filePaths) {
        results.add(StorageOperationResult.success());
        notifyEventHandlers('fileDeleted', bucketId, filePath: filePath);
      }
      
      // Update cache
      await updateCacheAfterOperation('delete', bucketId);
      
      logOperation('deleteFiles', 'Successfully deleted ${filePaths.length} files');
    } catch (e, stackTrace) {
      Logger.error('Batch delete failed for bucket $bucketId', e, stackTrace);
      
      // Create error results for all files
      for (final filePath in filePaths) {
        results.add(StorageOperationResult.error('Failed to delete $filePath: ${e.toString()}'));
      }
    }
    
    return results;
  }
}