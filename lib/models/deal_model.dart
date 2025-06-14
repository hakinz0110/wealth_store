import 'package:flutter/material.dart';
import 'product_model.dart';

class DealModel {
  final ProductModel product;
  final double discountPercentage;
  final DateTime expiryTime;
  final Color backgroundColor;
  final String dealTitle;
  final String dealDescription;

  DealModel({
    required this.product,
    required this.discountPercentage,
    required this.expiryTime,
    this.backgroundColor = const Color(0xFFFF5722),
    this.dealTitle = 'Deal of the Day',
    this.dealDescription = 'Limited time offer',
  });

  // Calculate discounted price
  double get discountedPrice {
    return product.price * (1 - (discountPercentage / 100));
  }

  // Check if deal is still valid
  bool get isValid {
    return DateTime.now().isBefore(expiryTime);
  }

  // Get remaining time in hours and minutes
  String get remainingTime {
    final now = DateTime.now();
    final difference = expiryTime.difference(now);

    if (difference.isNegative) {
      return 'Expired';
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours > 0) {
      return '$hours hrs $minutes mins';
    } else {
      return '$minutes mins';
    }
  }

  // Create a dummy deal for testing
  static DealModel createDummyDeal(ProductModel product) {
    return DealModel(
      product: product,
      discountPercentage: 25,
      expiryTime: DateTime.now().add(const Duration(hours: 12)),
      backgroundColor: const Color(0xFFFF5722),
      dealTitle: 'Flash Sale!',
      dealDescription: 'Limited time offer - 25% off today only!',
    );
  }
}
