import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wealth_app/features/feed/data/feed_repository.dart';
import 'package:wealth_app/features/feed/domain/feed_state.dart';

part 'feed_notifier.g.dart';

@riverpod
class FeedNotifier extends _$FeedNotifier {
  @override
  FeedState build() {
    loadFeed();
    return const FeedState();
  }

  Future<void> loadFeed() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final promotions = await ref.read(feedRepositoryProvider).getPromotions();
      
      state = state.copyWith(
        promotions: promotions,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load promotions: $e',
      );
    }
  }

  Future<void> loadCategoryPromotions(int categoryId) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final promotions = await ref.read(feedRepositoryProvider).getPromotionsByCategory(categoryId);
      
      state = state.copyWith(
        promotions: promotions,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load category promotions: $e',
      );
    }
  }

  Future<void> loadProductPromotions(int productId) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final promotions = await ref.read(feedRepositoryProvider).getPromotionsByProduct(productId);
      
      state = state.copyWith(
        promotions: promotions,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load product promotions: $e',
      );
    }
  }
} 