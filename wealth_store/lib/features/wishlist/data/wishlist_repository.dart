import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealth_app/core/services/supabase_service.dart';
import 'package:wealth_app/core/utils/app_exceptions.dart';
import 'package:wealth_app/shared/models/product.dart';
import 'package:wealth_app/shared/models/wishlist_item.dart';

part 'wishlist_repository.g.dart';

class WishlistRepository {
  final SupabaseClient _client;

  WishlistRepository(this._client);

  // Get all wishlist items for the current user
  Future<List<WishlistItem>> getWishlistItems() async {
    try {
      // Get current user
      final user = _client.auth.currentUser;
      if (user == null) {
        throw DataException('User not authenticated');
      }

      final response = await _client
          .from('wishlist')
          .select('*, products(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      
      return response.map((item) {
        final productData = item['products'] as Map<String, dynamic>?;
        Product? product;
        
        if (productData != null) {
          product = Product(
            id: productData['id'] as int,
            name: productData['name'] as String,
            description: productData['description'] as String,
            price: (productData['price'] as num).toDouble(),
            categoryId: productData['category_id'] as int? ?? 0,
            brandId: productData['brand_id'] as int?,
            imageUrls: productData['image_urls'] != null 
                ? List<String>.from(productData['image_urls'] as List)
                : [productData['image_url'] as String? ?? ''],
            specifications: productData['specifications'] as Map<String, dynamic>?,
            stock: productData['stock'] as int? ?? 0,
            rating: (productData['rating'] as num?)?.toDouble() ?? 0.0,
            reviewCount: productData['review_count'] as int? ?? 0,
            isFeatured: productData['is_featured'] as bool? ?? false,
            isActive: productData['is_active'] as bool? ?? true,
            tags: productData['tags'] != null 
                ? List<String>.from(productData['tags'] as List)
                : [],
            createdAt: productData['created_at'] != null 
                ? DateTime.parse(productData['created_at'] as String)
                : null,
          );
        }
        
        return WishlistItem(
          id: item['id'],
          userId: item['user_id'],
          productId: item['product_id'],
          createdAt: item['created_at'] != null 
              ? DateTime.parse(item['created_at']) 
              : null,
          product: product,
        );
      }).toList();
    } catch (e) {
      throw DataException('Failed to load wishlist: $e');
    }
  }

  // Check if a product is in the wishlist
  Future<bool> isInWishlist(int productId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return false;
      }

      final response = await _client
          .from('wishlist')
          .select('id')
          .eq('user_id', user.id)
          .eq('product_id', productId)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      throw DataException('Failed to check wishlist: $e');
    }
  }

  // Add item to wishlist
  Future<WishlistItem> addToWishlist(int productId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw DataException('User not authenticated');
      }

      // Check if item already exists
      final exists = await isInWishlist(productId);
      if (exists) {
        throw DataException('Item already in wishlist');
      }

      final data = {
        'user_id': user.id,
        'product_id': productId,
      };

      final response = await _client
          .from('wishlist')
          .insert(data)
          .select('*, products(*)')
          .single();
      
      final productData = response['products'] as Map<String, dynamic>?;
      Product? product;
      
      if (productData != null) {
        product = Product(
          id: productData['id'] as int,
          name: productData['name'] as String,
          description: productData['description'] as String,
          price: (productData['price'] as num).toDouble(),
          categoryId: productData['category_id'] as int? ?? 0,
          brandId: productData['brand_id'] as int?,
          imageUrls: productData['image_urls'] != null 
              ? List<String>.from(productData['image_urls'] as List)
              : [productData['image_url'] as String? ?? ''],
          specifications: productData['specifications'] as Map<String, dynamic>?,
          stock: productData['stock'] as int? ?? 0,
          rating: (productData['rating'] as num?)?.toDouble() ?? 0.0,
          reviewCount: productData['review_count'] as int? ?? 0,
          isFeatured: productData['is_featured'] as bool? ?? false,
          isActive: productData['is_active'] as bool? ?? true,
          tags: productData['tags'] != null 
              ? List<String>.from(productData['tags'] as List)
              : [],
          createdAt: productData['created_at'] != null 
              ? DateTime.parse(productData['created_at'] as String)
              : null,
        );
      }
      
      return WishlistItem(
        id: response['id'],
        userId: response['user_id'],
        productId: response['product_id'],
        createdAt: response['created_at'] != null 
            ? DateTime.parse(response['created_at']) 
            : null,
        product: product,
      );
    } catch (e) {
      throw DataException('Failed to add to wishlist: $e');
    }
  }

  // Remove item from wishlist
  Future<void> removeFromWishlist(int productId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw DataException('User not authenticated');
      }

      await _client
          .from('wishlist')
          .delete()
          .eq('user_id', user.id)
          .eq('product_id', productId);
    } catch (e) {
      throw DataException('Failed to remove from wishlist: $e');
    }
  }

  // Toggle wishlist status
  Future<bool> toggleWishlist(int productId) async {
    try {
      final isWishlisted = await isInWishlist(productId);
      
      if (isWishlisted) {
        await removeFromWishlist(productId);
        return false;
      } else {
        await addToWishlist(productId);
        return true;
      }
    } catch (e) {
      throw DataException('Failed to toggle wishlist: $e');
    }
  }
}

@riverpod
WishlistRepository wishlistRepository(WishlistRepositoryRef ref) {
  return WishlistRepository(ref.watch(supabaseProvider));
} 