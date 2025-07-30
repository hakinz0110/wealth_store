import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/product.dart';
import 'supabase_service.dart';
import 'storage_service.dart';

part 'product_service.g.dart';

@riverpod
ProductService productService(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  final storage = ref.watch(storageServiceProvider);
  return ProductService(supabase, storage);
}

class ProductService {
  final SupabaseClient _client;
  final StorageService _storageService;
  
  ProductService(this._client, this._storageService);
  
  // Get products with optional pagination and filtering
  Future<List<Product>> getProducts({
    int? limit,
    int? offset,
    String? categoryId,
    String? searchQuery,
    bool? isFeatured,
    String sortBy = 'created_at',
    bool ascending = false,
  }) async {
    try {
      var query = _client.from('products').select('*');
      
      // Apply filters
      if (categoryId != null) {
        query = query.eq('category_id', int.parse(categoryId));
      }
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('name.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }
      
      if (isFeatured != null) {
        query = query.eq('is_featured', isFeatured);
      }
      
      // Apply sorting and pagination - chain them properly
      var transformQuery = query.order(sortBy, ascending: ascending);
      
      if (limit != null) {
        transformQuery = transformQuery.limit(limit);
      }
      
      if (offset != null) {
        transformQuery = transformQuery.range(offset, offset + (limit ?? 10) - 1);
      }
      
      final response = await transformQuery;
      
      return (response as List<dynamic>)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }
  
  // Get a single product by ID
  Future<Product?> getProductById(int id) async {
    try {
      final response = await _client
          .from('products')
          .select('*')
          .eq('id', id)
          .single();
      
      return Product.fromJson(response);
    } catch (e) {
      if (e is PostgrestException && e.code == 'PGRST116') {
        return null; // Product not found
      }
      throw Exception('Failed to fetch product: $e');
    }
  }
  
  // Get products by category
  Future<List<Product>> getProductsByCategory(int categoryId, {
    int? limit,
    int? offset,
  }) async {
    return getProducts(
      categoryId: categoryId.toString(),
      limit: limit,
      offset: offset,
    );
  }
  
  // Get featured products
  Future<List<Product>> getFeaturedProducts({int? limit}) async {
    return getProducts(
      isFeatured: true,
      limit: limit,
      sortBy: 'rating',
      ascending: false,
    );
  }
  
  // Search products
  Future<List<Product>> searchProducts(String query, {
    int? limit,
    int? offset,
  }) async {
    return getProducts(
      searchQuery: query,
      limit: limit,
      offset: offset,
    );
  }
  
  // Create a new product (Admin only)
  Future<Product> createProduct(Product product) async {
    try {
      final productData = product.toJson();
      // Remove id for creation
      productData.remove('id');
      
      final response = await _client
          .from('products')
          .insert(productData)
          .select()
          .single();
      
      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }
  
  // Update an existing product (Admin only)
  Future<Product> updateProduct(int id, Product product) async {
    try {
      final productData = product.toJson();
      // Ensure the ID matches
      productData['id'] = id;
      
      final response = await _client
          .from('products')
          .update(productData)
          .eq('id', id)
          .select()
          .single();
      
      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }
  
  // Delete a product (Admin only)
  Future<void> deleteProduct(int id) async {
    try {
      // First get the product to retrieve image URLs for deletion
      final product = await getProductById(id);
      
      // Delete the product from database
      await _client
          .from('products')
          .delete()
          .eq('id', id);
      
      // Delete associated images from storage
      if (product != null && product.imageUrls != null && product.imageUrls!.isNotEmpty) {
        await _deleteProductImages(product.imageUrls!);
      }
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }
  
  // Update product stock
  Future<Product> updateProductStock(int id, int newStock) async {
    try {
      final response = await _client
          .from('products')
          .update({'stock': newStock})
          .eq('id', id)
          .select()
          .single();
      
      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update product stock: $e');
    }
  }
  
  // Toggle product featured status
  Future<Product> toggleFeaturedStatus(int id) async {
    try {
      // First get the current status
      final current = await getProductById(id);
      if (current == null) {
        throw Exception('Product not found');
      }
      
      final response = await _client
          .from('products')
          .update({'is_featured': !current.isFeatured})
          .eq('id', id)
          .select()
          .single();
      
      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to toggle featured status: $e');
    }
  }
  
  // Get product count for pagination
  Future<int> getProductCount({
    int? categoryId,
    String? searchQuery,
    bool? isFeatured,
  }) async {
    try {
      // Simple count by getting all products and counting them
      final products = await getProducts(
        categoryId: categoryId?.toString(),
        searchQuery: searchQuery,
        isFeatured: isFeatured,
      );
      return products.length;
    } catch (e) {
      throw Exception('Failed to get product count: $e');
    }
  }
  
  // Image upload and management methods
  
  /// Upload multiple images for a product
  Future<List<String>> uploadProductImages(
    List<File> images, 
    String productName, {
    void Function(int uploaded, int total)? onProgress,
  }) async {
    try {
      final imageUrls = <String>[];
      
      for (int i = 0; i < images.length; i++) {
        final imageUrl = await _storageService.uploadProductImage(
          images[i], 
          '${productName}_image_${i + 1}',
          onProgress: (progress) {
            // Individual image progress can be tracked here if needed
          },
        );
        imageUrls.add(imageUrl);
        
        // Report overall progress
        if (onProgress != null) {
          onProgress(i + 1, images.length);
        }
      }
      
      return imageUrls;
    } catch (e) {
      throw Exception('Failed to upload product images: $e');
    }
  }
  
  /// Upload a single image for a product
  Future<String> uploadProductImage(
    File image, 
    String productName, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      return await _storageService.uploadProductImage(
        image, 
        productName,
        onProgress: onProgress,
      );
    } catch (e) {
      throw Exception('Failed to upload product image: $e');
    }
  }
  
  /// Create a product with image uploads
  Future<Product> createProductWithImages(
    Product product, 
    List<File> images, {
    void Function(int uploaded, int total)? onProgress,
  }) async {
    try {
      // Upload images first
      List<String> imageUrls = [];
      if (images.isNotEmpty) {
        imageUrls = await uploadProductImages(
          images, 
          product.name,
          onProgress: onProgress,
        );
      }
      
      // Create product with image URLs
      final productWithImages = product.copyWith(imageUrls: imageUrls);
      return await createProduct(productWithImages);
    } catch (e) {
      // If product creation fails, clean up uploaded images
      if (images.isNotEmpty) {
        try {
          final imageUrls = await uploadProductImages(images, product.name);
          await _deleteProductImages(imageUrls);
        } catch (_) {
          // Ignore cleanup errors
        }
      }
      throw Exception('Failed to create product with images: $e');
    }
  }
  
  /// Update a product with new images (replaces existing images)
  Future<Product> updateProductWithImages(
    int id, 
    Product product, 
    List<File> newImages, {
    void Function(int uploaded, int total)? onProgress,
  }) async {
    try {
      // Get current product to retrieve existing image URLs
      final currentProduct = await getProductById(id);
      final oldImageUrls = currentProduct?.imageUrls ?? [];
      
      // Upload new images
      List<String> newImageUrls = [];
      if (newImages.isNotEmpty) {
        newImageUrls = await uploadProductImages(
          newImages, 
          product.name,
          onProgress: onProgress,
        );
      }
      
      // Update product with new image URLs
      final updatedProduct = product.copyWith(imageUrls: newImageUrls);
      final result = await updateProduct(id, updatedProduct);
      
      // Delete old images after successful update
      if (oldImageUrls.isNotEmpty) {
        await _deleteProductImages(oldImageUrls);
      }
      
      return result;
    } catch (e) {
      throw Exception('Failed to update product with images: $e');
    }
  }
  
  /// Add images to an existing product (appends to existing images)
  Future<Product> addProductImages(
    int id, 
    List<File> images, {
    void Function(int uploaded, int total)? onProgress,
  }) async {
    try {
      // Get current product
      final currentProduct = await getProductById(id);
      if (currentProduct == null) {
        throw Exception('Product not found');
      }
      
      // Upload new images
      final newImageUrls = await uploadProductImages(
        images, 
        currentProduct.name,
        onProgress: onProgress,
      );
      
      // Combine existing and new image URLs
      final allImageUrls = <String>[
        ...(currentProduct.imageUrls ?? []),
        ...newImageUrls,
      ];
      
      // Update product with combined image URLs
      final updatedProduct = currentProduct.copyWith(imageUrls: allImageUrls);
      return await updateProduct(id, updatedProduct);
    } catch (e) {
      throw Exception('Failed to add product images: $e');
    }
  }
  
  /// Remove specific images from a product
  Future<Product> removeProductImages(
    int id, 
    List<String> imageUrlsToRemove,
  ) async {
    try {
      // Get current product
      final currentProduct = await getProductById(id);
      if (currentProduct == null) {
        throw Exception('Product not found');
      }
      
      // Filter out the images to remove
      final remainingImageUrls = (currentProduct.imageUrls ?? [])
          .where((url) => !imageUrlsToRemove.contains(url))
          .toList();
      
      // Update product with remaining images
      final updatedProduct = currentProduct.copyWith(imageUrls: remainingImageUrls);
      final result = await updateProduct(id, updatedProduct);
      
      // Delete the removed images from storage
      await _deleteProductImages(imageUrlsToRemove);
      
      return result;
    } catch (e) {
      throw Exception('Failed to remove product images: $e');
    }
  }
  
  /// Private method to delete images from storage
  Future<void> _deleteProductImages(List<String> imageUrls) async {
    try {
      for (final imageUrl in imageUrls) {
        // Extract file path from URL
        final uri = Uri.parse(imageUrl);
        final pathSegments = uri.pathSegments;
        
        // Find the bucket and file path
        // URL format: https://[project].supabase.co/storage/v1/object/public/[bucket]/[path]
        if (pathSegments.length >= 5 && pathSegments[2] == 'object' && pathSegments[3] == 'public') {
          final bucket = pathSegments[4];
          final filePath = pathSegments.skip(5).join('/');
          
          await _storageService.deleteFile(bucket, filePath);
        }
      }
    } catch (e) {
      // Log error but don't throw - image deletion is not critical
      // In production, this should use a proper logging service
      // print('Warning: Failed to delete some product images: $e');
    }
  }
  
  // Batch operations for admin
  Future<List<Product>> createMultipleProducts(List<Product> products) async {
    try {
      final productsData = products.map((p) {
        final data = p.toJson();
        data.remove('id'); // Remove id for creation
        return data;
      }).toList();
      
      final response = await _client
          .from('products')
          .insert(productsData)
          .select();
      
      return (response as List<dynamic>)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to create multiple products: $e');
    }
  }
  
  Future<void> deleteMultipleProducts(List<int> ids) async {
    try {
      // Get all products first to retrieve image URLs
      final products = <Product>[];
      for (final id in ids) {
        final product = await getProductById(id);
        if (product != null) {
          products.add(product);
        }
      }
      
      // Delete products from database
      for (final id in ids) {
        await _client
            .from('products')
            .delete()
            .eq('id', id);
      }
      
      // Delete associated images from storage
      final allImageUrls = <String>[];
      for (final product in products) {
        if (product.imageUrls != null && product.imageUrls!.isNotEmpty) {
          allImageUrls.addAll(product.imageUrls!);
        }
      }
      
      if (allImageUrls.isNotEmpty) {
        await _deleteProductImages(allImageUrls);
      }
    } catch (e) {
      throw Exception('Failed to delete multiple products: $e');
    }
  }
  
  // Get low stock products (for admin alerts)
  Future<List<Product>> getLowStockProducts({int threshold = 10}) async {
    try {
      final response = await _client
          .from('products')
          .select('*')
          .lt('stock', threshold)
          .order('stock', ascending: true);
      
      return (response as List<dynamic>)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch low stock products: $e');
    }
  }
  
  // Real-time subscription for products
  Stream<List<Product>> watchProducts({
    int? categoryId,
    bool? isFeatured,
  }) {
    // For now, return a simple stream that fetches products periodically
    // This can be enhanced later with proper real-time subscriptions
    return Stream.periodic(const Duration(seconds: 5), (_) async {
      return await getProducts(categoryId: categoryId?.toString(), isFeatured: isFeatured);
    }).asyncMap((future) => future);
  }
  
  // Connection health check
  Future<bool> checkConnection() async {
    try {
      await _client.from('products').select('id').limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }
}