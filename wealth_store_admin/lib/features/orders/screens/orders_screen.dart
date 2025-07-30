import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/admin_layout.dart';
import '../../../models/order_models.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../widgets/order_status_chip.dart';
import '../widgets/order_details_dialog.dart';
import '../providers/order_providers.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      final ordersNotifier = ref.read(ordersProvider.notifier);
      ordersNotifier.loadNextPage();
    }
  }

  void _updateFilters(OrderFilters newFilters) {
    final ordersNotifier = ref.read(ordersProvider.notifier);
    ordersNotifier.updateFilters(newFilters);
  }

  Future<void> _updateOrderStatus(Order order, OrderStatus newStatus) async {
    try {
      final ordersNotifier = ref.read(ordersProvider.notifier);
      await ordersNotifier.updateOrderStatus(order.id, newStatus);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order ${order.id} status updated to ${newStatus.displayName}'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating order: $e')),
      );
    }
  }

  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) => OrderDetailsDialog(
        order: order,
        onStatusUpdate: (newStatus) => _updateOrderStatus(order, newStatus),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Orders',
      currentRoute: '/orders',
      breadcrumbs: const ['Dashboard', 'Orders'],
      child: Column(
        children: [
          // Header with stats
          _buildHeader(),
          
          const SizedBox(height: 24),
          
          // Filters
          _buildFilters(),
          
          const SizedBox(height: 24),
          
          // Orders table
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final statisticsAsync = ref.watch(orderStatisticsProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats cards
          statisticsAsync.when(
            data: (statistics) => Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Orders',
                    statistics['totalOrders']?.toString() ?? '0',
                    Icons.shopping_cart,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Total Revenue',
                    '\${(statistics['totalRevenue'] ?? 0.0).toStringAsFixed(2)}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Today\'s Orders',
                    statistics['todayOrders']?.toString() ?? '0',
                    Icons.today,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Avg Order Value',
                    '\${(statistics['averageOrderValue'] ?? 0.0).toStringAsFixed(2)}',
                    Icons.trending_up,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error loading statistics: $error'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ref.watch(ordersProvider.notifier).filters;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Search
            Expanded(
              flex: 2,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search orders...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (value) {
                  _updateFilters(filters.copyWith(
                    searchQuery: value.isEmpty ? null : value,
                  ));
                },
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Status filter
            Expanded(
              child: DropdownButtonFormField<OrderStatus?>(
                value: filters.status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem<OrderStatus?>(
                    value: null,
                    child: Text('All Statuses'),
                  ),
                  ...OrderStatus.values.map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.displayName),
                  )),
                ],
                onChanged: (value) {
                  _updateFilters(filters.copyWith(status: value));
                },
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Clear filters
            if (filters.status != null || filters.searchQuery != null)
              TextButton(
                onPressed: () {
                  _updateFilters(const OrderFilters());
                  _searchController.clear();
                },
                child: const Text('Clear Filters'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final ordersAsync = ref.watch(ordersProvider);
    
    return ordersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          final filters = ref.watch(ordersProvider.notifier).filters;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  filters.searchQuery != null || filters.status != null
                      ? 'No orders match your filters'
                      : 'No orders found',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  filters.searchQuery != null || filters.status != null
                      ? 'Try adjusting your search or filters'
                      : 'Orders will appear here when customers make purchases',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Card(
          child: DataTable2(
            columnSpacing: 12,
            horizontalMargin: 12,
            minWidth: 800,
            columns: const [
              DataColumn2(
                label: Text('Order ID'),
                size: ColumnSize.S,
              ),
              DataColumn2(
                label: Text('Customer'),
                size: ColumnSize.L,
              ),
              DataColumn2(
                label: Text('Status'),
                size: ColumnSize.S,
              ),
              DataColumn2(
                label: Text('Total'),
                size: ColumnSize.S,
              ),
              DataColumn2(
                label: Text('Date'),
                size: ColumnSize.M,
              ),
              DataColumn2(
                label: Text('Actions'),
                size: ColumnSize.S,
              ),
            ],
            rows: orders.map((order) => _buildOrderRow(order)).toList(),
          ),
        );
      },
      loading: () => const LoadingWidget(message: 'Loading orders...'),
      error: (error, stack) => ErrorDisplayWidget(
        error: error.toString(),
        onRetry: () => ref.refresh(ordersProvider),
      ),
    );
  }

  DataRow _buildOrderRow(Order order) {
    return DataRow(
      cells: [
        // Order ID
        DataCell(
          Text(
            '#${order.id}',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontFamily: 'monospace',
            ),
          ),
        ),
        
        // Customer
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                order.customerName,
                style: const TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                order.customerEmail,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        
        // Status
        DataCell(
          OrderStatusChip(
            status: OrderStatus.fromString(order.status),
            onTap: () => _showStatusUpdateDialog(order),
          ),
        ),
        
        // Total
        DataCell(
          Text(
            order.formattedTotal,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        // Date
        DataCell(
          Text(
            DateFormat('MMM dd, yyyy\nhh:mm a').format(order.createdAt),
            style: const TextStyle(fontSize: 12),
          ),
        ),
        
        // Actions
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, size: 18),
                onPressed: () => _showOrderDetails(order),
                tooltip: 'View Details',
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18),
                onSelected: (value) {
                  switch (value) {
                    case 'update_status':
                      _showStatusUpdateDialog(order);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'update_status',
                    child: Text('Update Status'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showStatusUpdateDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Order #${order.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: OrderStatus.values.map((status) {
            return ListTile(
              title: Text(status.displayName),
              leading: OrderStatusChip(status: status),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus(order, status);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}