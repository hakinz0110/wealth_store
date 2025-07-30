/// Comprehensive error handling models for storage operations
enum StorageErrorType {
  // Network errors
  networkTimeout,
  networkUnavailable,
  connectionLost,
  
  // Authentication errors
  unauthorized,
  sessionExpired,
  permissionDenied,
  
  // File operation errors
  fileNotFound,
  fileAlreadyExists,
  fileTooLarge,
  invalidFileType,
  invalidFileName,
  
  // Bucket errors
  bucketNotFound,
  bucketAccessDenied,
  bucketQuotaExceeded,
  
  // Upload errors
  uploadFailed,
  uploadCancelled,
  uploadTimeout,
  
  // Validation errors
  validationFailed,
  pathInvalid,
  
  // Server errors
  serverError,
  serviceUnavailable,
  rateLimitExceeded,
  
  // Unknown errors
  unknown,
}

/// Represents a storage operation error with context and recovery options
class StorageError {
  final StorageErrorType type;
  final String message;
  final String? technicalDetails;
  final String? context;
  final DateTime timestamp;
  final bool isRetryable;
  final Map<String, dynamic>? metadata;
  final Exception? originalException;

  const StorageError({
    required this.type,
    required this.message,
    this.technicalDetails,
    this.context,
    required this.timestamp,
    this.isRetryable = false,
    this.metadata,
    this.originalException,
  });

