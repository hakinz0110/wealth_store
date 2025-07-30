import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/order.dart';
import 'supabase_service.dart';

part 'order_service.g.dart';

@riverpod
OrderService orderService(OrderServiceRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return OrderService(supabase);
}

class OrderService {
  final SupabaseClient _client;
  
  OrderService(this._client);
  
  // Get orders with optional filtering and sorting
  Future<List<Order>> getOrders({
    int? limit,
    int? offset,
    String? status,
    String? userId,
    String sortBy = 'created_at',
    bool ascending = false,
  }) async {
    try {
      var query = _client.from('orders').select('*');
      
      // Apply filters
      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }
      
      if (userId != null && userId.isNotEmpty) {
        query = query.eq('user_id', userId);
      }
      
      // Apply sorting and pagination
      var transformQuery = query.order(sortBy, ascending: ascending);
      
      if (limit != null) {
        transformQuery = transformQuery.limit(limit);
      }
      
      if (offset != null) {
        transformQuery = transformQuery.range(offset, offset + (limit ?? 10) - 1);
      }
      
      final response = await transformQuery;
      
      return (response as List<dynamic>)
          .map((json) => Order.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }
  
  // Get a single order by ID
  Future<Order?> getOrderById(String id) async {
    try {
      final response = await _client
          .from('orders')
          .select('*')
          .eq('id', id)
          .single();
      
      return Order.fromJson(response);
    } catch (e) {
      if (e is PostgrestException && e.code == 'PGRST116') {
        return null; // Order not found
      }
      throw Exception('Failed to fetch order: $e');
    }
  }
  
  // Get orders by user ID
  Future<List<Order>> getOrdersByUserId(String userId, {
    int? limit,
    int? offset,
    String? status,
  }) async {
    return getOrders(
      userId: userId,
      status: status,
      limit: limit,
      offset: offset,
    );
  }
  
  // Get orders by status
  Future<List<Order>> getOrdersByStatus(String status, {
    int? limit,
    int? offset,
  }) async {
    return getOrders(
      status: status,
      limit: limit,
      offset: offset,
    );
  }
  
  // Get recent orders
  Future<List<Order>> getRecentOrders({int limit = 10}) async {
    return getOrders(
      limit: limit,
      sortBy: 'created_at',
      ascending: false,
    );
  }
  
  // Create a new order
  Future<Order> createOrder(Order order) async {
    try {
      final orderData = order.toJson();
      // Remove id and timestamps for creation
      orderData.remove('id');
      orderData.remove('created_at');
      orderData.remove('updated_at');
      
      // Add timestamps
      final now = DateTime.now().toIso8601String();
      orderData['created_at'] = now;
      orderData['updated_at'] = now;
      
      // Status is already a string
      orderData['status'] = order.status;
      
      final response = await _client
          .from('orders')
          .insert(orderData)
          .select()
          .single();
      
      return Order.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }
  
  // Update order status
  Future<Order> updateOrderStatus(String id, String status) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      final response = await _client
          .from('orders')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();
      
      return Order.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
  

  
  // Cancel an order
  Future<Order> cancelOrder(String id) async {
    try {
      // First check if order can be cancelled
      final order = await getOrderById(id);
      if (order == null) {
        throw Exception('Order not found');
      }
      
      if (!order.canBeCancelled) {
        throw Exception('Order cannot be cancelled in current status: ${order.statusDisplayName}');
      }
      
      return await updateOrderStatus(id, 'cancelled');
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }
  
  // Get order statistics
  Future<Map<String, int>> getOrderStatistics() async {
    try {
      final orders = await getOrders();
      
      final stats = <String, int>{
        'total': orders.length,
        'pending': 0,
        'confirmed': 0,
        'shipped': 0,
        'delivered': 0,
        'cancelled': 0,
      };
      
      for (final order in orders) {
        stats[order.status] = (stats[order.status] ?? 0) + 1;
      }
      
      return stats;
    } catch (e) {
      throw Exception('Failed to get order statistics: $e');
    }
  }
  
  // Get order count for pagination
  Future<int> getOrderCount({
    String? status,
    String? userId,
    String? paymentStatus,
  }) async {
    try {
      final orders = await getOrders(
        status: status,
        userId: userId,
      );
      return orders.length;
    } catch (e) {
      throw Exception('Failed to get order count: $e');
    }
  }
  
  // Search orders by order number or customer info
  Future<List<Order>> searchOrders(String query, {
    int? limit,
    int? offset,
  }) async {
    try {
      var dbQuery = _client.from('orders').select('*');
      
      // Search by order number or user info
      dbQuery = dbQuery.or('order_number.ilike.%$query%,shipping_address->>full_name.ilike.%$query%');
      
      // Apply sorting and pagination
      var transformQuery = dbQuery.order('created_at', ascending: false);
      
      if (limit != null) {
        transformQuery = transformQuery.limit(limit);
      }
      
      if (offset != null) {
        transformQuery = transformQuery.range(offset, offset + (limit ?? 10) - 1);
      }
      
      final response = await transformQuery;
      
      return (response as List<dynamic>)
          .map((json) => Order.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search orders: $e');
    }
  }
  
  // Get orders within date range
  Future<List<Order>> getOrdersByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client
          .from('orders')
          .select('*')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());
      
      // Apply sorting and pagination
      var transformQuery = query.order('created_at', ascending: false);
      
      if (limit != null) {
        transformQuery = transformQuery.limit(limit);
      }
      
      if (offset != null) {
        transformQuery = transformQuery.range(offset, offset + (limit ?? 10) - 1);
      }
      
      final response = await transformQuery;
      
      return (response as List<dynamic>)
          .map((json) => Order.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders by date range: $e');
    }
  }
  
  // Get total revenue
  Future<double> getTotalRevenue({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    try {
      var query = _client.from('orders').select('total_amount');
      
      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }
      
      if (status != null) {
        query = query.eq('status', status);
      } else {
        // Only count completed orders for revenue
        query = query.eq('status', 'delivered');
      }
      
      final response = await query;
      
      double totalRevenue = 0.0;
      for (final order in response) {
        totalRevenue += (order['total_amount'] as num).toDouble();
      }
      
      return totalRevenue;
    } catch (e) {
      throw Exception('Failed to calculate total revenue: $e');
    }
  }
  
  // Validation methods
  List<String> validateOrder(Order order) {
    final errors = <String>[];
    
    // User ID validation
    if (order.userId.trim().isEmpty) {
      errors.add('User ID is required');
    }
    
    // Order number validation
    if (order.orderNumber.trim().isEmpty) {
      errors.add('Order number is required');
    }
    
    // Total amount validation
    if (order.totalAmount <= 0) {
      errors.add('Total amount must be greater than 0');
    }
    
    // Order items validation
    if (order.orderItems.isEmpty) {
      errors.add('Order must contain at least one item');
    }
    
    // Shipping address validation
    if (order.shippingAddress.fullName.trim().isEmpty) {
      errors.add('Shipping address full name is required');
    }
    
    if (order.shippingAddress.addressLine1.trim().isEmpty) {
      errors.add('Shipping address line 1 is required');
    }
    
    if (order.shippingAddress.city.trim().isEmpty) {
      errors.add('Shipping city is required');
    }
    
    if (order.shippingAddress.state.trim().isEmpty) {
      errors.add('Shipping state is required');
    }
    
    if (order.shippingAddress.postalCode.trim().isEmpty) {
      errors.add('Shipping postal code is required');
    }
    
    if (order.shippingAddress.country.trim().isEmpty) {
      errors.add('Shipping country is required');
    }
    
    return errors;
  }
  
  // Check if order number exists (for validation)
  Future<bool> orderNumberExists(String orderNumber, {String? excludeId}) async {
    try {
      var query = _client
          .from('orders')
          .select('id')
          .eq('order_number', orderNumber);
      
      if (excludeId != null) {
        query = query.neq('id', excludeId);
      }
      
      final response = await query;
      return response.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check order number: $e');
    }
  }
  
  // Generate unique order number
  Future<String> generateOrderNumber() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    final orderNumber = 'ORD-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}-$random';
    
    // Check if it exists and regenerate if needed
    if (await orderNumberExists(orderNumber)) {
      return generateOrderNumber(); // Recursive call to generate new number
    }
    
    return orderNumber;
  }
  
  // Real-time subscription for orders
  Stream<List<Order>> watchOrders({
    String? status,
    String? userId,
  }) {
    // For now, return a simple stream that fetches orders periodically
    // This can be enhanced later with proper real-time subscriptions
    return Stream.periodic(const Duration(seconds: 5), (_) async {
      return await getOrders(status: status, userId: userId);
    }).asyncMap((future) => future);
  }
  
  // Connection health check
  Future<bool> checkConnection() async {
    try {
      await _client.from('orders').select('id').limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }
}