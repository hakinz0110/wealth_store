/// Constants for storage management feature
class StorageConstants {
  // File size limits (in bytes)
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  static const int maxVideoSize = 100 * 1024 * 1024; // 100MB
  static const int maxDocumentSize = 50 * 1024 * 1024; // 50MB
  static const int maxGeneralFileSize = 25 * 1024 * 1024; // 25MB
  
  // Allowed file types
  static const List<String> allowedImageTypes = [
    'jpg', 'jpeg', 'png', 'gif', 'webp', 'svg', 'bmp', 'tiff'
  ];
  
  static const List<String> allowedVideoTypes = [
    'mp4', 'avi', 'mov', 'wmv', 'flv', 'webm', 'mkv', '3gp', 'ogv'
  ];
  
  static const List<String> allowedDocumentTypes = [
    'pdf', 'doc', 'docx', 'txt', 'rtf', 'odt', 'xls', 'xlsx', 
    'ppt', 'pptx', 'csv', 'json', 'xml'
  ];
  
  static const List<String> allowedAudioTypes = [
    'mp3', 'wav', 'ogg', 'aac', 'flac', 'm4a', 'wma'
  ];
  
  // Default bucket names (from existing app constants)
  static const String productImagesBucket = 'product-images';
  static const String bannerImagesBucket = 'banner-images';
  static const String mediaBucket = 'media';
  static const String avatarsBucket = 'avatars';
  static const String documentsBucket = 'documents';
  
  // Additional buckets from Supabase
  static const String booksBucket = 'books';
  static const String clothingsBucket = 'clothings';
  static const String phonesBucket = 'phones';
  static const String categoryIconsBucket = 'category-icons';
  static const String customerAvatarsBucket = 'customer-avatars';
  static const String adminAvatarsBucket = 'admin-avatars';
  static const String projectImagesBucket = 'project-images';
  static const String brandLogosBucket = 'brand-logos';
  static const String userAvatarsBucket = 'user-avatars';
  
  // UI Constants
  static const int thumbnailSize = 200;
  static const int gridCrossAxisCount = 4;
  static const double gridChildAspectRatio = 1.0;
  static const double sidebarWidth = 280.0;
  static const double collapsedSidebarWidth = 60.0;
  
  // Pagination
  static const int defaultPageSize = 50;
  static const int maxPageSize = 200;
  
  // Performance optimization
  static const int virtualScrollingThreshold = 100; // Use virtual scrolling for lists with more than 100 items
  static const int thumbnailCacheSize = 500; // Maximum number of thumbnails to cache
  static const int maxConcurrentThumbnailLoads = 5;
  
  // Cache settings
  static const Duration cacheExpiration = Duration(minutes: 15);
  static const Duration statsRefreshInterval = Duration(minutes: 5);
  
  // Upload settings
  static const int maxConcurrentUploads = 3;
  static const int uploadChunkSize = 1024 * 1024; // 1MB chunks
  static const Duration uploadTimeout = Duration(minutes: 10);
  
  // Search settings
  static const int searchDebounceMs = 300;
  static const int maxSearchResults = 100;
  
  // File operation timeouts
  static const Duration deleteTimeout = Duration(seconds: 30);
  static const Duration renameTimeout = Duration(seconds: 15);
  static const Duration moveTimeout = Duration(seconds: 30);
  
  // Error messages
  static const String errorGeneric = 'An error occurred while performing the operation';
  static const String errorNetworkTimeout = 'Network timeout. Please check your connection';
  static const String errorFileNotFound = 'File not found';
  static const String errorPermissionDenied = 'Permission denied';
  static const String errorFileTooLarge = 'File size exceeds the maximum allowed limit';
  static const String errorInvalidFileType = 'File type is not allowed';
  static const String errorInvalidFileName = 'Invalid file name';
  static const String errorBucketNotFound = 'Storage bucket not found';
  static const String errorUploadFailed = 'File upload failed';
  static const String errorDeleteFailed = 'File deletion failed';
  static const String errorRenameFailed = 'File rename failed';
  static const String errorMoveFailed = 'File move failed';
  static const String errorFolderCreateFailed = 'Folder creation failed';
  
