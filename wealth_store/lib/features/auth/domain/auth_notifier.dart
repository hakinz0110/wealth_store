import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealth_app/core/utils/app_exceptions.dart';
import 'package:wealth_app/features/auth/data/auth_repository.dart';
import 'package:wealth_app/features/auth/domain/auth_state.dart';
import 'package:wealth_app/shared/models/customer.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AppAuthState build() {
    _checkCurrentUser();
    return AppAuthState.initial();
  }

  Future<void> _checkCurrentUser() async {
    try {
      final user = ref.read(authRepositoryProvider).getCurrentUser();
      if (user != null) {
        try {
          final customer = await ref.read(authRepositoryProvider).getCustomerProfile();
          state = AppAuthState.authenticated(user, customer);
        } catch (e) {
          debugPrint('Error loading profile, but user is authenticated: $e');
          // Even without a profile, we consider the user authenticated
          // We'll create a minimal customer object with available data
          final minimalCustomer = Customer(
            id: user.id,
            fullName: user.userMetadata?['full_name'] ?? 'User',
            email: user.email ?? '',
            phoneNumber: null,
            createdAt: DateTime.now(),
          );
          state = AppAuthState.authenticated(user, minimalCustomer);
        }
      }
    } catch (e) {
      debugPrint('Error checking current user: $e');
      state = AppAuthState.initial();
    }
  }

  Future<void> signIn(String email, String password) async {
    state = AppAuthState.loading();
    try {
      debugPrint('Starting sign in for $email');
      final response = await ref.read(authRepositoryProvider).signIn(email, password);
      debugPrint('Sign in response received: ${response.user != null}');
      
      if (response.user != null) {
        try {
          debugPrint('Getting customer profile for ${response.user!.id}');
          final customer = await ref.read(authRepositoryProvider).getCustomerProfile();
          debugPrint('Customer profile received: ${customer.fullName}');
          state = AppAuthState.authenticated(response.user!, customer);
        } catch (profileError) {
          debugPrint('Error getting customer profile: $profileError');
          
          // Create a minimal customer object from auth data
          final minimalCustomer = Customer(
            id: response.user!.id,
            fullName: response.user!.userMetadata?['full_name'] ?? email.split('@')[0],
            email: email,
            phoneNumber: null,
            createdAt: DateTime.now(),
          );
          
          // Still consider the user authenticated even without a profile
          state = AppAuthState.authenticated(response.user!, minimalCustomer);
        }
      } else {
        debugPrint('Authentication response has no user');
        state = AppAuthState.error("Authentication failed: No user returned");
      }
    } on AppAuthException catch (e) {
      debugPrint('AppAuthException during sign in: ${e.message}');
      state = AppAuthState.error(e.message);
    } catch (e, stackTrace) {
      debugPrint('Unexpected error during sign in: $e');
      debugPrint('Stack trace: $stackTrace');
      state = AppAuthState.error("Sign in error: $e");
    }
  }

  Future<void> signUp(String email, String password, String fullName) async {
    state = AppAuthState.loading();
    try {
      debugPrint('Starting sign up for $email');
      final response = await ref.read(authRepositoryProvider).signUp(email, password, fullName);
      debugPrint('Sign up response received: ${response.user != null}');
      
      if (response.user != null) {
        try {
          debugPrint('Getting customer profile for ${response.user!.id}');
          // Try to get the customer profile
          final customer = await ref.read(authRepositoryProvider).getCustomerProfile();
          debugPrint('Customer profile received: ${customer.fullName}');
          state = AppAuthState.authenticated(response.user!, customer);
        } catch (profileError) {
          debugPrint('Error getting customer profile after signup: $profileError');
          
          // Create a minimal customer object since profile creation might have failed
          final minimalCustomer = Customer(
            id: response.user!.id,
            fullName: fullName,
            email: email,
            phoneNumber: null,
            createdAt: DateTime.now(),
          );
          
          // Still consider the user authenticated
          state = AppAuthState.authenticated(response.user!, minimalCustomer);
        }
      } else {
        debugPrint('Registration response has no user');
        state = AppAuthState.error("Registration failed: No user returned");
      }
    } on AppAuthException catch (e) {
      debugPrint('AppAuthException during sign up: ${e.message}');
      state = AppAuthState.error(e.message);
    } catch (e, stackTrace) {
      debugPrint('Unexpected error during sign up: $e');
      debugPrint('Stack trace: $stackTrace');
      state = AppAuthState.error("Sign up error: $e");
    }
  }
  
  Future<void> signInWithGoogle() async {
    state = AppAuthState.loading();
    try {
      final response = await ref.read(authRepositoryProvider).signInWithGoogle();
      final user = response.user;
      
      if (user != null) {
        try {
          final customer = await ref.read(authRepositoryProvider).getCustomerProfile();
          state = AppAuthState.authenticated(user, customer);
        } catch (profileError) {
          debugPrint('Error getting customer profile after Google sign-in: $profileError');
          
          // Create a minimal customer object
          final minimalCustomer = Customer(
            id: user.id,
            fullName: user.userMetadata?['full_name'] ?? user.email?.split('@')[0] ?? 'User',
            email: user.email ?? '',
            phoneNumber: null,
            createdAt: DateTime.now(),
          );
          
          state = AppAuthState.authenticated(user, minimalCustomer);
        }
      } else {
        state = AppAuthState.error("Google sign in failed: No user returned");
      }
    } on AppAuthException catch (e) {
      state = AppAuthState.error(e.message);
    } catch (e, stackTrace) {
      debugPrint('Unexpected error during Google sign in: $e');
      debugPrint('Stack trace: $stackTrace');
      state = AppAuthState.error("Google sign in error: $e");
    }
  }

  Future<void> signOut() async {
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = AppAuthState.initial();
    } catch (e) {
      state = AppAuthState.error("Failed to sign out");
    }
  }

  Future<void> updateProfile({required String fullName, String? phoneNumber}) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedCustomer = await ref.read(authRepositoryProvider).updateCustomerProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      state = state.copyWith(
        customer: updatedCustomer,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to update profile",
      );
    }
  }

  void updateCustomer(Customer customer) {
    if (state.isAuthenticated && state.user != null) {
      state = state.copyWith(customer: customer);
    }
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(authRepositoryProvider).resetPassword(email);
      state = state.copyWith(
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to reset password",
      );
    }
  }
  
  // Force authentication state (useful for debugging or bypassing profile issues)
  void forceAuthenticated(User user, Customer customer) {
    state = AppAuthState.authenticated(user, customer);
  }
} 