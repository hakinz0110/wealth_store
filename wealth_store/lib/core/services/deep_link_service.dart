import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  GoRouter? _router;

  /// Initialize deep link handling
  Future<void> initialize(GoRouter router) async {
    _router = router;
    _appLinks = AppLinks();

    // Handle app launch from deep link
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      await _handleDeepLink(initialUri);
    }

    // Handle deep links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (err) {
        debugPrint('Deep link error: $err');
      },
    );
  }

  /// Handle incoming deep links
  Future<void> _handleDeepLink(Uri uri) async {
    debugPrint('Received deep link: $uri');

    try {
      // Handle password reset deep links
      if (uri.path == '/password-update') {
        await _handlePasswordResetLink(uri);
      } else {
        debugPrint('Unhandled deep link path: ${uri.path}');
      }
    } catch (e) {
      debugPrint('Error handling deep link: $e');
    }
  }

  /// Handle password reset deep links
  Future<void> _handlePasswordResetLink(Uri uri) async {
    final accessToken = uri.queryParameters['access_token'];
    final refreshToken = uri.queryParameters['refresh_token'];
    final type = uri.queryParameters['type'];

    if (type == 'recovery' && accessToken != null && refreshToken != null) {
      // Set the session with the tokens from the deep link
      try {
        await Supabase.instance.client.auth.recoverSession(accessToken);

        // Navigate to password update screen
        _router?.go('/password-update?access_token=$accessToken&refresh_token=$refreshToken');
      } catch (e) {
        debugPrint('Error setting session from deep link: $e');
        // Navigate to password reset screen with error
        _router?.go('/password-reset');
      }
    } else {
      debugPrint('Invalid password reset link parameters');
      _router?.go('/password-reset');
    }
  }

  /// Dispose resources
  void dispose() {
    _linkSubscription?.cancel();
  }
}