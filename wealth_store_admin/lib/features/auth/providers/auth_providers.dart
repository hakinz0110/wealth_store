import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/auth_models.dart';
import '../../../services/auth_service.dart';

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

// Admin check provider
final isAdminProvider = FutureProvider<bool>((ref) async {
  return await AuthService.isAdminUser();
});

// User role provider
final userRoleProvider = FutureProvider<String?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  
  final details = await AuthService.getCurrentAdminDetails();
  return details?['role'] as String?;
});

// Auth methods provider for compatibility
final authMethodsProvider = Provider<AuthMethods>((ref) {
  return AuthMethods();
});

class AuthMethods {
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await AuthService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await AuthService.signOut();
  }

  Future<void> resetPassword(String email) async {
    await AuthService.resetPassword(email);
  }

  Future<void> updatePassword(String newPassword) async {
    await AuthService.updatePassword(newPassword);
  }
}