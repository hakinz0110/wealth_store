/// Custom exception classes for the Wealth Store Admin application
/// Provides structured error handling with specific error types and user-friendly messages

/// Base exception class
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

/// Network connectivity exceptions
class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
  
  @override
  String toString() => 'NetworkException: $message';
}

/// Authentication related exceptions
class AuthenticationException extends AppException {
  const AuthenticationException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
  
  @override
  String toString() => 'AuthenticationException: $message';
}

/// Authorization related exceptions (role/permission issues)
class AuthorizationException extends AppException {
  const AuthorizationException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
  
  @override
  String toString() => 'AuthorizationException: $message';
}

/// Database operation exceptions
class DatabaseException extends AppException {
  const DatabaseException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
  
  @override
  String toString() => 'DatabaseException: $message';
}

/// Server-side exceptions
class ServerException extends AppException {
  const ServerException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
  
  @override
  String toString() => 'ServerException: $message';
}

/// Validation exceptions for user input
class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;
  
  const ValidationException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
    this.fieldErrors,
  });
  
  @override
  String toString() => 'ValidationException: $message';
}

/// Business logic exceptions
class BusinessLogicException extends AppException {
  const BusinessLogicException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
  
  @override
  String toString() => 'BusinessLogicException: $message';
}

/// Resource not found exceptions
class NotFoundException extends AppException {
  final String resourceType;
  final String? resourceId;
  
  const NotFoundException(
    this.resourceType, {
    this.resourceId,
    super.code,
    super.originalError,
    super.stackTrace,
  }) : super('$resourceType not found${resourceId != null ? ' (ID: $resourceId)' : ''}');
  
  @override
  String toString() => 'NotFoundException: $message';
}