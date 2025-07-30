import 'dart:io';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:wealth_app/core/services/supabase_service.dart';
import 'package:wealth_app/core/utils/app_exceptions.dart';

part 'storage_service.g.dart';

class StorageService {
  final SupabaseClient _client;

  StorageService(this._client);

  // File size limits (in bytes)
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxDocumentSize = 10 * 1024 * 1024; // 10MB
  
  // Allowed file types
  static const List<String> allowedImageTypes = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
  static const List<String> allowedDocumentTypes = ['.pdf', '.doc', '.docx', '.txt'];
  static const List<String> allowedVideoTypes = ['.mp4', '.mov', '.avi', '.mkv'];

  // Available buckets from the screenshots
  static const String productImagesBucket = 'product-images';
  static const String categoryIconsBucket = 'category-icons';
  static const String customerAvatarsBucket = 'customer-avatars';
  static const String adminAvatarsBucket = 'admin-avatars';

  /// Validate file type and size
  void _validateFile(File file, {List<String>? allowedTypes, int? maxSize}) {
    final fileExtension = path.extension(file.path).toLowerCase();
    final fileSize = file.lengthSync();
    
    // Check file type
    if (allowedTypes != null && !allowedTypes.contains(fileExtension)) {
      throw ValidationException(
        'File type $fileExtension is not allowed. Allowed types: ${allowedTypes.join(', ')}'
      );
    }
    
    // Check file size
    if (maxSize != null && fileSize > maxSize) {
      final maxSizeMB = (maxSize / (1024 * 1024)).toStringAsFixed(1);
      final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(1);
      throw ValidationException(
        'File size ${fileSizeMB}MB exceeds maximum allowed size of ${maxSizeMB}MB'
      );
    }
  }

  /// Upload a file to a specific bucket with validation and progress tracking
  Future<String> uploadFile({
    required String bucketName,
    required File file,
    required String fileName,
    String? folder,
    List<String>? allowedTypes,
    int? maxSize,
    void Function(double progress)? onProgress,
  }) async {
    try {
      // Validate file
      _validateFile(file, allowedTypes: allowedTypes, maxSize: maxSize);
      
      final fileExtension = path.extension(file.path);
      final storagePath = folder != null 
          ? '$folder/${fileName}_${DateTime.now().millisecondsSinceEpoch}$fileExtension'
          : '${fileName}_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      
      // Upload with progress tracking
      await _client.storage.from(bucketName).upload(
        storagePath,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      
      // Simulate progress for now (Supabase doesn't provide built-in progress tracking)
      if (onProgress != null) {
        onProgress(1.0); // 100% complete
      }
      
      return await getPublicUrl(bucketName, storagePath);
    } catch (e) {
      if (e is ValidationException) {
        rethrow;
      }
      throw NetworkException('Failed to upload file: $e');
    }
  }

  /// Upload binary data to a specific bucket
  Future<String> uploadBinary({
    required String bucketName,
    required Uint8List data,
    required String fileName,
    String? folder,
    String contentType = 'application/octet-stream',
    int? maxSize,
    void Function(double progress)? onProgress,
  }) async {
    try {
      // Check file size
      if (maxSize != null && data.length > maxSize) {
        final maxSizeMB = (maxSize / (1024 * 1024)).toStringAsFixed(1);
        final dataSizeMB = (data.length / (1024 * 1024)).toStringAsFixed(1);
        throw ValidationException(
          'Data size ${dataSizeMB}MB exceeds maximum allowed size of ${maxSizeMB}MB'
        );
      }
      
      final storagePath = folder != null 
          ? '$folder/${fileName}_${DateTime.now().millisecondsSinceEpoch}'
          : '${fileName}_${DateTime.now().millisecondsSinceEpoch}';
      
      await _client.storage.from(bucketName).uploadBinary(
        storagePath,
        data,
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: false,
          contentType: contentType,
        ),
      );
      
      // Simulate progress for now
      if (onProgress != null) {
        onProgress(1.0); // 100% complete
      }
      
      return await getPublicUrl(bucketName, storagePath);
    } catch (e) {
      if (e is ValidationException) {
        rethrow;
      }
      throw NetworkException('Failed to upload binary data: $e');
    }
  }

  /// Download a file from storage
  Future<Uint8List> downloadFile(String bucketName, String filePath) async {
    try {
      final response = await _client.storage.from(bucketName).download(filePath);
      return response;
    } catch (e) {
      throw NetworkException('Failed to download file: $e');
    }
  }

  /// Upload a product image with validation
  Future<String> uploadProductImage(
    File image, 
    String productName, {
    void Function(double progress)? onProgress,
  }) async {
    final sanitizedName = productName.toLowerCase().replaceAll(' ', '_');
    return uploadFile(
      bucketName: productImagesBucket,
      file: image,
      fileName: sanitizedName,
      allowedTypes: allowedImageTypes,
      maxSize: maxImageSize,
      onProgress: onProgress,
    );
  }

  /// Upload a category icon with validation
  Future<String> uploadCategoryIcon(
    File image, 
    String categoryName, {
    void Function(double progress)? onProgress,
  }) async {
    final sanitizedName = categoryName.toLowerCase().replaceAll(' ', '_');
    return uploadFile(
      bucketName: categoryIconsBucket,
      file: image,
      fileName: sanitizedName,
      allowedTypes: allowedImageTypes,
      maxSize: maxImageSize,
      onProgress: onProgress,
    );
  }

  /// Upload a customer avatar with validation
  Future<String> uploadCustomerAvatar(
    File image, 
    String userId, {
    void Function(double progress)? onProgress,
  }) async {
    return uploadFile(
      bucketName: customerAvatarsBucket,
      file: image,
      fileName: userId,
      allowedTypes: allowedImageTypes,
      maxSize: maxImageSize,
      onProgress: onProgress,
    );
  }

  /// Get a public URL for a file
  Future<String> getPublicUrl(String bucketName, String filePath) async {
    try {
      final url = _client.storage.from(bucketName).getPublicUrl(filePath);
      return url;
    } catch (e) {
      throw NetworkException('Failed to get public URL: $e');
    }
  }

  /// Delete a file from storage
  Future<void> deleteFile(String bucketName, String filePath) async {
    try {
      await _client.storage.from(bucketName).remove([filePath]);
    } catch (e) {
      throw NetworkException('Failed to delete file: $e');
    }
  }

  /// Delete multiple files from storage
  Future<void> deleteFiles(String bucketName, List<String> filePaths) async {
    try {
      await _client.storage.from(bucketName).remove(filePaths);
    } catch (e) {
      throw NetworkException('Failed to delete files: $e');
    }
  }

  /// List all files in a bucket or folder
  Future<List<FileObject>> listFiles(String bucketName, {String? folder}) async {
    try {
      return await _client.storage.from(bucketName).list(path: folder);
    } catch (e) {
      throw NetworkException('Failed to list files: $e');
    }
  }

  /// Check if a file exists in storage
  Future<bool> fileExists(String bucketName, String filePath) async {
    try {
      final files = await listFiles(bucketName);
      return files.any((file) => file.name == filePath);
    } catch (e) {
      return false;
    }
  }

  /// Get file metadata
  Future<FileObject?> getFileMetadata(String bucketName, String filePath) async {
    try {
      final files = await listFiles(bucketName);
      return files.firstWhere(
        (file) => file.name == filePath,
        orElse: () => throw Exception('File not found'),
      );
    } catch (e) {
      throw NetworkException('Failed to get file metadata: $e');
    }
  }
}

@riverpod
StorageService storageService(StorageServiceRef ref) {
  return StorageService(ref.watch(supabaseProvider));
} 