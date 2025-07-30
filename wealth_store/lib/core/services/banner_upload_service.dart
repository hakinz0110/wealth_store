import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wealth_app/core/services/supabase_storage_service.dart';

part 'banner_upload_service.g.dart';

class BannerUploadService {
  final SupabaseStorageService _storageService;
  
  BannerUploadService(this._storageService);
  
  /// Upload banner images to Supabase Storage
  /// This is a helper method for initial setup
  Future<List<String>> uploadDefaultBanners() async {
    final uploadedUrls = <String>[];
    
    try {
      // List of banner file names that should be in your Supabase Storage
      final bannerFiles = [
        'sneakers-banner.png',
        'electronics-banner.png', 
        'furniture-banner.png',
        'fashion-banner.png',
        'sports-banner.png',
      ];
      
      for (final fileName in bannerFiles) {
        // Check if banner already exists
        final exists = await _storageService.imageExists(
          SupabaseStorageService.projectImagesBucket,
          fileName,
        );
        
        if (exists) {
          // Get existing URL
          final url = _storageService.getProjectImageUrl(fileName);
          uploadedUrls.add(url);
          print('Banner already exists: $fileName -> $url');
        } else {
          print('Banner missing: $fileName - Please upload to Supabase Storage');
          // You can add placeholder URL or skip
          final placeholderUrl = _storageService.getProjectImageUrl(fileName);
          uploadedUrls.add(placeholderUrl);
        }
      }
      
      return uploadedUrls;
    } catch (e) {
      print('Error checking banner images: $e');
      return [];
    }
  }
  
  /// Upload a single banner image
  Future<String?> uploadBanner({
    required String fileName,
    required Uint8List imageBytes,
  }) async {
    try {
      final url = await _storageService.uploadImage(
        bucketName: SupabaseStorageService.projectImagesBucket,
        fileName: fileName,
        imageBytes: imageBytes,
        contentType: 'image/png',
      );
      
      print('Banner uploaded successfully: $fileName -> $url');
      return url;
    } catch (e) {
      print('Failed to upload banner $fileName: $e');
      return null;
    }
  }
  
  /// Get all banner URLs from Supabase Storage
  Future<List<String>> getAllBannerUrls() async {
    try {
      final files = await _storageService.listImages(
        SupabaseStorageService.projectImagesBucket,
      );
      
      return files
          .where((file) => file.name.toLowerCase().contains('banner'))
          .map((file) => _storageService.getProjectImageUrl(file.name))
          .toList();
    } catch (e) {
      print('Error getting banner URLs: $e');
      return [];
    }
  }
}

@riverpod
BannerUploadService bannerUploadService(BannerUploadServiceRef ref) {
  return BannerUploadService(ref.watch(supabaseStorageServiceProvider));
}