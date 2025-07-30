import 'package:flutter/material.dart';
import 'package:wealth_app/shared/models/category.dart';

/// Enhanced category model for home screen display with icon and routing information
class HomeCategory {
  final int id;
  final String name;
  final IconData icon;
  final String route;
  final Category? originalCategory;

  const HomeCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.route,
    this.originalCategory,
  });

  /// Create HomeCategory from existing Category model
  factory HomeCategory.fromCategory(Category category) {
    return HomeCategory(
      id: category.id,
      name: category.name,
      icon: _getIconForCategory(category.name),
      route: '/products?category=${category.id}',
      originalCategory: category,
    );
  }

  /// Get appropriate icon for category name
  static IconData _getIconForCategory(String categoryName) {
    final name = categoryName.toLowerCase();
    
    if (name.contains('sport') || name.contains('fitness') || name.contains('gym')) {
      return Icons.sports_soccer;
    } else if (name.contains('furniture') || name.contains('home') || name.contains('decor')) {
      return Icons.chair;
    } else if (name.contains('electronic') || name.contains('tech') || name.contains('phone') || name.contains('computer')) {
      return Icons.smartphone;
    } else if (name.contains('cloth') || name.contains('fashion') || name.contains('apparel') || name.contains('wear')) {
      return Icons.checkroom;
    } else if (name.contains('animal') || name.contains('pet') || name.contains('dog') || name.contains('cat')) {
      return Icons.pets;
    } else if (name.contains('shoe') || name.contains('footwear') || name.contains('sneaker')) {
      return Icons.sports_tennis;
    } else {
      return Icons.category;
    }
  }
}

/// Predefined popular categories for home screen
class PopularCategories {
  static const List<HomeCategory> defaultCategories = [
    HomeCategory(
      id: 1,
      name: 'Sports',
      icon: Icons.sports_soccer,
      route: '/products?category=sports',
    ),
    HomeCategory(
      id: 2,
      name: 'Furniture',
      icon: Icons.chair,
      route: '/products?category=furniture',
    ),
    HomeCategory(
      id: 3,
      name: 'Electronics',
      icon: Icons.smartphone,
      route: '/products?category=electronics',
    ),
    HomeCategory(
      id: 4,
      name: 'Clothes',
      icon: Icons.checkroom,
      route: '/products?category=clothes',
    ),
    HomeCategory(
      id: 5,
      name: 'Animals',
      icon: Icons.pets,
      route: '/products?category=animals',
    ),
    HomeCategory(
      id: 6,
      name: 'Shoes',
      icon: Icons.sports_tennis,
      route: '/products?category=shoes',
    ),
  ];
}