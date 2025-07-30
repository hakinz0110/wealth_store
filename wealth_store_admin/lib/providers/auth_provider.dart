import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../shared/utils/logger.dart';

// Auth state provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  return AuthService.authStateChanges;
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (state) => state.session?.user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Authentication status provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

// Admin user details provider
final adminUserProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  
  return await AuthService.getCurrentAdminDetails();
});

// Is admin provider
final isAdminProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  
  return await AuthService.isAdminUser();
});

// User role provider
final userRoleProvider = FutureProvider<String?>((ref) async {
  final adminDetails = await ref.watch(adminUserProvider.future);
  return adminDetails?['role'] as String?;
});

// Auth loading state provider
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Auth error provider
final authErrorProvider = StateProvider<String?>((ref) => null);

// Auth methods provider
final authMethodsProvider = Provider<AdminAuthMethods>((ref) {
  return AdminAuthMethods(ref);
});

class AdminAuthMethods {
  final Ref _ref;
  
  AdminAuthMethods(this._ref);
  
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;
    
    try {
      Logger.info('Attempting admin sign in for: $email');
      
      final response = await AuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Refresh admin user data
      _ref.invalidate(adminUserProvider);
      _ref.invalidate(isAdminProvider);
      
      Logger.info('Admin sign in successful');
      return response;
    } catch (e) {
      final errorMessage = AuthService.getErrorMessage(e);
      _ref.read(authErrorProvider.notifier).state = errorMessage;
      Logger.error('Admin sign in failed', e);
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }
  
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String role,
    Map<String, dynamic>? metadata,
  }) async {
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;
    
    try {
      Logger.info('Attempting admin signup for: $email with role: $role');
      
      final response = await AuthService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        role: role,
        metadata: metadata,
      );
      
      Logger.info('Admin signup successful');
      return response;
    } catch (e) {
      final errorMessage = AuthService.getErrorMessage(e);
      _ref.read(authErrorProvider.notifier).state = errorMessage;
      Logger.error('Admin signup failed', e);
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }
  
  Future<void> signOut() async {
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;
    
    try {
      Logger.info('Attempting admin sign out');
      
      await AuthService.signOut();
      
      // Clear all cached data
      _ref.invalidate(adminUserProvider);
      _ref.invalidate(isAdminProvider);
      
      Logger.info('Admin sign out successful');
    } catch (e) {
      final errorMessage = AuthService.getErrorMessage(e);
      _ref.read(authErrorProvider.notifier).state = errorMessage;
      Logger.error('Admin sign out failed', e);
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }
  
  Future<void> resetPassword(String email) async {
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;
    
    try {
      Logger.info('Requesting password reset for: $email');
      
      await AuthService.resetPassword(email);
      
      Logger.info('Password reset email sent');
    } catch (e) {
      final errorMessage = AuthService.getErrorMessage(e);
      _ref.read(authErrorProvider.notifier).state = errorMessage;
      Logger.error('Password reset failed', e);
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }
  
  Future<UserResponse> updatePassword(String newPassword) async {
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;
    
    try {
      Logger.info('Updating password for current admin user');
      
      final response = await AuthService.updatePassword(newPassword);
      
      Logger.info('Password updated successfully');
      return response;
    } catch (e) {
      final errorMessage = AuthService.getErrorMessage(e);
      _ref.read(authErrorProvider.notifier).state = errorMessage;
      Logger.error('Password update failed', e);
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }
  
  Future<void> updateProfile({
    String? fullName,
    String? email,
    Map<String, dynamic>? metadata,
  }) async {
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;
    
    try {
      Logger.info('Updating admin profile');
      
      await AuthService.updateAdminProfile(
        fullName: fullName,
        email: email,
        metadata: metadata,
      );
      
      // Refresh admin user data
      _ref.invalidate(adminUserProvider);
      
      Logger.info('Admin profile updated successfully');
    } catch (e) {
      final errorMessage = AuthService.getErrorMessage(e);
      _ref.read(authErrorProvider.notifier).state = errorMessage;
      Logger.error('Admin profile update failed', e);
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }
  
  Future<bool> checkAdminAccess() async {
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) return false;
      
      return await AuthService.isAdminUser();
    } catch (e) {
      Logger.error('Failed to check admin access', e);
      return false;
    }
  }
  
  Future<bool> hasRole(String role) async {
    try {
      return await AuthService.hasRole(role);
    } catch (e) {
      Logger.error('Failed to check user role', e);
      return false;
    }
  }
}