  // Success messages
  static const String successUpload = 'File uploaded successfully';
  static const String successDelete = 'File deleted successfully';
  static const String successRename = 'File renamed successfully';
  static const String successMove = 'File moved successfully';
  static const String successFolderCreate = 'Folder created successfully';
  static const String successUrlCopied = 'URL copied to clipboard';
  
  // File type icons (Material Icons)
  static const Map<String, String> fileTypeIcons = {
    'folder': 'folder',
    'image': 'image',
    'video': 'video_file',
    'document': 'description',
    'audio': 'audio_file',
    'pdf': 'picture_as_pdf',
    'zip': 'archive',
    'code': 'code',
    'other': 'insert_drive_file',
  };
  
  // MIME type mappings
  static const Map<String, String> mimeTypeMap = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'webp': 'image/webp',
    'svg': 'image/svg+xml',
    'bmp': 'image/bmp',
    'tiff': 'image/tiff',
    'mp4': 'video/mp4',
    'avi': 'video/x-msvideo',
    'mov': 'video/quicktime',
    'wmv': 'video/x-ms-wmv',
    'flv': 'video/x-flv',
    'webm': 'video/webm',
    'mkv': 'video/x-matroska',
    '3gp': 'video/3gpp',
    'pdf': 'application/pdf',
    'doc': 'application/msword',
    'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'txt': 'text/plain',
    'rtf': 'application/rtf',
    'odt': 'application/vnd.oasis.opendocument.text',
    'xls': 'application/vnd.ms-excel',
    'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'ppt': 'application/vnd.ms-powerpoint',
    'pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'csv': 'text/csv',
    'json': 'application/json',
    'xml': 'application/xml',
    'mp3': 'audio/mpeg',
    'wav': 'audio/wav',
    'ogg': 'audio/ogg',
    'aac': 'audio/aac',
    'flac': 'audio/flac',
    'm4a': 'audio/mp4',
    'wma': 'audio/x-ms-wma',
  };
  

  
  // Filter presets
  static const Map<String, Map<String, dynamic>> filterPresets = {
    'images': {
      'name': 'Images',
      'fileTypes': allowedImageTypes,
      'icon': 'image',
    },
    'videos': {
      'name': 'Videos',
      'fileTypes': allowedVideoTypes,
      'icon': 'video_file',
    },
    'documents': {
      'name': 'Documents',
      'fileTypes': allowedDocumentTypes,
      'icon': 'description',
    },
    'audio': {
      'name': 'Audio',
      'fileTypes': allowedAudioTypes,
      'icon': 'audio_file',
    },
    'large_files': {
      'name': 'Large Files (>10MB)',
      'minSize': 10 * 1024 * 1024,
      'icon': 'storage',
    },
    'recent': {
      'name': 'Recent (Last 7 days)',
      'uploadedAfter': 7, // days
      'icon': 'schedule',
    },
  };
  
  // Keyboard shortcuts
  static const Map<String, String> keyboardShortcuts = {
    'upload': 'Ctrl+U',
    'delete': 'Delete',
    'rename': 'F2',
    'selectAll': 'Ctrl+A',
    'copy': 'Ctrl+C',
    'paste': 'Ctrl+V',
    'refresh': 'F5',
    'search': 'Ctrl+F',
    'newFolder': 'Ctrl+Shift+N',
  };
  
  // Accessibility
  static const Map<String, String> accessibilityLabels = {
    'uploadButton': 'Upload files',
    'deleteButton': 'Delete selected files',
    'renameButton': 'Rename file',
    'createFolderButton': 'Create new folder',
    'searchInput': 'Search files and folders',
    'viewModeToggle': 'Toggle view mode',
    'sortButton': 'Sort files',
    'filterButton': 'Filter files',
    'refreshButton': 'Refresh file list',
    'backButton': 'Go back to parent folder',
    'homeButton': 'Go to bucket root',
  };
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  
  // Grid responsive settings
  static const Map<String, int> responsiveGridColumns = {
    'mobile': 2,
    'tablet': 3,
    'desktop': 4,
    'large': 6,
  };
}

// View modes
enum ViewMode {
  grid,
  list,
}

// Sort options
enum SortBy {
  name,
  size,
  dateCreated,
  dateModified,
  type,
}

enum SortOrder {
  ascending,
  descending,
}