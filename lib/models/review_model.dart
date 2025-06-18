import 'package:flutter/material.dart';

class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String productId;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<String> images;
  final bool isVerifiedPurchase;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.productId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.images = const [],
    this.isVerifiedPurchase = false,
  });

  // Create dummy reviews for testing
  static List<ReviewModel> getDummyReviews() {
    return [
      ReviewModel(
        id: '1',
        userId: 'user1',
        userName: 'John Smith',
        productId: '1',
        rating: 4.5,
        comment:
            'Great product! The sound quality is excellent and battery life is impressive. Would definitely recommend to anyone looking for wireless headphones.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isVerifiedPurchase: true,
      ),
      ReviewModel(
        id: '2',
        userId: 'user2',
        userName: 'Emma Wilson',
        productId: '2',
        rating: 5.0,
        comment:
            'This laptop exceeds all my expectations. Fast performance, beautiful display, and the battery lasts all day!',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isVerifiedPurchase: true,
      ),
      ReviewModel(
        id: '3',
        userId: 'user3',
        userName: 'Michael Brown',
        productId: '3',
        rating: 4.0,
        comment:
            'Good value for money. Works as expected and shipping was fast.',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        isVerifiedPurchase: false,
      ),
      ReviewModel(
        id: '4',
        userId: 'user4',
        userName: 'Sarah Johnson',
        productId: '4',
        rating: 5.0,
        comment:
            'Absolutely love this gaming laptop! Graphics are amazing and it handles all my games without any lag.',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        isVerifiedPurchase: true,
      ),
    ];
  }

  // Get avatar color based on user name
  static Color getAvatarColor(String userName) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.red,
    ];

    // Use hash of name to determine color
    final hash = userName.hashCode.abs();
    return colors[hash % colors.length];
  }

  // Format creation date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}
