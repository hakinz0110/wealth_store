import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException, StorageException;
import 'package:gotrue/gotrue.dart' as gotrue;
import 'package:storage_client/storage_client.dart' as storage;
import 'app_exceptions.dart';

/// Centralized error handler for processing Supabase and other errors
/// Converts raw errors into user-friendly AppException instances
class ErrorHandler {
  /// Processes Supabase errors and converts them to appropriate AppExceptions
  static AppException handleSupabaseError(dynamic error, [StackTrace? stackTrace]) {
    // If already an AppException, return as is
    if (error is AppException) {
      return error;
    }
    
    if (error is gotrue.AuthException) {
      return _handleAuthError(error, stackTrace);
    } else if (error is PostgrestException) {
      return _handleDatabaseError(error, stackTrace);
    } else if (error is storage.StorageException) {
      return _handleStorageError(error, stackTrace);
    } else if (error.toString().contains('realtime')) {
      return _handleRealtimeError(error, stackTrace);
    } else if (error is SocketException) {
      return NetworkException.noConnection();
    } else if (error is TimeoutException) {
      return NetworkException.timeout();
    } else if (error is FormatException) {
      return ValidationException(
        'Invalid data format: ${error.message}',
        code: 'format_error',
        originalError: error,
        stackTrace: stackTrace,
      );
    } else if (error is HttpException) {
      return NetworkException(
        'HTTP error: ${error.message}',
        code: 'http_error',
        originalError: error,
        stackTrace: stackTrace,
      );
    } else if (error is ArgumentError) {
      return ValidationException(
        'Invalid argument: ${error.message}',
        code: 'invalid_argument',
        originalError: error,
        stackTrace: stackTrace,
      );
    } else if (error is StateError) {
      return BusinessException(
        'Invalid state: ${error.message}',
        code: 'state_error',
        originalError: error,
        stackTrace: stackTrace,
      );
    } else if (error is AssertionError) {
      return BusinessException(
        'Assertion failed: ${error.message}',
        code: 'assertion_error',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Generic error handling
    return BusinessException(
      'An unexpected error occurred: ${error.toString()}',
      code: 'unknown_error',
      originalError: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Handles Supabase Realtime errors
  static AppException _handleRealtimeError(dynamic error, StackTrace? stackTrace) {
    final message = error.message.toLowerCase();
    
    if (message.contains('connection closed')) {
      return NetworkException(
        'Realtime connection closed. Reconnecting...',
        code: 'realtime_connection_closed',
        originalError: error,
        stackTrace: stackTrace,
      );
    } else if (message.contains('timeout')) {
      return NetworkException(
        'Realtime connection timed out. Reconnecting...',
        code: 'realtime_timeout',
        originalError: error,
        stackTrace: stackTrace,
      );
    } else if (message.contains('unauthorized')) {
      return AuthException(
        'Unauthorized access to realtime channel',
        code: 'realtime_unauthorized',
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    return NetworkException(
      'Realtime error: ${error.message}',
      code: 'realtime_error',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Handles Supabase Auth errors
  static AppException _handleAuthError(gotrue.AuthException error, StackTrace? stackTrace) {
    final message = error.message.toLowerCase();
    
    if (message.contains('invalid login credentials') || 
        message.contains('invalid email or password')) {
      return AuthException.invalidCredentials();
    } else if (message.contains('user not found')) {
      return AuthException.userNotFound();
    } else if (message.contains('email already registered') || 
               message.contains('user already registered')) {
      return AuthException.emailAlreadyInUse();
    } else if (message.contains('password is too weak') || 
               message.contains('weak password')) {
      return AuthException.weakPassword();
    } else if (message.contains('session expired') || 
               message.contains('jwt expired')) {
      return AuthException.sessionExpired();
    } else if (message.contains('unauthorized') || 
               message.contains('access denied')) {
      return AuthException.unauthorized();
    }

    return AuthException(
      'Authentication error: ${error.message}',
      code: 'auth_error',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Handles Supabase Database (Postgrest) errors
  static AppException _handleDatabaseError(PostgrestException error, StackTrace? stackTrace) {
    final message = error.message.toLowerCase();
    final code = error.code;

    // Handle specific HTTP status codes
    switch (code) {
      case '404':
        return DatabaseException.notFound('Resource');
      case '409':
        return DatabaseException.duplicateEntry('field');
      case '400':
        return NetworkException.badRequest();
      case '500':
      case '502':
      case '503':
        return NetworkException.serverError();
    }

    // Handle specific error messages
    if (message.contains('not found')) {
      return DatabaseException.notFound('Record');
    } else if (message.contains('duplicate key') || 
               message.contains('unique constraint')) {
      return DatabaseException.duplicateEntry('value');
    } else if (message.contains('foreign key constraint') || 
               message.contains('check constraint')) {
      return DatabaseException.constraintViolation();
    } else if (message.contains('permission denied') || 
               message.contains('insufficient privileges')) {
      return AuthException.unauthorized();
    }

    return DatabaseException(
      'Database error: ${error.message}',
      code: error.code,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Handles Supabase Storage errors
  static AppException _handleStorageError(storage.StorageException error, StackTrace? stackTrace) {
    final message = error.message.toLowerCase();

    if (message.contains('file not found') || 
        message.contains('object not found')) {
      return StorageException.fileNotFound();
    } else if (message.contains('file too large') || 
               message.contains('payload too large')) {
      return StorageException.fileTooLarge();
    } else if (message.contains('invalid file type') || 
               message.contains('unsupported media type')) {
      return StorageException.invalidFileType();
    } else if (message.contains('quota exceeded') || 
               message.contains('storage limit')) {
      return StorageException.quotaExceeded();
    } else if (message.contains('upload failed')) {
      return StorageException.uploadFailed();
    } else if (message.contains('download failed')) {
      return StorageException.downloadFailed();
    }

    return StorageException(
      'Storage error: ${error.message}',
      code: 'storage_error',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Handles validation errors from form inputs
  static ValidationException handleValidationError(Map<String, dynamic> errors) {
    final fieldErrors = <String, String>{};
    
    errors.forEach((field, error) {
      if (error is List && error.isNotEmpty) {
        fieldErrors[field] = error.first.toString();
      } else {
        fieldErrors[field] = error.toString();
      }
    });

    return ValidationException.multipleFields(fieldErrors);
  }
  
  /// Validates a single field value
  static String? validateField(String field, dynamic value, {
    bool required = false,
    int? minLength,
    int? maxLength,
    Pattern? pattern,
    String? patternErrorMessage,
    List<String>? allowedValues,
  }) {
    // Check if required
    if (required && (value == null || (value is String && value.trim().isEmpty))) {
      return '$field is required';
    }
    
    // Skip other validations if value is null or empty
    if (value == null || (value is String && value.trim().isEmpty)) {
      return null;
    }
    
    // String-specific validations
    if (value is String) {
      // Check minimum length
      if (minLength != null && value.length < minLength) {
        return '$field must be at least $minLength characters';
      }
      
      // Check maximum length
      if (maxLength != null && value.length > maxLength) {
        return '$field must be no more than $maxLength characters';
      }
      
      // Check pattern match
      if (pattern != null && !RegExp(pattern.toString()).hasMatch(value)) {
        return patternErrorMessage ?? 'Invalid $field format';
      }
    }
    
    // Check allowed values
    if (allowedValues != null && !allowedValues.contains(value.toString())) {
      return '$field must be one of: ${allowedValues.join(", ")}';
    }
    
    return null;
  }
  
  /// Sanitizes user input to prevent XSS and injection attacks
  static String sanitizeInput(String input) {
    // Replace potentially dangerous HTML characters
    return input
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#x27;')
      .replaceAll('/', '&#x2F;');
  }

  /// Logs errors for debugging and monitoring
  static void logError(AppException error, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final errorData = {
      'timestamp': timestamp,
      'type': error.runtimeType.toString(),
      'message': error.message,
      'code': error.code,
      'context': context,
      'additionalData': additionalData,
    };
    
    // In debug mode, print detailed information
    if (kDebugMode) {
      print('ERROR LOG: $errorData');
      if (error.originalError != null) {
        print('Original Error: ${error.originalError}');
      }
      if (error.stackTrace != null) {
        print('Stack Trace: ${error.stackTrace}');
      }
    } else {
      // In production, log without stack trace for privacy
      print('ERROR: ${error.runtimeType} - ${error.message} - ${error.code}');
    }
    
    // TODO: In production, integrate with a proper logging service
    // like Firebase Crashlytics, Sentry, or a custom backend
  }

  /// Determines if an error is retryable
  static bool isRetryable(AppException error) {
    return error is NetworkException || 
           (error is DatabaseException && error.code == 'query_failed') ||
           (error is StorageException && 
            (error.code == 'upload_failed' || error.code == 'download_failed'));
  }

  /// Gets user-friendly error message for display
  static String getUserMessage(AppException error) {
    // Return the error message as it's already user-friendly
    return error.message;
  }
}

/// Extension to add error handling to Future operations
extension FutureErrorHandling<T> on Future<T> {
  /// Catches and converts errors to AppExceptions
  Future<T> handleErrors([String? context]) async {
    try {
      return await this;
    } catch (error, stackTrace) {
      final appError = ErrorHandler.handleSupabaseError(error, stackTrace);
      if (context != null) {
        ErrorHandler.logError(appError, context: context);
      }
      throw appError;
    }
  }
  
  /// Adds timeout to a future
  Future<T> withTimeout(Duration timeout, {String? timeoutMessage}) async {
    try {
      return await this.timeout(timeout);
    } on TimeoutException {
      throw NetworkException(
        timeoutMessage ?? 'Operation timed out after ${timeout.inSeconds} seconds',
        code: 'timeout',
      );
    }
  }
  
  /// Adds simple retry logic without using RetryHelper
  Future<T> withSimpleRetry({
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    dynamic lastError;
    
    while (attempts < maxAttempts) {
      try {
        return await this;
      } catch (error, stackTrace) {
        attempts++;
        lastError = ErrorHandler.handleSupabaseError(error, stackTrace);
        
        if (attempts >= maxAttempts) {
          ErrorHandler.logError(
            lastError,
            context: 'Simple retry failed after $attempts attempts',
          );
          rethrow;
        }
        
        await Future.delayed(delay);
      }
    }
    
    // This should never be reached due to the rethrow above
    throw lastError ?? BusinessException('Operation failed after $maxAttempts attempts');
  }
}