import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealth_app/core/services/supabase_service.dart';
import 'package:wealth_app/core/services/supabase_storage_service.dart';
import 'package:wealth_app/shared/models/product.dart';

part 'product_image_service.g.dart';

class ProductImageService {
  final SupabaseClient _client;
  final SupabaseStorageService _storageService;
  
  ProductImageService(this._client, this._storageService);
  
  /// Get all products and ensure they have valid image URLs from Supabase Storage
  Future<List<Product>> getProductsWithValidImages() async {
    try {
      // Fetch all products from database
      final response = await _client
          .from('products')
          .select()
          .order('created_at', ascending: false);
      
      final products = response.map((json) => Product.fromJson(json)).toList();
      
      // Process each product to ensure valid image URL
      final processedProducts = <Product>[];
      
      for (final product in products) {
        Product updatedProduct = product;
        
        // Check if product has a valid image URL
        if (product.imageUrl.isEmpty || !product.imageUrl.startsWith('http')) {
          // Generate image URL from Supabase Storage
          final imageUrl = _storageService.getProductImageUrl(product.id.toString());
          
          // Check if image exists in storage
          final imageExists = await _storageService.imageExists(
            SupabaseStorageService.productImagesBucket,
            '${product.id}.png',
          );
          
          if (imageExists) {
            // Update product with Supabase Storage URL
            updatedProduct = product.copyWith(imageUrls: [imageUrl]);
            
            // Update database record
            await _updateProductImageUrl(product.id, imageUrl);
          } else {
            // Use placeholder or generate image (implement as needed)
            final placeholderUrl = _getPlaceholderImageUrl(product);
            updatedProduct = product.copyWith(imageUrls: [placeholderUrl]);
          }
        }
        
        processedProducts.add(updatedProduct);
      }
      
      return processedProducts;
    } catch (e) {
      throw Exception('Failed to get products with valid images: $e');
    }
  }
  
  /// Update product image URL in database
  Future<void> _updateProductImageUrl(int productId, String imageUrl) async {
    try {
      await _client
          .from('products')
          .update({'image_url': imageUrl})
          .eq('id', productId);
    } catch (e) {
      // Log error but don't throw to avoid breaking the flow
      print('Failed to update product image URL for product $productId: $e');
    }
  }
  
  /// Get placeholder image URL based on product category
  String _getPlaceholderImageUrl(Product product) {
    // Use category-based placeholder from Supabase Storage
    final categoryName = product.name.toLowerCase();
    
    if (categoryName.contains('shoe') || categoryName.contains('sneaker')) {
      return _storageService.getProjectImageUrl('placeholder-shoes.png');
    } else if (categoryName.contains('shirt') || categoryName.contains('cloth')) {
      return _storageService.getProjectImageUrl('placeholder-clothing.png');
    } else if (categoryName.contains('phone') || categoryName.contains('electronic')) {
      return _storageService.getProjectImageUrl('placeholder-electronics.png');
    } else if (categoryName.contains('furniture') || categoryName.contains('chair')) {
      return _storageService.getProjectImageUrl('placeholder-furniture.png');
    } else {
      return _storageService.getProjectImageUrl('placeholder-product.png');
    }
  }
  
  /// Upload product image to Supabase Storage
  Future<String> uploadProductImage({
    required int productId,
    required Uint8List imageBytes,
  }) async {
    try {
      final fileName = '$productId.png';
      final imageUrl = await _storageService.uploadImage(
        bucketName: SupabaseStorageService.productImagesBucket,
        fileName: fileName,
        imageBytes: imageBytes,
        contentType: 'image/png',
      );
      
      // Update product record with new image URL
      await _updateProductImageUrl(productId, imageUrl);
      
      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload product image: $e');
    }
  }
  
  /// Check if product has valid image in Supabase Storage
  Future<bool> hasValidProductImage(int productId) async {
    return await _storageService.imageExists(
      SupabaseStorageService.productImagesBucket,
      '$productId.png',
    );
  }
  
  /// Get product image URL from Supabase Storage
  String getProductImageUrl(int productId) {
    return _storageService.getProductImageUrl(productId.toString());
  }
}

@riverpod
ProductImageService productImageService(ProductImageServiceRef ref) {
  return ProductImageService(
    ref.watch(supabaseProvider),
    ref.watch(supabaseStorageServiceProvider),
  );
}