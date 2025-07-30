import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wealth_app/core/providers/auth_provider.dart';
import 'package:wealth_app/features/orders/data/order_repository.dart';
import 'package:wealth_app/features/orders/domain/order_state.dart';
import 'package:wealth_app/shared/models/order.dart';

part 'order_notifier.g.dart';

@riverpod
class OrderNotifier extends _$OrderNotifier {
  @override
  OrderState build() {
    _loadOrders();
    return OrderState.initial();
  }

  Future<void> _loadOrders() async {
    state = OrderState.loading();
    
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        state = OrderState.error('User not authenticated');
        return;
      }
      
      final orders = await ref.read(orderRepositoryProvider).getUserOrders(
        userId: user.id,
      );
      
      state = OrderState.loaded(orders);
    } catch (e) {
      state = OrderState.error('Failed to load orders: $e');
    }
  }

  Future<void> refreshOrders() async {
    await _loadOrders();
  }

  Future<void> getOrderById(String orderId) async {
    try {
      final order = await ref.read(orderRepositoryProvider).getOrderById(orderId);
      if (order != null) {
        state = state.copyWith(selectedOrder: order);
      } else {
        state = state.copyWith(error: 'Order not found');
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to load order: $e');
    }
  }

  Future<Order> createOrder({
    required double total,
    required List<OrderItem> items,
    required ShippingAddress shippingAddress,
    required String paymentMethod,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      final order = await ref.read(orderRepositoryProvider).createOrder(
        customerId: user.id,
        total: total,
        items: items,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
      );
      
      // Refresh orders list
      await _loadOrders();
      
      return order;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to create order: $e');
      rethrow;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await ref.read(orderRepositoryProvider).cancelOrder(orderId);
      await _loadOrders();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to cancel order: $e');
    }
  }

  // Filter orders by status
  Future<void> filterByStatus(String status) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      final orders = await ref.read(orderRepositoryProvider).getUserOrders(
        userId: user.id,
        status: status,
      );
      
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to filter orders: $e');
    }
  }
}