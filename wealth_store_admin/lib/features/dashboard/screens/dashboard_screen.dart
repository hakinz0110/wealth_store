import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../shared/widgets/admin_layout.dart';
import '../../../shared/constants/app_colors.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/metric_card.dart';
import '../widgets/weekly_sales_chart.dart';
import '../widgets/order_status_chart.dart';
import '../widgets/recent_orders_table.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardData = ref.watch(dashboardDataProvider);

    return AdminLayout(
      title: 'Dashboard',
      currentRoute: '/dashboard',
      child: dashboardData.when(
        data: (data) => _buildDashboardContent(context, data),
        loading: () => _buildLoadingState(),
        error: (error, stackTrace) => _buildErrorState(error, ref),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, data) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh dashboard data
        // ref.refresh(dashboardDataProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            _buildWelcomeSection(),
            
            const SizedBox(height: 24),
            
            // Metrics cards
            _buildMetricsSection(data.metrics, isDesktop),
            
            const SizedBox(height: 24),
            
            // Charts section
            _buildChartsSection(data, isDesktop),
            
            const SizedBox(height: 24),
            
            // Recent orders table
            RecentOrdersTable(orders: data.recentOrders),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back to your dashboard!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Here\'s what\'s happening with your store today.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.dashboard,
            size: 48,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(metrics, bool isDesktop) {
    final cards = [
      MetricCard.salesTotal(
        amount: metrics.salesTotal,
        changePercentage: metrics.salesChange,
      ),
      MetricCard.averageOrderValue(
        amount: metrics.averageOrderValue,
        changePercentage: metrics.averageOrderChange,
      ),
      MetricCard.totalOrders(
        count: metrics.totalOrders,
        changePercentage: metrics.ordersChange,
      ),
      MetricCard.visitors(
        count: metrics.visitors,
        changePercentage: metrics.visitorsChange,
      ),
    ];

    if (isDesktop) {
      return LayoutBuilder(
        builder: (context, constraints) {
          // Use GridView for better responsive behavior
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: constraints.maxWidth > 1200 ? 4 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: constraints.maxWidth > 1200 ? 2.5 : 2.0,
            children: cards,
          );
        },
      );
    } else {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
        children: cards,
      );
    }
  }

  Widget _buildChartsSection(data, bool isDesktop) {
    final salesChart = WeeklySalesChart(data: data.weeklySales);
    final statusChart = OrderStatusChart(data: data.orderStatus);

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: salesChart,
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: statusChart,
          ),
        ],
      );
    } else {
      return Column(
        children: [
          salesChart,
          const SizedBox(height: 16),
          statusChart,
        ],
      );
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ),
          SizedBox(height: 16),
          Text(
            'Loading dashboard data...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load dashboard data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.refresh(dashboardDataProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}