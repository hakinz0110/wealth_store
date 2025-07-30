import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealth_app/core/services/supabase_service.dart';
import 'package:wealth_app/core/utils/app_exceptions.dart';
import 'package:wealth_app/shared/models/product.dart';

part 'product_repository.g.dart';

class ProductRepository {
  final SupabaseClient _client;

  ProductRepository(this._client);

  Future<List<Product>> getProducts({
    int limit = 20,
    int offset = 0,
    int? categoryId,
  }) async {
    try {
      final query = _client.from('products').select();
      
      if (categoryId != null) {
        query.eq('category_id', categoryId);
      }
      
      final response = await query
          .range(offset, offset + limit - 1)
          .order('created_at', ascending: false);
      
      if (response.isEmpty) {
        return [];
      }
      
      final products = response.map((json) {
        return Product.fromJson(json);
      }).toList();
      
      return products;
    } catch (e) {
      throw DataException('Failed to load products: $e');
    }
  }

  Future<Product> getProduct(int id) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('id', id)
          .single();
      
      return Product.fromJson(response);
    } catch (e) {
      throw DataException('Failed to load product: $e');
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .ilike('name', '%$query%')
          .limit(20);
      
      return response.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw DataException('Failed to search products: $e');
    }
  }

  // For future admin functionality
  Future<Product> createProduct(Product product) async {
    try {
      final response = await _client
          .from('products')
          .insert(product.toJson())
          .select()
          .single();
      
      return Product.fromJson(response);
    } catch (e) {
      throw DataException('Failed to create product: $e');
    }
  }

  // For future admin functionality
  Future<Product> updateProduct(Product product) async {
    try {
      final response = await _client
          .from('products')
          .update(product.toJson())
          .eq('id', product.id)
          .select()
          .single();
      
      return Product.fromJson(response);
    } catch (e) {
      throw DataException('Failed to update product: $e');
    }
  }

  // For future admin functionality
  Future<void> deleteProduct(int id) async {
    try {
      await _client
          .from('products')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw DataException('Failed to delete product: $e');
    }
  }
}

@riverpod
ProductRepository productRepository(ProductRepositoryRef ref) {
  return ProductRepository(ref.watch(supabaseProvider));
} 