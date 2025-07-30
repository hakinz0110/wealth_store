import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wealth_app/features/cart/data/cart_repository.dart';

part 'cart_state.freezed.dart';
part 'cart_state.g.dart';

@freezed
class CartState with _$CartState {
  const factory CartState({
    @Default([]) List<CartItem> items,
    @Default(0.0) double total,
    @Default(0) int itemCount,
    @Default(false) bool isLoading,
    String? error,
  }) = _CartState;

  const CartState._();

  factory CartState.initial() => const CartState();

  factory CartState.loading() => const CartState(isLoading: true);

  factory CartState.error(String message) => CartState(error: message);

  factory CartState.loaded(List<CartItem> items) {
    double total = 0.0;
    int count = 0;
    
    for (final item in items) {
      total += item.total;
      count += item.quantity;
    }
    
    return CartState(
      items: items,
      total: total,
      itemCount: count,
    );
  }

  factory CartState.fromJson(Map<String, dynamic> json) => _$CartStateFromJson(json);
} 