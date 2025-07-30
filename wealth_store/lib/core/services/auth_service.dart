import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../exceptions/error_handler.dart';
import '../utils/retry_helper.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  // Getter for the Supabase client
  static SupabaseClient get client => _client;
  
  // Auth state getters
  static User? get currentUser => _client.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;
  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  // Sign in with email and password
  static Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return RetryHelper.withAuthRetry(() async {
      try {
        final response = await _client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        
        if (response.user != null) {
          // Log successful sign in
          print('Customer sign in successful for user: ${response.user!.id}');
        }
        
        return response;
      } catch (error, stackTrace) {
        final appException = ErrorHandler.handleSupabaseError(error, stackTrace);
        print('Customer sign in error: ${appException.message}');
        throw appException;
      }
    });
  }
  
  // Sign up with email and password
  static Future<AuthResponse> signUpWithEmailAndPassword({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    return RetryHelper.withAuthRetry(() async {
      try {
        final response = await _client.auth.signUp(
          email: email,
          password: password,
          data: metadata,
        );
        
        if (response.user != null) {
          // Create user profile with customer role
          await _createUserProfile(response.user!, metadata);
          print('Customer sign up successful for user: ${response.user!.id}');
        }
        
        return response;
      } catch (error, stackTrace) {
        final appException = ErrorHandler.handleSupabaseError(error, stackTrace);
        print('Customer sign up error: ${appException.message}');
        throw appException;
      }
    });
  }
  
  // Sign out
  static Future<void> signOut() async {
    try {
      final userId = currentUser?.id;
      await _client.auth.signOut();
      
      if (userId != null) {
        print('Customer sign out successful for user: $userId');
      }
    } catch (e) {
      print('Customer sign out failed - Error: $e');
      rethrow;
    }
  }
  
  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'com.wealthstore.app://password-update',
      );
      print('Password reset email sent to: $email');
    } catch (e) {
      print('Password reset failed for email: $email - Error: $e');
      rethrow;
    }
  }
  
  // Update password
  static Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      
      if (response.user != null) {
        print('Password updated successfully for user: ${response.user!.id}');
      }
      
      return response;
    } catch (e) {
      print('Password update failed - Error: $e');
      rethrow;
    }
  }
  
  // Update user profile
  static Future<UserResponse> updateProfile({
    String? email,
    Map<String, dynamic>? data,
  }) async {
    try {
      final attributes = UserAttributes(
        email: email,
        data: data,
      );
      
      final response = await _client.auth.updateUser(attributes);
      
      if (response.user != null) {
        print('Profile updated successfully for user: ${response.user!.id}');
      }
      
      return response;
    } catch (e) {
      print('Profile update failed - Error: $e');
      rethrow;
    }
  }
  
  // Get current user profile from database
  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) return null;
      
      final response = await _client
          .from(AppConfig.usersTable)
          .select('*')
          .eq('id', user.id)
          .single();
      
      return response;
    } catch (e) {
      print('Failed to get user profile - Error: $e');
      return null;
    }
  }
  
  // Check if user has specific role
  static Future<bool> hasRole(String role) async {
    try {
      final profile = await getCurrentUserProfile();
      if (profile == null) return false;
      
      final userRole = profile['role'] as String?;
      return userRole == role;
    } catch (e) {
      print('Failed to check user role - Error: $e');
      return false;
    }
  }
  
  // Check if user is customer
  static Future<bool> isCustomer() async {
    return await hasRole(AppConfig.customerRole);
  }
  
  // Create user profile in database
  static Future<void> _createUserProfile(
    User user, 
    Map<String, dynamic>? metadata,
  ) async {
    try {
      final profileData = {
        'id': user.id,
        'email': user.email,
        'role': AppConfig.customerRole,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      // Add metadata if provided
      if (metadata != null) {
        if (metadata['full_name'] != null) {
          profileData['full_name'] = metadata['full_name'];
        }
        if (metadata['username'] != null) {
          profileData['username'] = metadata['username'];
        }
      }
      
      await _client.from(AppConfig.usersTable).insert(profileData);
      print('User profile created successfully for user: ${user.id}');
    } catch (e) {
      print('Failed to create user profile for user: ${user.id} - Error: $e');
      // Don't rethrow as this is not critical for sign up
    }
  }
  
  // Connection health check
  static Future<bool> checkConnection() async {
    try {
      await _client.from(AppConfig.usersTable).select('id').limit(1);
      return true;
    } catch (e) {
      print('Auth service connection check failed - Error: $e');
      return false;
    }
  }
  
  // Handle auth errors
  static String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message.toLowerCase()) {
        case 'invalid login credentials':
          return 'Invalid email or password. Please try again.';
        case 'email not confirmed':
          return 'Please check your email and click the confirmation link.';
        case 'user not found':
          return 'No account found with this email address.';
        case 'weak password':
          return 'Password is too weak. Please choose a stronger password.';
        case 'email already registered':
          return 'An account with this email already exists.';
        default:
          return error.message;
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }
}