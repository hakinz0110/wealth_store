import '../models/dashboard_models.dart';
import '../shared/utils/logger.dart';
import '../shared/utils/error_handler.dart';
import 'supabase_service.dart';

class DashboardService {
  // Get dashboard data from Supabase
  static Future<DashboardData> getDashboardData() async {
    try {
      Logger.info('Fetching dashboard data from Supabase');
      
      // Fetch all data in parallel
      final futures = await Future.wait([
        getMetrics(),
        getWeeklySales(),
        getOrderStatusData(),
        getRecentOrders(),
      ]);

      return DashboardData(
        metrics: futures[0] as DashboardMetrics,
        weeklySales: futures[1] as List<WeeklySalesData>,
        orderStatus: futures[2] as List<OrderStatusData>,
        recentOrders: futures[3] as List<RecentOrder>,
      );
    } catch (e, stackTrace) {
      ErrorHandler.logError('Dashboard data fetch', e, stackTrace);
      rethrow;
    }
  }

  // Get metrics from Supabase
  static Future<DashboardMetrics> getMetrics() async {
    try {
      Logger.info('Fetching dashboard metrics from Supabase');
      
      // Get total sales
      final salesResponse = await SupabaseService.client
          .from('orders')
          .select('total')
          .eq('status', 'completed');
      
      final totalSales = salesResponse.fold<double>(
        0.0, 
        (sum, order) => sum + (order['total'] as num).toDouble()
      );

      // Get total orders
      final ordersResponse = await SupabaseService.client
          .from('orders')
          .select('id');
      final ordersCount = ordersResponse.length;

      // Get total products
      final productsResponse = await SupabaseService.client
          .from('products')
          .select('id');
      final productsCount = productsResponse.length;

      // Get total users
      final usersResponse = await SupabaseService.client
          .from('users')
          .select('id')
          .neq('role', 'admin');
      final usersCount = usersResponse.length;

      // Calculate average order value
      final avgOrderValue = ordersCount > 0 ? totalSales / ordersCount : 0.0;

      // Get previous period data for comparison (simplified)
      final previousSales = totalSales * 0.85; // Mock 15% growth
      final salesChange = totalSales > 0 ? ((totalSales - previousSales) / previousSales * 100) : 0.0;

      return DashboardMetrics(
        salesTotal: totalSales,
        salesChange: salesChange,
        averageOrderValue: avgOrderValue,
        averageOrderChange: 8.2, // Mock data
        totalOrders: ordersCount,
        ordersChange: 12.5, // Mock data
        visitors: usersCount,
        visitorsChange: 5.3, // Mock data
      );
    } catch (e, stackTrace) {
      ErrorHandler.logError('Dashboard metrics fetch', e, stackTrace);
      // Return default metrics on error
      return const DashboardMetrics(
        salesTotal: 0,
        salesChange: 0,
        averageOrderValue: 0,
        averageOrderChange: 0,
        totalOrders: 0,
        ordersChange: 0,
        visitors: 0,
        visitorsChange: 0,
      );
    }
  }

  // Get weekly sales data from Supabase
  static Future<List<WeeklySalesData>> getWeeklySales() async {
    try {
      Logger.info('Fetching weekly sales data from Supabase');
      
      // Get sales data for the last 7 days
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 6));
      
      final response = await SupabaseService.client
          .from('orders')
          .select('created_at, total')
          .eq('status', 'completed')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      // Group by day
      final salesByDay = <String, double>{};
      for (final order in response) {
        final date = DateTime.parse(order['created_at']).toLocal();
        final dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        salesByDay[dayKey] = (salesByDay[dayKey] ?? 0) + (order['total'] as num).toDouble();
      }

      // Create data for all 7 days
      final weeklyData = <WeeklySalesData>[];
      for (int i = 0; i < 7; i++) {
        final date = startDate.add(Duration(days: i));
        final dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final dayName = _getDayName(date.weekday);
        
        weeklyData.add(WeeklySalesData(
          day: dayName,
          amount: salesByDay[dayKey] ?? 0,
        ));
      }

      return weeklyData;
    } catch (e, stackTrace) {
      ErrorHandler.logError('Weekly sales data fetch', e, stackTrace);
      // Return empty data on error
      return [];
    }
  }

  // Get order status distribution from Supabase
  static Future<List<OrderStatusData>> getOrderStatusData() async {
    try {
      Logger.info('Fetching order status data from Supabase');
      
      final response = await SupabaseService.client
          .from('orders')
          .select('status');

      // Count orders by status
      final statusCounts = <String, int>{};
      for (final order in response) {
        final status = order['status'] as String;
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }

      // Convert to OrderStatusData list
      final totalCount = statusCounts.values.fold(0, (a, b) => a + b);
      return statusCounts.entries.map((entry) {
        return OrderStatusData(
          status: _formatStatusName(entry.key),
          count: entry.value,
          percentage: 50, // Simple default percentage
        );
      }).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Order status data fetch', e, stackTrace);
      // Return empty data on error
      return [];
    }
  }

  // Get recent orders from Supabase
  static Future<List<RecentOrder>> getRecentOrders() async {
    try {
      Logger.info('Fetching recent orders from Supabase');
      
      final response = await SupabaseService.client
          .from('orders')
          .select('id, total, status, created_at, users(email)')
          .order('created_at', ascending: false)
          .limit(10);

      return response.map<RecentOrder>((json) {
        return RecentOrder(
          id: json['id'].toString(),
          customerName: json['users']?['email'] ?? 'Unknown',
          date: DateTime.parse(json['created_at']),
          itemCount: 1, // Default to 1 for now
          status: json['status'],
          amount: (json['total'] as num).toDouble(),
        );
      }).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Recent orders fetch', e, stackTrace);
      // Return empty data on error
      return [];
    }
  }

  // Helper method to get day name
  static String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return 'Unknown';
    }
  }

  // Helper method to format status name
  static String _formatStatusName(String status) {
    return status.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }

  // Helper method to get status color
  static int _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 0xFFF59E0B; // Orange
      case 'processing': return 0xFF3B82F6; // Blue
      case 'shipped': return 0xFF8B5CF6; // Purple
      case 'delivered': return 0xFF10B981; // Green
      case 'completed': return 0xFF10B981; // Green
      case 'cancelled': return 0xFFEF4444; // Red
      default: return 0xFF6B7280; // Gray
    }
  }
}