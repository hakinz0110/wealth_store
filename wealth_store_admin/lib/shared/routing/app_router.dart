import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../features/auth/providers/developer_auth_provider.dart';
import '../guards/auth_guard.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/auth/screens/developer_login_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/products/screens/products_screen.dart';
import '../../features/products/screens/add_product_screen.dart';
import '../../features/products/screens/edit_product_screen.dart';
import '../../features/categories/screens/categories_screen.dart';

import '../../features/banners/screens/banners_screen.dart';

import '../../features/storage/file_manager.dart';

import '../widgets/admin_layout.dart';





class BrandsScreen extends StatelessWidget {
  const BrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      title: 'Banners',
      currentRoute: '/banners',
      breadcrumbs: ['Dashboard', 'Banners'],
      child: BannersScreen(),
    );
  }
}

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      title: 'Customers',
      currentRoute: '/customers',
      breadcrumbs: ['Dashboard', 'Customers'],
      child: Center(
        child: Text(
          'Customers Management Screen\nComing Soon...',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      title: 'Orders',
      currentRoute: '/orders',
      breadcrumbs: ['Dashboard', 'Orders'],
      child: Center(
        child: Text(
          'Orders Management Screen\nComing Soon...',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class CouponsScreen extends StatelessWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      title: 'Coupons',
      currentRoute: '/coupons',
      breadcrumbs: ['Dashboard', 'Coupons'],
      child: Center(
        child: Text(
          'Coupons Management Screen\nComing Soon...',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      title: 'Settings',
      currentRoute: '/settings',
      breadcrumbs: ['Dashboard', 'Settings'],
      child: Center(
        child: Text(
          'Settings Screen\nComing Soon...',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      title: 'Activity Logs',
      currentRoute: '/logs',
      breadcrumbs: ['Dashboard', 'Logs'],
      child: Center(
        child: Text(
          'Activity Logs Screen\nComing Soon...',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

// Router configuration
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final developerAuth = ref.watch(developerAuthProvider);
  
  return GoRouter(
    initialLocation: '/dashboard',
    debugLogDiagnostics: true, // Enable debug logging for router
    redirect: (context, state) {
      // Log navigation attempts for debugging
      print('Navigation attempt to: ${state.matchedLocation}');
      
      // Allow access to auth-related routes without authentication
      final publicRoutes = [
        '/login',
        '/register',
        '/forgot-password',
        '/reset-password',
        '/developer-login',
      ];
      
      if (publicRoutes.contains(state.matchedLocation)) {
        // If already authenticated and trying to access login page, redirect to dashboard
        if (state.matchedLocation == '/login') {
          final isAuthenticated = authState.maybeWhen(
            data: (auth) => auth.session?.user != null,
            orElse: () => false,
          );
          
          if (isAuthenticated || developerAuth) {
            print('Already authenticated, redirecting to dashboard');
            return '/dashboard';
          }
        }
        
        return null; // Allow access to public routes
      }
      
      return authState.when(
        data: (auth) {
          final isAuthenticated = (auth.session?.user != null) || developerAuth;
          
          // If not authenticated, redirect to login
          if (!isAuthenticated) {
            print('Not authenticated, redirecting to login');
            return '/login';
          }
          
          // Check if user is admin (for critical routes only)
          if (state.matchedLocation == '/settings' || 
              state.matchedLocation == '/users' ||
              state.matchedLocation.startsWith('/logs')) {
            
            // For these routes, we'll let the AuthGuard handle the check
            // to avoid unnecessary API calls during navigation
            print('Protected route access, letting AuthGuard handle it');
          }
          
          // No redirect needed for authenticated users
          print('Authenticated, allowing access to: ${state.matchedLocation}');
          return null;
        },
        loading: () {
          if (developerAuth) {
            print('Auth loading but developer mode active, allowing access');
            return null;
          }
          
          // During loading, allow access to dashboard but redirect other routes to login
          if (state.matchedLocation == '/dashboard') {
            print('Auth loading, allowing access to dashboard');
            return null;
          }
          
          print('Auth loading, redirecting to login');
          return '/login';
        },
        error: (error, stackTrace) {
          print('Auth error: $error');
          if (developerAuth) {
            print('Auth error but developer mode active, allowing access');
            return null;
          }
          
          print('Auth error, redirecting to login');
          return '/login';
        },
      );
    },
    routes: [
      // Login route
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Register route (for development only)
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Developer login route
      GoRoute(
        path: '/developer-login',
        builder: (context, state) => const DeveloperLoginScreen(),
      ),
      
      // Forgot password route
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      
      // Reset password route
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final accessToken = state.uri.queryParameters['access_token'];
          final refreshToken = state.uri.queryParameters['refresh_token'];
          return ResetPasswordScreen(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        },
      ),
      
      // Dashboard route (default)
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const AuthGuard(
          child: DashboardScreen(),
        ),
      ),
      

      
      // Storage management
      GoRoute(
        path: '/storage',
        builder: (context, state) => const AuthGuard(
          child: AdminLayout(
            title: 'Storage Management',
            currentRoute: '/storage',
            breadcrumbs: ['Dashboard', 'Storage'],
            child: FileManager(),
          ),
        ),
      ),
      
      // Storage debug test

      

      
      // Products management
      GoRoute(
        path: '/products',
        builder: (context, state) => const AuthGuard(
          child: ProductsScreen(),
        ),
        routes: [
          // Add product
          GoRoute(
            path: 'add',
            builder: (context, state) => const AuthGuard(
              child: AddProductScreen(),
            ),
          ),
          // Edit product
          GoRoute(
            path: 'edit/:id',
            builder: (context, state) {
              final productId = state.pathParameters['id']!;
              return AuthGuard(
                child: EditProductScreen(productId: productId),
              );
            },
          ),
        ],
      ),
      
      // Categories management
      GoRoute(
        path: '/categories',
        builder: (context, state) => const AuthGuard(
          child: CategoriesScreen(),
        ),
      ),
      
      // Banners management
      GoRoute(
        path: '/banners',
        builder: (context, state) => const AuthGuard(
          child: BrandsScreen(),
        ),
      ),
      
      // Customers management (Admin only)
      GoRoute(
        path: '/customers',
        builder: (context, state) => const AuthGuard(
          requiredRole: 'admin',
          child: CustomersScreen(),
        ),
      ),
      
      // Orders management
      GoRoute(
        path: '/orders',
        builder: (context, state) => const AuthGuard(
          child: OrdersScreen(),
        ),
      ),
      
      // Coupons management
      GoRoute(
        path: '/coupons',
        builder: (context, state) => const AuthGuard(
          child: CouponsScreen(),
        ),
      ),
      
      // Settings (Admin only)
      GoRoute(
        path: '/settings',
        builder: (context, state) => const AuthGuard(
          requiredRole: 'admin',
          child: SettingsScreen(),
        ),
      ),
      
      // Activity logs (Admin only)
      GoRoute(
        path: '/logs',
        builder: (context, state) => const AuthGuard(
          requiredRole: 'admin',
          child: LogsScreen(),
        ),
      ),
      
      // Root redirect
      GoRoute(
        path: '/',
        redirect: (context, state) => '/dashboard',
      ),
    ],
  );
});