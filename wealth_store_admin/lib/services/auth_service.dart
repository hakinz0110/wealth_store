import 'package:supabase_flutter/supabase_flutter.dart';
import '../shared/constants/app_constants.dart';
import '../shared/utils/logger.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  // Getter for the Supabase client
  static SupabaseClient get client => _client;
  
  // Auth state getters
  static User? get currentUser => _client.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;
  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  // Admin sign in with email and password
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
          throw AuthException('Access denied: Admin privileges required');
        }
        
        Logger.info('Admin login successful for user: ${response.user!.id}');
        await _logActivity('admin_login', {'email': email});
      }
      
      return response;
    } catch (e) {
      Logger.error('Admin login failed for email: $email', e);
      rethrow;
    }
  }
  
  // Sign up (admin only - typically done by super admin)
  static Future<AuthResponse> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String role,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      Logger.info('Attempting admin signup for email: $email with role: $role');
      
      // Verify current user is admin before allowing signup
      if (isAuthenticated) {
        final canCreateAdmin = await isAdminUser();
        if (!canCreateAdmin) {
          throw AuthException('Access denied: Only admins can create new admin accounts');
        }
      }
      
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );
      
      if (response.user != null) {
        // Create admin profile
        await _createAdminProfile(response.user!, role, metadata);
        Logger.info('Admin signup successful for user: ${response.user!.id}');
        await _logActivity('admin_created', {'email': email, 'role': role});
      }
      
      return response;
    } catch (e) {
      Logger.error('Admin signup failed for email: $email', e);
      rethrow;
    }
  }
  
  // Sign out
  static Future<void> signOut() async {
    try {
      final userId = currentUser?.id;
      await _client.auth.signOut();
      
      if (userId != null) {
        Logger.info('Admin logout successful for user: $userId');
        await _logActivity('admin_logout', {'user_id': userId});
      }
    } catch (e) {
      Logger.error('Admin logout failed', e);
      rethrow;
    }
  }
  
  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'com.wealthstore.admin://reset-password',
      );
      Logger.info('Password reset email sent to: $email');
      await _logActivity('password_reset_requested', {'email': email});
    } catch (e) {
      Logger.error('Password reset failed for email: $email', e);
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
        Logger.info('Password updated successfully for user: ${response.user!.id}');
        await _logActivity('password_updated', {'user_id': response.user!.id});
      }
      
      return response;
    } catch (e) {
      Logger.error('Password update failed', e);
      rethrow;
    }
  }
  
  // Check if user is admin
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
      Logger.info('Admin access granted for email: $userEmail');
      return true;
    }
    
    try {
      final response = await _client
          .from(AppConstants.usersTable)
          .select('role')
          .eq('id', user)
          .single();
      
      final role = response['role'] as String?;
      final isAdmin = role == AppConstants.adminRole || role == AppConstants.managerRole;
      
      if (isAdmin) {
        Logger.info('Admin access granted for user ID: $user with role: $role');
      } else {
        Logger.warning('Admin access denied for user ID: $user with role: $role');
      }
      
      return isAdmin;
    } catch (e) {
      Logger.error('Failed to check admin role for user: $user', e);
      
      // If we can't check the role in the database, default to allowing access for the specified emails
      if (userEmail != null && [
        'abereakinola@gmail.com',
        'admin@example.com',
        'test@example.com',
      ].contains(userEmail)) {
        Logger.info('Admin access granted as fallback for email: $userEmail');
        return true;
      }
      
      return false;
    }
  }
  
  // Check if user has specific role
  static Future<bool> hasRole(String role) async {
    try {
      final user = currentUser;
      if (user == null) return false;
      
      final response = await _client
          .from(AppConstants.usersTable)
          .select('role')
          .eq('id', user.id)
          .single();
      
      final userRole = response['role'] as String?;
      return userRole == role;
    } catch (e) {
      Logger.error('Failed to check user role', e);
      return false;
    }
  }
  
  // Get current admin user details
  static Future<Map<String, dynamic>?> getCurrentAdminDetails() async {
    try {
      final user = currentUser;
      if (user == null) return null;
      
      final response = await _client
          .from(AppConstants.usersTable)
          .select('id, email, role, full_name, created_at, updated_at, is_active')
          .eq('id', user.id)
          .single();
      
      return response;
    } catch (e) {
      Logger.error('Failed to get current admin details', e);
      return null;
    }
  }
  
  // Update admin profile
  static Future<void> updateAdminProfile({
    String? fullName,
    String? email,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw AuthException('No authenticated user');
      
      // Update auth user if email is provided
      if (email != null || metadata != null) {
        await _client.auth.updateUser(UserAttributes(
          email: email,
          data: metadata,
        ));
      }
      
      // Update profile in database
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (fullName != null) {
        updateData['full_name'] = fullName;
      }
      
      await _client
          .from(AppConstants.usersTable)
          .update(updateData)
          .eq('id', user.id);
      
      Logger.info('Admin profile updated for user: ${user.id}');
      await _logActivity('profile_updated', {'user_id': user.id});
    } catch (e) {
      Logger.error('Failed to update admin profile', e);
      rethrow;
    }
  }
  
  // Create admin profile in database
  static Future<void> _createAdminProfile(
    User user, 
    String role,
    Map<String, dynamic>? metadata,
  ) async {
    try {
      final profileData = {
        'id': user.id,
        'email': user.email,
        'role': role,
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
      
      await _client.from(AppConstants.usersTable).insert(profileData);
      Logger.info('Admin profile created successfully for user: ${user.id}');
    } catch (e) {
      Logger.error('Failed to create admin profile for user: ${user.id}', e);
      rethrow; // This is critical for admin creation
    }
  }
  
  // Activity logging
  static Future<void> _logActivity(String action, Map<String, dynamic> details) async {
    try {
      final user = currentUser;
      if (user == null) return;
      
      await _client.from(AppConstants.activityLogsTable).insert({
        'admin_id': user.id,
        'action': action,
        'details': details,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      Logger.error('Failed to log activity: $action', e);
      // Don't rethrow as this is not critical
    }
  }
  
  // Connection health check
  static Future<bool> checkConnection() async {
    try {
      await _client.from(AppConstants.usersTable).select('id').limit(1);
      return true;
    } catch (e) {
      Logger.warning('Auth service connection check failed', e);
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
        case 'access denied: admin privileges required':
          return 'Access denied. This account does not have admin privileges.';
        case 'access denied: only admins can create new admin accounts':
          return 'Access denied. Only existing admins can create new admin accounts.';
        default:
          return error.message;
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }
}