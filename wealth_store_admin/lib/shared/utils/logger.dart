import 'dart:developer' as developer;
import 'app_config.dart';

enum LogLevel { debug, info, warning, error }

class Logger {
  static const String _name = 'WealthStoreAdmin';
  
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (AppConfig.enableLogging) {
      _log(LogLevel.debug, message, error, stackTrace);
    }
  }
  
  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    if (AppConfig.enableLogging) {
      _log(LogLevel.info, message, error, stackTrace);
    }
  }
  
  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.warning, message, error, stackTrace);
  }
  
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }
  
  static void _log(LogLevel level, String message, Object? error, StackTrace? stackTrace) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] [${level.name.toUpperCase()}] $message';
    
    developer.log(
      logMessage,
      name: _name,
      error: error,
      stackTrace: stackTrace,
      level: _getLevelValue(level),
    );
  }
  
  static int _getLevelValue(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }
}