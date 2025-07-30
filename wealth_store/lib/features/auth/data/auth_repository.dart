import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealth_app/core/services/supabase_service.dart';
import 'package:wealth_app/core/utils/app_exceptions.dart';
import 'package:wealth_app/core/utils/secure_storage.dart';
import 'package:wealth_app/shared/models/customer.dart';
import 'package:flutter/foundation.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  // Get the currently authenticated user
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  // Sign up a new user
  Future<AuthResponse> signUp(String email, String password, String fullName) async {
    try {
      debugPrint('Starting sign up for $email in auth repository');
      
      // Step 1: Sign up the user (this creates the auth record)
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'io.supabase.wealthapp://auth-callback/',
        data: {
          'full_name': fullName
        }
      );
      
      debugPrint('Sign up response received: ${response.user != null}');

      if (response.user != null) {
        try {
          debugPrint('Creating customer profile for ${response.user!.id}');
          
          // Wait a moment for auth to fully propagate
          await Future.delayed(const Duration(milliseconds: 500));
          
          // IMPORTANT: Use the REST API directly instead of Supabase client
          // This is a workaround for RLS issues during sign-up
          await _createCustomerProfileDirectly(
            response.user!.id,
            fullName,
            email,
          );
          
          // Store the user ID securely
          await SecureStorage.storeUserId(response.user!.id);
          
          // Store auth session for future requests
          if (response.session != null) {
            await SecureStorage.storeToken(response.session!.accessToken);
            debugPrint('Access token stored for future requests');
          }
        } catch (e, stackTrace) {
          debugPrint('Warning: Failed to create customer profile: $e');
          debugPrint('Stack trace: $stackTrace');
          
          // Even if profile creation fails, we'll proceed with auth
          // The profile can be created later when the user is authenticated
        }
      }

      return response;
    } catch (e, stackTrace) {
      debugPrint('Sign up error: $e');
      debugPrint('Stack trace: $stackTrace');
      throw AppAuthException('Sign up failed: $e');
    }
  }

  // Helper method to create customer profile using direct API call
  Future<void> _createCustomerProfileDirectly(String userId, String fullName, String email) async {
    try {
      // Get the current session
      final session = _client.auth.currentSession;
      
      if (session == null) {
        throw AppAuthException('No active session for profile creation');
      }
      
      // Create customer profile using direct REST API call with auth token
      final response = await _client.rest.from('customers')
        .insert({
          'id': userId,
          'full_name': fullName,
          'email': email,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();
      
      debugPrint('Customer profile created successfully: ${response['id']}');
    } catch (e) {
      // If this fails, we'll try an alternative approach
      debugPrint('Direct profile creation failed: $e');
      await _tryAlternativeProfileCreation(userId, fullName, email);
    }
  }
  
  // Alternative approach for profile creation
  Future<void> _tryAlternativeProfileCreation(String userId, String fullName, String email) async {
    try {
      // First, check if profile already exists (might have been created but error thrown)
      final existingProfile = await _client.from('customers')
        .select()
        .eq('id', userId)
        .maybeSingle();
        
      if (existingProfile != null) {
        debugPrint('Profile already exists, no need to create');
        return;
      }
      
      // Try with upsert instead of insert
      await _client.from('customers')
        .upsert({
          'id': userId,
          'full_name': fullName,
          'email': email,
          'created_at': DateTime.now().toIso8601String(),
        });
        
      debugPrint('Customer profile created with upsert method');
    } catch (e) {
      debugPrint('Alternative profile creation also failed: $e');
      // We'll still proceed with authentication
    }
  }

  // Sign in an existing user
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      debugPrint('Starting sign in for $email in auth repository');
      
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      debugPrint('Sign in response received: ${response.user != null}');

      if (response.user != null) {
        debugPrint('Storing user ID: ${response.user!.id}');
        // Store the user ID securely
        await SecureStorage.storeUserId(response.user!.id);
        
        // Store auth token
        if (response.session != null) {
          await SecureStorage.storeToken(response.session!.accessToken);
        }
        
        // Check if customer profile exists, create it if it doesn't
        try {
          final existingCustomer = await _client
              .from('customers')
              .select()
              .eq('id', response.user!.id)
              .maybeSingle();
              
          if (existingCustomer == null) {
            debugPrint('Creating missing customer profile');
            
            // Create customer profile with basic info
            await _client.from('customers').insert({
              'id': response.user!.id,
              'full_name': response.user!.userMetadata?['full_name'] ?? email.split('@')[0],
              'email': email,
              'created_at': DateTime.now().toIso8601String(),
            });
            
            debugPrint('Customer profile created during sign in');
          } else {
            debugPrint('Customer profile exists: ${existingCustomer['full_name']}');
          }
        } catch (e) {
          debugPrint('Error checking/creating customer profile: $e');
          // Continue anyway, as the user is authenticated
        }
      } else {
        debugPrint('Warning: No user returned from sign in');
      }

      return response;
    } catch (e, stackTrace) {
      debugPrint('Sign in error: $e');
      debugPrint('Stack trace: $stackTrace');
      
      if (e is AuthException) {
        throw AppAuthException('Sign in failed: ${e.message}');
      } else {
        throw AppAuthException('Sign in failed: $e');
      }
    }
  }
  
  // Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    try {
      // Step 1: Start OAuth flow
      final oAuthResponse = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.wealthapp://login-callback/',
      );
      
      // Check if the OAuth flow was started successfully
      if (!oAuthResponse) {
        throw AppAuthException('Failed to start Google OAuth flow');
      }
      
      // Since OAuth is a redirect flow in web, we can't directly get the user here
      // We need to handle the session in the callback URL
      
      // For testing/development, we'll check if there's already a user signed in
      // In a real app, you'd implement a proper OAuth callback handler
      final currentUser = _client.auth.currentUser;
      final session = _client.auth.currentSession;
      
      if (currentUser != null && session != null) {
        // Store auth info
        await SecureStorage.storeUserId(currentUser.id);
        await SecureStorage.storeToken(session.accessToken);
        
        // User is authenticated, check/create customer profile
        try {
          final existingCustomer = await _client
              .from('customers')
              .select()
              .eq('id', currentUser.id)
              .maybeSingle();
          
          // If not, create a new customer record
          if (existingCustomer == null) {
            await _createCustomerProfileDirectly(
              currentUser.id,
              currentUser.userMetadata?['full_name'] ?? '',
              currentUser.email ?? '',
            );
          }
        } catch (e) {
          // Log but don't fail if profile creation fails
          debugPrint('Warning: Failed to create/verify customer profile: $e');
        }
        
        // Return a synthetic AuthResponse with the current user and session
        return AuthResponse(
          user: currentUser,
          session: session,
        );
      } else {
        // For now, we'll create a mock AuthResponse for development
        // In production, this should be handled by the OAuth callback
        throw AppAuthException('Google sign-in flow started. Please complete authentication in the browser.');
      }
    } catch (e) {
      throw AppAuthException('Google sign in failed: $e');
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      await SecureStorage.deleteToken();
      await SecureStorage.clearAll();
    } catch (e) {
      throw AppAuthException('Sign out failed: $e');
    }
  }

  // Get customer profile data
  Future<Customer> getCustomerProfile() async {
    try {
      final user = _client.auth.currentUser;
      
      if (user == null) {
        throw AppAuthException('User not authenticated');
      }
      
      final response = await _client
          .from('customers')
          .select()
          .eq('id', user.id)
          .single();
      
      return Customer.fromJson(response);
    } catch (e) {
      throw DataException('Failed to load profile: $e');
    }
  }

  // Update customer profile data
  Future<Customer> updateCustomerProfile({
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      final user = _client.auth.currentUser;
      
      if (user == null) {
        throw AppAuthException('User not authenticated');
      }

      final updates = {
        'full_name': fullName,
        if (phoneNumber != null) 'phone_number': phoneNumber,
      };
      
      final response = await _client
          .from('customers')
          .update(updates)
          .eq('id', user.id)
          .select()
          .single();
      
      return Customer.fromJson(response);
    } catch (e) {
      throw DataException('Failed to update profile: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AppAuthException('Password reset failed: $e');
    }
  }
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(ref.watch(supabaseProvider));
} 