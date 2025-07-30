import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../shared/utils/logger.dart';

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

    try {
      // Handle app launch from deep link
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        Logger.info('Initial deep link received: $initialUri');
        await _handleDeepLink(initialUri);
      }

      // Handle deep links while app is running
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (uri) async {
          Logger.info('Deep link received: $uri');
          await _handleDeepLink(uri);
        },
        onError: (err) {
          Logger.error('Deep link error', err);
        },
      );

      Logger.info('Deep link service initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize deep link service', e);
    }
  }

  /// Handle incoming deep links
  Future<void> _handleDeepLink(Uri uri) async {
    try {
      // Handle password reset deep links
      if (uri.path == '/reset-password') {
        await _handlePasswordResetLink(uri);
      } else {
        Logger.warning('Unhandled deep link path: ${uri.path}');
      }
    } catch (e) {
      Logger.error('Error handling deep link', e);
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

        Logger.info('Session set successfully from deep link');

        // Navigate to password reset screen
        _router?.go('/reset-password?access_token=$accessToken&refresh_token=$refreshToken');
      } catch (e) {
        Logger.error('Error setting session from deep link', e);
        // Navigate to forgot password screen with error
        _router?.go('/forgot-password');
      }
    } else {
      Logger.warning('Invalid password reset link parameters');
      _router?.go('/forgot-password');
    }
  }

  /// Dispose resources
  void dispose() {
    _linkSubscription?.cancel();
    Logger.info('Deep link service disposed');
  }
}