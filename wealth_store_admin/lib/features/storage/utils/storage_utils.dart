import 'dart:io';
import 'dart:typed_data';
import '../models/storage_models.dart';
import '../constants/storage_constants.dart';

/// Utility functions for storage operations
class StorageUtils {
  /// Format file size in human-readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  /// Get file extension from filename
  static String getFileExtension(String fileName) {
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot == -1) return '';
    return fileName.substring(lastDot + 1).toLowerCase();
  }

  /// Get MIME type from file extension
  static String getMimeType(String fileName) {
    final extension = getFileExtension(fileName);
    return StorageConstants.mimeTypeMap[extension] ?? 'application/octet-stream';
  }

  /// Check if file is an image
  static bool isImageFile(String fileName) {
    final extension = getFileExtension(fileName);
    return StorageConstants.allowedImageTypes.contains(extension);
  }

  /// Check if file is a video
  static bool isVideoFile(String fileName) {
    final extension = getFileExtension(fileName);
    return StorageConstants.allowedVideoTypes.contains(extension);
  }

  /// Check if file is a document
  static bool isDocumentFile(String fileName) {
    final extension = getFileExtension(fileName);
    return StorageConstants.allowedDocumentTypes.contains(extension);
  }

  /// Check if file is an audio file
  static bool isAudioFile(String fileName) {
    final extension = getFileExtension(fileName);
    return StorageConstants.allowedAudioTypes.contains(extension);
  }

  /// Get file type from filename
  static StorageFileType getFileType(String fileName) {
    if (isImageFile(fileName)) return StorageFileType.image;
    if (isVideoFile(fileName)) return StorageFileType.video;
    if (isDocumentFile(fileName)) return StorageFileType.document;
    return StorageFileType.other;
  }

  /// Get appropriate icon for file type
  static String getFileIcon(StorageFileType fileType, {String? fileName}) {
    switch (fileType) {
      case StorageFileType.folder:
        return StorageConstants.fileTypeIcons['folder']!;
      case StorageFileType.image:
        return StorageConstants.fileTypeIcons['image']!;
      case StorageFileType.video:
        return StorageConstants.fileTypeIcons['video']!;
      case StorageFileType.document:
        if (fileName != null && getFileExtension(fileName) == 'pdf') {
          return StorageConstants.fileTypeIcons['pdf']!;
        }
        return StorageConstants.fileTypeIcons['document']!;
      case StorageFileType.other:
        if (fileName != null) {
          final extension = getFileExtension(fileName);
          if (StorageConstants.allowedAudioTypes.contains(extension)) {
            return StorageConstants.fileTypeIcons['audio']!;
          }
          if (['zip', 'rar', '7z', 'tar', 'gz'].contains(extension)) {
            return StorageConstants.fileTypeIcons['zip']!;
          }
          if (['js', 'ts', 'dart', 'py', 'java', 'cpp', 'c', 'html', 'css'].contains(extension)) {
            return StorageConstants.fileTypeIcons['code']!;
          }
        }
        return StorageConstants.fileTypeIcons['other']!;
    }
  }

  /// Validate file name
  static bool isValidFileName(String fileName) {
    if (fileName.isEmpty || fileName.length > 255) return false;
    
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
    return !reservedNames.contains(nameWithoutExt);
  }

  /// Sanitize file name for safe storage
  static String sanitizeFileName(String fileName) {
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
      final extension = getFileExtension(sanitized);
      final nameWithoutExt = sanitized.substring(0, sanitized.lastIndexOf('.'));
      final maxNameLength = 255 - extension.length - 1;
      sanitized = '${nameWithoutExt.substring(0, maxNameLength)}.$extension';
    }
    
    return sanitized;
  }

  /// Generate unique file name to avoid conflicts
  static String generateUniqueFileName(String originalName, List<String> existingNames) {
    if (!existingNames.contains(originalName)) {
      return originalName;
    }
    
    final extension = getFileExtension(originalName);
    final nameWithoutExt = originalName.substring(0, originalName.lastIndexOf('.'));
    
    int counter = 1;
    String newName;
    do {
      newName = extension.isEmpty 
          ? '${nameWithoutExt}_$counter'
          : '${nameWithoutExt}_$counter.$extension';
      counter++;
    } while (existingNames.contains(newName));
    
    return newName;
  }

  /// Parse file path into components
  static Map<String, String> parseFilePath(String filePath) {
    final parts = filePath.split('/');
    final fileName = parts.last;
    final directory = parts.length > 1 ? parts.sublist(0, parts.length - 1).join('/') : '';
    
    return {
      'directory': directory,
      'fileName': fileName,
      'fullPath': filePath,
    };
  }

  /// Build file path from components
  static String buildFilePath(String directory, String fileName) {
    if (directory.isEmpty) return fileName;
    return directory.endsWith('/') ? '$directory$fileName' : '$directory/$fileName';
  }

  /// Get parent directory from file path
  static String getParentDirectory(String filePath) {
    final parts = filePath.split('/');
    if (parts.length <= 1) return '';
    return parts.sublist(0, parts.length - 1).join('/');
  }

  /// Check if path is a subdirectory of another path
  static bool isSubdirectory(String path, String parentPath) {
    if (parentPath.isEmpty) return true;
    return path.startsWith('$parentPath/');
  }

  /// Get breadcrumb items from file path
  static List<Map<String, String>> getBreadcrumbs(String filePath) {
    final breadcrumbs = <Map<String, String>>[];
    
    // Add root
    breadcrumbs.add({
      'name': 'Root',
      'path': '',
    });
    
    if (filePath.isEmpty) return breadcrumbs;
    
    final parts = filePath.split('/');
    String currentPath = '';
    
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      
      currentPath = currentPath.isEmpty ? parts[i] : '$currentPath/${parts[i]}';
      breadcrumbs.add({
        'name': parts[i],
        'path': currentPath,
      });
    }
    
    return breadcrumbs;
  }

  /// Filter files based on search query and filters
  static List<StorageFile> filterFiles(
    List<StorageFile> files,
    StorageFilters filters,
  ) {
    return files.where((file) {
      // Search query filter
      if (filters.searchQuery?.isNotEmpty == true) {
        final query = filters.searchQuery!.toLowerCase();
        if (!file.name.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      // File type filter
      if (filters.fileType != null && file.fileType != filters.fileType) {
        return false;
      }
      
      // Date filters
      if (filters.uploadedAfter != null && file.createdAt.isBefore(filters.uploadedAfter!)) {
        return false;
      }
      
      if (filters.uploadedBefore != null && file.createdAt.isAfter(filters.uploadedBefore!)) {
        return false;
      }
      
      // Size filters
      if (filters.minSize != null && file.size < filters.minSize!) {
        return false;
      }
      
      if (filters.maxSize != null && file.size > filters.maxSize!) {
        return false;
      }
      
      return true;
    }).toList();
  }

  /// Sort files based on criteria
  static List<StorageFile> sortFiles(
    List<StorageFile> files,
    SortBy sortBy,
    SortOrder sortOrder,
  ) {
    final sortedFiles = List<StorageFile>.from(files);
    
    // Always put folders first
    sortedFiles.sort((a, b) {
      if (a.isFolder && !b.isFolder) return -1;
      if (!a.isFolder && b.isFolder) return 1;
      
      int comparison = 0;
      switch (sortBy) {
        case SortBy.name:
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case SortBy.size:
          comparison = a.size.compareTo(b.size);
          break;
        case SortBy.dateCreated:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case SortBy.dateModified:
          comparison = a.updatedAt.compareTo(b.updatedAt);
          break;
        case SortBy.type:
          comparison = a.fileType.name.compareTo(b.fileType.name);
          break;
      }
      
      return sortOrder == SortOrder.ascending ? comparison : -comparison;
    });
    
    return sortedFiles;
  }

  /// Calculate storage statistics from file list
  static StorageStats calculateStats(String bucketId, List<StorageFile> files) {
    final nonFolderFiles = files.where((f) => !f.isFolder).toList();
    final totalSize = nonFolderFiles.fold<int>(0, (sum, file) => sum + file.size);
    final averageSize = nonFolderFiles.isEmpty ? 0 : (totalSize / nonFolderFiles.length).round();
    
    final typeBreakdown = <StorageFileType, int>{};
    for (final file in nonFolderFiles) {
      typeBreakdown[file.fileType] = (typeBreakdown[file.fileType] ?? 0) + 1;
    }
    
    return StorageStats(
      bucketId: bucketId,
      totalFiles: nonFolderFiles.length,
      totalSize: totalSize,
      averageFileSize: averageSize,
      fileTypeBreakdown: typeBreakdown,
      lastUpdated: DateTime.now(),
    );
  }

  /// Check if file size is within limits for file type
  static bool isFileSizeValid(String fileName, int fileSize) {
    final fileType = getFileType(fileName);
    
    switch (fileType) {
      case StorageFileType.image:
        return fileSize <= StorageConstants.maxImageSize;
      case StorageFileType.video:
        return fileSize <= StorageConstants.maxVideoSize;
      case StorageFileType.document:
        return fileSize <= StorageConstants.maxDocumentSize;
      case StorageFileType.other:
        return fileSize <= StorageConstants.maxGeneralFileSize;
      case StorageFileType.folder:
        return true;
    }
  }

  /// Get maximum allowed file size for file type
  static int getMaxFileSize(String fileName) {
    final fileType = getFileType(fileName);
    
    switch (fileType) {
      case StorageFileType.image:
        return StorageConstants.maxImageSize;
      case StorageFileType.video:
        return StorageConstants.maxVideoSize;
      case StorageFileType.document:
        return StorageConstants.maxDocumentSize;
      case StorageFileType.other:
        return StorageConstants.maxGeneralFileSize;
      case StorageFileType.folder:
        return 0;
    }
  }

  /// Convert File to Uint8List
  static Future<Uint8List> fileToBytes(File file) async {
    return await file.readAsBytes();
  }

  /// Get file size from File object
  static Future<int> getFileSize(File file) async {
    return await file.length();
  }

  /// Extract file name from URL
  static String extractFileNameFromUrl(String url) {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    return pathSegments.isNotEmpty ? pathSegments.last : 'unknown';
  }

  /// Extract bucket name from Supabase storage URL
  static String? extractBucketFromUrl(String url) {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    
    // Supabase storage URL format: /storage/v1/object/public/{bucket}/{path}
    if (pathSegments.length >= 5 && 
        pathSegments[0] == 'storage' && 
        pathSegments[1] == 'v1' && 
        pathSegments[2] == 'object' && 
        pathSegments[3] == 'public') {
      return pathSegments[4];
    }
    
    return null;
  }

  /// Extract file path from Supabase storage URL
  static String? extractFilePathFromUrl(String url) {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    
    // Supabase storage URL format: /storage/v1/object/public/{bucket}/{path}
    if (pathSegments.length >= 6 && 
        pathSegments[0] == 'storage' && 
        pathSegments[1] == 'v1' && 
        pathSegments[2] == 'object' && 
        pathSegments[3] == 'public') {
      return pathSegments.skip(5).join('/');
    }
    
    return null;
  }

  /// Generate thumbnail URL for images (if supported by storage provider)
  static String? generateThumbnailUrl(String originalUrl, {int width = 200, int height = 200}) {
    // This would depend on the storage provider's thumbnail generation capabilities
    // For now, return the original URL for images
    if (originalUrl.contains('image')) {
      return originalUrl;
    }
    return null;
  }

  /// Check if two file paths are the same
  static bool isSamePath(String path1, String path2) {
    return path1.replaceAll('//', '/') == path2.replaceAll('//', '/');
  }

  /// Normalize file path (remove double slashes, etc.)
  static String normalizePath(String path) {
    return path.replaceAll(RegExp(r'/+'), '/').replaceAll(RegExp(r'^/|/$'), '');
  }
}