import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/product.dart';
import '../../shared/models/category.dart';
import '../../shared/models/order.dart';
import '../../shared/models/banner.dart';
import '../../shared/models/coupon.dart';
import 'supabase_service.dart';
import 'cache_service.dart';

part 'realtime_service.g.dart';

@riverpod
RealtimeService realtimeService(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  final cache = ref.watch(cacheServiceProvider);
  return RealtimeService(supabase, cache);
}

/// Service for handling real-time data synchronization with Supabase
class RealtimeService {
  final SupabaseClient _client;
  final CacheService _cache;
  final Map<String, RealtimeChannel> _channels = {};
  final Map<String, StreamController> _controllers = {};
  final Map<String, Timer> _debounceTimers = {};
  final Map<String, int> _subscriptionCounts = {};
  
  static const Duration _debounceDelay = Duration(milliseconds: 300);
  static const Duration _reconnectDelay = Duration(seconds: 5);
  static const int _maxSubscriptions = 10; // Limit concurrent subscriptions
  
  RealtimeService(this._client, this._cache);
  
  /// Watch products with real-time updates
  Stream<List<Product>> watchProducts({
    int? categoryId,
    bool? isFeatured,
    String? searchQuery,
  }) {
    final channelKey = 'products_${categoryId ?? 'all'}_${isFeatured ?? 'all'}_${searchQuery ?? 'all'}';
    
    if (_controllers.containsKey(channelKey)) {
      _subscriptionCounts[channelKey] = (_subscriptionCounts[channelKey] ?? 0) + 1;
      return (_controllers[channelKey] as StreamController<List<Product>>).stream;
    }
    
    // Check subscription limit
    if (_channels.length >= _maxSubscriptions) {
      // Return cached data stream without real-time updates
      return _getCachedProductStream(categoryId: categoryId, isFeatured: isFeatured, searchQuery: searchQuery);
    }
    
    final controller = StreamController<List<Product>>.broadcast();
    _controllers[channelKey] = controller;
    
    // Initial data fetch
    _fetchProducts(categoryId: categoryId, isFeatured: isFeatured, searchQuery: searchQuery)
        .then((products) {
      if (!controller.isClosed) {
        controller.add(products);
      }
    }).catchError((error) {
      if (!controller.isClosed) {
        controller.addError(error);
      }
    });
    
    // Set up real-time subscription
    final channel = _client.channel('products_$channelKey')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'products',
          callback: (payload) => _handleProductsChange(
            payload, 
            controller, 
            categoryId: categoryId, 
            isFeatured: isFeatured,
            searchQuery: searchQuery,
          ),
        )
        .subscribe();
    
    _channels[channelKey] = channel;
    
    // Clean up when stream is cancelled
    controller.onCancel = () {
      _cleanupChannel(channelKey);
    };
    
