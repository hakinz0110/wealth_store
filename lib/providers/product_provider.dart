import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = false;
  String? _selectedCategory = 'All';
  String? _selectedSubcategory;
  String _searchQuery = '';

  List<ProductModel> get products => _products;
  List<ProductModel> get filteredProducts => _filteredProducts;
  bool get isLoading => _isLoading;
  String? get selectedCategory => _selectedCategory;
  String? get selectedSubcategory => _selectedSubcategory;

  List<String> get categories {
    final categorySet = <String>{'All'};
    for (var product in _products) {
      categorySet.add(product.category);
    }
    return categorySet.toList();
  }

  List<String> getSubcategoriesForCategory(String category) {
    final subcategorySet = <String>{};
    for (var product in _products) {
      if (product.category == category && product.subcategories.isNotEmpty) {
        subcategorySet.addAll(product.subcategories);
      }
    }
    return subcategorySet.toList();
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

        // Ensure the product flags are properly set from Firestore
        productData['isFeatured'] = productData['isFeatured'] ?? true;
        productData['isNew'] = productData['isNew'] ?? false;
        productData['isPopular'] = productData['isPopular'] ?? false;
        productData['isDeal'] = productData['isDeal'] ?? false;
        productData['isVisible'] = productData['isVisible'] ?? true;

        return ProductModel.fromJson(productData);
      }).toList();

      // Filter out invisible products
      _products = _products.where((product) => product.isVisible).toList();

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
    // Create dummy products with subcategories
    _products = [
      ProductModel(
        id: '1',
        name: 'Wireless Headphone 12A',
        imageUrl: 'assets/images/products/cat3_4.png',
        price: 95.0,
        rating: 4.6,
        category: 'Electronics',
        subcategories: ['Headphones', 'Audio'],
        description:
            'Premium noise cancelling headphones with excellent sound quality.',
        discountPercentage: 15.0,
        isFeatured: true,
        isNew: true,
        isPopular: false,
        isDeal: true,
        isVisible: true,
      ),
      ProductModel(
        id: '2',
        name: 'Business Laptop Pro',
        imageUrl: 'assets/images/products/loptop2.png',
        price: 550.0,
        rating: 4.7,
        category: 'Electronics',
        subcategories: ['Laptops', 'Computers'],
        description: 'High performance business laptop with long battery life.',
        isFeatured: true,
        isNew: false,
        isPopular: true,
        isDeal: false,
        isVisible: true,
      ),
      ProductModel(
        id: '3',
        name: 'Studio Monitor HD',
        imageUrl: 'assets/images/products/cat3_1.png',
        price: 120.0,
        rating: 4.3,
        category: 'Electronics',
        subcategories: ['Audio'],
        description: 'Professional studio monitors for music production.',
        discountPercentage: 10.0,
        isFeatured: true,
        isNew: false,
        isPopular: false,
        isDeal: true,
        isVisible: true,
      ),
      ProductModel(
        id: '4',
        name: 'Gaming Laptop RTX',
        imageUrl: 'assets/images/products/loptop5.png',
        price: 1200.0,
        rating: 4.9,
        category: 'Electronics',
        subcategories: ['Gaming', 'Laptops'],
        description:
            'High-end gaming laptop with RGB keyboard and excellent graphics.',
        discountPercentage: 5.0,
        isFeatured: true,
        isNew: true,
        isPopular: true,
        isDeal: false,
        isVisible: true,
      ),
      ProductModel(
        id: '5',
        name: 'Smartphone X Pro',
        imageUrl: 'assets/images/products/cat2_1.png',
        price: 899.0,
        rating: 4.8,
        category: 'Electronics',
        subcategories: ['Smartphones'],
        description: 'Latest flagship smartphone with advanced camera system.',
        isFeatured: true,
        isNew: true,
        isPopular: true,
        isDeal: false,
        isVisible: true,
      ),
      ProductModel(
        id: '6',
        name: 'Tablet Ultra',
        imageUrl: 'assets/images/products/cat2_2.png',
        price: 450.0,
        rating: 4.5,
        category: 'Electronics',
        subcategories: ['Tablets'],
        description: 'Lightweight tablet with high-resolution display.',
        discountPercentage: 20.0,
        isFeatured: true,
        isNew: false,
        isPopular: false,
        isDeal: true,
        isVisible: true,
      ),
      ProductModel(
        id: '7',
        name: 'Smart Watch Series 5',
        imageUrl: 'assets/images/products/cat2_3.png',
        price: 299.0,
        rating: 4.4,
        category: 'Electronics',
        subcategories: ['Smartwatches', 'Wearables'],
        description: 'Advanced smartwatch with health monitoring features.',
        isFeatured: true,
        isNew: true,
        isPopular: false,
        isDeal: false,
        isVisible: true,
      ),
      ProductModel(
        id: '8',
        name: 'Men\'s Casual Shirt',
        imageUrl: 'assets/images/products/cat1_1.png',
        price: 45.0,
        rating: 4.2,
        category: 'Fashion',
        subcategories: ['Men\'s Clothing'],
        description: 'Comfortable casual shirt for everyday wear.',
        discountPercentage: 25.0,
        isFeatured: true,
        isNew: false,
        isPopular: false,
        isDeal: true,
        isVisible: true,
      ),
      ProductModel(
        id: '9',
        name: 'Women\'s Summer Dress',
        imageUrl: 'assets/images/products/cat1_2.png',
        price: 65.0,
        rating: 4.6,
        category: 'Fashion',
        subcategories: ['Women\'s Clothing'],
        description: 'Stylish summer dress with floral pattern.',
        discountPercentage: 15.0,
        isFeatured: true,
        isNew: false,
        isPopular: true,
        isDeal: true,
        isVisible: true,
      ),
      ProductModel(
        id: '10',
        name: 'Premium Coffee Maker',
        imageUrl: 'assets/images/products/cat4_1.png',
        price: 89.0,
        rating: 4.7,
        category: 'Home & Kitchen',
        subcategories: ['Appliances', 'Kitchen'],
        description: 'Programmable coffee maker with thermal carafe.',
        isFeatured: true,
        isNew: false,
        isPopular: true,
        isDeal: false,
        isVisible: true,
      ),
    ];

    _applyFilters();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    _selectedSubcategory = null; // Reset subcategory when changing category
    _applyFilters();
    notifyListeners();
  }

  void setSubcategory(String? subcategory) {
    _selectedSubcategory = subcategory;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    // Start with only visible products
    var filteredList = _products.where((product) => product.isVisible).toList();

    // Apply category filter if not 'All'
    if (_selectedCategory != null && _selectedCategory != 'All') {
      filteredList = filteredList
          .where((product) => product.category == _selectedCategory)
          .toList();

      // Apply subcategory filter if selected
      if (_selectedSubcategory != null && _selectedSubcategory!.isNotEmpty) {
        filteredList = filteredList
            .where(
              (product) => product.subcategories.contains(_selectedSubcategory),
            )
            .toList();
      }
    }

    // Apply search filter if query is not empty
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredList = filteredList.where((product) {
        return product.name.toLowerCase().contains(query) ||
            product.description.toLowerCase().contains(query) ||
            product.category.toLowerCase().contains(query) ||
            (product.brand?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    _filteredProducts = filteredList;
  }

  List<ProductModel> getProductsByCategory(String category) {
    return _products
        .where(
          (product) => product.category.toLowerCase() == category.toLowerCase(),
        )
        .toList();
  }

  List<ProductModel> getProductsByCategoryAndSubcategory(
    String category,
    String subcategory,
  ) {
    return _products.where((product) {
      return product.category == category &&
          product.subcategories.contains(subcategory);
    }).toList();
  }

  // Get products that belong to any of the specified subcategories
  List<ProductModel> getProductsBySubcategories(List<String> subcategories) {
    if (subcategories.isEmpty) {
      return [];
    }

    return _products.where((product) {
      // Check if any of the product's subcategories match the requested ones
      return product.subcategories.any((sub) => subcategories.contains(sub));
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
              product.category.toLowerCase().contains(query.toLowerCase()) ||
              product.subcategories.any(
                (subcategory) =>
                    subcategory.toLowerCase().contains(query.toLowerCase()),
              ),
        )
        .toList();

    // Use the existing method to update filtered products
    updateFilteredProducts(searchResults);
  }

  void resetFilter() {
    // Reset to show all products
    _selectedCategory = 'All';
    _selectedSubcategory = null;
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  void updateFilteredProducts(List<ProductModel> newProducts) {
    _filteredProducts = newProducts;
    notifyListeners();
  }
}
