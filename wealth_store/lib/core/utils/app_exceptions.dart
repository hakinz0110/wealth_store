class AppException implements Exception {
  final String message;
  final String? code;
  
  AppException(this.message, {this.code});
  
  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message, code: 'NETWORK_ERROR');
}

class AppAuthException extends AppException {
  AppAuthException(String message) : super(message, code: 'AUTH_ERROR');
}

class DataException extends AppException {
  DataException(String message) : super(message, code: 'DATA_ERROR');
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message, code: 'VALIDATION_ERROR');
}

class PermissionException extends AppException {
  PermissionException(String message) : super(message, code: 'PERMISSION_ERROR');
} 