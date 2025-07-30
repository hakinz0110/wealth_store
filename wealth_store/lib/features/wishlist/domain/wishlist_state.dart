import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wealth_app/shared/models/wishlist_item.dart';

part 'wishlist_state.freezed.dart';
part 'wishlist_state.g.dart';

@freezed
class WishlistState with _$WishlistState {
  const factory WishlistState({
    @Default([]) List<WishlistItem> items,
    @Default(false) bool isLoading,
    String? error,
    @Default({}) Map<int, bool> productWishlistStatus,
  }) = _WishlistState;

  const WishlistState._();

  factory WishlistState.initial() => const WishlistState();

  factory WishlistState.loading() => const WishlistState(isLoading: true);

  factory WishlistState.error(String message) => WishlistState(error: message);

  factory WishlistState.loaded(List<WishlistItem> items) {
    // Create a map of product IDs to their wishlist status for quick lookups
    final productWishlistStatus = <int, bool>{};
    for (final item in items) {
      productWishlistStatus[item.productId] = true;
    }
    
    return WishlistState(
      items: items,
      productWishlistStatus: productWishlistStatus,
    );
  }

  factory WishlistState.fromJson(Map<String, dynamic> json) => _$WishlistStateFromJson(json);
} 