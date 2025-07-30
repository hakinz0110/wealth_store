import '../core/storage_base.dart';
import '../models/storage_models.dart';
import '../constants/storage_constants.dart';
import '../utils/storage_utils.dart';
import '../../../shared/utils/logger.dart';

/// Concrete implementation of file validator
class StorageFileValidator extends FileValidatorBase {
  final Map<String, List<String>>? _bucketAllowedTypes;
  final Map<String, int>? _bucketMaxSizes;

  StorageFileValidator({
    Map<String, List<String>>? bucketAllowedTypes,
    Map<String, int>? bucketMaxSizes,
  }) : _bucketAllowedTypes = bucketAllowedTypes,
       _bucketMaxSizes = bucketMaxSizes;

  @override
  bool validateFileType(String fileName, List<String>? allowedTypes) {
    // Use provided allowed types or fall back to general validation
    final typesToCheck = allowedTypes ?? _getAllowedTypesForFile(fileName);
    return super.validateFileType(fileName, typesToCheck);
  }

  @override
  bool validateFileSize(int fileSize, int? maxSize) {
    // Use provided max size or fall back to default limits
    final sizeToCheck = maxSize ?? _getDefaultMaxSize(fileSize);
    return super.validateFileSize(fileSize, sizeToCheck);
  }

  /// Validate file for specific bucket
  bool validateFileForBucket(String fileName, int fileSize, String bucketId) {
    try {
      // Check bucket-specific allowed types
      final bucketAllowedTypes = _bucketAllowedTypes?[bucketId];
      if (!validateFileType(fileName, bucketAllowedTypes)) {
        Logger.warning('File type validation failed for $fileName in bucket $bucketId');
        return false;
      }

      // Check bucket-specific size limits
      final bucketMaxSize = _bucketMaxSizes?[bucketId];
      if (!validateFileSize(fileSize, bucketMaxSize)) {
        Logger.warning('File size validation failed for $fileName in bucket $bucketId');
        return false;
      }

      return true;
    } catch (e) {
      Logger.error('File validation error for $fileName in bucket $bucketId', e);
      return false;
    }
  }

  /// Get validation errors for a file
  List<String> getValidationErrors(String fileName, int fileSize, {String? bucketId}) {
    final errors = <String>[];

    // Validate file name
    if (!validateFileName(fileName)) {
      errors.add('Invalid file name: $fileName');
    }

    // Validate file type
    final allowedTypes = bucketId != null 
        ? _bucketAllowedTypes?[bucketId] 
        : _getAllowedTypesForFile(fileName);
    
    if (!validateFileType(fileName, allowedTypes)) {
      final typesStr = allowedTypes?.join(', ') ?? 'any';
      errors.add('File type not allowed. Allowed types: $typesStr');
    }

    // Validate file size
    final maxSize = bucketId != null 
        ? _bucketMaxSizes?[bucketId] 
        : StorageUtils.getMaxFileSize(fileName);
    
    if (!validateFileSize(fileSize, maxSize)) {
      final maxSizeMB = maxSize != null ? (maxSize / (1024 * 1024)).toStringAsFixed(1) : 'unlimited';
      final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(1);
      errors.add('File size ${fileSizeMB}MB exceeds maximum allowed size of ${maxSizeMB}MB');
    }

    return errors;
  }

  /// Check if file is safe to upload (security validation)
  bool isFileSafe(String fileName, {List<int>? fileBytes}) {
    try {
      // Check for potentially dangerous file extensions
      const dangerousExtensions = [
        'exe', 'bat', 'cmd', 'com', 'pif', 'scr', 'vbs', 'js', 'jar',
        'app', 'deb', 'pkg', 'rpm', 'dmg', 'iso', 'msi', 'run'
      ];
      
      final extension = StorageUtils.getFileExtension(fileName).toLowerCase();
      if (dangerousExtensions.contains(extension)) {
        Logger.warning('Potentially dangerous file extension detected: $extension');
        return false;
      }

      // Check for suspicious file names
      const suspiciousPatterns = [
        'autorun', 'desktop.ini', 'thumbs.db', '.htaccess', 'web.config'
      ];
      
      final lowerFileName = fileName.toLowerCase();
      for (final pattern in suspiciousPatterns) {
        if (lowerFileName.contains(pattern)) {
          Logger.warning('Suspicious file name pattern detected: $pattern');
          return false;
        }
      }

      // Additional byte-level validation could be added here
      if (fileBytes != null) {
        return _validateFileBytes(fileBytes, extension);
      }

      return true;
    } catch (e) {
      Logger.error('File safety validation error for $fileName', e);
      return false;
    }
  }

