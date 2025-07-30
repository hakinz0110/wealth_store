import 'dart:async';
import 'dart:math';
import '../exceptions/app_exceptions.dart';
import '../exceptions/error_handler.dart';

/// Utility class for implementing retry logic with exponential backoff
class RetryHelper {
  /// Execute a function with retry logic
  static Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    Duration maxDelay = const Duration(seconds: 30),
    double backoffMultiplier = 2.0,
    bool Function(AppException)? shouldRetry,
    void Function(AppException, int)? onRetry,
  }) async {
    int attemptCount = 0;
    Duration currentDelay = initialDelay;
    
    while (attemptCount < maxAttempts) {
      attemptCount++;
      
      try {
        return await operation();
      } catch (error, stackTrace) {
        final appException = ErrorHandler.handleError(error, stackTrace);
        
        // Check if we should retry this error
        final shouldRetryError = shouldRetry?.call(appException) ?? 
                                ErrorHandler.isRetryable(appException);
        
        // If this is the last attempt or error is not retryable, throw
        if (attemptCount >= maxAttempts || !shouldRetryError) {
          ErrorHandler.logError(
            appException,
            context: 'RetryHelper - Final attempt failed',
            additionalData: {
              'attemptCount': attemptCount,
              'maxAttempts': maxAttempts,
            },
          );
          throw appException;
        }
        
        // Log retry attempt
        ErrorHandler.logError(
          appException,
          context: 'RetryHelper - Retrying operation',
          additionalData: {
            'attemptCount': attemptCount,
            'maxAttempts': maxAttempts,
            'nextRetryIn': currentDelay.inMilliseconds,
          },
        );
        
        // Call retry callback if provided
        onRetry?.call(appException, attemptCount);
        
        // Wait before retrying
        await Future.delayed(currentDelay);
        
        // Calculate next delay with exponential backoff and jitter
        currentDelay = _calculateNextDelay(
          currentDelay, 
          backoffMultiplier, 
          maxDelay,
        );
      }
    }
    
    // This should never be reached, but just in case
    throw AppException('Maximum retry attempts exceeded');
  }
  
  /// Execute with timeout and retry
  static Future<T> executeWithTimeoutAndRetry<T>(
    Future<T> Function() operation, {
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    Duration maxDelay = const Duration(seconds: 30),
    double backoffMultiplier = 2.0,
    bool Function(AppException)? shouldRetry,
    void Function(AppException, int)? onRetry,
  }) async {
    return executeWithRetry(
      () => operation().timeout(timeout),
      maxAttempts: maxAttempts,
      initialDelay: initialDelay,
      maxDelay: maxDelay,
      backoffMultiplier: backoffMultiplier,
      shouldRetry: shouldRetry,
      onRetry: onRetry,
    );
  }
  
  /// Calculate next delay with exponential backoff and jitter
  static Duration _calculateNextDelay(
    Duration currentDelay,
    double backoffMultiplier,
    Duration maxDelay,
  ) {
    // Apply exponential backoff
    final nextDelay = Duration(
      milliseconds: (currentDelay.inMilliseconds * backoffMultiplier).round(),
    );
    
    // Add jitter (±25% of the delay)
    final jitterRange = (nextDelay.inMilliseconds * 0.25).round();
    final jitter = Random().nextInt(jitterRange * 2) - jitterRange;
    final delayWithJitter = Duration(
      milliseconds: nextDelay.inMilliseconds + jitter,
    );
    
    // Ensure we don't exceed max delay
    return delayWithJitter > maxDelay ? maxDelay : delayWithJitter;
  }
  
  /// Predefined retry configurations for common scenarios
  
  /// Configuration for network operations
  static Future<T> networkOperation<T>(
    Future<T> Function() operation, {
    void Function(AppException, int)? onRetry,
  }) {
    return executeWithRetry(
      operation,
      maxAttempts: 3,
      initialDelay: const Duration(seconds: 2),
      maxDelay: const Duration(seconds: 30),
      backoffMultiplier: 2.0,
      shouldRetry: (error) => error is NetworkException || error is ServerException,
      onRetry: onRetry,
    );
  }
  
  /// Configuration for database operations
  static Future<T> databaseOperation<T>(
    Future<T> Function() operation, {
    void Function(AppException, int)? onRetry,
  }) {
    return executeWithRetry(
      operation,
      maxAttempts: 2,
      initialDelay: const Duration(seconds: 1),
      maxDelay: const Duration(seconds: 10),
      backoffMultiplier: 2.0,
      shouldRetry: (error) => 
        error is DatabaseException && 
        (error.code?.startsWith('5') == true || error.code == 'NETWORK_ERROR'),
      onRetry: onRetry,
    );
  }
  
  /// Configuration for authentication operations
  static Future<T> authOperation<T>(
    Future<T> Function() operation, {
    void Function(AppException, int)? onRetry,
  }) {
    return executeWithRetry(
      operation,
      maxAttempts: 2,
      initialDelay: const Duration(seconds: 1),
      maxDelay: const Duration(seconds: 5),
      backoffMultiplier: 1.5,
      shouldRetry: (error) => 
        error is NetworkException || 
        (error is AuthenticationException && error.code == 'NETWORK_ERROR'),
      onRetry: onRetry,
    );
  }
  
  /// Configuration for file upload operations
  static Future<T> fileOperation<T>(
    Future<T> Function() operation, {
    void Function(AppException, int)? onRetry,
  }) {
    return executeWithRetry(
      operation,
      maxAttempts: 3,
      initialDelay: const Duration(seconds: 3),
      maxDelay: const Duration(minutes: 1),
      backoffMultiplier: 2.0,
      shouldRetry: (error) => 
        error is NetworkException || 
        error is ServerException ||
        (error is StorageException && 
         !error.message.contains('too large') &&
         !error.message.contains('invalid file type')),
      onRetry: onRetry,
    );
  }
}

/// Extension to add retry functionality to any Future
extension FutureRetry<T> on Future<T> {
  /// Add retry logic to any future
  Future<T> withRetry({
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    Duration maxDelay = const Duration(seconds: 30),
    double backoffMultiplier = 2.0,
    bool Function(AppException)? shouldRetry,
    void Function(AppException, int)? onRetry,
  }) {
    return RetryHelper.executeWithRetry(
      () => this,
      maxAttempts: maxAttempts,
      initialDelay: initialDelay,
      maxDelay: maxDelay,
      backoffMultiplier: backoffMultiplier,
      shouldRetry: shouldRetry,
      onRetry: onRetry,
    );
  }
  
  /// Add network-specific retry logic
  Future<T> withNetworkRetry({
    void Function(AppException, int)? onRetry,
  }) {
    return RetryHelper.networkOperation(() => this, onRetry: onRetry);
  }
  
  /// Add database-specific retry logic
  Future<T> withDatabaseRetry({
    void Function(AppException, int)? onRetry,
  }) {
    return RetryHelper.databaseOperation(() => this, onRetry: onRetry);
  }
}