  factory StorageError.networkTimeout({
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    return StorageError(
      type: StorageErrorType.networkTimeout,
      message: 'The operation timed out. Please check your connection and try again.',
      technicalDetails: 'Network request exceeded timeout limit',
      context: context,
      timestamp: DateTime.now(),
      isRetryable: true,
      metadata: metadata,
    );
  }

  factory StorageError.networkUnavailable({
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    return StorageError(
      type: StorageErrorType.networkUnavailable,
      message: 'No internet connection available. Please check your network settings.',
      technicalDetails: 'Network connectivity not available',
      context: context,
      timestamp: DateTime.now(),
      isRetryable: true,
      metadata: metadata,
    );
  }

  factory StorageError.unauthorized({
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    return StorageError(
      type: StorageErrorType.unauthorized,
      message: 'You are not authorized to perform this action. Please log in again.',
      technicalDetails: 'Authentication required or invalid credentials',
      context: context,
      timestamp: DateTime.now(),
      isRetryable: false,
      metadata: metadata,
    );
  }

  factory StorageError.fileNotFound({
    String? fileName,
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    return StorageError(
      type: StorageErrorType.fileNotFound,
      message: fileName != null 
          ? 'File "$fileName" was not found. It may have been moved or deleted.'
          : 'The requested file was not found.',
      technicalDetails: 'File does not exist at specified path',
      context: context,
      timestamp: DateTime.now(),
      isRetryable: false,
      metadata: metadata,
    );
  }

  factory StorageError.fileTooLarge({
    String? fileName,
    int? maxSize,
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    final sizeText = maxSize != null ? _formatBytes(maxSize) : 'the allowed limit';
    return StorageError(
      type: StorageErrorType.fileTooLarge,
      message: fileName != null
          ? 'File "$fileName" is too large. Maximum size allowed is $sizeText.'
          : 'The file is too large. Maximum size allowed is $sizeText.',
      technicalDetails: 'File size exceeds bucket limit',
      context: context,
      timestamp: DateTime.now(),
      isRetryable: false,
      metadata: metadata,
    );
  }

  factory StorageError.invalidFileType({
    String? fileName,
    List<String>? allowedTypes,
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    final typesText = allowedTypes?.join(', ') ?? 'allowed types';
    return StorageError(
      type: StorageErrorType.invalidFileType,
      message: fileName != null
          ? 'File "$fileName" has an invalid type. Allowed types: $typesText.'
          : 'Invalid file type. Allowed types: $typesText.',
      technicalDetails: 'File MIME type not in allowed list',
      context: context,
      timestamp: DateTime.now(),
      isRetryable: false,
      metadata: metadata,
    );
  }

  factory StorageError.bucketQuotaExceeded({
    String? bucketName,
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    return StorageError(
      type: StorageErrorType.bucketQuotaExceeded,
      message: bucketName != null
          ? 'Storage quota exceeded for bucket "$bucketName". Please free up space or contact administrator.'
          : 'Storage quota exceeded. Please free up space or contact administrator.',
      technicalDetails: 'Bucket storage limit reached',
      context: context,
      timestamp: DateTime.now(),
      isRetryable: false,
      metadata: metadata,
    );
  }

  factory StorageError.uploadFailed({
    String? fileName,
    String? reason,
    String? context,
    Map<String, dynamic>? metadata,
    Exception? originalException,
  }) {
    return StorageError(
      type: StorageErrorType.uploadFailed,
      message: fileName != null
          ? 'Failed to upload "$fileName". ${reason ?? "Please try again."}'
          : 'Upload failed. ${reason ?? "Please try again."}',
      technicalDetails: reason ?? 'Upload operation failed',
      context: context,
      timestamp: DateTime.now(),
      isRetryable: true,
      metadata: metadata,
      originalException: originalException,
    );
  }

  factory StorageError.serverError({
    String? context,
    Map<String, dynamic>? metadata,
    Exception? originalException,
  }) {
    return StorageError(
      type: StorageErrorType.serverError,
      message: 'A server error occurred. Please try again later.',
      technicalDetails: 'Internal server error',
      context: context,
      timestamp: DateTime.now(),
      isRetryable: true,
      metadata: metadata,
      originalException: originalException,
    );
  }

  factory StorageError.fromException(
    Exception exception, {
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    final message = exception.toString();
    
    // Categorize based on exception message
    if (message.contains('timeout') || message.contains('TimeoutException')) {
      return StorageError.networkTimeout(context: context, metadata: metadata);
    }
    
    if (message.contains('SocketException') || message.contains('network')) {
      return StorageError.networkUnavailable(context: context, metadata: metadata);
    }
    
    if (message.contains('401') || message.contains('unauthorized')) {
      return StorageError.unauthorized(context: context, metadata: metadata);
    }
    
    if (message.contains('404') || message.contains('not found')) {
      return StorageError.fileNotFound(context: context, metadata: metadata);
    }
    
    if (message.contains('413') || message.contains('too large')) {
      return StorageError.fileTooLarge(context: context, metadata: metadata);
    }
    
    if (message.contains('500') || message.contains('server error')) {
      return StorageError.serverError(
        context: context,
        metadata: metadata,
        originalException: exception,
      );
    }
    
    // Default to unknown error
    return StorageError(
      type: StorageErrorType.unknown,
      message: 'An unexpected error occurred. Please try again.',
      technicalDetails: message,
      context: context,
      timestamp: DateTime.now(),
      isRetryable: true,
      metadata: metadata,
      originalException: exception,
    );
  }

  /// Get user-friendly error message with action suggestions
  String get userMessage {
    switch (type) {
      case StorageErrorType.networkTimeout:
      case StorageErrorType.networkUnavailable:
        return '$message\n\nTry:\n• Check your internet connection\n• Refresh the page\n• Try again in a moment';
      
      case StorageErrorType.unauthorized:
      case StorageErrorType.sessionExpired:
        return '$message\n\nTry:\n• Log out and log back in\n• Contact administrator if problem persists';
      
      case StorageErrorType.fileTooLarge:
        return '$message\n\nTry:\n• Compress the file\n• Use a smaller file\n• Contact administrator for limit increase';
      
      case StorageErrorType.invalidFileType:
        return '$message\n\nTry:\n• Convert to an allowed format\n• Check file extension\n• Contact administrator for format support';
      
      case StorageErrorType.bucketQuotaExceeded:
        return '$message\n\nTry:\n• Delete unused files\n• Move files to another bucket\n• Contact administrator for quota increase';
      
      default:
        return isRetryable 
            ? '$message\n\nTry:\n• Refresh and try again\n• Check your connection'
            : message;
    }
  }

  /// Get severity level for logging and display
  StorageErrorSeverity get severity {
    switch (type) {
      case StorageErrorType.networkTimeout:
      case StorageErrorType.networkUnavailable:
      case StorageErrorType.uploadCancelled:
        return StorageErrorSeverity.warning;
      
      case StorageErrorType.unauthorized:
      case StorageErrorType.sessionExpired:
      case StorageErrorType.permissionDenied:
      case StorageErrorType.serverError:
        return StorageErrorSeverity.error;
      
      case StorageErrorType.bucketQuotaExceeded:
      case StorageErrorType.rateLimitExceeded:
        return StorageErrorSeverity.critical;
      
      default:
        return StorageErrorSeverity.info;
    }
  }

  /// Create a copy with updated properties
  StorageError copyWith({
    StorageErrorType? type,
    String? message,
    String? technicalDetails,
    String? context,
    DateTime? timestamp,
    bool? isRetryable,
    Map<String, dynamic>? metadata,
    Exception? originalException,
  }) {
    return StorageError(
      type: type ?? this.type,
      message: message ?? this.message,
      technicalDetails: technicalDetails ?? this.technicalDetails,
      context: context ?? this.context,
      timestamp: timestamp ?? this.timestamp,
      isRetryable: isRetryable ?? this.isRetryable,
      metadata: metadata ?? this.metadata,
      originalException: originalException ?? this.originalException,
    );
  }

  @override
  String toString() {
    return 'StorageError(type: $type, message: $message, context: $context)';
  }
}

/// Error severity levels for categorization and handling
enum StorageErrorSeverity {
  info,
  warning,
  error,
  critical;

  String get displayName {
    switch (this) {
      case StorageErrorSeverity.info:
        return 'Info';
      case StorageErrorSeverity.warning:
        return 'Warning';
      case StorageErrorSeverity.error:
        return 'Error';
      case StorageErrorSeverity.critical:
        return 'Critical';
    }
  }
}

/// Helper function to format bytes
String _formatBytes(int bytes) {
  if (bytes < 1024) return '${bytes}B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
  if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
}