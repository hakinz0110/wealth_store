import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'logger.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      return _getAuthErrorMessage(error);
    } else if (error is PostgrestException) {
      return _getDatabaseErrorMessage(error);
    } else if (error is StorageException) {
      return _getStorageErrorMessage(error);
    } else if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
  
  static String _getAuthErrorMessage(AuthException error) {
    switch (error.statusCode) {
      case '400':
        if (error.message.contains('Invalid login credentials')) {
          return 'Invalid email or password. Please check your credentials.';
        }
        return 'Invalid request. Please check your input.';
      case '401':
        return 'Authentication failed. Please check your credentials.';
      case '403':
        return 'Access denied. Admin privileges required.';
      case '422':
        return 'Invalid email format or password requirements not met.';
      case '429':
        return 'Too many login attempts. Please try again later.';
      default:
        return error.message.isNotEmpty 
            ? error.message 
            : 'Authentication error occurred.';
    }
  }
  
  static String _getDatabaseErrorMessage(PostgrestException error) {
    if (error.message.contains('permission denied')) {
      return 'Access denied. You do not have permission to perform this action.';
    } else if (error.message.contains('duplicate key')) {
      return 'This record already exists.';
    } else if (error.message.contains('foreign key')) {
      return 'Cannot delete this record as it is referenced by other data.';
    } else if (error.message.contains('not found')) {
      return 'The requested data was not found.';
    } else {
      return 'Database error: ${error.message}';
    }
  }
  
  static String _getStorageErrorMessage(StorageException error) {
    if (error.message.contains('file size')) {
      return 'File size exceeds the maximum allowed limit.';
    } else if (error.message.contains('file type')) {
      return 'File type not supported. Please use a valid image format.';
    } else if (error.message.contains('permission denied')) {
      return 'Access denied. You do not have permission to upload files.';
    } else {
      return 'File upload error: ${error.message}';
    }
  }
  
  static void logError(String operation, dynamic error, [StackTrace? stackTrace]) {
    Logger.error('Error in $operation: ${getErrorMessage(error)}', error, stackTrace);
    
    // In debug mode, also print to console for easier debugging
    if (kDebugMode) {
      debugPrint('ERROR [$operation]: ${getErrorMessage(error)}');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }
  
  static void handleError(String operation, dynamic error, [StackTrace? stackTrace]) {
    logError(operation, error, stackTrace);
    // Additional error handling logic can be added here
    // such as crash reporting, user notifications, etc.
  }
}