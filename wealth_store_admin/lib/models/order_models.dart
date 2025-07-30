import 'product_models.dart';

enum OrderSortBy {
  createdAt('created_at', 'Date Created'),
  total('total', 'Total Amount'),
  status('status', 'Status'),
  customerName('customer_name', 'Customer Name'),
  updatedAt('updated_at', 'Last Updated');

  const OrderSortBy(this.value, this.displayName);
  final String value;
  final String displayName;
}

enum SortOrder {
  ascending('asc', 'Ascending'),
  descending('desc', 'Descending');

  const SortOrder(this.value, this.displayName);
  final String value;
  final String displayName;
}

class Order {
  final String id;
  final String userId;
  final String status;
  final double total;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;
  final List<OrderItem> items;
  final ShippingAddress shippingAddress;
  final String? paymentMethod;
  final PaymentStatus paymentStatus;
  final String? paymentTransactionId;
  final double subtotal;
  final double taxAmount;
  final double shippingAmount;
  final double discountAmount;
  final String? trackingNumber;
  final String? notes;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;

  const Order({
    required this.id,
    required this.userId,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.items = const [],
    required this.shippingAddress,
    this.paymentMethod,
    this.paymentStatus = PaymentStatus.pending,
    this.paymentTransactionId,
    required this.subtotal,
    this.taxAmount = 0.0,
    this.shippingAmount = 0.0,
    this.discountAmount = 0.0,
    this.trackingNumber,
    this.notes,
    this.shippedAt,
    this.deliveredAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      user: json['users'] != null ? User.fromJson(json['users']) : null,
      items: json['order_items'] != null 
          ? (json['order_items'] as List).map((item) => OrderItem.fromJson(item)).toList()
          : [],
      shippingAddress: json['shipping_address'] != null 
          ? ShippingAddress.fromJson(json['shipping_address'])
          : const ShippingAddress(fullName: '', address: '', city: '', state: '', zipCode: '', country: ''),
      paymentMethod: json['payment_method']?.toString(),
      paymentStatus: PaymentStatus.fromString(json['payment_status']?.toString() ?? 'pending'),
      paymentTransactionId: json['payment_transaction_id']?.toString(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
      shippingAmount: (json['shipping_amount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      trackingNumber: json['tracking_number']?.toString(),
      notes: json['notes']?.toString(),
      shippedAt: json['shipped_at'] != null ? DateTime.parse(json['shipped_at']) : null,
      deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': status,
      'total': total,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Order copyWith({
    String? id,
    String? userId,
    String? status,
    double? total,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
    List<OrderItem>? items,
    ShippingAddress? shippingAddress,
    String? paymentMethod,
    PaymentStatus? paymentStatus,
    String? paymentTransactionId,
    double? subtotal,
    double? taxAmount,
    double? shippingAmount,
    double? discountAmount,
    String? trackingNumber,
    String? notes,
    DateTime? shippedAt,
    DateTime? deliveredAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentTransactionId: paymentTransactionId ?? this.paymentTransactionId,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      shippingAmount: shippingAmount ?? this.shippingAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  // Helper getters
  String get formattedTotal => '\$${total.toStringAsFixed(2)}';
  String get customerName => user?.fullName ?? 'Unknown Customer';
  String get customerEmail => user?.email ?? 'No email';
  int get itemCount => items.length;
  
  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isShipped => status == 'shipped';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';

  // Additional helper getters for OrderDetailsDialog
  String get orderNumber => '#$id';
  String? get userName => user?.fullName;
  String get userEmail => user?.email ?? '';
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  String get formattedSubtotal => '\${subtotal.toStringAsFixed(2)}';
  String get formattedTaxAmount => '\${taxAmount.toStringAsFixed(2)}';
  String get formattedShippingAmount => '\${shippingAmount.toStringAsFixed(2)}';
  String get formattedDiscountAmount => '\${discountAmount.toStringAsFixed(2)}';
  String get formattedTotalAmount => '\${total.toStringAsFixed(2)}';
}

class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final double price;
  final Product? product;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      product: json['products'] != null ? Product.fromJson(json['products']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
  }

  // Helper getters
  double get subtotal => quantity * price;
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';
  String get productName => product?.name ?? 'Unknown Product';
  String get formattedUnitPrice => '\${price.toStringAsFixed(2)}';
  String get formattedTotalPrice => '\${subtotal.toStringAsFixed(2)}';
  String? get productImageUrl => product?.imageUrl;
}

class User {
  final String id;
  final String email;
  final String? fullName;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    this.fullName,
    required this.role,
    this.isActive = true,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString(),
      role: json['role']?.toString() ?? 'customer',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper getters
  String get displayName => fullName ?? email;
  bool get isAdmin => role == 'admin';
  bool get isCustomer => role == 'customer';
}

enum OrderStatus {
  pending('pending', 'Pending'),
  processing('processing', 'Processing'),
  shipped('shipped', 'Shipped'),
  delivered('delivered', 'Delivered'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled'),
  refunded('refunded', 'Refunded');

  const OrderStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

class OrderFilters {
  final OrderStatus? status;
  final PaymentStatus? paymentStatus;
  final String? customerId;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minTotal;
  final double? maxTotal;
  final double? minAmount;
  final double? maxAmount;
  final String? searchQuery;
  final OrderSortBy? sortBy;
  final SortOrder? sortOrder;

  const OrderFilters({
    this.status,
    this.paymentStatus,
    this.customerId,
    this.startDate,
    this.endDate,
    this.minTotal,
    this.maxTotal,
    this.minAmount,
    this.maxAmount,
    this.searchQuery,
    this.sortBy,
    this.sortOrder,
  });

  OrderFilters copyWith({
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? customerId,
    DateTime? startDate,
    DateTime? endDate,
    double? minTotal,
    double? maxTotal,
    double? minAmount,
    double? maxAmount,
    String? searchQuery,
    OrderSortBy? sortBy,
    SortOrder? sortOrder,
  }) {
    return OrderFilters(
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      customerId: customerId ?? this.customerId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minTotal: minTotal ?? this.minTotal,
      maxTotal: maxTotal ?? this.maxTotal,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
class ShippingAddress {
  final String fullName;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String? phoneNumber;

  const ShippingAddress({
    required this.fullName,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.phoneNumber,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      fullName: json['full_name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      zipCode: json['zip_code']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'address': address,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'country': country,
      'phone_number': phoneNumber,
    };
  }

  String get formattedAddress => '$address, $city, $state $zipCode, $country';
}

enum PaymentStatus {
  pending('pending', 'Pending'),
  paid('paid', 'Paid'),
  failed('failed', 'Failed'),
  refunded('refunded', 'Refunded');

  const PaymentStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}