import 'package:supabase_flutter/supabase_flutter.dart';

class ImageUrlHelper {
  static const String productImagesBucket = 'product-images';
  static const String categoryIconsBucket = 'category-icons';
  static const String customerAvatarsBucket = 'customer-avatars';
  
  /// Get the full public URL for a product image
  static String getProductImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    
    // If it's already a full URL, return as is
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    
    // Get the public URL from Supabase storage
    try {
      return Supabase.instance.client.storage
          .from(productImagesBucket)
          .getPublicUrl(imagePath);
    } catch (e) {
      // Fallback to a placeholder or return empty string
      return '';
    }
  }
  
  /// Get the full public URL for a category icon
  static String getCategoryIconUrl(String iconPath) {
    if (iconPath.isEmpty) return '';
    
    if (iconPath.startsWith('http')) {
      return iconPath;
    }
    
    try {
      return Supabase.instance.client.storage
          .from(categoryIconsBucket)
          .getPublicUrl(iconPath);
    } catch (e) {
      return '';
    }
  }
  
  /// Get the full public URL for a customer avatar
  static String getCustomerAvatarUrl(String avatarPath) {
    if (avatarPath.isEmpty) return '';
    
    if (avatarPath.startsWith('http')) {
      return avatarPath;
    }
    
    try {
      return Supabase.instance.client.storage
          .from(customerAvatarsBucket)
          .getPublicUrl(avatarPath);
    } catch (e) {
      return '';
    }
  }
  
  /// Check if an image URL is valid
  static bool isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}