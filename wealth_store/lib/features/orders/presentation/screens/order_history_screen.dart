import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/features/orders/domain/order_notifier.dart';
import 'package:wealth_app/shared/models/order.dart';
import 'package:wealth_app/shared/widgets/error_widget.dart';
import 'package:wealth_app/shared/widgets/loading_widget.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  String _selectedStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Status filter
          _buildStatusFilter(),
          
          // Order list
          Expanded(
            child: orderState.isLoading
                ? const LoadingWidget()
                : orderState.error != null
                    ? CustomErrorWidget(
                        error: orderState.error!,
                        onRetry: () => ref.read(orderNotifierProvider.notifier).refreshOrders(),
                      )
                    : orderState.orders.isEmpty
                        ? _buildEmptyState()
                        : _buildOrderList(orderState.orders),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
        child: Row(
          children: [
            _buildFilterChip('All', 'all'),
            _buildFilterChip('Pending', 'pending'),
            _buildFilterChip('Confirmed', 'confirmed'),
            _buildFilterChip('Shipped', 'shipped'),
            _buildFilterChip('Delivered', 'delivered'),
            _buildFilterChip('Cancelled', 'cancelled'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedStatus == value;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedStatus = value;
          });
          
          if (value == 'all') {
            ref.read(orderNotifierProvider.notifier).refreshOrders();
          } else {
            ref.read(orderNotifierProvider.notifier).filterByStatus(value);
          }
        },
        backgroundColor: Colors.grey[200],
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'No orders found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            _selectedStatus == 'all'
                ? 'You haven\'t placed any orders yet'
                : 'You don\'t have any ${_selectedStatus} orders',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderList(List<Order> orders) {
    return RefreshIndicator(
      onRefresh: () => ref.read(orderNotifierProvider.notifier).refreshOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.medium),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _OrderCard(order: order);
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: InkWell(
        onTap: () => context.push('/orders/${order.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.orderNumber}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusBadge(context, order.status),
                ],
              ),
              const Divider(height: 24),
              
              // Order date
              Text(
                'Placed on ${_formatDate(order.createdAt)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              
              // Order items summary
              Text(
                '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.small),
              
              // Order total
              Text(
                'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              
              // Action buttons
              if (order.canBeCancelled)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.medium),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => _showCancelDialog(context, order),
                        child: const Text('Cancel Order'),
                      ),
                      const SizedBox(width: AppSpacing.medium),
                      ElevatedButton(
                        onPressed: () => context.push('/orders/${order.id}'),
                        child: const Text('View Details'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusBadge(BuildContext context, String status) {
    Color color;
    
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'confirmed':
        color = Colors.blue;
        break;
      case 'shipped':
        color = Colors.indigo;
        break;
      case 'delivered':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12.0,
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
  
  void _showCancelDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No, Keep Order'),
          ),
          Consumer(
            builder: (context, ref, _) => TextButton(
              onPressed: () {
                ref.read(orderNotifierProvider.notifier).cancelOrder(order.id);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Yes, Cancel Order',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}