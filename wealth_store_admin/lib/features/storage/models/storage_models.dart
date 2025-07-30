import 'package:supabase_flutter/supabase_flutter.dart';

/// Represents a storage bucket with its configuration and metadata
class StorageBucket {
  final String id;
  final String name;
  final bool isPublic;
  final int? fileSizeLimit;
  final List<String>? allowedMimeTypes;
  final int fileCount;
  final int totalSize;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StorageBucket({
    required this.id,
    required this.name,
    required this.isPublic,
    this.fileSizeLimit,
    this.allowedMimeTypes,
    this.fileCount = 0,
    this.totalSize = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StorageBucket.fromSupabaseBucket(Bucket bucket) {
    return StorageBucket(
      id: bucket.id,
      name: bucket.name,
      isPublic: bucket.public,
      fileSizeLimit: bucket.fileSizeLimit,
      allowedMimeTypes: bucket.allowedMimeTypes,
      fileCount: 0, // Will be calculated separately
      totalSize: 0, // Will be calculated separately
      createdAt: DateTime.tryParse(bucket.createdAt.toString()) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(bucket.updatedAt.toString()) ?? DateTime.now(),
    );
  }

  StorageBucket copyWith({
    String? id,
    String? name,
    bool? isPublic,
    int? fileSizeLimit,
    List<String>? allowedMimeTypes,
    int? fileCount,
    int? totalSize,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StorageBucket(
      id: id ?? this.id,
      name: name ?? this.name,
      isPublic: isPublic ?? this.isPublic,
      fileSizeLimit: fileSizeLimit ?? this.fileSizeLimit,
      allowedMimeTypes: allowedMimeTypes ?? this.allowedMimeTypes,
      fileCount: fileCount ?? this.fileCount,
      totalSize: totalSize ?? this.totalSize,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get formatted file size limit
  String get formattedSizeLimit {
    if (fileSizeLimit == null) return 'No limit';
    if (fileSizeLimit! < 1024) return '${fileSizeLimit}B';
    if (fileSizeLimit! < 1024 * 1024) return '${(fileSizeLimit! / 1024).toStringAsFixed(1)}KB';
    if (fileSizeLimit! < 1024 * 1024 * 1024) return '${(fileSizeLimit! / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(fileSizeLimit! / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  /// Get formatted total size
  String get formattedTotalSize {
    if (totalSize < 1024) return '${totalSize}B';
    if (totalSize < 1024 * 1024) return '${(totalSize / 1024).toStringAsFixed(1)}KB';
    if (totalSize < 1024 * 1024 * 1024) return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(totalSize / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}

/// Represents a file or folder in storage
class StorageFile {
  final String id;
  final String name;
  final String bucketId;
  final String path;
  final int size;
  final String? mimeType;
  final String? publicUrl;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFolder;

  const StorageFile({
    required this.id,
    required this.name,
    required this.bucketId,
    required this.path,
    required this.size,
    this.mimeType,
    this.publicUrl,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.isFolder = false,
  });

  factory StorageFile.fromSupabaseFileObject(
    FileObject fileObject,
    String bucketId, {
    String? publicUrl,
  }) {
    return StorageFile(
      id: fileObject.id ?? fileObject.name,
      name: fileObject.name,
      bucketId: bucketId,
      path: fileObject.name,
      size: fileObject.metadata?['size'] ?? 0,
      mimeType: fileObject.metadata?['mimetype'],
      publicUrl: publicUrl,
      metadata: fileObject.metadata ?? {},
      createdAt: DateTime.tryParse(fileObject.createdAt?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(fileObject.updatedAt?.toString() ?? '') ?? DateTime.now(),
      isFolder: fileObject.metadata?['mimetype'] == null,
    );
  }

  StorageFile copyWith({
    String? id,
    String? name,
    String? bucketId,
    String? path,
    int? size,
    String? mimeType,
    String? publicUrl,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFolder,
  }) {
    return StorageFile(
      id: id ?? this.id,
      name: name ?? this.name,
      bucketId: bucketId ?? this.bucketId,
      path: path ?? this.path,
      size: size ?? this.size,
      mimeType: mimeType ?? this.mimeType,
      publicUrl: publicUrl ?? this.publicUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFolder: isFolder ?? this.isFolder,
    );
  }

  /// Get formatted file size
  String get formattedSize {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  /// Get file extension
  String get extension {
    if (isFolder) return '';
    return name.split('.').last.toLowerCase();
  }

  /// Check if file is an image
  bool get isImage {
    if (isFolder) return false;
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'];
    return imageExtensions.contains(extension);
  }

  /// Check if file is a video
  bool get isVideo {
    if (isFolder) return false;
    const videoExtensions = ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm'];
    return videoExtensions.contains(extension);
  }

  /// Check if file is a document
  bool get isDocument {
    if (isFolder) return false;
    const docExtensions = ['pdf', 'doc', 'docx', 'txt', 'rtf', 'odt'];
    return docExtensions.contains(extension);
  }

  /// Get file type for display
  StorageFileType get fileType {
    if (isFolder) return StorageFileType.folder;
    if (isImage) return StorageFileType.image;
    if (isVideo) return StorageFileType.video;
    if (isDocument) return StorageFileType.document;
    return StorageFileType.other;
  }
}

/// Enum for different file types
enum StorageFileType {
  folder,
  image,
  video,
  document,
  other;

  String get displayName {
    switch (this) {
      case StorageFileType.folder:
        return 'Folder';
      case StorageFileType.image:
        return 'Image';
      case StorageFileType.video:
        return 'Video';
      case StorageFileType.document:
        return 'Document';
      case StorageFileType.other:
        return 'File';
    }
  }
}

/// Storage statistics for a bucket or overall storage
class StorageStats {
  final String bucketId;
  final int totalFiles;
  final int totalSize;
  final int averageFileSize;
  final Map<StorageFileType, int> fileTypeBreakdown;
  final DateTime lastUpdated;

  const StorageStats({
    required this.bucketId,
    required this.totalFiles,
    required this.totalSize,
    required this.averageFileSize,
    required this.fileTypeBreakdown,
    required this.lastUpdated,
  });

  /// Get formatted total size
  String get formattedTotalSize {
    if (totalSize < 1024) return '${totalSize}B';
    if (totalSize < 1024 * 1024) return '${(totalSize / 1024).toStringAsFixed(1)}KB';
    if (totalSize < 1024 * 1024 * 1024) return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(totalSize / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  /// Get formatted average file size
  String get formattedAverageSize {
    if (averageFileSize < 1024) return '${averageFileSize}B';
    if (averageFileSize < 1024 * 1024) return '${(averageFileSize / 1024).toStringAsFixed(1)}KB';
    if (averageFileSize < 1024 * 1024 * 1024) return '${(averageFileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(averageFileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}

/// Upload progress tracking
class StorageUploadProgress {
  final String fileName;
  final double progress;
  final bool isComplete;
  final String? error;
  final int? uploadedBytes;
  final int? totalBytes;

  const StorageUploadProgress({
    required this.fileName,
    required this.progress,
    this.isComplete = false,
    this.error,
    this.uploadedBytes,
    this.totalBytes,
  });

  StorageUploadProgress copyWith({
    String? fileName,
    double? progress,
    bool? isComplete,
    String? error,
    int? uploadedBytes,
    int? totalBytes,
  }) {
    return StorageUploadProgress(
      fileName: fileName ?? this.fileName,
      progress: progress ?? this.progress,
      isComplete: isComplete ?? this.isComplete,
      error: error ?? this.error,
      uploadedBytes: uploadedBytes ?? this.uploadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
    );
  }

  /// Get formatted upload speed (if available)
  String get formattedSpeed {
    if (uploadedBytes == null || totalBytes == null) return '';
    final speed = uploadedBytes! / 1024; // KB/s (simplified)
    if (speed < 1024) return '${speed.toStringAsFixed(1)} KB/s';
    return '${(speed / 1024).toStringAsFixed(1)} MB/s';
  }
}

/// File operation result
class StorageOperationResult {
  final bool success;
  final String? error;
  final StorageFile? file;

  const StorageOperationResult({
    required this.success,
    this.error,
    this.file,
  });

  factory StorageOperationResult.success([StorageFile? file]) {
    return StorageOperationResult(
      success: true,
      file: file,
    );
  }

  factory StorageOperationResult.error(String error) {
    return StorageOperationResult(
      success: false,
      error: error,
    );
  }
}

/// Search and filter options for storage files
class StorageFilters {
  final String? searchQuery;
  final StorageFileType? fileType;
  final DateTime? uploadedAfter;
  final DateTime? uploadedBefore;
  final int? minSize;
  final int? maxSize;
  final String? bucketId;

  const StorageFilters({
    this.searchQuery,
    this.fileType,
    this.uploadedAfter,
    this.uploadedBefore,
    this.minSize,
    this.maxSize,
    this.bucketId,
  });

  StorageFilters copyWith({
    String? searchQuery,
    StorageFileType? fileType,
    DateTime? uploadedAfter,
    DateTime? uploadedBefore,
    int? minSize,
    int? maxSize,
    String? bucketId,
  }) {
    return StorageFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      fileType: fileType ?? this.fileType,
      uploadedAfter: uploadedAfter ?? this.uploadedAfter,
      uploadedBefore: uploadedBefore ?? this.uploadedBefore,
      minSize: minSize ?? this.minSize,
      maxSize: maxSize ?? this.maxSize,
      bucketId: bucketId ?? this.bucketId,
    );
  }

  /// Check if any filters are active
  bool get hasActiveFilters {
    return searchQuery?.isNotEmpty == true ||
        fileType != null ||
        uploadedAfter != null ||
        uploadedBefore != null ||
        minSize != null ||
        maxSize != null;
  }
}