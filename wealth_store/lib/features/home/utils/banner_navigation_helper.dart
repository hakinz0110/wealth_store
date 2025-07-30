import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wealth_app/shared/models/banner.dart' as app_banner;

/// Helper class for handling banner navigation
class BannerNavigationHelper {
  /// Navigate based on banner link URL
  static void navigateFromBanner(BuildContext context, app_banner.Banner banner) {
    if (banner.linkUrl == null || banner.linkUrl!.isEmpty) {
      return;
    }
    
    final linkUrl = banner.linkUrl!;
    
    // Handle internal routes
    if (linkUrl.startsWith('/')) {
      context.push(linkUrl);
      return;
    }
    
    // Handle category links
    if (linkUrl.startsWith('category:')) {
      final categoryId = linkUrl.substring('category:'.length);
      context.push('/categories/$categoryId');
      return;
    }
    
    // Handle product links
    if (linkUrl.startsWith('product:')) {
      final productId = linkUrl.substring('product:'.length);
      context.push('/products/$productId');
      return;
    }
    
    // Handle external URLs
    if (linkUrl.startsWith('http://') || linkUrl.startsWith('https://')) {
      _launchUrl(linkUrl);
      return;
    }
  }
  
  /// Launch external URL
  static Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }
}