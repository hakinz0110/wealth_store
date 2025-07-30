import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../shared/utils/logger.dart';
import '../shared/utils/error_handler.dart';
import '../shared/constants/app_constants.dart';

class StorageService {
  // File size limits (in bytes)
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  
  // Allowed file types
  static const List<String> allowedImageTypes = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];

  /// Validate file type and size
  void _validateFile(File file, {List<String>? allowedTypes, int? maxSize}) {
    final fileExtension = path.extension(file.path).toLowerCase();
    final fileSize = file.lengthSync();
    
    // Check file type
    if (allowedTypes != null && !allowedTypes.contains(fileExtension)) {
      throw Exception(
        'File type $fileExtension is not allowed. Allowed types: ${allowedTypes.join(', ')}'
      );
    }
    
    // Check file size
    if (maxSize != null && fileSize > maxSize) {
      final maxSizeMB = (maxSize / (1024 * 1024)).toStringAsFixed(1);
      final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(1);
      throw Exception(
        'File size ${fileSizeMB}MB exceeds maximum allowed size of ${maxSizeMB}MB'
      );
    }
  }

  /// Upload a file to a specific bucket with validation
  Future<String> uploadFile({
    required String bucketName,
    required File file,
    required String fileName,
    String? folder,
    List<String>? allowedTypes,
    int? maxSize,
  }) async {
    try {
      Logger.info('Uploading file: $fileName to bucket: $bucketName');
      
      // Validate file
      _validateFile(file, allowedTypes: allowedTypes, maxSize: maxSize);
      
      final fileExtension = path.extension(file.path);
      final storagePath = folder != null 
          ? '$folder/${fileName}_${DateTime.now().millisecondsSinceEpoch}$fileExtension'
          : '${fileName}_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      
      // Upload file
      await SupabaseService.storage.from(bucketName).upload(
        storagePath,
        file,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: false,
        ),
      );
      
      // Get public URL
      final publicUrl = SupabaseService.storage.from(bucketName).getPublicUrl(storagePath);
      
      Logger.info('File uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e, stackTrace) {
      ErrorHandler.logError('Upload file', e, stackTrace);
      rethrow;
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
  }) async {
    try {
      Logger.info('Uploading binary data: $fileName to bucket: $bucketName');
      
      // Check file size
      if (maxSize != null && data.length > maxSize) {
        final maxSizeMB = (maxSize / (1024 * 1024)).toStringAsFixed(1);
        final dataSizeMB = (data.length / (1024 * 1024)).toStringAsFixed(1);
        throw Exception(
          'Data size ${dataSizeMB}MB exceeds maximum allowed size of ${maxSizeMB}MB'
        );
      }
      
      final storagePath = folder != null 
          ? '$folder/${fileName}_${DateTime.now().millisecondsSinceEpoch}'
          : '${fileName}_${DateTime.now().millisecondsSinceEpoch}';
      
      await SupabaseService.storage.from(bucketName).uploadBinary(
        storagePath,
        data,
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: false,
          contentType: contentType,
        ),
      );
      
      // Get public URL
      final publicUrl = SupabaseService.storage.from(bucketName).getPublicUrl(storagePath);
      
      Logger.info('Binary data uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e, stackTrace) {
      ErrorHandler.logError('Upload binary data', e, stackTrace);
      rethrow;
    }
  }

  /// Upload a banner image with validation
  Future<String> uploadBannerImage(
    File image, 
    String bannerTitle,
  ) async {
    final sanitizedName = bannerTitle.toLowerCase().replaceAll(' ', '_').replaceAll(RegExp(r'[^a-z0-9_]'), '');
    return uploadFile(
      bucketName: AppConstants.bannerImagesBucket,
      file: image,
      fileName: 'banner_$sanitizedName',
      allowedTypes: allowedImageTypes,
      maxSize: maxImageSize,
    );
  }

  /// Upload a product image with validation
  Future<String> uploadProductImage(
    File image, 
    String productName,
  ) async {
    final sanitizedName = productName.toLowerCase().replaceAll(' ', '_').replaceAll(RegExp(r'[^a-z0-9_]'), '');
    return uploadFile(
      bucketName: AppConstants.productImagesBucket,
      file: image,
      fileName: 'product_$sanitizedName',
      allowedTypes: allowedImageTypes,
      maxSize: maxImageSize,
    );
  }

  /// Delete a file from storage
  Future<void> deleteFile(String bucketName, String filePath) async {
    try {
      Logger.info('Deleting file: $filePath from bucket: $bucketName');
      
      // Extract the file path from the URL if it's a full URL
      String actualPath = filePath;
      if (filePath.startsWith('http')) {
        final uri = Uri.parse(filePath);
        final pathSegments = uri.pathSegments;
        if (pathSegments.length >= 3) {
          // Remove '/storage/v1/object/public/bucket-name/' part
          actualPath = pathSegments.skip(4).join('/');
        }
      }
      
      await SupabaseService.storage.from(bucketName).remove([actualPath]);
      Logger.info('File deleted successfully: $actualPath');
    } catch (e, stackTrace) {
      ErrorHandler.logError('Delete file', e, stackTrace);
      rethrow;
    }
  }

  /// List all files in a bucket or folder
  Future<List<FileObject>> listFiles(String bucketName, {String? folder}) async {
    try {
      Logger.info('Listing files in bucket: $bucketName, folder: $folder');
      return await SupabaseService.storage.from(bucketName).list(path: folder);
    } catch (e, stackTrace) {
      ErrorHandler.logError('List files', e, stackTrace);
      rethrow;
    }
  }

  /// Check if a file exists in storage
  Future<bool> fileExists(String bucketName, String filePath) async {
    try {
      final files = await listFiles(bucketName);
      return files.any((file) => file.name == filePath);
    } catch (e) {
      Logger.warning('Failed to check file existence: $filePath', e);
      return false;
    }
  }
}