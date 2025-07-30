import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/realtime_service.dart';
import '../../shared/models/product.dart';
import '../../shared/models/category.dart';
import '../../shared/models/order.dart';
import '../../shared/models/banner.dart';
import '../../shared/models/coupon.dart';

part 'realtime_providers.g.dart';

// =============================================================================
// PRODUCTS PROVIDERS
// =============================================================================

/// Stream provider for all products with real-time updates
@riverpod
Stream<List<Product>> allProducts(Ref ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.watchProducts();
}

/// Stream provider for featured products with real-time updates
@riverpod
Stream<List<Product>> featuredProducts(Ref ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.watchProducts(isFeatured: true);
}

/// Stream provider for products by category with real-time updates
@riverpod
Stream<List<Product>> productsByCategory(Ref ref, int categoryId) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.watchProducts(categoryId: categoryId);
}

/// Stream provider for product search with real-time updates
@riverpod
Stream<List<Product>> searchProducts(Ref ref, String query) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.watchProducts(searchQuery: query);
}

/// Stream provider for products with complex filtering
@riverpod
Stream<List<Product>> filteredProducts(
  Ref ref, {
  int? categoryId,
  bool? isFeatured,
  String? searchQuery,
}) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.watchProducts(
    categoryId: categoryId,
    isFeatured: isFeatured,
    searchQuery: searchQuery,
  );
}

// =============================================================================
// CATEGORIES PROVIDERS
// =============================================================================

/// Stream provider for all categories with real-time updates
@riverpod
Stream<List<Category>> allCategories(Ref ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.watchCategories();
}

/// Stream provider for active categories with real-time updates
@riverpod
Stream<List<Category>> activeCategories(Ref ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.watchCategories(isActive: true);
}

// =============================================================================
// ORDERS PROVIDERS
// =============================================================================

/// Stream provider for all orders with real-time updates
@riverpod
Stream<List<Order>> allOrders(Ref ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.watchOrders();
}

/// Stream provider for orders by status with real-time updates
@riverpod
Stream<List<Order>> ordersByStatus(Ref ref, String status) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.watchOrders(status: status);
}

/// Stream provider for user orders with real-time updates
@riverpod
Stream<List<Order>> userOrders(Ref ref, String userId) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.watchOrders(userId: userId);
}

/// Stream provider for pending orders with real-time updates
@riverpod
Stream<List<Order>> pendingOrders(Ref ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.watchOrders(status: 'pending');
}

/// Stream provider for completed orders with real-time updates
@riverpod
Stream<List<Order>> completedOrders(Ref ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.watchOrders(status: 'completed');
}

// =============================================================================
// BANNERS PROVIDERS
// =============================================================================

/// Stream provider for all banners with real-time updates
@riverpod
Stream<List<Banner>> allBanners(Ref ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.watchBanners();
}

/// Stream provider for active banners with real-time updates
@riverpod
Stream<List<Banner>> activeBanners(Ref ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.watchBanners(isActive: true);
}

// =============================================================================
// COUPONS PROVIDERS
// =============================================================================

/// Stream provider for all coupons with real-time updates
@riverpod
Stream<List<Coupon>> allCoupons(Ref ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.watchCoupons();
}

/// Stream provider for active coupons with real-time updates
@riverpod
Stream<List<Coupon>> activeCoupons(Ref ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.watchCoupons(isActive: true);
}

// =============================================================================
// CONNECTION STATUS PROVIDERS
// =============================================================================

/// Stream provider for real-time connection status
@riverpod
Stream<RealtimeConnectionState> realtimeConnectionStatus(Ref ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.connectionStatus;
}

/// Provider for current connection status
@riverpod
bool isRealtimeConnected(Ref ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.isConnected;
}

// =============================================================================
// UTILITY PROVIDERS
// =============================================================================

/// Provider for real-time service methods
@riverpod
RealtimeMethods realtimeMethods(Ref ref) {
  return RealtimeMethods(ref);
}

/// Helper class for real-time operations
class RealtimeMethods {
  final Ref _ref;
  
  RealtimeMethods(this._ref);
  
  /// Manually reconnect real-time connection
  Future<void> reconnect() async {
    final realtimeService = _ref.read(realtimeServiceProvider);
    await realtimeService.reconnect();
  }
  
  /// Check if real-time is connected
  bool get isConnected {
    final realtimeService = _ref.read(realtimeServiceProvider);
    return realtimeService.isConnected;
  }
  
  /// Get connection status stream
  Stream<RealtimeConnectionState> get connectionStatus {
    final realtimeService = _ref.read(realtimeServiceProvider);
    return realtimeService.connectionStatus;
  }
  
  /// Refresh all data by invalidating providers
  void refreshAllData() {
    _ref.invalidate(allProductsProvider);
    _ref.invalidate(allCategoriesProvider);
    _ref.invalidate(allOrdersProvider);
    _ref.invalidate(allBannersProvider);
    _ref.invalidate(allCouponsProvider);
  }
  
  /// Refresh specific entity data
  void refreshProducts() {
    _ref.invalidate(allProductsProvider);
    _ref.invalidate(featuredProductsProvider);
  }
  
  void refreshCategories() {
    _ref.invalidate(allCategoriesProvider);
    _ref.invalidate(activeCategoriesProvider);
  }
  
  void refreshOrders() {
    _ref.invalidate(allOrdersProvider);
    _ref.invalidate(pendingOrdersProvider);
    _ref.invalidate(completedOrdersProvider);
  }
  
  void refreshBanners() {
    _ref.invalidate(allBannersProvider);
    _ref.invalidate(activeBannersProvider);
  }
  
  void refreshCoupons() {
    _ref.invalidate(allCouponsProvider);
    _ref.invalidate(activeCouponsProvider);
  }
}

// =============================================================================
// STATE MANAGEMENT PROVIDERS
// =============================================================================

/// Provider for managing real-time connection state
@riverpod
class RealtimeConnectionNotifier extends _$RealtimeConnectionNotifier {
  @override
  RealtimeConnectionState build() {
    final realtimeService = ref.watch(realtimeServiceProvider);
    
    // Listen to connection status changes
    ref.listen(realtimeConnectionStatusProvider, (previous, next) {
      next.when(
        data: (status) => state = status,
        loading: () => state = RealtimeConnectionState.connecting,
        error: (_, __) => state = RealtimeConnectionState.error,
      );
    });
    
    return realtimeService.isConnected 
        ? RealtimeConnectionState.connected 
        : RealtimeConnectionState.disconnected;
  }
  
  /// Manually set connection state
  void setConnectionState(RealtimeConnectionState newState) {
    state = newState;
  }
  
  /// Attempt to reconnect
  Future<void> reconnect() async {
    state = RealtimeConnectionState.connecting;
    try {
      final realtimeService = ref.read(realtimeServiceProvider);
      await realtimeService.reconnect();
      state = RealtimeConnectionState.connected;
    } catch (e) {
      state = RealtimeConnectionState.error;
      rethrow;
    }
  }
}

// =============================================================================
// ERROR HANDLING PROVIDERS
// =============================================================================

/// Provider for tracking real-time errors
@riverpod
class RealtimeErrorNotifier extends _$RealtimeErrorNotifier {
  @override
  String? build() {
    return null;
  }
  
  void setError(String error) {
    state = error;
  }
  
  void clearError() {
    state = null;
  }
}

/// Provider for tracking loading states
@riverpod
class RealtimeLoadingNotifier extends _$RealtimeLoadingNotifier {
  @override
  bool build() {
    return false;
  }
  
  void setLoading(bool loading) {
    state = loading;
  }
}