    return controller.stream;
  }
  
  /// Watch categories with real-time updates
  Stream<List<Category>> watchCategories({bool? isActive}) {
    final channelKey = 'categories_${isActive ?? 'all'}';
    
    if (_controllers.containsKey(channelKey)) {
      return (_controllers[channelKey] as StreamController<List<Category>>).stream;
    }
    
    final controller = StreamController<List<Category>>.broadcast();
    _controllers[channelKey] = controller;
    
    // Initial data fetch
    _fetchCategories(isActive: isActive).then((categories) {
      if (!controller.isClosed) {
        controller.add(categories);
      }
    }).catchError((error) {
      if (!controller.isClosed) {
        controller.addError(error);
      }
    });
    
    // Set up real-time subscription
    final channel = _client.channel('categories_$channelKey')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'categories',
          callback: (payload) => _handleCategoriesChange(
            payload, 
            controller,
            isActive: isActive,
          ),
        )
        .subscribe();
    
    _channels[channelKey] = channel;
    
    // Clean up when stream is cancelled
    controller.onCancel = () {
      _cleanupChannel(channelKey);
    };
    
    return controller.stream;
  }
  
  /// Watch orders with real-time updates
  Stream<List<Order>> watchOrders({
    String? status,
    String? userId,
  }) {
    final channelKey = 'orders_${status ?? 'all'}_${userId ?? 'all'}';
    
    if (_controllers.containsKey(channelKey)) {
      return (_controllers[channelKey] as StreamController<List<Order>>).stream;
    }
    
    final controller = StreamController<List<Order>>.broadcast();
    _controllers[channelKey] = controller;
    
    // Initial data fetch
    _fetchOrders(status: status, userId: userId).then((orders) {
      if (!controller.isClosed) {
        controller.add(orders);
      }
    }).catchError((error) {
      if (!controller.isClosed) {
        controller.addError(error);
      }
    });
    
    // Set up real-time subscription
    final channel = _client.channel('orders_$channelKey')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          callback: (payload) => _handleOrdersChange(
            payload, 
            controller,
            status: status,
            userId: userId,
          ),
        )
        .subscribe();
    
    _channels[channelKey] = channel;
    
    // Clean up when stream is cancelled
    controller.onCancel = () {
      _cleanupChannel(channelKey);
    };
    
    return controller.stream;
  }
  
  /// Watch banners with real-time updates
  Stream<List<Banner>> watchBanners({bool? isActive}) {
    final channelKey = 'banners_${isActive ?? 'all'}';
    
    if (_controllers.containsKey(channelKey)) {
      return (_controllers[channelKey] as StreamController<List<Banner>>).stream;
    }
    
    final controller = StreamController<List<Banner>>.broadcast();
    _controllers[channelKey] = controller;
    
    // Initial data fetch
    _fetchBanners(isActive: isActive).then((banners) {
      if (!controller.isClosed) {
        controller.add(banners);
      }
    }).catchError((error) {
      if (!controller.isClosed) {
        controller.addError(error);
      }
    });
    
    // Set up real-time subscription
    final channel = _client.channel('banners_$channelKey')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'banners',
          callback: (payload) => _handleBannersChange(
            payload, 
            controller,
            isActive: isActive,
          ),
        )
        .subscribe();
    
    _channels[channelKey] = channel;
    
    // Clean up when stream is cancelled
    controller.onCancel = () {
      _cleanupChannel(channelKey);
    };
    
    return controller.stream;
  }
  
  /// Watch coupons with real-time updates
  Stream<List<Coupon>> watchCoupons({bool? isActive}) {
    final channelKey = 'coupons_${isActive ?? 'all'}';
    
    if (_controllers.containsKey(channelKey)) {
      return (_controllers[channelKey] as StreamController<List<Coupon>>).stream;
    }
    
    final controller = StreamController<List<Coupon>>.broadcast();
    _controllers[channelKey] = controller;
    
    // Initial data fetch
    _fetchCoupons(isActive: isActive).then((coupons) {
      if (!controller.isClosed) {
        controller.add(coupons);
      }
    }).catchError((error) {
      if (!controller.isClosed) {
        controller.addError(error);
      }
    });
    
    // Set up real-time subscription
    final channel = _client.channel('coupons_$channelKey')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'coupons',
          callback: (payload) => _handleCouponsChange(
            payload, 
            controller,
            isActive: isActive,
          ),
        )
        .subscribe();
    
    _channels[channelKey] = channel;
    
    // Clean up when stream is cancelled
    controller.onCancel = () {
      _cleanupChannel(channelKey);
    };
    
    return controller.stream;
  }
  
  /// Get connection status stream
  Stream<RealtimeConnectionState> get connectionStatus {
    // Create a stream that emits the current connection state
    return Stream.periodic(Duration(seconds: 1), (_) => _client.realtime.connectionState)
        .distinct()
        .map((state) => RealtimeConnectionStateExtension.fromSupabase(state.toString()));
  }
  
  /// Check if real-time is connected
  bool get isConnected {
    return _client.realtime.connectionState.toString().toLowerCase() == 'connected';
  }
  
  /// Manually reconnect real-time connection
  Future<void> reconnect() async {
    try {
      await _client.realtime.disconnect();
      // Note: connect() is internal, so we'll just disconnect and let it auto-reconnect
      // await _client.realtime.connect();
    } catch (e) {
      throw Exception('Failed to reconnect real-time: $e');
    }
  }
  
  /// Dispose all channels and controllers
  void dispose() {
    for (final channel in _channels.values) {
      channel.unsubscribe();
    }
    _channels.clear();
    
    for (final controller in _controllers.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _controllers.clear();
  }
  
  // Private helper methods
  
  Future<List<Product>> _fetchProducts({
    int? categoryId,
    bool? isFeatured,
    String? searchQuery,
  }) async {
    try {
      var query = _client.from('products').select('*');
      
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      
      if (isFeatured != null) {
        query = query.eq('is_featured', isFeatured);
      }
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('name.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }
      
      final response = await query.order('created_at', ascending: false);
      
      return (response as List<dynamic>)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }
  
  Future<List<Category>> _fetchCategories({bool? isActive}) async {
    try {
      var query = _client.from('categories').select('*');
      
      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }
      
      final response = await query.order('name', ascending: true);
      
      return (response as List<dynamic>)
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }
  
  Future<List<Order>> _fetchOrders({String? status, String? userId}) async {
    try {
      var query = _client.from('orders').select('*');
      
      if (status != null) {
        query = query.eq('status', status);
      }
      
      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      
      final response = await query.order('created_at', ascending: false);
      
      return (response as List<dynamic>)
          .map((json) => Order.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }
  
  Future<List<Banner>> _fetchBanners({bool? isActive}) async {
    try {
      var query = _client.from('banners').select('*');
      
      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }
      
      final response = await query.order('sort_order', ascending: true);
      
      return (response as List<dynamic>)
          .map((json) => Banner.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch banners: $e');
    }
  }
  
  Future<List<Coupon>> _fetchCoupons({bool? isActive}) async {
    try {
      var query = _client.from('coupons').select('*');
      
      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }
      
      final response = await query.order('created_at', ascending: false);
      
      return (response as List<dynamic>)
          .map((json) => Coupon.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch coupons: $e');
    }
  }
  
  void _handleProductsChange(
    PostgresChangePayload payload,
    StreamController<List<Product>> controller, {
    int? categoryId,
    bool? isFeatured,
    String? searchQuery,
  }) {
    final channelKey = 'products_${categoryId ?? 'all'}_${isFeatured ?? 'all'}_${searchQuery ?? 'all'}';
    
    // Cancel existing timer
    _debounceTimers[channelKey]?.cancel();
    
    // Set up debounced update
    _debounceTimers[channelKey] = Timer(_debounceDelay, () {
      // Clear cache first
      _cache.clearCache(CacheService.productsKey);
      
      // Refetch data when changes occur
      _fetchProducts(
        categoryId: categoryId,
        isFeatured: isFeatured,
        searchQuery: searchQuery,
      ).then((products) {
        if (!controller.isClosed) {
          controller.add(products);
        }
      }).catchError((error) {
        if (!controller.isClosed) {
          controller.addError(error);
        }
      });
    });
  }
  
  void _handleCategoriesChange(
    PostgresChangePayload payload,
    StreamController<List<Category>> controller, {
    bool? isActive,
  }) {
    final channelKey = 'categories_${isActive ?? 'all'}';
    
    // Cancel existing timer
    _debounceTimers[channelKey]?.cancel();
    
    // Set up debounced update
    _debounceTimers[channelKey] = Timer(_debounceDelay, () {
      // Clear cache first
      _cache.clearCache(CacheService.categoriesKey);
      
      _fetchCategories(isActive: isActive).then((categories) {
        if (!controller.isClosed) {
          controller.add(categories);
        }
      }).catchError((error) {
        if (!controller.isClosed) {
          controller.addError(error);
        }
      });
    });
  }
  
  void _handleOrdersChange(
    PostgresChangePayload payload,
    StreamController<List<Order>> controller, {
    String? status,
    String? userId,
  }) {
    final channelKey = 'orders_${status ?? 'all'}_${userId ?? 'all'}';
    
    // Cancel existing timer
    _debounceTimers[channelKey]?.cancel();
    
    // Set up debounced update
    _debounceTimers[channelKey] = Timer(_debounceDelay, () {
      // Clear cache first
      _cache.clearCache(CacheService.ordersKey);
      
      _fetchOrders(status: status, userId: userId).then((orders) {
        if (!controller.isClosed) {
          controller.add(orders);
        }
      }).catchError((error) {
        if (!controller.isClosed) {
          controller.addError(error);
        }
      });
    });
  }
  
  void _handleBannersChange(
    PostgresChangePayload payload,
    StreamController<List<Banner>> controller, {
    bool? isActive,
  }) {
    final channelKey = 'banners_${isActive ?? 'all'}';
    
    // Cancel existing timer
    _debounceTimers[channelKey]?.cancel();
    
    // Set up debounced update
    _debounceTimers[channelKey] = Timer(_debounceDelay, () {
      // Clear cache first
      _cache.clearCache(CacheService.bannersKey);
      
      _fetchBanners(isActive: isActive).then((banners) {
        if (!controller.isClosed) {
          controller.add(banners);
        }
      }).catchError((error) {
        if (!controller.isClosed) {
          controller.addError(error);
        }
      });
    });
  }
  
  void _handleCouponsChange(
    PostgresChangePayload payload,
    StreamController<List<Coupon>> controller, {
    bool? isActive,
  }) {
    _fetchCoupons(isActive: isActive).then((coupons) {
      if (!controller.isClosed) {
        controller.add(coupons);
      }
    }).catchError((error) {
      if (!controller.isClosed) {
        controller.addError(error);
      }
    });
  }
  
  void _cleanupChannel(String channelKey) {
    final channel = _channels[channelKey];
    if (channel != null) {
      channel.unsubscribe();
      _channels.remove(channelKey);
    }
    
    final controller = _controllers[channelKey];
    if (controller != null) {
      if (!controller.isClosed) {
        controller.close();
      }
      _controllers.remove(channelKey);
    }
    
    _subscriptionCounts.remove(channelKey);
  }
  
  /// Decrement subscription count and cleanup if needed
  void _decrementSubscription(String channelKey) {
    final count = _subscriptionCounts[channelKey] ?? 0;
    if (count <= 1) {
      _cleanupChannel(channelKey);
    } else {
      _subscriptionCounts[channelKey] = count - 1;
    }
  }
  
  /// Get cached product stream without real-time updates
  Stream<List<Product>> _getCachedProductStream({
    int? categoryId,
    bool? isFeatured,
    String? searchQuery,
  }) {
    return Stream.fromFuture(
      _fetchProducts(
        categoryId: categoryId,
        isFeatured: isFeatured,
        searchQuery: searchQuery,
      ),
    );
  }
  
  /// Get cached category stream without real-time updates
  Stream<List<Category>> _getCachedCategoryStream({bool? isActive}) {
    return Stream.fromFuture(_fetchCategories(isActive: isActive));
  }
  
  /// Get cached order stream without real-time updates
  Stream<List<Order>> _getCachedOrderStream({String? status, String? userId}) {
    return Stream.fromFuture(_fetchOrders(status: status, userId: userId));
  }
  
  /// Get cached banner stream without real-time updates
  Stream<List<Banner>> _getCachedBannerStream({bool? isActive}) {
    return Stream.fromFuture(_fetchBanners(isActive: isActive));
  }
  
  /// Get cached coupon stream without real-time updates
  Stream<List<Coupon>> _getCachedCouponStream({bool? isActive}) {
    return Stream.fromFuture(_fetchCoupons(isActive: isActive));
  }
  
  /// Get subscription statistics
  Map<String, int> getSubscriptionStats() {
    return {
      'active_channels': _channels.length,
      'active_controllers': _controllers.length,
      'total_subscriptions': _subscriptionCounts.values.fold(0, (sum, count) => sum + count),
      'max_subscriptions': _maxSubscriptions,
    };
  }
}

/// Connection state enum for better type safety
enum RealtimeConnectionState {
  connecting,
  connected,
  disconnected,
  error,
}

/// Extension to convert Supabase connection state to our enum
extension RealtimeConnectionStateExtension on RealtimeConnectionState {
  static RealtimeConnectionState fromSupabase(String state) {
    switch (state.toLowerCase()) {
      case 'connecting':
        return RealtimeConnectionState.connecting;
      case 'connected':
        return RealtimeConnectionState.connected;
      case 'disconnected':
        return RealtimeConnectionState.disconnected;
      case 'error':
        return RealtimeConnectionState.error;
      default:
        return RealtimeConnectionState.disconnected;
    }
  }
  
  String get value {
    switch (this) {
      case RealtimeConnectionState.connecting:
        return 'connecting';
      case RealtimeConnectionState.connected:
        return 'connected';
      case RealtimeConnectionState.disconnected:
        return 'disconnected';
      case RealtimeConnectionState.error:
        return 'error';
    }
  }
}