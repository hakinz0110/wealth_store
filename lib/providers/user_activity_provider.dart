import 'package:flutter/material.dart';
import '../models/user_activity_model.dart';
import '../models/product_model.dart';
import 'product_provider.dart';

class UserActivityProvider with ChangeNotifier {
  UserActivityModel _userActivity = UserActivityModel.empty();
  List<ProductModel> _recentlyViewedProducts = [];
  List<ProductModel> _recommendedProducts = [];
  bool _isLoading = true;
  List<String> _recentSearches = [];

  UserActivityModel get userActivity => _userActivity;
  List<ProductModel> get recentlyViewedProducts => _recentlyViewedProducts;
  List<ProductModel> get recommendedProducts => _recommendedProducts;
  bool get isLoading => _isLoading;
  List<String> get recentSearches => List.unmodifiable(_recentSearches);

  UserActivityProvider() {
    _loadUserActivity();
  }

  Future<void> _loadUserActivity() async {
    _isLoading = true;
    notifyListeners();

    try {
      _userActivity = await UserActivityModel.loadFromPrefs();
    } catch (e) {
      debugPrint('Error loading user activity: $e');
      _userActivity = UserActivityModel.empty();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveUserActivity() async {
    try {
      await UserActivityModel.saveToPrefs(_userActivity);
    } catch (e) {
      debugPrint('Error saving user activity: $e');
    }
  }

  // Track product view and add to recently viewed
  Future<void> trackProductView(ProductModel product) async {
    _userActivity = _userActivity.addToRecentlyViewed(product.id);
    _userActivity = _userActivity.incrementCategoryInterest(product.category);
    _userActivity = _userActivity.incrementProductInteraction(product.id);
    await _saveUserActivity();
    notifyListeners();
  }

  // Load recently viewed products using product IDs from user activity
  Future<void> loadRecentlyViewedProducts(
    ProductProvider productProvider,
  ) async {
    _isLoading = true;
    notifyListeners();

    final recentlyViewedIds = _userActivity.recentlyViewed;
    final allProducts = productProvider.products;
    final recentlyViewed = <ProductModel>[];

    for (final id in recentlyViewedIds) {
      final product = allProducts.firstWhere(
        (p) => p.id == id,
        orElse: () => ProductModel(
          id: '',
          name: '',
          imageUrl: '',
          price: 0,
          rating: 0,
          category: '',
          description: '',
        ),
      );

      if (product.id.isNotEmpty) {
        recentlyViewed.add(product);
      }
    }

    _recentlyViewedProducts = recentlyViewed;
    _isLoading = false;
    notifyListeners();
  }

  // Generate personalized recommendations based on user interests
  Future<void> generateRecommendations(ProductProvider productProvider) async {
    _isLoading = true;
    notifyListeners();

    final allProducts = productProvider.products;
    final recommendations = <ProductModel>[];
    final categoryScores = _userActivity.categoryInterests;

    // Score each product based on category interest
    final productScores = <String, double>{};

    for (final product in allProducts) {
      final categoryScore = categoryScores[product.category] ?? 0;
      final interactionScore =
          _userActivity.productInteractions[product.id] ?? 0;

      // Calculate a weighted score (higher is better)
      final score =
          (categoryScore * 0.7) +
          (interactionScore * 0.3) +
          (product.rating * 0.5);
      productScores[product.id] = score;
    }

    // Sort products by score
    final sortedProducts = List<ProductModel>.from(allProducts);
    sortedProducts.sort((a, b) {
      final scoreA = productScores[a.id] ?? 0;
      final scoreB = productScores[b.id] ?? 0;
      return scoreB.compareTo(scoreA); // Descending order
    });

    // Take top recommendations, excluding recently viewed
    final recentIds = _recentlyViewedProducts.map((p) => p.id).toSet();

    for (final product in sortedProducts) {
      if (!recentIds.contains(product.id)) {
        recommendations.add(product);
        if (recommendations.length >= 10) break;
      }
    }

    // If we don't have enough recommendations, add some random products
    if (recommendations.length < 5 && allProducts.length > 5) {
      final remainingProducts = allProducts
          .where(
            (p) => !recentIds.contains(p.id) && !recommendations.contains(p),
          )
          .toList();

      remainingProducts.shuffle();
      recommendations.addAll(
        remainingProducts.take(5 - recommendations.length),
      );
    }

    _recommendedProducts = recommendations;
    _isLoading = false;
    notifyListeners();
  }

  // Clear user activity
  Future<void> clearUserActivity() async {
    _userActivity = UserActivityModel.empty();
    _recentlyViewedProducts = [];
    _recommendedProducts = [];
    await _saveUserActivity();
    notifyListeners();
  }

  void addSearchActivity(String searchQuery) {
    // Add search query to recent searches
    if (!_recentSearches.contains(searchQuery)) {
      _recentSearches.insert(0, searchQuery);

      // Limit recent searches to 10 items
      if (_recentSearches.length > 10) {
        _recentSearches.removeLast();
      }

      notifyListeners();
    }
  }
}
