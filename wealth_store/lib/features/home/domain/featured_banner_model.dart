import 'package:flutter/material.dart';

/// Featured banner model for home screen promotional content
class FeaturedBanner {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String targetRoute;
  final Color backgroundColor;
  final Color textColor;
  final bool isActive;

  const FeaturedBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.targetRoute,
    required this.backgroundColor,
    this.textColor = Colors.black,
    this.isActive = true,
  });

  FeaturedBanner copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? targetRoute,
    Color? backgroundColor,
    Color? textColor,
    bool? isActive,
  }) {
    return FeaturedBanner(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      targetRoute: targetRoute ?? this.targetRoute,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Predefined featured banners for home screen
class DefaultFeaturedBanners {
  static const List<FeaturedBanner> banners = [
    FeaturedBanner(
      id: 'sneakers-week',
      title: 'SNEAKERS OF\nTHE WEEK',
      subtitle: 'Nike',
      imageUrl: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400&h=300&fit=crop',
      targetRoute: '/products?category=shoes&featured=true',
      backgroundColor: Color(0xFFE8E8E8),
      textColor: Colors.black,
    ),
    FeaturedBanner(
      id: 'electronics-sale',
      title: 'TECH DEALS\nUP TO 50% OFF',
      subtitle: 'Electronics',
      imageUrl: 'https://images.unsplash.com/photo-1468495244123-6c6c332eeece?w=400&h=300&fit=crop',
      targetRoute: '/products?category=electronics&sale=true',
      backgroundColor: Color(0xFF1E3A8A),
      textColor: Colors.white,
    ),
    FeaturedBanner(
      id: 'furniture-collection',
      title: 'NEW FURNITURE\nCOLLECTION',
      subtitle: 'Home & Living',
      imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=300&fit=crop',
      targetRoute: '/products?category=furniture&new=true',
      backgroundColor: Color(0xFFF3F4F6),
      textColor: Colors.black,
    ),
  ];
}