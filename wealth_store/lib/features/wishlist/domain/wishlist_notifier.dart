import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wealth_app/core/utils/app_exceptions.dart';
import 'package:wealth_app/features/wishlist/data/wishlist_repository.dart';
import 'package:wealth_app/features/wishlist/domain/wishlist_state.dart';

part 'wishlist_notifier.g.dart';

@riverpod
class WishlistNotifier extends _$WishlistNotifier {
  @override
  WishlistState build() {
    loadWishlist();
    return WishlistState.initial();
  }

  Future<void> loadWishlist() async {
    state = WishlistState.loading();
    try {
      final items = await ref.read(wishlistRepositoryProvider).getWishlistItems();
      state = WishlistState.loaded(items);
    } on DataException catch (e) {
      state = WishlistState.error(e.message);
    } catch (e) {
      state = WishlistState.error("Failed to load wishlist");
    }
  }

  Future<bool> isInWishlist(int productId) async {
    try {
      // First check our local cache
      if (state.productWishlistStatus.containsKey(productId)) {
        return state.productWishlistStatus[productId] ?? false;
      }
      
      // If not in cache, check with the repository
      final isWishlisted = await ref.read(wishlistRepositoryProvider).isInWishlist(productId);
      
      // Update our cache
      state = state.copyWith(
        productWishlistStatus: {
          ...state.productWishlistStatus,
          productId: isWishlisted
        }
      );
      
      return isWishlisted;
    } catch (e) {
      return false;
    }
  }

  Future<void> toggleWishlist(int productId) async {
    try {
      // Optimistically update UI
      final currentStatus = await isInWishlist(productId);
      final newStatus = !currentStatus;
      
      state = state.copyWith(
        productWishlistStatus: {
          ...state.productWishlistStatus,
          productId: newStatus
        }
      );
      
      // Update on server
      final success = await ref.read(wishlistRepositoryProvider).toggleWishlist(productId);
      
      // If server update failed, revert UI
      if (success != newStatus) {
        state = state.copyWith(
          productWishlistStatus: {
            ...state.productWishlistStatus,
            productId: currentStatus
          }
        );
      }
      
      // Reload full wishlist if needed
      if (success) {
        // Item was added to wishlist
        await loadWishlist();
      } else {
        // Item was removed, filter it out locally
        state = state.copyWith(
          items: state.items.where((item) => item.productId != productId).toList()
        );
      }
    } catch (e) {
      // On error, revert to previous state
      await loadWishlist();
    }
  }
  
  Future<void> removeFromWishlist(int productId) async {
    try {
      // Optimistically update UI
      state = state.copyWith(
        items: state.items.where((item) => item.productId != productId).toList(),
        productWishlistStatus: {
          ...state.productWishlistStatus,
          productId: false
        }
      );
      
      // Update on server
      await ref.read(wishlistRepositoryProvider).removeFromWishlist(productId);
    } catch (e) {
      // On error, revert to previous state
      await loadWishlist();
    }
  }
} 