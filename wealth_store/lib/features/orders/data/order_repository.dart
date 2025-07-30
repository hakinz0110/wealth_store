import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wealth_app/core/services/order_service.dart';
import 'package:wealth_app/shared/models/order.dart';

part 'order_repository.g.dart';

@riverpod
OrderRepository orderRepository(OrderRepositoryRef ref) {
  final orderService = ref.watch(orderServiceProvider);
  return OrderRepository(orderService);
}

class OrderRepository {
  final OrderService _orderService;

  OrderRepository(this._orderService);

  // Get orders for the current user
  Future<List<Order>> getUserOrders({
    int? limit,
    int? offset,
    String? status,
    required String userId,
  }) async {
    return _orderService.getOrdersByUserId(
      userId,
      limit: limit,
      offset: offset,
      status: status,
    );
  }

  // Get a single order by ID
  Future<Order?> getOrderById(String id) async {
    return _orderService.getOrderById(id);
  }

  // Create a new order
  Future<Order> createOrder({
    required String customerId,
    required double total,
    required List<OrderItem> items,
    required ShippingAddress shippingAddress,
    String paymentMethod = 'credit_card',
  }) async {
    // Generate a unique order number
    final orderNumber = await _orderService.generateOrderNumber();
    
    // Create the order object
    final order = Order(
      id: '', // Will be assigned by the database
      userId: customerId,
      orderNumber: orderNumber,
      status: 'pending',
      totalAmount: total,
      orderItems: items,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      paymentStatus: 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Validate the order
    final errors = _orderService.validateOrder(order);
    if (errors.isNotEmpty) {
      throw Exception('Invalid order: ${errors.join(', ')}');
    }
    
    // Create the order in the database
    return _orderService.createOrder(order);
  }

  // Cancel an order
  Future<Order> cancelOrder(String id) async {
    return _orderService.cancelOrder(id);
  }

  // Get real-time updates for user orders
  Stream<List<Order>> watchUserOrders(String userId) {
    return _orderService.watchOrders(userId: userId);
  }
}