  /// Validate file content matches its extension
  bool _validateFileBytes(List<int> bytes, String extension) {
    if (bytes.isEmpty) return false;

    // Check file signatures (magic numbers)
    final signature = bytes.take(8).toList();
    
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return signature.length >= 2 && signature[0] == 0xFF && signature[1] == 0xD8;
      
      case 'png':
        return signature.length >= 8 && 
               signature[0] == 0x89 && signature[1] == 0x50 && 
               signature[2] == 0x4E && signature[3] == 0x47;
      
      case 'gif':
        return signature.length >= 6 && 
               signature[0] == 0x47 && signature[1] == 0x49 && signature[2] == 0x46;
      
      case 'pdf':
        return signature.length >= 4 && 
               signature[0] == 0x25 && signature[1] == 0x50 && 
               signature[2] == 0x44 && signature[3] == 0x46;
      
      case 'zip':
        return signature.length >= 4 && 
               signature[0] == 0x50 && signature[1] == 0x4B;
      
      default:
        // For other file types, we'll trust the extension for now
        return true;
    }
  }

  /// Get allowed file types based on file characteristics
  List<String>? _getAllowedTypesForFile(String fileName) {
    final fileType = StorageUtils.getFileType(fileName);
    
    switch (fileType) {
      case StorageFileType.image:
        return StorageConstants.allowedImageTypes;
      case StorageFileType.video:
        return StorageConstants.allowedVideoTypes;
      case StorageFileType.document:
        return StorageConstants.allowedDocumentTypes;
      case StorageFileType.other:
        // Check if it's an audio file
        final extension = StorageUtils.getFileExtension(fileName);
        if (StorageConstants.allowedAudioTypes.contains(extension)) {
          return StorageConstants.allowedAudioTypes;
        }
        return null; // Allow any type for 'other'
      case StorageFileType.folder:
        return null; // Folders don't have file type restrictions
    }
  }

  /// Get default max size based on file size (fallback)
  int? _getDefaultMaxSize(int fileSize) {
    // This is a fallback - normally we'd determine by file type
    if (fileSize <= StorageConstants.maxImageSize) return StorageConstants.maxImageSize;
    if (fileSize <= StorageConstants.maxDocumentSize) return StorageConstants.maxDocumentSize;
    if (fileSize <= StorageConstants.maxVideoSize) return StorageConstants.maxVideoSize;
    return StorageConstants.maxVideoSize; // Maximum allowed
  }

  /// Create validator with bucket-specific rules
  static StorageFileValidator createWithBucketRules() {
    return StorageFileValidator(
      bucketAllowedTypes: {
        StorageConstants.productImagesBucket: StorageConstants.allowedImageTypes,
        StorageConstants.bannerImagesBucket: StorageConstants.allowedImageTypes,
        StorageConstants.avatarsBucket: StorageConstants.allowedImageTypes,
        StorageConstants.documentsBucket: StorageConstants.allowedDocumentTypes,
        StorageConstants.mediaBucket: [
          ...StorageConstants.allowedImageTypes,
          ...StorageConstants.allowedVideoTypes,
          ...StorageConstants.allowedAudioTypes,
        ],
      },
      bucketMaxSizes: {
        StorageConstants.productImagesBucket: StorageConstants.maxImageSize,
        StorageConstants.bannerImagesBucket: StorageConstants.maxImageSize,
        StorageConstants.avatarsBucket: StorageConstants.maxImageSize,
        StorageConstants.documentsBucket: StorageConstants.maxDocumentSize,
        StorageConstants.mediaBucket: StorageConstants.maxVideoSize,
      },
    );
  }

  /// Validate multiple files at once
  Map<String, List<String>> validateFiles(Map<String, int> files, {String? bucketId}) {
    final results = <String, List<String>>{};
    
    for (final entry in files.entries) {
      final fileName = entry.key;
      final fileSize = entry.value;
      results[fileName] = getValidationErrors(fileName, fileSize, bucketId: bucketId);
    }
    
    return results;
  }

  /// Get file type restrictions for a bucket
  List<String>? getBucketAllowedTypes(String bucketId) {
    return _bucketAllowedTypes?[bucketId];
  }

  /// Get size limit for a bucket
  int? getBucketMaxSize(String bucketId) {
    return _bucketMaxSizes?[bucketId];
  }

  /// Check if bucket has specific restrictions
  bool hasBucketRestrictions(String bucketId) {
    return _bucketAllowedTypes?.containsKey(bucketId) == true ||
           _bucketMaxSizes?.containsKey(bucketId) == true;
  }
}