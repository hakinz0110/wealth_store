import 'package:supabase_flutter/supabase_flutter.dart';
import '../shared/constants/app_constants.dart';
import '../shared/utils/logger.dart';
import '../shared/utils/app_config.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  // Getter for the Supabase client
  static SupabaseClient get client => _client;
  
  // Auth methods
  static User? get currentUser => _client.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;
  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  // Database table references
  static SupabaseQueryBuilder get users => _client.from(AppConstants.usersTable);
  static SupabaseQueryBuilder get products => _client.from(AppConstants.productsTable);
  static SupabaseQueryBuilder get categories => _client.from(AppConstants.categoriesTable);
  static SupabaseQueryBuilder get orders => _client.from(AppConstants.ordersTable);
  static SupabaseQueryBuilder get banners => _client.from(AppConstants.bannersTable);
  static SupabaseQueryBuilder get coupons => _client.from(AppConstants.couponsTable);
  static SupabaseQueryBuilder get activityLogs => _client.from(AppConstants.activityLogsTable);
  
  // Storage bucket references
  static SupabaseStorageClient get storage => _client.storage;
  static StorageFileApi get productImages => storage.from(AppConstants.productImagesBucket);
  static StorageFileApi get bannerImages => storage.from(AppConstants.bannerImagesBucket);
  static StorageFileApi get books => storage.from(AppConstants.booksBucket);
  static StorageFileApi get clothings => storage.from(AppConstants.clothingsBucket);
  static StorageFileApi get phones => storage.from(AppConstants.phonesBucket);
  static StorageFileApi get categoryIcons => storage.from(AppConstants.categoryIconsBucket);
  static StorageFileApi get customerAvatars => storage.from(AppConstants.customerAvatarsBucket);
  static StorageFileApi get adminAvatars => storage.from(AppConstants.adminAvatarsBucket);
  static StorageFileApi get projectImages => storage.from(AppConstants.projectImagesBucket);
  static StorageFileApi get brandLogos => storage.from(AppConstants.brandLogosBucket);
  static StorageFileApi get userAvatars => storage.from(AppConstants.userAvatarsBucket);
  static StorageFileApi get media => storage.from(AppConstants.mediaBucket);
  
  // Initialize Supabase with error handling
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
        debug: AppConfig.enableDebugMode,
      );
      Logger.info('Supabase initialized successfully');
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize Supabase', e, stackTrace);
      rethrow;
    }
  }
  
  // Authentication methods
  static Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      Logger.info('Attempting admin login for email: $email');
      
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        // Verify admin role
        final isAdmin = await isAdminUser(response.user!.id);
        if (!isAdmin) {
          await signOut();
          throw Exception('Access denied: Admin privileges required');
        }
        
        Logger.info('Admin login successful for user: ${response.user!.id}');
        await _logActivity('admin_login', {'email': email});
      }
      
      return response;
    } catch (e, stackTrace) {
      Logger.error('Admin login failed for email: $email', e, stackTrace);
      rethrow;
    }
  }
  
  static Future<void> signOut() async {
    try {
      final userId = currentUser?.id;
      await _client.auth.signOut();
      
      if (userId != null) {
        Logger.info('Admin logout successful for user: $userId');
        await _logActivity('admin_logout', {'user_id': userId});
      }
    } catch (e, stackTrace) {
      Logger.error('Admin logout failed', e, stackTrace);
      rethrow;
    }
  }
  
  // Helper method to check if user is admin
  static Future<bool> isAdminUser([String? userId]) async {
    final user = userId ?? currentUser?.id;
    if (user == null) return false;
    
    // TEMPORARY: Allow specific emails for testing
    final userEmail = currentUser?.email;
    if (userEmail != null && [
      'abereakinola@gmail.com', // Your admin email
      'admin@example.com',
      'test@example.com',
      // Add more emails as needed
    ].contains(userEmail)) {
      return true;
    }
    
    try {
      final response = await users
          .select('role')
          .eq('id', user)
          .single();
      
      final role = response['role'] as String?;
      return role == AppConstants.adminRole || role == AppConstants.managerRole;
    } catch (e, stackTrace) {
      Logger.error('Failed to check admin role for user: $user', e, stackTrace);
      return false;
    }
  }
  
  // Activity logging
  static Future<void> _logActivity(String action, Map<String, dynamic> details) async {
    try {
      final user = currentUser;
      if (user == null) return;
      
      await activityLogs.insert({
        'admin_id': user.id,
        'action': action,
        'details': details,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e, stackTrace) {
      Logger.error('Failed to log activity: $action', e, stackTrace);
      // Don't rethrow as this is not critical
    }
  }
  
  // Generic error handler for database operations
  static T handleDatabaseError<T>(dynamic error, String operation) {
    Logger.error('Database operation failed: $operation', error);
    
    if (error is PostgrestException) {
      throw Exception('Database error: ${error.message}');
    } else if (error is StorageException) {
      throw Exception('Storage error: ${error.message}');
    } else if (error is AuthException) {
      throw Exception('Authentication error: ${error.message}');
    } else {
      throw Exception('Unexpected error during $operation');
    }
  }
  
  // Connection health check
  static Future<bool> checkConnection() async {
    try {
      await _client.from('users').select('id').limit(1);
      return true;
    } catch (e) {
      Logger.warning('Supabase connection check failed', e);
      return false;
    }
  }
  
  // Get current admin user details
  static Future<Map<String, dynamic>?> getCurrentAdminDetails() async {
    try {
      final user = currentUser;
      if (user == null) return null;
      
      final response = await users
          .select('id, email, role, created_at, last_sign_in_at')
          .eq('id', user.id)
          .single();
      
      return response;
    } catch (e, stackTrace) {
      Logger.error('Failed to get current admin details', e, stackTrace);
      return null;
    }
  }
}