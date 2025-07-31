import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_exceptions.dart';

/// Centralized error handler for converting various error types to AppExceptions
/// and providing user-friendly error messages
class ErrorHandler {
  /// Convert any error to an appropriate AppException
  static AppException handleError(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppException) {
      return error;
    }
    
    // Handle Supabase specific errors
    if (error is AuthException) {
      return _handleAuthException(error, stackTrace);
    }
    
    if (error is PostgrestException) {
      return _handlePostgrestException(error, stackTrace);
    }
    
    if (error is StorageException) {
      return _handleStorageException(error, stackTrace);
    }
    
    // Handle network errors
    if (error is SocketException) {
      return NetworkException(
        'No internet connection. Please check your network and try again.',
        code: 'NETWORK_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    if (error is HttpException) {
      return NetworkException(
        'Network error occurred. Please try again.',
        code: 'HTTP_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    // Handle timeout errors
    if (error is TimeoutException) {
      return NetworkException(
        'Request timed out. Please check your connection and try again.',
        code: 'TIMEOUT_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    // Handle format exceptions (JSON parsing, etc.)
    if (error is FormatException) {
      return DatabaseException(
        'Data format error. Please try again or contact support.',
        code: 'FORMAT_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    // Handle argument errors (validation)
    if (error is ArgumentError) {
      return ValidationException(
        'Invalid input provided: ${error.message}',
        code: 'VALIDATION_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    // Handle state errors
    if (error is StateError) {
      return BusinessLogicException(
        'Operation cannot be performed in current state: ${error.message}',
        code: 'STATE_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    // Handle assertion errors
    if (error is AssertionError) {
      return BusinessLogicException(
        'Assertion failed: ${error.message}',
        code: 'ASSERTION_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    // Default to generic network exception
    return NetworkException(
      'An unexpected error occurred. Please try again.',
      code: 'UNKNOWN_ERROR',
      originalError: error,
      stackTrace: stackTrace,
    );
  }
  
  // RealtimeError handling removed as it's deprecated in newer Supabase versions
  
  /// Handle Supabase Auth exceptions
  static AppException _handleAuthException(
    AuthException error, 
    StackTrace? stackTrace,
  ) {
    final message = _getAuthErrorMessage(error.message);
    return AuthenticationException(
      message,
      code: error.statusCode,
      originalError: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Handle Supabase Postgrest (database) exceptions
  static AppException _handlePostgrestException(
    PostgrestException error, 
    StackTrace? stackTrace,
  ) {
    // Check for specific error codes
    switch (error.code) {
      case 'PGRST116': // No rows found
        return NotFoundException(
          'Resource',
          code: error.code,
          originalError: error,
          stackTrace: stackTrace,
        );
      
      case 'PGRST301': // Row level security violation
        return AuthorizationException(
          'Access denied. You do not have permission to perform this action.',
          code: error.code,
          originalError: error,
          stackTrace: stackTrace,
        );
      
      case '23505': // Unique constraint violation
        return ValidationException(
          'This item already exists. Please use a different value.',
          code: error.code,
          originalError: error,
          stackTrace: stackTrace,
        );
      
      case '23503': // Foreign key constraint violation
        return ValidationException(
          'Cannot perform this action due to related data constraints.',
          code: error.code,
          originalError: error,
          stackTrace: stackTrace,
        );
      
      case '23502': // Not null constraint violation
        return ValidationException(
          'Required information is missing. Please fill in all required fields.',
          code: error.code,
          originalError: error,
          stackTrace: stackTrace,
        );
      
      default:
        // Check if it's a server error (5xx)
        if (error.code?.startsWith('5') == true) {
          return ServerException(
            'Server error occurred. Please try again later.',
            code: error.code,
            originalError: error,
            stackTrace: stackTrace,
          );
        }
        
        return DatabaseException(
          error.message.isNotEmpty 
            ? error.message 
            : 'Database operation failed. Please try again.',
          code: error.code,
          originalError: error,
          stackTrace: stackTrace,
        );
    }
  }
  
  /// Handle Supabase Storage exceptions
  static AppException _handleStorageException(
    StorageException error, 
    StackTrace? stackTrace,
  ) {
    String message;
    
    // Common storage error messages
    if (error.message.contains('not found')) {
      message = 'File not found.';
    } else if (error.message.contains('too large')) {
      message = 'File is too large. Please choose a smaller file.';
    } else if (error.message.contains('invalid file type')) {
      message = 'Invalid file type. Please choose a supported file format.';
    } else if (error.message.contains('permission')) {
      message = 'Permission denied. You do not have access to this file.';
    } else if (error.message.contains('quota')) {
      message = 'Storage quota exceeded. Please free up space or contact support.';
    } else {
      message = 'File operation failed. Please try again.';
    }
    
    return NetworkException(
      message,
      code: error.statusCode,
      originalError: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Get user-friendly authentication error messages
  static String _getAuthErrorMessage(String originalMessage) {
    final lowerMessage = originalMessage.toLowerCase();
    
    if (lowerMessage.contains('invalid login credentials') || 
        lowerMessage.contains('invalid email or password')) {
      return 'Invalid email or password. Please check your credentials and try again.';
    }
    
    if (lowerMessage.contains('email not confirmed')) {
      return 'Please check your email and click the confirmation link before signing in.';
    }
    
    if (lowerMessage.contains('user not found')) {
      return 'No account found with this email address. Please contact your administrator.';
    }
    
    if (lowerMessage.contains('weak password')) {
      return 'Password is too weak. Please choose a stronger password with at least 8 characters.';
    }
    
    if (lowerMessage.contains('email already registered') || 
        lowerMessage.contains('user already registered')) {
      return 'An account with this email already exists.';
    }
    
    if (lowerMessage.contains('signup disabled')) {
      return 'New account registration is currently disabled. Please contact your administrator.';
    }
    
    if (lowerMessage.contains('email rate limit')) {
      return 'Too many email requests. Please wait a few minutes before trying again.';
    }
    
    if (lowerMessage.contains('password reset')) {
      return 'Password reset failed. Please try again or contact your administrator.';
    }
    
    if (lowerMessage.contains('token expired') || lowerMessage.contains('jwt expired')) {
      return 'Your session has expired. Please sign in again.';
    }
    
    if (lowerMessage.contains('access denied') || lowerMessage.contains('unauthorized')) {
      return 'Access denied. You do not have admin privileges.';
    }
    
    if (lowerMessage.contains('admin privileges required')) {
      return 'Access denied. This account does not have admin privileges.';
    }
    
    // Return original message if no specific handling found
    return originalMessage.isNotEmpty 
      ? originalMessage 
      : 'Authentication failed. Please try again.';
  }
  
  /// Get user-friendly error message from any AppException
  static String getUserFriendlyMessage(AppException exception) {
    // Return the message as it's already user-friendly
    return exception.message;
  }
  
  /// Check if error is retryable
  static bool isRetryable(AppException exception) {
    return exception is NetworkException ||
           exception is ServerException ||
           (exception is DatabaseException && 
            exception.code?.startsWith('5') == true);
  }
  
  /// Get retry delay based on error type
  static Duration getRetryDelay(AppException exception, int attemptCount) {
    // Exponential backoff with jitter
    final baseDelay = Duration(seconds: 2);
    final exponentialDelay = baseDelay * (1 << (attemptCount - 1));
    final maxDelay = Duration(seconds: 30);
    
    // Add some jitter to prevent thundering herd
    final jitter = Duration(milliseconds: (DateTime.now().millisecond % 1000));
    
    final totalDelay = exponentialDelay + jitter;
    return totalDelay > maxDelay ? maxDelay : totalDelay;
  }
  
  /// Log error for debugging/monitoring
  static void logError(AppException exception, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    // In production, this should integrate with a proper logging service
    // For now, we'll use print statements
    
    final timestamp = DateTime.now().toIso8601String();
    final logData = {
      'timestamp': timestamp,
      'type': exception.runtimeType.toString(),
      'message': exception.message,
      'code': exception.code,
      'context': context,
      'additionalData': additionalData,
    };
    
    // In debug mode, print detailed information
    if (kDebugMode) {
      print('ADMIN ERROR LOG: $logData');
      if (exception.originalError != null) {
        print('Original Error: ${exception.originalError}');
      }
      if (exception.stackTrace != null) {
        print('Stack Trace: ${exception.stackTrace}');
      }
    } else {
      // In production, log without stack trace for privacy
      print('ADMIN ERROR: ${exception.runtimeType} - ${exception.message} - ${exception.code}');
    }
    
    // TODO: Integrate with proper logging service like Firebase Crashlytics,
    // Sentry, or custom logging backend
  }
  
  /// Validates form input with detailed rules
  static ValidationException? validateForm(Map<String, dynamic> formData, Map<String, dynamic> rules) {
    final errors = <String, List<String>>{};
    
    rules.forEach((field, fieldRules) {
      final value = formData[field];
      final fieldErrors = <String>[];
      
      if (fieldRules['required'] == true && (value == null || value.toString().trim().isEmpty)) {
        fieldErrors.add('${fieldRules['label'] ?? field} is required');
      }
      
      // Skip other validations if value is null or empty
      if (value != null && value.toString().trim().isNotEmpty) {
        // Validate minimum length
        if (fieldRules['minLength'] != null && value.toString().length < fieldRules['minLength']) {
          fieldErrors.add('${fieldRules['label'] ?? field} must be at least ${fieldRules['minLength']} characters');
        }
        
        // Validate maximum length
        if (fieldRules['maxLength'] != null && value.toString().length > fieldRules['maxLength']) {
          fieldErrors.add('${fieldRules['label'] ?? field} must be no more than ${fieldRules['maxLength']} characters');
        }
        
        // Validate pattern
        if (fieldRules['pattern'] != null) {
          final pattern = RegExp(fieldRules['pattern']);
          if (!pattern.hasMatch(value.toString())) {
            fieldErrors.add(fieldRules['patternError'] ?? 'Invalid ${fieldRules['label'] ?? field} format');
          }
        }
        
        // Validate email
        if (fieldRules['isEmail'] == true) {
          final emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
          if (!emailPattern.hasMatch(value.toString())) {
            fieldErrors.add('Please enter a valid email address');
          }
        }
        
        // Validate numeric
        if (fieldRules['isNumeric'] == true) {
          if (double.tryParse(value.toString()) == null) {
            fieldErrors.add('${fieldRules['label'] ?? field} must be a number');
          }
        }
        
        // Validate integer
        if (fieldRules['isInteger'] == true) {
          if (int.tryParse(value.toString()) == null) {
            fieldErrors.add('${fieldRules['label'] ?? field} must be a whole number');
          }
        }
        
        // Validate minimum value
        if (fieldRules['min'] != null) {
          final numValue = double.tryParse(value.toString());
          if (numValue != null && numValue < fieldRules['min']) {
            fieldErrors.add('${fieldRules['label'] ?? field} must be at least ${fieldRules['min']}');
          }
        }
        
        // Validate maximum value
        if (fieldRules['max'] != null) {
          final numValue = double.tryParse(value.toString());
          if (numValue != null && numValue > fieldRules['max']) {
            fieldErrors.add('${fieldRules['label'] ?? field} must be no more than ${fieldRules['max']}');
          }
        }
        
        // Validate allowed values
        if (fieldRules['allowedValues'] != null) {
          if (!fieldRules['allowedValues'].contains(value)) {
            fieldErrors.add('${fieldRules['label'] ?? field} must be one of: ${fieldRules['allowedValues'].join(', ')}');
          }
        }
        
        // Custom validation
        if (fieldRules['validate'] != null && fieldRules['validate'] is Function) {
          final customError = fieldRules['validate'](value);
          if (customError != null && customError.isNotEmpty) {
            fieldErrors.add(customError);
          }
        }
      }
      
      if (fieldErrors.isNotEmpty) {
        errors[field] = fieldErrors;
      }
    });
    
    if (errors.isNotEmpty) {
      return ValidationException(
        'Please correct the errors in the form',
        code: 'FORM_VALIDATION_ERROR',
        fieldErrors: errors,
      );
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
  
  /// Sanitizes a map of form data
  static Map<String, dynamic> sanitizeFormData(Map<String, dynamic> formData) {
    final sanitized = <String, dynamic>{};
    
    formData.forEach((key, value) {
      if (value is String) {
        sanitized[key] = sanitizeInput(value);
      } else {
        sanitized[key] = value;
      }
    });
    
    return sanitized;
  }
}

/// Extension to add error handling functionality to futures
extension FutureErrorHandling<T> on Future<T> {
  /// Add timeout to a future
  Future<T> withTimeout(Duration timeout) {
    return Future.any([
      this,
      Future.delayed(timeout, () => throw TimeoutException('Operation timed out', timeout)),
    ]);
  }
  
  /// Handle errors and convert to AppExceptions
  Future<T> handleError([String? context]) async {
    try {
      return await this;
    } catch (error, stackTrace) {
      final appError = ErrorHandler.handleError(error, stackTrace);
      if (context != null) {
        ErrorHandler.logError(appError, context: context);
      }
      throw appError;
    }
  }
  
  /// Handle errors with custom error message
  Future<T> handleErrorWithMessage(String errorMessage, [String? context]) async {
    try {
      return await this;
    } catch (error, stackTrace) {
      final appError = ErrorHandler.handleError(error, stackTrace);
      final customError = NetworkException(
        errorMessage,
        code: appError.code,
        originalError: appError,
        stackTrace: stackTrace,
      );
      
      if (context != null) {
        ErrorHandler.logError(customError, context: context);
      }
      throw customError;
    }
  }
  
  /// Add simple retry logic without using RetryHelper
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
        lastError = ErrorHandler.handleError(error, stackTrace);
        
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
    throw lastError ?? NetworkException('Operation failed after $maxAttempts attempts');
  }
}

/// Timeout exception for operations that take too long
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;
  
  const TimeoutException(this.message, this.timeout);
  
  @override
  String toString() => 'TimeoutException: $message (${timeout.inSeconds}s)';
}