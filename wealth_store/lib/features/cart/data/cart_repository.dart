import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealth_app/core/utils/app_exceptions.dart';

part 'cart_repository.g.dart';

class CartItem {
  final int productId;
  final String name;
  final double price;
  final String? imageUrl;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    this.imageUrl,
    this.quantity = 1,
  });

  double get total => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'],
      name: json['name'],
      price: json['price'],
      imageUrl: json['imageUrl'],
      quantity: json['quantity'],
    );
  }
}

class CartRepository {
  static const String _cartKey = 'cart_items';

  // Get all cart items
  Future<List<CartItem>> getCartItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);

      if (cartJson == null) {
        return [];
      }

      final cartList = jsonDecode(cartJson) as List;
      return cartList.map((item) => CartItem.fromJson(item)).toList();
    } catch (e) {
      throw DataException('Failed to load cart items: $e');
    }
  }

  // Add item to cart
  Future<void> addToCart(CartItem item) async {
    try {
      final items = await getCartItems();
      final existingItemIndex = items.indexWhere((i) => i.productId == item.productId);

      if (existingItemIndex >= 0) {
        // Update existing item quantity
        items[existingItemIndex].quantity += item.quantity;
      } else {
        // Add new item
        items.add(item);
      }

      // Save updated cart
      await _saveCart(items);
    } catch (e) {
      throw DataException('Failed to add item to cart: $e');
    }
  }

  // Update cart item
  Future<void> updateCartItem(int productId, int quantity) async {
    try {
      final items = await getCartItems();
      final index = items.indexWhere((item) => item.productId == productId);

      if (index >= 0) {
        if (quantity <= 0) {
          // Remove item if quantity is zero or negative
          items.removeAt(index);
        } else {
          // Update quantity
          items[index].quantity = quantity;
        }

        await _saveCart(items);
      }
    } catch (e) {
      throw DataException('Failed to update cart item: $e');
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(int productId) async {
    try {
      final items = await getCartItems();
      items.removeWhere((item) => item.productId == productId);
      await _saveCart(items);
    } catch (e) {
      throw DataException('Failed to remove item from cart: $e');
    }
  }

  // Clear the entire cart
  Future<void> clearCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartKey);
    } catch (e) {
      throw DataException('Failed to clear cart: $e');
    }
  }

  // Get cart total
  Future<double> getCartTotal() async {
    try {
      final items = await getCartItems();
      double total = 0.0;
      for (final item in items) {
        total += item.total;
      }
      return total;
    } catch (e) {
      throw DataException('Failed to calculate cart total: $e');
    }
  }

  // Get number of items in cart
  Future<int> getItemCount() async {
    try {
      final items = await getCartItems();
      int count = 0;
      for (final item in items) {
        count += item.quantity;
      }
      return count;
    } catch (e) {
      throw DataException('Failed to get item count: $e');
    }
  }

  // Helper method to save cart to SharedPreferences
  Future<void> _saveCart(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_cartKey, itemsJson);
  }
}

@riverpod
CartRepository cartRepository(CartRepositoryRef ref) {
  return CartRepository();
} 