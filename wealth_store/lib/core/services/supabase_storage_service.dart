import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealth_app/core/services/supabase_service.dart';

part 'supabase_storage_service.g.dart';

class SupabaseStorageService {
  final SupabaseClient _client;
  
  SupabaseStorageService(this._client);
  
  // Storage bucket names
  static const String productImagesBucket = 'product-images';
  static const String categoryIconsBucket = 'category-icons';
  static const String customerAvatarsBucket = 'customer-avatars';
  static const String adminAvatarsBucket = 'admin-avatars';
  static const String projectImagesBucket = 'project-images';
  
  /// Get public URL for an image in a specific bucket
  String getPublicUrl(String bucketName, String fileName) {
    return _client.storage.from(bucketName).getPublicUrl(fileName);
  }
  
  /// Get product image URL
  String getProductImageUrl(String productId) {
    return getPublicUrl(productImagesBucket, '$productId.png');
  }
  
  /// Get category icon URL
  String getCategoryIconUrl(String categoryId) {
    return getPublicUrl(categoryIconsBucket, '$categoryId.png');
  }
  
  /// Get customer avatar URL
  String getCustomerAvatarUrl(String customerId) {
    return getPublicUrl(customerAvatarsBucket, '$customerId.png');
  }
  
  /// Get project/banner image URL
  String getProjectImageUrl(String imageName) {
    return getPublicUrl(projectImagesBucket, imageName);
  }
  
  /// Upload image to storage bucket
  Future<String> uploadImage({
    required String bucketName,
    required String fileName,
    required Uint8List imageBytes,
    String contentType = 'image/png',
  }) async {
    try {
      await _client.storage.from(bucketName).uploadBinary(
        fileName,
        imageBytes,
        fileOptions: FileOptions(
          contentType: contentType,
          upsert: true, // Allow overwriting existing files
        ),
      );
      
      return getPublicUrl(bucketName, fileName);
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
  
  /// Check if image exists in storage
  Future<bool> imageExists(String bucketName, String fileName) async {
    try {
      final files = await _client.storage.from(bucketName).list(
        path: '',
        searchOptions: const SearchOptions(
          limit: 1,
        ),
      );
      
      return files.any((file) => file.name == fileName);
    } catch (e) {
      return false;
    }
  }
  
  /// List all images in a bucket
  Future<List<FileObject>> listImages(String bucketName) async {
    try {
      return await _client.storage.from(bucketName).list();
    } catch (e) {
      throw Exception('Failed to list images: $e');
    }
  }
  
  /// Delete image from storage
  Future<void> deleteImage(String bucketName, String fileName) async {
    try {
      await _client.storage.from(bucketName).remove([fileName]);
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }
  
  /// Get banner images from project-images bucket
  Future<List<String>> getBannerImages() async {
    try {
      final files = await listImages(projectImagesBucket);
      
      // Filter for banner images (you can customize this logic)
      final bannerFiles = files.where((file) => 
        file.name.toLowerCase().contains('banner') ||
        file.name.toLowerCase().contains('slide') ||
        file.name.toLowerCase().contains('hero')
      ).toList();
      
      return bannerFiles.map((file) => getProjectImageUrl(file.name)).toList();
    } catch (e) {
      // Return default banner images if none found
      return [
        getProjectImageUrl('banner1.png'),
        getProjectImageUrl('banner2.png'),
        getProjectImageUrl('banner3.png'),
        getProjectImageUrl('banner4.png'),
      ];
    }
  }
}

@riverpod
SupabaseStorageService supabaseStorageService(SupabaseStorageServiceRef ref) {
  return SupabaseStorageService(ref.watch(supabaseProvider));
}