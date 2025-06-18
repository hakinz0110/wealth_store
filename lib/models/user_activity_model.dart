import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserActivityModel {
  final List<String> recentlyViewed;
  final Map<String, int> categoryInterests;
  final Map<String, int> productInteractions;

  UserActivityModel({
    required this.recentlyViewed,
    required this.categoryInterests,
    required this.productInteractions,
  });

  factory UserActivityModel.empty() {
    return UserActivityModel(
      recentlyViewed: [],
      categoryInterests: {},
      productInteractions: {},
    );
  }

  factory UserActivityModel.fromJson(Map<String, dynamic> json) {
    return UserActivityModel(
      recentlyViewed: List<String>.from(json['recentlyViewed'] ?? []),
      categoryInterests: Map<String, int>.from(json['categoryInterests'] ?? {}),
      productInteractions: Map<String, int>.from(
        json['productInteractions'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recentlyViewed': recentlyViewed,
      'categoryInterests': categoryInterests,
      'productInteractions': productInteractions,
    };
  }

  // Add a product to recently viewed
  UserActivityModel addToRecentlyViewed(String productId) {
    final updatedList = List<String>.from(recentlyViewed);

    // Remove if already exists to avoid duplicates
    updatedList.remove(productId);

    // Add to the beginning of the list
    updatedList.insert(0, productId);

    // Keep only the last 10 items
    if (updatedList.length > 10) {
      updatedList.removeLast();
    }

    return UserActivityModel(
      recentlyViewed: updatedList,
      categoryInterests: categoryInterests,
      productInteractions: productInteractions,
    );
  }

  // Increment category interest
  UserActivityModel incrementCategoryInterest(String category) {
    final updatedInterests = Map<String, int>.from(categoryInterests);
    updatedInterests[category] = (updatedInterests[category] ?? 0) + 1;

    return UserActivityModel(
      recentlyViewed: recentlyViewed,
      categoryInterests: updatedInterests,
      productInteractions: productInteractions,
    );
  }

  // Increment product interaction
  UserActivityModel incrementProductInteraction(String productId) {
    final updatedInteractions = Map<String, int>.from(productInteractions);
    updatedInteractions[productId] = (updatedInteractions[productId] ?? 0) + 1;

    return UserActivityModel(
      recentlyViewed: recentlyViewed,
      categoryInterests: categoryInterests,
      productInteractions: updatedInteractions,
    );
  }

  // Save user activity to shared preferences
  static Future<void> saveToPrefs(UserActivityModel activity) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(activity.toJson());
    await prefs.setString('user_activity', jsonString);
  }

  // Load user activity from shared preferences
  static Future<UserActivityModel> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('user_activity');

    if (jsonString == null) {
      return UserActivityModel.empty();
    }

    try {
      final json = jsonDecode(jsonString);
      return UserActivityModel.fromJson(json);
    } catch (e) {
      return UserActivityModel.empty();
    }
  }
}
