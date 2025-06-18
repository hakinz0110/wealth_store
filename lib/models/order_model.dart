import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final String address;
  final List<Map<String, dynamic>> products;
  final double totalPrice;
  final DateTime orderDate;
  final String status;
  final String contactNumber;
  final String name;

  OrderModel({
    required this.id,
    required this.userId,
    required this.address,
    required this.products,
    required this.totalPrice,
    required this.orderDate,
    required this.status,
    required this.contactNumber,
    required this.name,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      address: json['address'] ?? '',
      products: List<Map<String, dynamic>>.from(json['products'] ?? []),
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      orderDate: (json['orderDate'] as Timestamp).toDate(),
      status: json['status'] ?? 'Pending',
      contactNumber: json['contactNumber'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'address': address,
      'products': products,
      'totalPrice': totalPrice,
      'orderDate': Timestamp.fromDate(orderDate),
      'status': status,
      'contactNumber': contactNumber,
      'name': name,
    };
  }

  static OrderModel fromCartItems(
    String id,
    String userId,
    String address,
    List<CartItemModel> cartItems,
    String contactNumber,
    String name,
  ) {
    final products = cartItems.map((item) => item.toJson()).toList();
    final totalPrice = cartItems.fold(
      0.0,
      (double acc, item) => acc + item.totalPrice,
    );

    return OrderModel(
      id: id,
      userId: userId,
      address: address,
      products: products,
      totalPrice: totalPrice,
      orderDate: DateTime.now(),
      status: 'Pending',
      contactNumber: contactNumber,
      name: name,
    );
  }
}
