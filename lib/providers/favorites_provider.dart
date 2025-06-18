import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class FavoritesProvider with ChangeNotifier {
  final List<ProductModel> _favoriteItems = [];

  List<ProductModel> get favoriteItems => List.unmodifiable(_favoriteItems);

  bool isFavorite(ProductModel product) {
    return _favoriteItems.any((item) => item.id == product.id);
  }

  void toggleFavorite(ProductModel product) {
    if (isFavorite(product)) {
      _favoriteItems.removeWhere((item) => item.id == product.id);
    } else {
      _favoriteItems.add(product);
    }
    notifyListeners();
  }

  void addToFavorites(ProductModel product) {
    if (!isFavorite(product)) {
      _favoriteItems.add(product);
      notifyListeners();
    }
  }

  void removeFromFavorites(ProductModel product) {
    _favoriteItems.removeWhere((item) => item.id == product.id);
    notifyListeners();
  }

  void clearFavorites() {
    _favoriteItems.clear();
    notifyListeners();
  }
}
