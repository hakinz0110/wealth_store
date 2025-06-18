import 'package:flutter/material.dart';
import '../models/deal_model.dart';
import '../models/product_model.dart';
import 'product_provider.dart';

class DealProvider with ChangeNotifier {
  DealModel? _dealOfTheDay;
  bool _isLoading = true;

  DealModel? get dealOfTheDay => _dealOfTheDay;
  bool get isLoading => _isLoading;
  bool get hasDeal => _dealOfTheDay != null;

  // Generate a deal of the day
  Future<void> generateDealOfTheDay(ProductProvider productProvider) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would fetch from an API or database
      // For now, we'll select a random product from the top-rated ones
      final products = productProvider.products;

      if (products.isEmpty) {
        _dealOfTheDay = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Sort by rating and take top products
      final topProducts = List<ProductModel>.from(products);
      topProducts.sort((a, b) => b.rating.compareTo(a.rating));
      final topRatedProducts = topProducts.take(5).toList();

      // Select a random product from top rated
      topRatedProducts.shuffle();
      final selectedProduct = topRatedProducts.first;

      // Create a deal with random discount between 15-40%
      final discount = 15 + (DateTime.now().millisecondsSinceEpoch % 25);

      // Set expiry time to end of day
      final now = DateTime.now();
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // Create deal
      _dealOfTheDay = DealModel(
        product: selectedProduct,
        discountPercentage: discount.toDouble(),
        expiryTime: endOfDay,
        backgroundColor: _getRandomDealColor(),
        dealTitle: 'Deal of the Day',
        dealDescription: 'Save $discount% on this top-rated item!',
      );
    } catch (e) {
      debugPrint('Error generating deal of the day: $e');
      _dealOfTheDay = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get a random color for the deal background
  Color _getRandomDealColor() {
    final colors = [
      const Color(0xFFFF5722), // Deep Orange
      const Color(0xFF2196F3), // Blue
      const Color(0xFF4CAF50), // Green
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFE91E63), // Pink
    ];

    return colors[DateTime.now().millisecondsSinceEpoch % colors.length];
  }

  // Reset the deal (for testing)
  void resetDeal() {
    _dealOfTheDay = null;
    _isLoading = true;
    notifyListeners();
  }
}
