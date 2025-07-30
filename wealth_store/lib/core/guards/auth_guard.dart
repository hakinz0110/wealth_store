import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/error_widget.dart';

class AuthGuard extends ConsumerWidget {
  final Widget child;
  final bool requireAuth;
  final String redirectTo;

  const AuthGuard({
    super.key,
    required this.child,
    this.requireAuth = true,
    this.redirectTo = '/login',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUser = ref.watch(currentUserProvider);
    
    return authState.when(
      data: (state) {
        // Check if authentication is required
        if (requireAuth && currentUser == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(redirectTo);
          });
          return const LoadingWidget(message: 'Redirecting to login...');
        }

        // If not requiring auth or user is authenticated, show child
        return child;
      },
      loading: () => const LoadingWidget(message: 'Checking authentication...'),
      error: (error, stackTrace) {
        return CustomErrorWidget(
          error: 'Authentication error: ${error.toString()}',
          onRetry: () => ref.refresh(authStateProvider),
        );
      },
    );
  }
}

class ProfileGuard extends ConsumerWidget {
  final Widget child;
  final String redirectTo;

  const ProfileGuard({
    super.key,
    required this.child,
    this.redirectTo = '/login',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final currentUser = ref.watch(currentUserProvider);
    
    if (currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(redirectTo);
      });
      return const LoadingWidget(message: 'Redirecting to login...');
    }
    
    return userProfileAsync.when(
      data: (profile) {
        if (profile == null) {
          return const CustomErrorWidget(
            error: 'Unable to load user profile. Please try signing in again.',
          );
        }

        // Check if user account is active
        final isActive = profile['is_active'] as bool? ?? true;
        if (!isActive) {
          return _buildAccountDeactivatedWidget(context);
        }

        return child;
      },
      loading: () => const LoadingWidget(message: 'Loading profile...'),
      error: (error, stackTrace) {
        return CustomErrorWidget(
          error: 'Failed to load profile: ${error.toString()}',
          onRetry: () => ref.refresh(userProfileProvider),
        );
      },
    );
  }

  Widget _buildAccountDeactivatedWidget(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_circle_outlined,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              const Text(
                'Account Deactivated',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your account has been deactivated. Please contact support for assistance.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await AuthService.signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Utility class for permission checking
class PermissionChecker {
  static Future<bool> isAuthenticated(WidgetRef ref) async {
    try {
      final user = ref.read(currentUserProvider);
      return user != null;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> hasActiveProfile(WidgetRef ref) async {
    try {
      final profile = await ref.read(userProfileProvider.future);
      if (profile == null) return false;
      
      return profile['is_active'] as bool? ?? true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isCustomer(WidgetRef ref) async {
    try {
      return await ref.read(isCustomerProvider.future);
    } catch (e) {
      return false;
    }
  }

  static Future<String?> getUserRole(WidgetRef ref) async {
    try {
      return await ref.read(userRoleProvider.future);
    } catch (e) {
      return null;
    }
  }
}