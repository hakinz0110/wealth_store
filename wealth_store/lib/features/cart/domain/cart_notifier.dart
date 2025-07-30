import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wealth_app/core/utils/app_exceptions.dart';
import 'package:wealth_app/features/cart/data/cart_repository.dart';
import 'package:wealth_app/features/cart/domain/cart_state.dart';
import 'package:wealth_app/shared/models/product.dart';

part 'cart_notifier.g.dart';

@riverpod
class CartNotifier extends _$CartNotifier {
  @override
  CartState build() {
    _loadCart();
    return CartState.initial();
  }

  Future<void> _loadCart() async {
    state = CartState.loading();
    try {
      final items = await ref.read(cartRepositoryProvider).getCartItems();
      state = CartState.loaded(items);
    } catch (e) {
      state = CartState.error("Failed to load cart");
    }
  }

  Future<void> addItem(Product product, {int quantity = 1}) async {
    try {
      final cartItem = CartItem(
        productId: product.id,
        name: product.name,
        price: product.price,
        imageUrl: product.imageUrl,
        quantity: quantity,
      );
      
      await ref.read(cartRepositoryProvider).addToCart(cartItem);
      await _loadCart();
    } on DataException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (e) {
      state = state.copyWith(error: "Failed to add item to cart");
    }
  }
  
  // Direct method for adding CartItem objects
  Future<void> addToCart(CartItem cartItem) async {
    try {
      await ref.read(cartRepositoryProvider).addToCart(cartItem);
      await _loadCart();
    } on DataException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (e) {
      state = state.copyWith(error: "Failed to add item to cart");
    }
  }

  Future<void> removeItem(int productId) async {
    try {
      await ref.read(cartRepositoryProvider).removeFromCart(productId);
      await _loadCart();
    } catch (e) {
      state = state.copyWith(error: "Failed to remove item from cart");
    }
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    try {
      await ref.read(cartRepositoryProvider).updateCartItem(productId, quantity);
      await _loadCart();
    } catch (e) {
      state = state.copyWith(error: "Failed to update cart");
    }
  }

  Future<void> clearCart() async {
    try {
      await ref.read(cartRepositoryProvider).clearCart();
      state = CartState.initial();
    } catch (e) {
      state = state.copyWith(error: "Failed to clear cart");
    }
  }
} 