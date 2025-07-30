import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

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

// User profile provider
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  
  return await AuthService.getCurrentUserProfile();
});

// User role provider
final userRoleProvider = FutureProvider<String?>((ref) async {
  final profile = await ref.watch(userProfileProvider.future);
  return profile?['role'] as String?;
});

// Is customer provider
final isCustomerProvider = FutureProvider<bool>((ref) async {
  return await AuthService.isCustomer();
});

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Auth loading state provider
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Auth error provider
final authErrorProvider = StateProvider<String?>((ref) => null);

// Auth methods provider
final authMethodsProvider = Provider<AuthMethods>((ref) {
  return AuthMethods(ref);
});

class AuthMethods {
  final Ref _ref;
  
  AuthMethods(this._ref);
  
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;
    
    try {
      final response = await AuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return response;
    } catch (e) {
      final errorMessage = AuthService.getErrorMessage(e);
      _ref.read(authErrorProvider.notifier).state = errorMessage;
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }
  
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;
    
    try {
      final response = await AuthService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        metadata: metadata,
      );
      
      return response;
    } catch (e) {
      final errorMessage = AuthService.getErrorMessage(e);
      _ref.read(authErrorProvider.notifier).state = errorMessage;
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }
  
  Future<void> signOut() async {
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;
    
    try {
      await AuthService.signOut();
    } catch (e) {
      final errorMessage = AuthService.getErrorMessage(e);
      _ref.read(authErrorProvider.notifier).state = errorMessage;
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }
  
  Future<void> resetPassword(String email) async {
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;
    
    try {
      await AuthService.resetPassword(email);
    } catch (e) {
      final errorMessage = AuthService.getErrorMessage(e);
      _ref.read(authErrorProvider.notifier).state = errorMessage;
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }
  
  Future<UserResponse> updatePassword(String newPassword) async {
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;
    
    try {
      final response = await AuthService.updatePassword(newPassword);
      return response;
    } catch (e) {
      final errorMessage = AuthService.getErrorMessage(e);
      _ref.read(authErrorProvider.notifier).state = errorMessage;
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }
  
  Future<UserResponse> updateProfile({
    String? email,
    Map<String, dynamic>? data,
  }) async {
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;
    
    try {
      final response = await AuthService.updateProfile(
        email: email,
        data: data,
      );
      
      // Refresh user profile
      _ref.invalidate(userProfileProvider);
      
      return response;
    } catch (e) {
      final errorMessage = AuthService.getErrorMessage(e);
      _ref.read(authErrorProvider.notifier).state = errorMessage;
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }
}