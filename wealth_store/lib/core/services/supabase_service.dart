import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

part 'supabase_service.g.dart';

@riverpod
SupabaseClient supabase(SupabaseRef ref) {
  return Supabase.instance.client;
}

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  // Getter for the Supabase client
  static SupabaseClient get client => _client;
  
  // Auth methods
  static User? get currentUser => _client.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;
  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  // Database table references
  static SupabaseQueryBuilder get users => _client.from('users');
  static SupabaseQueryBuilder get products => _client.from('products');
  static SupabaseQueryBuilder get categories => _client.from('categories');
  static SupabaseQueryBuilder get orders => _client.from('orders');
  static SupabaseQueryBuilder get banners => _client.from('banners');
  static SupabaseQueryBuilder get coupons => _client.from('coupons');
  
  // Storage bucket references
  static SupabaseStorageClient get storage => _client.storage;
  static StorageFileApi get productImages => storage.from('product-images');
  static StorageFileApi get bannerImages => storage.from('banner-images');
  
  // Initialize Supabase with error handling
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
        debug: AppConfig.isDevelopment,
      );
    } catch (e) {
      throw Exception('Failed to initialize Supabase: $e');
    }
  }
  
  // Authentication methods
  static Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }
  
  static Future<AuthResponse> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }
  
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }
  
  static Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }
  
  // Connection health check
  static Future<bool> checkConnection() async {
    try {
      await _client.from('users').select('id').limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }
}

@riverpod
SupabaseService supabaseService(SupabaseServiceRef ref) {
  return SupabaseService();
} 