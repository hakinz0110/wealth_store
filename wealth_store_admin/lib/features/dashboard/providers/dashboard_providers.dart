import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../models/dashboard_models.dart';
import '../../../services/dashboard_service.dart';

// Dashboard data provider
final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  return await DashboardService.getDashboardData();
});

// Dashboard metrics provider
final dashboardMetricsProvider = FutureProvider<DashboardMetrics>((ref) async {
  return await DashboardService.getMetrics();
});

// Weekly sales data provider
final weeklySalesProvider = FutureProvider<List<WeeklySalesData>>((ref) async {
  return await DashboardService.getWeeklySales();
});

// Order status data provider
final orderStatusProvider = FutureProvider<List<OrderStatusData>>((ref) async {
  return await DashboardService.getOrderStatusData();
});

// Recent orders provider
final recentOrdersProvider = FutureProvider<List<RecentOrder>>((ref) async {
  return await DashboardService.getRecentOrders();
});

// Auto-refresh provider (refreshes every 5 minutes)
final autoRefreshProvider = StreamProvider<int>((ref) {
  return Stream.periodic(const Duration(minutes: 5), (count) => count);
});

// Combined dashboard state provider
final dashboardStateProvider = Provider<AsyncValue<DashboardData>>((ref) {
  // Listen to auto-refresh to trigger data refresh
  ref.watch(autoRefreshProvider);
  
  // Return the dashboard data
  return ref.watch(dashboardDataProvider);
});