/// Custom exception classes for the Wealth Store application
/// Provides structured error handling for different types of failures

abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message';
}

/// Authentication related exceptions
class AuthException extends AppException {
  const AuthException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory AuthException.invalidCredentials() => const AuthException(
        'Invalid email or password. Please check your credentials and try again.',
        code: 'invalid_credentials',
      );

  factory AuthException.userNotFound() => const AuthException(
        'No account found with this email address.',
        code: 'user_not_found',
      );

  factory AuthException.emailAlreadyInUse() => const AuthException(
        'An account with this email already exists.',
        code: 'email_already_in_use',
      );

  factory AuthException.weakPassword() => const AuthException(
        'Password is too weak. Please choose a stronger password.',
        code: 'weak_password',
      );

  factory AuthException.sessionExpired() => const AuthException(
        'Your session has expired. Please log in again.',
        code: 'session_expired',
      );

  factory AuthException.unauthorized() => const AuthException(
        'You are not authorized to perform this action.',
        code: 'unauthorized',
      );

  factory AuthException.adminAccessRequired() => const AuthException(
        'Admin access is required to perform this action.',
        code: 'admin_access_required',
      );
}

/// Network and connectivity related exceptions
class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory NetworkException.noConnection() => const NetworkException(
        'No internet connection. Please check your network and try again.',
        code: 'no_connection',
      );

  factory NetworkException.timeout() => const NetworkException(
        'Request timed out. Please try again.',
        code: 'timeout',
      );

  factory NetworkException.serverError() => const NetworkException(
        'Server error occurred. Please try again later.',
        code: 'server_error',
      );

  factory NetworkException.badRequest() => const NetworkException(
        'Invalid request. Please check your input and try again.',
        code: 'bad_request',
      );
}

/// Database related exceptions
class DatabaseException extends AppException {
  const DatabaseException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory DatabaseException.notFound(String entity) => DatabaseException(
        '$entity not found.',
        code: 'not_found',
      );

  factory DatabaseException.duplicateEntry(String field) => DatabaseException(
        'A record with this $field already exists.',
        code: 'duplicate_entry',
      );

  factory DatabaseException.constraintViolation() => const DatabaseException(
        'Operation violates database constraints.',
        code: 'constraint_violation',
      );

  factory DatabaseException.queryFailed() => const DatabaseException(
        'Database query failed. Please try again.',
        code: 'query_failed',
      );
}

/// Storage related exceptions
class StorageException extends AppException {
  const StorageException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory StorageException.uploadFailed() => const StorageException(
        'File upload failed. Please try again.',
        code: 'upload_failed',
      );

  factory StorageException.downloadFailed() => const StorageException(
        'File download failed. Please try again.',
        code: 'download_failed',
      );

  factory StorageException.fileNotFound() => const StorageException(
        'File not found.',
        code: 'file_not_found',
      );

  factory StorageException.fileTooLarge() => const StorageException(
        'File is too large. Please choose a smaller file.',
        code: 'file_too_large',
      );

  factory StorageException.invalidFileType() => const StorageException(
        'Invalid file type. Please choose a supported file format.',
        code: 'invalid_file_type',
      );

  factory StorageException.quotaExceeded() => const StorageException(
        'Storage quota exceeded. Please free up space and try again.',
        code: 'quota_exceeded',
      );
}

/// Validation related exceptions
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
    this.fieldErrors,
  });

  factory ValidationException.required(String field) => ValidationException(
        '$field is required.',
        code: 'required_field',
        fieldErrors: {field: '$field is required.'},
      );

  factory ValidationException.invalidFormat(String field) => ValidationException(
        'Invalid $field format.',
        code: 'invalid_format',
        fieldErrors: {field: 'Invalid $field format.'},
      );

  factory ValidationException.tooShort(String field, int minLength) => ValidationException(
        '$field must be at least $minLength characters long.',
        code: 'too_short',
        fieldErrors: {field: '$field must be at least $minLength characters long.'},
      );

  factory ValidationException.tooLong(String field, int maxLength) => ValidationException(
        '$field must be no more than $maxLength characters long.',
        code: 'too_long',
        fieldErrors: {field: '$field must be no more than $maxLength characters long.'},
      );

  factory ValidationException.multipleFields(Map<String, String> errors) => ValidationException(
        'Validation failed for multiple fields.',
        code: 'multiple_validation_errors',
        fieldErrors: errors,
      );
}

/// Business logic related exceptions
class BusinessException extends AppException {
  const BusinessException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory BusinessException.insufficientStock() => const BusinessException(
        'Insufficient stock available for this product.',
        code: 'insufficient_stock',
      );

  factory BusinessException.orderNotFound() => const BusinessException(
        'Order not found.',
        code: 'order_not_found',
      );

  factory BusinessException.invalidCoupon() => const BusinessException(
        'Invalid or expired coupon code.',
        code: 'invalid_coupon',
      );

  factory BusinessException.paymentFailed() => const BusinessException(
        'Payment processing failed. Please try again.',
        code: 'payment_failed',
      );

  factory BusinessException.productNotAvailable() => const BusinessException(
        'This product is currently not available.',
        code: 'product_not_available',
      );
}