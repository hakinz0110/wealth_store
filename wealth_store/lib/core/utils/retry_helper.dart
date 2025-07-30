import 'dart:async';
import 'dart:math';
import '../exceptions/app_exceptions.dart';
import '../exceptions/error_handler.dart';

/// Utility class for handling retry logic with exponential backoff
class RetryHelper {
  /// Maximum number of retry attempts
  static const int maxRetries = 3;
  
  /// Base delay for exponential backoff (in milliseconds)
  static const int baseDelayMs = 1000;
  
  /// Maximum delay between retries (in milliseconds)
  static const int maxDelayMs = 10000;

  /// Executes an operation with retry logic and exponential backoff
  /// 
  /// [operation] - The async operation to retry
  /// [maxAttempts] - Maximum number of attempts (default: 3)
  /// [baseDelay] - Base delay for exponential backoff (default: 1 second)
  /// [maxDelay] - Maximum delay between retries (default: 10 seconds)
  /// [shouldRetry] - Custom function to determine if error should be retried
  static Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int maxAttempts = maxRetries,
    Duration baseDelay = const Duration(milliseconds: baseDelayMs),
    Duration maxDelay = const Duration(milliseconds: maxDelayMs),
    bool Function(AppException)? shouldRetry,
  }) async {
    int attempt = 0;
    AppException? lastError;

    while (attempt < maxAttempts) {
      try {
        return await operation();
      } catch (error) {
        attempt++;
        
        // Convert to AppException if not already
        final appError = error is AppException 
            ? error 
            : ErrorHandler.handleSupabaseError(error);
        
        lastError = appError;

        // Check if we should retry this error
        final canRetry = shouldRetry?.call(appError) ?? 
                        ErrorHandler.isRetryable(appError);
        
        // Don't retry if this is the last attempt or error is not retryable
        if (attempt >= maxAttempts || !canRetry) {
          break;
        }

        // Calculate delay with exponential backoff and jitter
        final delay = _calculateDelay(attempt, baseDelay, maxDelay);
        
        print('Retry attempt $attempt/$maxAttempts after ${delay.inMilliseconds}ms delay');
        await Future.delayed(delay);
      }
    }

    // If we get here, all retries failed
    throw lastError ?? BusinessException('Operation failed after $maxAttempts attempts');
  }

  /// Calculates delay with exponential backoff and jitter
  static Duration _calculateDelay(int attempt, Duration baseDelay, Duration maxDelay) {
    // Exponential backoff: baseDelay * 2^(attempt-1)
    final exponentialDelay = baseDelay.inMilliseconds * pow(2, attempt - 1);
    
    // Add jitter (random factor between 0.5 and 1.5)
    final random = Random();
    final jitter = 0.5 + random.nextDouble();
    final delayWithJitter = (exponentialDelay * jitter).round();
    
    // Cap at maximum delay
    final finalDelay = min(delayWithJitter, maxDelay.inMilliseconds);
    
    return Duration(milliseconds: finalDelay);
  }

  /// Retry specifically for network operations
  static Future<T> withNetworkRetry<T>(Future<T> Function() operation) {
    return withRetry(
      operation,
      maxAttempts: 3,
      baseDelay: const Duration(seconds: 1),
      maxDelay: const Duration(seconds: 5),
      shouldRetry: (error) => error is NetworkException || 
                             (error is DatabaseException && error.code == 'query_failed'),
    );
  }

  /// Retry specifically for storage operations
  static Future<T> withStorageRetry<T>(Future<T> Function() operation) {
    return withRetry(
      operation,
      maxAttempts: 2,
      baseDelay: const Duration(milliseconds: 500),
      maxDelay: const Duration(seconds: 3),
      shouldRetry: (error) => error is StorageException && 
                             (error.code == 'upload_failed' || error.code == 'download_failed'),
    );
  }

  /// Retry for authentication operations (limited retries)
  static Future<T> withAuthRetry<T>(Future<T> Function() operation) {
    return withRetry(
      operation,
      maxAttempts: 2,
      baseDelay: const Duration(milliseconds: 500),
      maxDelay: const Duration(seconds: 2),
      shouldRetry: (error) => error is NetworkException,
    );
  }

  /// Circuit breaker pattern for preventing cascading failures
  static final Map<String, _CircuitBreaker> _circuitBreakers = {};

  /// Execute operation with circuit breaker pattern
  static Future<T> withCircuitBreaker<T>(
    String operationKey,
    Future<T> Function() operation, {
    int failureThreshold = 5,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final circuitBreaker = _circuitBreakers.putIfAbsent(
      operationKey,
      () => _CircuitBreaker(failureThreshold, timeout),
    );

    return circuitBreaker.execute(operation);
  }
}

/// Internal circuit breaker implementation
class _CircuitBreaker {
  final int failureThreshold;
  final Duration timeout;
  
  int _failureCount = 0;
  DateTime? _lastFailureTime;
  bool _isOpen = false;

  _CircuitBreaker(this.failureThreshold, this.timeout);

  Future<T> execute<T>(Future<T> Function() operation) async {
    // Check if circuit is open and timeout has passed
    if (_isOpen) {
      if (_lastFailureTime != null && 
          DateTime.now().difference(_lastFailureTime!) > timeout) {
        _isOpen = false;
        _failureCount = 0;
      } else {
        throw BusinessException(
          'Circuit breaker is open. Service temporarily unavailable.',
          code: 'circuit_breaker_open',
        );
      }
    }

    try {
      final result = await operation();
      // Reset on success
      _failureCount = 0;
      _isOpen = false;
      return result;
    } catch (error) {
      _failureCount++;
      _lastFailureTime = DateTime.now();
      
      if (_failureCount >= failureThreshold) {
        _isOpen = true;
      }
      
      rethrow;
    }
  }
}