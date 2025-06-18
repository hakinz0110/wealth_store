import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user document data
  Future<Map<String, dynamic>?> getUserData() async {
    if (_auth.currentUser == null) return null;

    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Get user stream for real-time updates
  Stream<DocumentSnapshot> getUserStream() {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .snapshots();
  }

  // Get all products
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('products').get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  // Get products by category
  Future<List<Map<String, dynamic>>> getProductsByCategory(
    String category,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .get();

      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error getting products by category: $e');
      return [];
    }
  }

  // Get product details
  Future<Map<String, dynamic>?> getProductDetails(String productId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('products')
          .doc(productId)
          .get();

      if (doc.exists) {
        // Add product to recently viewed
        if (_auth.currentUser != null) {
          await addToRecentlyViewed(productId);
        }

        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }
      return null;
    } catch (e) {
      print('Error getting product details: $e');
      return null;
    }
  }

  // Add product to recently viewed
  Future<void> addToRecentlyViewed(String productId) async {
    if (_auth.currentUser == null) return;

    try {
      DocumentReference userRef = _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid);

      DocumentSnapshot userSnapshot = await userRef.get();
      List<dynamic> recentlyViewed =
          (userSnapshot.data() as Map<String, dynamic>)['recentlyViewed'] ?? [];

      // Remove product if it already exists in the list
      recentlyViewed.removeWhere((item) => item == productId);

      // Add product to the beginning of the list
      recentlyViewed.insert(0, productId);

      // Limit to 10 items
      if (recentlyViewed.length > 10) {
        recentlyViewed = recentlyViewed.sublist(0, 10);
      }

      await userRef.update({'recentlyViewed': recentlyViewed});
    } catch (e) {
      print('Error adding to recently viewed: $e');
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String productId) async {
    if (_auth.currentUser == null) return;

    try {
      DocumentReference userRef = _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid);

      DocumentSnapshot userSnapshot = await userRef.get();
      List<dynamic> favorites =
          (userSnapshot.data() as Map<String, dynamic>)['favorites'] ?? [];

      if (favorites.contains(productId)) {
        favorites.remove(productId);
      } else {
        favorites.add(productId);
      }

      await userRef.update({'favorites': favorites});
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  // Get user's favorite products
  Future<List<Map<String, dynamic>>> getFavoriteProducts() async {
    if (_auth.currentUser == null) return [];

    try {
      DocumentSnapshot userSnapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      List<dynamic> favorites =
          (userSnapshot.data() as Map<String, dynamic>)['favorites'] ?? [];

      if (favorites.isEmpty) return [];

      List<Map<String, dynamic>> products = [];
      for (String productId in favorites) {
        Map<String, dynamic>? product = await getProductDetails(productId);
        if (product != null) {
          products.add(product);
        }
      }

      return products;
    } catch (e) {
      print('Error getting favorite products: $e');
      return [];
    }
  }

  // Get user's recently viewed products
  Future<List<Map<String, dynamic>>> getRecentlyViewedProducts() async {
    if (_auth.currentUser == null) return [];

    try {
      DocumentSnapshot userSnapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      List<dynamic> recentlyViewed =
          (userSnapshot.data() as Map<String, dynamic>)['recentlyViewed'] ?? [];

      if (recentlyViewed.isEmpty) return [];

      List<Map<String, dynamic>> products = [];
      for (String productId in recentlyViewed) {
        Map<String, dynamic>? product = await getProductDetails(productId);
        if (product != null) {
          products.add(product);
        }
      }

      return products;
    } catch (e) {
      print('Error getting recently viewed products: $e');
      return [];
    }
  }

  // Create an order
  Future<String?> createOrder(Map<String, dynamic> orderData) async {
    if (_auth.currentUser == null) return null;

    try {
      // Add order to orders collection
      DocumentReference orderRef = await _firestore.collection('orders').add({
        'userId': _auth.currentUser!.uid,
        'createdAt': Timestamp.now(),
        'status': 'pending',
        ...orderData,
      });

      // Add order ID to user's orders
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'orders': FieldValue.arrayUnion([orderRef.id]),
      });

      return orderRef.id;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }
}
