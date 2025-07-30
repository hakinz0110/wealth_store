class DashboardMetrics {
  final double salesTotal;
  final double salesChange;
  final double averageOrderValue;
  final double averageOrderChange;
  final int totalOrders;
  final double ordersChange;
  final int visitors;
  final double visitorsChange;

  const DashboardMetrics({
    required this.salesTotal,
    required this.salesChange,
    required this.averageOrderValue,
    required this.averageOrderChange,
    required this.totalOrders,
    required this.ordersChange,
    required this.visitors,
    required this.visitorsChange,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      salesTotal: (json['sales_total'] as num?)?.toDouble() ?? 0.0,
      salesChange: (json['sales_change'] as num?)?.toDouble() ?? 0.0,
      averageOrderValue: (json['average_order_value'] as num?)?.toDouble() ?? 0.0,
      averageOrderChange: (json['average_order_change'] as num?)?.toDouble() ?? 0.0,
      totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
      ordersChange: (json['orders_change'] as num?)?.toDouble() ?? 0.0,
      visitors: (json['visitors'] as num?)?.toInt() ?? 0,
      visitorsChange: (json['visitors_change'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sales_total': salesTotal,
      'sales_change': salesChange,
      'average_order_value': averageOrderValue,
      'average_order_change': averageOrderChange,
      'total_orders': totalOrders,
      'orders_change': ordersChange,
      'visitors': visitors,
      'visitors_change': visitorsChange,
    };
  }
}

class WeeklySalesData {
  final String day;
  final double amount;

  const WeeklySalesData({
    required this.day,
    required this.amount,
  });

  factory WeeklySalesData.fromJson(Map<String, dynamic> json) {
    return WeeklySalesData(
      day: json['day'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OrderStatusData {
  final String status;
  final int count;
  final double percentage;

  const OrderStatusData({
    required this.status,
    required this.count,
    required this.percentage,
  });

  factory OrderStatusData.fromJson(Map<String, dynamic> json) {
    return OrderStatusData(
      status: json['status'] as String,
      count: (json['count'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RecentOrder {
  final String id;
  final String customerName;
  final DateTime date;
  final int itemCount;
  final String status;
  final double amount;

  const RecentOrder({
    required this.id,
    required this.customerName,
    required this.date,
    required this.itemCount,
    required this.status,
    required this.amount,
  });

  factory RecentOrder.fromJson(Map<String, dynamic> json) {
    return RecentOrder(
      id: json['id'] as String,
      customerName: json['customer_name'] as String,
      date: DateTime.parse(json['date'] as String),
      itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
      status: json['status'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DashboardData {
  final DashboardMetrics metrics;
  final List<WeeklySalesData> weeklySales;
  final List<OrderStatusData> orderStatus;
  final List<RecentOrder> recentOrders;

  const DashboardData({
    required this.metrics,
    required this.weeklySales,
    required this.orderStatus,
    required this.recentOrders,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      metrics: DashboardMetrics.fromJson(json['metrics'] as Map<String, dynamic>),
      weeklySales: (json['weekly_sales'] as List<dynamic>)
          .map((item) => WeeklySalesData.fromJson(item as Map<String, dynamic>))
          .toList(),
      orderStatus: (json['order_status'] as List<dynamic>)
          .map((item) => OrderStatusData.fromJson(item as Map<String, dynamic>))
          .toList(),
      recentOrders: (json['recent_orders'] as List<dynamic>)
          .map((item) => RecentOrder.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  // Mock data for development
  static DashboardData get mockData {
    return DashboardData(
      metrics: const DashboardMetrics(
        salesTotal: 34945.76,
        salesChange: 2.5,
        averageOrderValue: 1543.44,
        averageOrderChange: -1.8,
        totalOrders: 522,
        ordersChange: 4.4,
        visitors: 25035,
        visitorsChange: 7.2,
      ),
      weeklySales: const [
        WeeklySalesData(day: 'Mon', amount: 2500),
        WeeklySalesData(day: 'Tue', amount: 4200),
        WeeklySalesData(day: 'Wed', amount: 3800),
        WeeklySalesData(day: 'Thu', amount: 2100),
        WeeklySalesData(day: 'Fri', amount: 1800),
        WeeklySalesData(day: 'Sat', amount: 3200),
        WeeklySalesData(day: 'Sun', amount: 2800),
      ],
      orderStatus: const [
        OrderStatusData(status: 'Processing', count: 4, percentage: 40),
        OrderStatusData(status: 'Shipping', count: 2, percentage: 20),
        OrderStatusData(status: 'Delivered', count: 3, percentage: 30),
        OrderStatusData(status: 'Cancelled', count: 1, percentage: 10),
      ],
      recentOrders: [
        RecentOrder(
          id: 'ORD-001',
          customerName: 'John Doe',
          date: DateTime.now().subtract(const Duration(hours: 2)),
          itemCount: 3,
          status: 'Processing',
          amount: 299.99,
        ),
        RecentOrder(
          id: 'ORD-002',
          customerName: 'Jane Smith',
          date: DateTime.now().subtract(const Duration(hours: 5)),
          itemCount: 1,
          status: 'Shipped',
          amount: 149.50,
        ),
        RecentOrder(
          id: 'ORD-003',
          customerName: 'Mike Johnson',
          date: DateTime.now().subtract(const Duration(hours: 8)),
          itemCount: 2,
          status: 'Delivered',
          amount: 89.99,
        ),
        RecentOrder(
          id: 'ORD-004',
          customerName: 'Sarah Wilson',
          date: DateTime.now().subtract(const Duration(days: 1)),
          itemCount: 4,
          status: 'Processing',
          amount: 459.99,
        ),
        RecentOrder(
          id: 'ORD-005',
          customerName: 'David Brown',
          date: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
          itemCount: 1,
          status: 'Cancelled',
          amount: 199.99,
        ),
      ],
    );
  }
}