import '../models/order_models.dart';
import '../shared/utils/logger.dart';
import '../shared/utils/error_handler.dart';
import 'supabase_service.dart';

class OrderService {
  static const String _tableName = 'orders';

  // Get all orders from Supabase with pagination and filters
  Future<List<Order>> getOrders({
    int page = 1,
    int limit = 20,
    OrderFilters? filters,
  }) async {
    try {
      Logger.info('Fetching orders from Supabase - Page: $page, Limit: $limit');
      
      var query = SupabaseService.client
          .from(_tableName)
          .select('*, users(email, full_name)');

      // Apply filters
      if (filters != null) {
        if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
          query = query.ilike('id', '%${filters.searchQuery}%');
        }
        
        if (filters.status != null) {
          query = query.eq('status', filters.status!.value);
        }
        
        if (filters.customerId != null) {
          query = query.eq('user_id', filters.customerId!);
        }
        
        if (filters.startDate != null) {
          query = query.gte('created_at', filters.startDate!.toIso8601String());
        }
        
        if (filters.endDate != null) {
          query = query.lte('created_at', filters.endDate!.toIso8601String());
        }
        
        if (filters.minTotal != null) {
          query = query.gte('total', filters.minTotal!);
        }
        
        if (filters.maxTotal != null) {
          query = query.lte('total', filters.maxTotal!);
        }
      }

      // Apply ordering and pagination
      final offset = (page - 1) * limit;
      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map<Order>((json) {
        // Ensure we have default values for required fields
        final orderData = Map<String, dynamic>.from(json);
        orderData['subtotal'] ??= orderData['total'] ?? 0.0;
        return Order.fromJson(orderData);
      }).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get orders', e, stackTrace);
      rethrow;
    }
  }

  // Get order by ID from Supabase
  Future<Order?> getOrderById(String id) async {
    try {
      Logger.info('Fetching order by ID: $id');
      
      final response = await SupabaseService.client
          .from(_tableName)
          .select('*, users(email, full_name)')
          .eq('id', id)
          .single();

      // Ensure we have default values for required fields
      final orderData = Map<String, dynamic>.from(response);
      orderData['subtotal'] ??= orderData['total'] ?? 0.0;
      return Order.fromJson(orderData);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get order by ID', e, stackTrace);
      return null;
    }
  }

  // Update order status
  Future<Order> updateOrderStatus(String id, OrderStatus status) async {
    try {
      Logger.info('Updating order status: $id to ${status.value}');

      final response = await SupabaseService.client
          .from(_tableName)
          .update({
            'status': status.value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select('*, users(email, full_name)')
          .single();

      Logger.info('Order status updated successfully: $id');
      // Ensure we have default values for required fields
      final orderData = Map<String, dynamic>.from(response);
      orderData['subtotal'] ??= orderData['total'] ?? 0.0;
      return Order.fromJson(orderData);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Update order status', e, stackTrace);
      rethrow;
    }
  }

  // Get orders by status
  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    try {
      Logger.info('Fetching orders by status: ${status.value}');
      
      final response = await SupabaseService.client
          .from(_tableName)
          .select('*, users(email, full_name)')
          .eq('status', status.value)
          .order('created_at', ascending: false);

      return response.map<Order>((json) {
        // Ensure we have default values for required fields
        final orderData = Map<String, dynamic>.from(json);
        orderData['subtotal'] ??= orderData['total'] ?? 0.0;
        return Order.fromJson(orderData);
      }).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get orders by status', e, stackTrace);
      rethrow;
    }
  }

  // Get recent orders
  Future<List<Order>> getRecentOrders({int limit = 10}) async {
    try {
      Logger.info('Fetching recent orders');
      
      final response = await SupabaseService.client
          .from(_tableName)
          .select('*, users(email, full_name)')
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map<Order>((json) {
        // Ensure we have default values for required fields
        final orderData = Map<String, dynamic>.from(json);
        orderData['subtotal'] ??= orderData['total'] ?? 0.0;
        return Order.fromJson(orderData);
      }).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get recent orders', e, stackTrace);
      rethrow;
    }
  }

  // Get order statistics
  Future<Map<String, dynamic>> getOrderStatistics() async {
    try {
      Logger.info('Fetching order statistics');
      
      final allOrders = await SupabaseService.client
          .from(_tableName)
          .select('status, total, created_at');

      final totalOrders = allOrders.length;
      final totalRevenue = allOrders.fold<double>(
        0.0, 
        (sum, order) => sum + (order['total'] as num).toDouble()
      );

      final statusCounts = <String, int>{};
      for (final order in allOrders) {
        final status = order['status'] as String;
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }

      // Calculate today's orders
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayOrders = allOrders.where((order) {
        final orderDate = DateTime.parse(order['created_at']);
        return orderDate.isAfter(todayStart);
      }).length;

      return {
        'totalOrders': totalOrders,
        'totalRevenue': totalRevenue,
        'todayOrders': todayOrders,
        'statusCounts': statusCounts,
        'averageOrderValue': totalOrders > 0 ? totalRevenue / totalOrders : 0.0,
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get order statistics', e, stackTrace);
      return {
        'totalOrders': 0,
        'totalRevenue': 0.0,
        'todayOrders': 0,
        'statusCounts': <String, int>{},
        'averageOrderValue': 0.0,
      };
    }
  }

  // Search orders
  Future<List<Order>> searchOrders(String query) async {
    try {
      Logger.info('Searching orders: $query');
      
      final response = await SupabaseService.client
          .from(_tableName)
          .select('*, users(email, full_name)')
          .or('id.ilike.%$query%')
          .order('created_at', ascending: false)
          .limit(50);

      return response.map<Order>((json) {
        // Ensure we have default values for required fields
        final orderData = Map<String, dynamic>.from(json);
        orderData['subtotal'] ??= orderData['total'] ?? 0.0;
        return Order.fromJson(orderData);
      }).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Search orders', e, stackTrace);
      rethrow;
    }
  }
}