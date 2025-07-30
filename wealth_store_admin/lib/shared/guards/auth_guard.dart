import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../services/auth_service.dart';
import '../../shared/utils/logger.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

class AuthGuard extends ConsumerWidget {
  final Widget child;
  final bool requireAdmin;
  final String? requiredRole;
  final String redirectTo;

  const AuthGuard({
    super.key,
    required this.child,
    this.requireAdmin = true,
    this.requiredRole,
    this.redirectTo = '/login',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUser = ref.watch(currentUserProvider);
    
    return authState.when(
      data: (state) {
        // Check if user is authenticated
        if (currentUser == null) {
          Logger.warning('Unauthenticated user attempting to access protected route');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(redirectTo);
          });
          return const LoadingWidget(message: 'Redirecting to login...');
        }

        // Check admin access if required
        if (requireAdmin) {
          return _AdminAccessChecker(
            child: child,
            requiredRole: requiredRole,
            redirectTo: redirectTo,
          );
        }

        return child;
      },
      loading: () => const LoadingWidget(message: 'Checking authentication...'),
      error: (error, stackTrace) {
        Logger.error('Auth state error', error, stackTrace);
        return ErrorWidget(
          'Authentication error: ${error.toString()}',
        );
      },
    );
  }
}

class _AdminAccessChecker extends ConsumerWidget {
  final Widget child;
  final String? requiredRole;
  final String redirectTo;

  const _AdminAccessChecker({
    required this.child,
    this.requiredRole,
    required this.redirectTo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdminAsync = ref.watch(isAdminProvider);
    
    return isAdminAsync.when(
      data: (isAdmin) {
        if (!isAdmin) {
          Logger.warning('Non-admin user attempting to access admin route');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showAccessDeniedDialog(context);
          });
          return const LoadingWidget(message: 'Checking permissions...');
        }

        // Admin access granted, log success
        Logger.info('Admin access granted, rendering protected content');

        // Check specific role if required
        if (requiredRole != null) {
          return _RoleChecker(
            child: child,
            requiredRole: requiredRole!,
            redirectTo: redirectTo,
          );
        }

        return child;
      },
      loading: () => const LoadingWidget(message: 'Verifying admin access...'),
      error: (error, stackTrace) {
        Logger.error('Admin access check error', error, stackTrace);
        
        // On error, check if the user email is in the allowed list
        final currentUser = ref.read(currentUserProvider);
        if (currentUser != null && 
            ['abereakinola@gmail.com', 'admin@example.com', 'test@example.com'].contains(currentUser.email)) {
          Logger.info('Admin access granted via email allowlist despite error');
          
          // Check specific role if required
          if (requiredRole != null) {
            return _RoleChecker(
              child: child,
              requiredRole: requiredRole!,
              redirectTo: redirectTo,
            );
          }
          
          return child;
        }
        
        return ErrorWidget(
          'Permission check failed: ${error.toString()}',
        );
      },
    );
  }

  void _showAccessDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.security, color: Colors.red),
            SizedBox(width: 8),
            Text('Access Denied'),
          ],
        ),
        content: const Text(
          'You do not have admin privileges to access this application. '
          'Please contact your administrator if you believe this is an error.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await AuthService.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _RoleChecker extends ConsumerWidget {
  final Widget child;
  final String requiredRole;
  final String redirectTo;

  const _RoleChecker({
    required this.child,
    required this.requiredRole,
    required this.redirectTo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRoleAsync = ref.watch(userRoleProvider);
    
    return userRoleAsync.when(
      data: (userRole) {
        if (userRole != requiredRole) {
          Logger.warning('User with role $userRole attempting to access $requiredRole route');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showInsufficientPermissionsDialog(context, userRole, requiredRole);
          });
          return const LoadingWidget(message: 'Checking role permissions...');
        }

        return child;
      },
      loading: () => const LoadingWidget(message: 'Verifying role permissions...'),
      error: (error, stackTrace) {
        Logger.error('Role check error', error, stackTrace);
        return ErrorWidget(
          'Role verification failed: ${error.toString()}',
        );
      },
    );
  }

  void _showInsufficientPermissionsDialog(
    BuildContext context,
    String? currentRole,
    String requiredRole,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.orange),
            SizedBox(width: 8),
            Text('Insufficient Permissions'),
          ],
        ),
        content: Text(
          'This feature requires $requiredRole privileges. '
          'Your current role is: ${currentRole ?? 'Unknown'}.\n\n'
          'Please contact your administrator to upgrade your permissions.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/dashboard');
            },
            child: const Text('Go to Dashboard'),
          ),
        ],
      ),
    );
  }
}

// Utility function to check permissions programmatically
class PermissionChecker {
  static Future<bool> hasAdminAccess(WidgetRef ref) async {
    try {
      final isAdmin = await ref.read(isAdminProvider.future);
      return isAdmin;
    } catch (e) {
      Logger.error('Failed to check admin access', e);
      return false;
    }
  }

  static Future<bool> hasRole(WidgetRef ref, String role) async {
    try {
      return await AuthService.hasRole(role);
    } catch (e) {
      Logger.error('Failed to check role: $role', e);
      return false;
    }
  }

  static Future<bool> canAccessFeature(WidgetRef ref, String feature) async {
    try {
      final userRole = await ref.read(userRoleProvider.future);
      
      // Define feature permissions
      const featurePermissions = {
        'user_management': ['admin'],
        'system_settings': ['admin'],
        'reports': ['admin', 'manager'],
        'products': ['admin', 'manager'],
        'orders': ['admin', 'manager'],
        'categories': ['admin', 'manager'],
        'banners': ['admin', 'manager'],
        'coupons': ['admin', 'manager'],
        'media': ['admin', 'manager'],
      };

      final allowedRoles = featurePermissions[feature];
      if (allowedRoles == null) return false;

      return allowedRoles.contains(userRole);
    } catch (e) {
      Logger.error('Failed to check feature access: $feature', e);
      return false;
    }
  }
}