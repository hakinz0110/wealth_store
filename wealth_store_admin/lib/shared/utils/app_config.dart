import '../constants/app_constants.dart';

class AppConfig {
  static const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
  
  // Supabase Configuration
  static String get supabaseUrl => AppConstants.supabaseUrl;
  static String get supabaseAnonKey => AppConstants.supabaseAnonKey;
  
  // Environment checks
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';
  
  // Debug settings
  static bool get enableLogging => isDevelopment;
  static bool get enableDebugMode => isDevelopment;
  
  // API Configuration
  static Duration get apiTimeout => const Duration(seconds: 30);
  static int get maxRetries => 3;
  
  // File upload limits
  static int get maxFileSize => AppConstants.maxFileSize;
  static List<String> get allowedImageTypes => AppConstants.allowedImageTypes;
  
  // Pagination defaults
  static int get defaultPageSize => AppConstants.defaultPageSize;
  static int get maxPageSize => AppConstants.maxPageSize;
  
  // Cache settings
  static Duration get cacheExpiry => const Duration(minutes: 15);
  static int get maxCacheSize => 100;
}