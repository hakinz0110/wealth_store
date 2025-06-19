import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final List<String> subcategories;
  final String? iconName;
  final String? color;
  final String? imageUrl;
  final bool isVisible;

  CategoryModel({
    required this.id,
    required this.name,
    this.subcategories = const [],
    this.iconName,
    this.color,
    this.imageUrl,
    this.isVisible = true,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      subcategories: List<String>.from(data['subcategories'] ?? []),
      iconName: data['iconName'],
      color: data['color'],
      imageUrl: data['imageUrl'],
      isVisible: data['isVisible'] ?? true,
    );
  }

  // Helper method to convert iconName string to IconData
  IconData getIconData() {
    // Default icon if none specified
    if (iconName == null || iconName!.isEmpty) {
      return Icons.category;
    }

    // Map common icon names to IconData
    switch (iconName) {
      case 'devices':
        return Icons.devices;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'home':
        return Icons.home;
      case 'spa':
        return Icons.spa;
      case 'sports_basketball':
        return Icons.sports_basketball;
      case 'book':
        return Icons.book;
      case 'toys':
        return Icons.toys;
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'restaurant':
        return Icons.restaurant;
      case 'checkroom':
        return Icons.checkroom;
      case 'child_care':
        return Icons.child_care;
      case 'menu_book':
        return Icons.menu_book;
      default:
        return Icons.category;
    }
  }

  // Helper method to convert color string to Color
  Color getColor() {
    if (color == null || color!.isEmpty) {
      return const Color(0xFF6518F4); // Default purple color
    }

    try {
      // Handle hex color format (0xFF6518F4)
      if (color!.startsWith('0x')) {
        return Color(int.parse(color!));
      }

      // Handle hex color format (#6518F4)
      if (color!.startsWith('#')) {
        return Color(int.parse('0xFF${color!.substring(1)}'));
      }

      return const Color(0xFF6518F4); // Default if parsing fails
    } catch (e) {
      return const Color(0xFF6518F4); // Default if parsing fails
    }
  }
}

class CategoryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CategoryProvider() {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final snapshot = await _firestore
          .collection('categories')
          .orderBy('name')
          .get();

      _categories = snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();

      // Filter out invisible categories - only show categories marked as visible
      _categories = _categories
          .where((category) => category.isVisible)
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;

      // If we can't fetch from Firestore, use default categories
      _createDefaultCategories();

      notifyListeners();
    }
  }

  void _createDefaultCategories() {
    _categories = [
      CategoryModel(
        id: '1',
        name: 'Electronics',
        subcategories: [
          'Smartphones',
          'Laptops',
          'Tablets',
          'Smartwatches',
          'Gaming Consoles',
        ],
        iconName: 'devices',
        color: '0xFF1976D2',
        imageUrl: '',
        isVisible: true,
      ),
      CategoryModel(
        id: '2',
        name: 'Fashion',
        subcategories: [
          'Women\'s Clothing',
          'Men\'s Clothing',
          'Kids\' Clothing',
          'Shoes',
          'Accessories',
        ],
        iconName: 'checkroom',
        color: '0xFF9C27B0',
        imageUrl: '',
        isVisible: true,
      ),
      CategoryModel(
        id: '3',
        name: 'Home & Kitchen',
        subcategories: [
          'Furniture',
          'Home Decor',
          'Kitchen Appliances',
          'Cookware',
          'Dinnerware',
        ],
        iconName: 'home',
        color: '0xFF4CAF50',
        imageUrl: '',
        isVisible: true,
      ),
      CategoryModel(
        id: '4',
        name: 'Beauty & Health',
        subcategories: ['Skincare', 'Haircare', 'Makeup', 'Fragrances'],
        iconName: 'spa',
        color: '0xFFE91E63',
        imageUrl: '',
        isVisible: true,
      ),
      CategoryModel(
        id: '5',
        name: 'Sports & Outdoors',
        subcategories: ['Fitness Equipment', 'Sports Gear', 'Outdoor Gear'],
        iconName: 'sports_basketball',
        color: '0xFFFF9800',
        imageUrl: '',
        isVisible: true,
      ),
      CategoryModel(
        id: '6',
        name: 'Books & Media',
        subcategories: ['Books', 'E-books', 'Music', 'Movies'],
        iconName: 'menu_book',
        color: '0xFF795548',
        imageUrl: '',
        isVisible: true,
      ),
    ];
  }
}
