import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wealth_app/features/home/domain/featured_banner_model.dart';
import 'package:wealth_app/core/services/supabase_storage_service.dart';

part 'featured_banner_service.g.dart';

class FeaturedBannerService {
  final SupabaseStorageService _storageService;
  
  FeaturedBannerService(this._storageService);
  
  /// Get featured banners for home screen display using Supabase Storage
  Future<List<FeaturedBanner>> getFeaturedBanners() async {
    try {
      // Get banner images from Supabase Storage
      final bannerImageUrls = await _storageService.getBannerImages();
      
      // Create banners with Supabase Storage URLs
      final banners = <FeaturedBanner>[
        FeaturedBanner(
          id: 'sneakers-week',
          title: 'SNEAKERS OF\nTHE WEEK',
          subtitle: 'Nike',
          imageUrl: _storageService.getProjectImageUrl('sneakers-banner.png'),
          targetRoute: '/products?category=shoes&featured=true',
          backgroundColor: const Color(0xFFE8E8E8),
          textColor: Colors.black,
        ),
        FeaturedBanner(
          id: 'electronics-sale',
          title: 'TECH DEALS\nUP TO 50% OFF',
          subtitle: 'Electronics',
          imageUrl: _storageService.getProjectImageUrl('electronics-banner.png'),
          targetRoute: '/products?category=electronics&sale=true',
          backgroundColor: const Color(0xFF1E3A8A),
          textColor: Colors.white,
        ),
        FeaturedBanner(
          id: 'furniture-collection',
          title: 'NEW FURNITURE\nCOLLECTION',
          subtitle: 'Home & Living',
          imageUrl: _storageService.getProjectImageUrl('furniture-banner.png'),
          targetRoute: '/products?category=furniture&new=true',
          backgroundColor: const Color(0xFFF3F4F6),
          textColor: Colors.black,
        ),
        FeaturedBanner(
          id: 'fashion-trends',
          title: 'LATEST FASHION\nTRENDS 2024',
          subtitle: 'Clothing',
          imageUrl: _storageService.getProjectImageUrl('fashion-banner.png'),
          targetRoute: '/products?category=clothes&trending=true',
          backgroundColor: const Color(0xFFFF6B6B),
          textColor: Colors.white,
        ),
        FeaturedBanner(
          id: 'sports-gear',
          title: 'SPORTS GEAR\nCOLLECTION',
          subtitle: 'Sports & Fitness',
          imageUrl: _storageService.getProjectImageUrl('sports-banner.png'),
          targetRoute: '/products?category=sports&collection=gear',
          backgroundColor: const Color(0xFF4ECDC4),
          textColor: Colors.white,
        ),
      ];
      
      return banners.where((banner) => banner.isActive).toList();
    } catch (e) {
      // Fallback to default banners if Supabase fails
      return DefaultFeaturedBanners.banners
          .where((banner) => banner.isActive)
          .toList();
    }
  }

  /// Get banner by ID
  Future<FeaturedBanner?> getBannerById(String id) async {
    try {
      final banners = await getFeaturedBanners();
      return banners.firstWhere((banner) => banner.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Check if banner is currently active
  bool isBannerActive(String id) {
    return DefaultFeaturedBanners.banners
        .any((banner) => banner.id == id && banner.isActive);
  }

  /// Get banner count for page indicators
  Future<int> getBannerCount() async {
    final banners = await getFeaturedBanners();
    return banners.length;
  }
}

@riverpod
FeaturedBannerService featuredBannerService(FeaturedBannerServiceRef ref) {
  return FeaturedBannerService(ref.watch(supabaseStorageServiceProvider));
}

@riverpod
Future<List<FeaturedBanner>> featuredBanners(FeaturedBannersRef ref) async {
  final service = ref.watch(featuredBannerServiceProvider);
  return service.getFeaturedBanners();
}