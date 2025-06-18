import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = false;
  String? _selectedCategory = 'All';
  String _searchQuery = '';

  List<ProductModel> get products => _products;
  List<ProductModel> get filteredProducts => _filteredProducts;
  bool get isLoading => _isLoading;
  String? get selectedCategory => _selectedCategory;
  List<String> get categories {
    final categorySet = <String>{'All'};
    for (var product in _products) {
      categorySet.add(product.category);
    }
    return categorySet.toList();
  }

  Future<void> fetchProducts() async {
    // Ensure we're not already loading
    if (_isLoading) return;

    try {
      // Set loading state before async operation
      _isLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      final snapshot = await _firestore.collection('products').get();
      _products = snapshot.docs.map((doc) {
        final productData = {'id': doc.id, ...doc.data()};

        // If imageUrl doesn't start with "assets/", assign a temporary local asset
        if (!productData['imageUrl'].toString().startsWith('assets/')) {
          // Generate a deterministic but seemingly random product image based on the product ID
          final productId = doc.id;
          final categoryIndex = productId.hashCode % 5 + 1; // 1-5
          final productIndex = productId.hashCode % 3 + 1; // 1-3

          // Assign temporary asset path
          if (categoryIndex == 5) {
            // For category 5, use laptop images
            productData['imageUrl'] =
                'assets/images/products/loptop${productIndex}.png';
          } else {
            productData['imageUrl'] =
                'assets/images/products/cat${categoryIndex}_${productIndex}.png';
          }
        }

        return ProductModel.fromJson(productData);
      }).toList();

      _applyFilters();

      // Notify listeners after the operation is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error fetching products: $e');

      // Create some dummy products with local assets if Firebase fetch fails
      _createDummyProducts();

      // Notify listeners after the operation is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  void _createDummyProducts() {
    _products = [
      ProductModel(
        id: '1',
        name: 'Headphone 12A',
        imageUrl: 'assets/images/products/cat3_4.png',
        price: 95.0,
        rating: 4.6,
        category: 'Headphones',
        description:
            'Premium noise cancelling headphones with excellent sound quality.',
      ),
      ProductModel(
        id: '2',
        name: 'Business Laptop',
        imageUrl: 'assets/images/products/loptop2.png',
        price: 550.0,
        rating: 4.7,
        category: 'Laptops',
        description: 'High performance business laptop with long battery life.',
      ),
      ProductModel(
        id: '3',
        name: 'Studio Monitor',
        imageUrl: 'assets/images/products/cat3_1.png',
        price: 120.0,
        rating: 4.3,
        category: 'Audio',
        description: 'Professional studio monitors for music production.',
      ),
      ProductModel(
        id: '4',
        name: 'Gaming Laptop',
        imageUrl: 'assets/images/products/loptop5.png',
        price: 1200.0,
        rating: 4.9,
        category: 'Gaming',
        description:
            'High-end gaming laptop with RGB keyboard and excellent graphics.',
      ),
    ];

    _applyFilters();
  }

  void setCategory(String? category) {
    // If category is null, reset to show all products
    if (category == null) {
      _filteredProducts = List.from(products);
      _selectedCategory = null;
    } else {
      // Filter products by the selected category
      _selectedCategory = category;
      _filteredProducts = products
          .where(
            (product) =>
                product.category.toLowerCase() == category.toLowerCase(),
          )
          .toList();
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      // Apply category filter
      final categoryMatches =
          _selectedCategory == null ||
          _selectedCategory == 'All' ||
          product.category == _selectedCategory;

      // Apply search filter if there's a search query
      final searchMatches =
          _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase());

      return categoryMatches && searchMatches;
    }).toList();
  }

  Future<ProductModel?> getProductById(String id) async {
    try {
      final doc = await _firestore.collection('products').doc(id).get();
      if (doc.exists) {
        return ProductModel.fromJson({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      debugPrint('Error getting product by ID: $e');
      return null;
    }
  }

  // Placeholder for deal of the day
  dynamic get dealOfTheDay => null;

  // Placeholder for recently viewed products
  List<ProductModel> get recentlyViewedProducts => [];

  void searchProducts(String query) {
    // Filter products based on the search query
    final searchResults = products
        .where(
          (product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()) ||
              product.category.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    // Use the existing method to update filtered products
    updateFilteredProducts(searchResults);
  }

  void resetFilter() {
    // Reset to show all products
    updateFilteredProducts(List.from(products));
    setCategory(null);
  }

  void updateFilteredProducts(List<ProductModel> newProducts) {
    _filteredProducts = newProducts;
    notifyListeners();
  }
}
