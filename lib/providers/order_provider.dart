import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';

class OrderProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  
  List<OrderModel> get orders => [..._orders];
  bool get isLoading => _isLoading;
  
  Future<void> fetchOrders(String userId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('orderDate', descending: true)
          .get();
      
      _orders = snapshot.docs.map((doc) {
        return OrderModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> placeOrder({
    required String userId,
    required String address,
    required List<CartItemModel> cartItems,
    required String contactNumber,
    required String name,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Create a new document reference
      final orderRef = _firestore.collection('orders').doc();
      
      // Create the order model
      final order = OrderModel.fromCartItems(
        orderRef.id,
        userId,
        address,
        cartItems,
        contactNumber,
        name,
      );
      
      // Save to Firestore
      await orderRef.set(order.toJson());
      
      // Add to local orders list
      _orders.insert(0, order);
      
      return true;
    } catch (e) {
      debugPrint('Error placing order: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 