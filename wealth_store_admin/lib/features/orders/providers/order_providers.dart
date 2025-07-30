import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/order_models.dart';
import '../../../services/order_service.dart';

// Order service provider
final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

// Orders state notifier
class OrdersNotifier extends StateNotifier<AsyncValue<List<Order>>> {
  final OrderService _orderService;
  OrderFilters _filters = const OrderFilters();
  int _currentPage = 1;
  static const int _pageSize = 20;

  OrdersNotifier(this._orderService) : super(const AsyncValue.loading()) {
    loadOrders();
  }

  OrderFilters get filters => _filters;

  Future<void> loadOrders({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      state = const AsyncValue.loading();
    }

    try {
      final orders = await _orderService.getOrders(
        page: _currentPage,
        limit: _pageSize,
        filters: _filters,
      );
      
      state = AsyncValue.data(orders);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoading) return;
    
    try {
      _currentPage++;
      final nextPageOrders = await _orderService.getOrders(
        page: _currentPage,
        limit: _pageSize,
        filters: _filters,
      );
      
      if (nextPageOrders.isEmpty) {
        _currentPage--;
        return;
      }
      
      state.whenData((currentOrders) {
        state = AsyncValue.data([...currentOrders, ...nextPageOrders]);
      });
    } catch (e, stack) {
      _currentPage = _currentPage > 1 ? _currentPage - 1 : 1;
      state = AsyncValue.error(e, stack);
    }
  }

  void updateFilters(OrderFilters newFilters) {
    _filters = newFilters;
    loadOrders(refresh: true);
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      final updatedOrder = await _orderService.updateOrderStatus(orderId, newStatus);
      
      state.whenData((orders) {
        final updatedOrders = orders.map((order) {
          return order.id == orderId ? updatedOrder : order;
        }).toList();
        
        state = AsyncValue.data(updatedOrders);
      });
    } catch (e, stack) {
      // Keep the current state but notify of error
      debugPrint('Error updating order status: $e');
    }
  }
}

// Orders provider
final ordersProvider = StateNotifierProvider<OrdersNotifier, AsyncValue<List<Order>>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  return OrdersNotifier(orderService);
});

// Order statistics provider
final orderStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final orderService = ref.watch(orderServiceProvider);
  return await orderService.getOrderStatistics();
});

// Single order provider
final orderDetailsProvider = FutureProvider.family<Order?, String>((ref, orderId) async {
  final orderService = ref.watch(orderServiceProvider);
  return await orderService.getOrderById(orderId);
});

// Order filters provider
final orderFiltersProvider = StateProvider<OrderFilters>((ref) {
  return const OrderFilters();
});