import 'dart:typed_data';
import 'dart:io';
import '../models/product_models.dart';
// Media models removed - using storage service instead
import '../shared/utils/logger.dart';
import '../shared/utils/error_handler.dart';
import 'supabase_service.dart';
// Media service removed - using storage service instead

class ProductService {
  static const String _tableName = 'products';
  // Media service removed - using storage service instead

  // Get all products from Supabase with pagination and filters
  Future<List<Product>> getProducts({
    int page = 1,
    int limit = 20,
    ProductFilters? filters,
  }) async {
    try {
      Logger.info('Fetching products from Supabase - Page: $page, Limit: $limit');
      
      var query = SupabaseService.client
          .from(_tableName)
          .select('*');

      // Apply filters
      if (filters != null) {
        if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
          query = query.or('name.ilike.%${filters.searchQuery}%,description.ilike.%${filters.searchQuery}%');
        }
        
        if (filters.categoryId != null) {
          query = query.eq('category_id', filters.categoryId!);
        }
        
        if (filters.brandId != null) {
          query = query.eq('brand_id', filters.brandId!);
        }
        
        if (filters.lowStock == true) {
          query = query.lt('stock', 10); // Consider low stock as less than 10
        }
        
        if (filters.isActive == true) {
          query = query.eq('is_active', true);
        }
      }

      // Apply ordering and pagination
      final offset = (page - 1) * limit;
      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map<Product>((json) => Product.fromJson(json)).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get products', e, stackTrace);
      rethrow;
    }
  }

  // Get product by ID from Supabase
  Future<Product?> getProductById(String id) async {
    try {
      Logger.info('Fetching product by ID: $id');
      
      final response = await SupabaseService.client
          .from(_tableName)
          .select('*')
          .eq('id', id)
          .single();

      return Product.fromJson(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get product by ID', e, stackTrace);
      return null;
    }
  }

  // Create new product in Supabase
  Future<Product> createProduct(ProductFormData data) async {
    try {
      Logger.info('Creating new product: ${data.name}');

      final response = await SupabaseService.client
          .from(_tableName)
          .insert({
            'name': data.name,
            'description': data.description,
            'price': data.price,
            'stock': data.stock,
            'category_id': data.categoryId,
            'brand_id': data.brandId,
            'image_urls': data.imageUrls,
            'specifications': data.specifications,
            'is_active': data.isActive ?? true,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      Logger.info('Product created successfully: ${data.name}');
      return Product.fromJson(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Create product', e, stackTrace);
      rethrow;
    }
  }

  // Upload product image using bytes (for web compatibility)
  Future<String> uploadProductImageBytes(List<int> imageBytes, String fileName) async {
    try {
      Logger.info('Uploading product image: $fileName');
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$fileName';
      
      // Convert List<int> to Uint8List
      final uint8List = Uint8List.fromList(imageBytes);
      
      await SupabaseService.client.storage
          .from('product-images')
          .uploadBinary(uniqueFileName, uint8List);
      
      final imageUrl = SupabaseService.client.storage
          .from('product-images')
          .getPublicUrl(uniqueFileName);
      
      Logger.info('Product image uploaded successfully: $uniqueFileName');
      return imageUrl;
    } catch (e, stackTrace) {
      ErrorHandler.logError('Upload product image', e, stackTrace);
      rethrow;
    }
  }

  // Update product in Supabase
  Future<Product> updateProduct(String id, ProductFormData data) async {
    try {
      Logger.info('Updating product: $id');

      final response = await SupabaseService.client
          .from(_tableName)
          .update({
            'name': data.name,
            'description': data.description,
            'price': data.price,
            'stock': data.stock,
            'category_id': data.categoryId,
            'brand_id': data.brandId,
            'image_urls': data.imageUrls,
            'specifications': data.specifications,
            'is_active': data.isActive ?? true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      Logger.info('Product updated successfully: $id');
      return Product.fromJson(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Update product', e, stackTrace);
      rethrow;
    }
  }

  // Delete product from Supabase
  Future<void> deleteProduct(String id) async {
    try {
      Logger.info('Deleting product: $id');

      await SupabaseService.client
          .from(_tableName)
          .delete()
          .eq('id', id);

      Logger.info('Product deleted successfully: $id');
    } catch (e, stackTrace) {
      ErrorHandler.logError('Delete product', e, stackTrace);
      rethrow;
    }
  }

  // Get categories from Supabase (moved from CategoryService)
  Future<List<Category>> getCategories() async {
    try {
      Logger.info('Fetching categories from Supabase');
      
      final response = await SupabaseService.client
          .from('categories')
          .select('*')
          .order('created_at', ascending: false);

      return response.map<Category>((json) => Category.fromJson(json)).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get categories', e, stackTrace);
      rethrow;
    }
  }

  // Get brands from Supabase
  Future<List<Brand>> getBrands() async {
    try {
      Logger.info('Fetching brands from Supabase');
      
      final response = await SupabaseService.client
          .from('brands')
          .select('*')
          .order('name', ascending: true);

      return response.map<Brand>((json) => Brand.fromJson(json)).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get brands', e, stackTrace);
      rethrow;
    }
  }

  // Get total product count
  Future<int> getTotalProductCount() async {
    try {
      final response = await SupabaseService.client
          .from('products')
          .select('id');
      return response.length;
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get total product count', e, stackTrace);
      return 0;
    }
  }

  // Get low stock count
  Future<int> getLowStockCount() async {
    try {
      final response = await SupabaseService.client
          .from('products')
          .select('id')
          .lt('stock', 10);
      return response.length;
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get low stock count', e, stackTrace);
      return 0;
    }
  }

  // Get out of stock count
  Future<int> getOutOfStockCount() async {
    try {
      final response = await SupabaseService.client
          .from('products')
          .select('id')
          .eq('stock', 0);
      return response.length;
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get out of stock count', e, stackTrace);
      return 0;
    }
  }

  // Get brand by ID from Supabase
  Future<Brand?> getBrandById(String id) async {
    try {
      Logger.info('Fetching brand by ID: $id');
      
      final response = await SupabaseService.client
          .from('brands')
          .select('*')
          .eq('id', id)
          .single();

      return Brand.fromJson(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get brand by ID', e, stackTrace);
      return null;
    }
  }

  // Update product stock
  Future<void> updateProductStock(String id, int newStock) async {
    try {
      Logger.info('Updating product stock: $id to $newStock');

      await SupabaseService.client
          .from(_tableName)
          .update({
            'stock': newStock,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);

      Logger.info('Product stock updated successfully: $id');
    } catch (e, stackTrace) {
      ErrorHandler.logError('Update product stock', e, stackTrace);
      rethrow;
    }
  }

  // Get low stock products
  Future<List<Product>> getLowStockProducts({int threshold = 10}) async {
    try {
      Logger.info('Fetching low stock products (threshold: $threshold)');
      
      final response = await SupabaseService.client
          .from(_tableName)
          .select('*')
          .lt('stock', threshold)
          .eq('is_active', true)
          .order('stock', ascending: true);

      return response.map<Product>((json) => Product.fromJson(json)).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get low stock products', e, stackTrace);
      rethrow;
    }
  }

  // Search products
  Future<List<Product>> searchProducts(String query) async {
    try {
      Logger.info('Searching products: $query');
      
      final response = await SupabaseService.client
          .from(_tableName)
          .select('*')
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(50);

      return response.map<Product>((json) => Product.fromJson(json)).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Search products', e, stackTrace);
      rethrow;
    }
  }

  // Image upload functionality using File (for mobile/desktop)
  Future<String> uploadProductImage(File imageFile, String productName) async {
    try {
      Logger.info('Uploading product image for: $productName');
      
      final bytes = await imageFile.readAsBytes();
      final fileName = '${productName}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Upload directly to Supabase storage
      await SupabaseService.client.storage
          .from('product-images')
          .uploadBinary(fileName, Uint8List.fromList(bytes));
      
      final fileUrl = SupabaseService.client.storage
          .from('product-images')
          .getPublicUrl(fileName);
      
      Logger.info('Product image uploaded successfully: $fileUrl');
      return fileUrl;
    } catch (e, stackTrace) {
      ErrorHandler.logError('Upload product image', e, stackTrace);
      rethrow;
    }
  }

  // Upload multiple product images
  Future<List<String>> uploadProductImages(
    List<File> imageFiles, 
    String productName, {
    Function(int, int)? onProgress,
  }) async {
    try {
      Logger.info('Uploading ${imageFiles.length} product images for: $productName');
      
      final imageUrls = <String>[];
      
      for (int i = 0; i < imageFiles.length; i++) {
        final bytes = await imageFiles[i].readAsBytes();
        final fileName = '${productName}_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        // Upload directly to Supabase storage
        await SupabaseService.client.storage
            .from('product-images')
            .uploadBinary(fileName, Uint8List.fromList(bytes));
        
        final fileUrl = SupabaseService.client.storage
            .from('product-images')
            .getPublicUrl(fileName);
        
        imageUrls.add(fileUrl);
        
        if (onProgress != null) {
          onProgress(i + 1, imageFiles.length);
        }
      }
      
      Logger.info('All product images uploaded successfully');
      return imageUrls;
    } catch (e, stackTrace) {
      ErrorHandler.logError('Upload product images', e, stackTrace);
      rethrow;
    }
  }

  // Delete product image
  Future<void> deleteProductImage(String imageUrl) async {
    try {
      Logger.info('Deleting product image: $imageUrl');
      
      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      if (pathSegments.length >= 5 && pathSegments[2] == 'object' && pathSegments[3] == 'public') {
        final bucket = pathSegments[4];
        final filePath = pathSegments.skip(5).join('/');
        
        // Use Supabase storage directly for deletion
        await SupabaseService.client.storage
            .from(bucket)
            .remove([filePath]);
        Logger.info('Product image deleted successfully');
      }
    } catch (e, stackTrace) {
      ErrorHandler.logError('Delete product image', e, stackTrace);
      // Don't rethrow - image deletion is not critical
    }
  }

  // Create product with image upload
  Future<Product> createProductWithImages(
    ProductFormData data,
    List<File> imageFiles, {
    Function(int, int)? onProgress,
  }) async {
    try {
      Logger.info('Creating product with images: ${data.name}');
      
      // Upload images first
      List<String> imageUrls = [];
      if (imageFiles.isNotEmpty) {
        imageUrls = await uploadProductImages(
          imageFiles,
          data.name,
          onProgress: onProgress,
        );
      }
      
      // Create product with image URLs
      final productData = data.copyWith(imageUrls: imageUrls);
      return await createProduct(productData);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Create product with images', e, stackTrace);
      rethrow;
    }
  }

  // Update product with new images
  Future<Product> updateProductWithImages(
    String id,
    ProductFormData data,
    List<File> newImageFiles, {
    Function(int, int)? onProgress,
  }) async {
    try {
      Logger.info('Updating product with images: $id');
      
      // Get current product to retrieve existing image URLs
      final currentProduct = await getProductById(id);
      final oldImageUrls = currentProduct?.imageUrls ?? [];
      
      // Upload new images
      List<String> newImageUrls = [];
      if (newImageFiles.isNotEmpty) {
        newImageUrls = await uploadProductImages(
          newImageFiles,
          data.name,
          onProgress: onProgress,
        );
      }
      
      // Combine existing and new image URLs
      final allImageUrls = [...data.imageUrls, ...newImageUrls];
      
      // Update product with combined image URLs
      final updatedData = data.copyWith(imageUrls: allImageUrls);
      final result = await updateProduct(id, updatedData);
      
      // Delete old images that are no longer used
      final imagesToDelete = oldImageUrls
          .where((url) => !allImageUrls.contains(url))
          .toList();
      
      for (final imageUrl in imagesToDelete) {
        await deleteProductImage(imageUrl);
      }
      
      return result;
    } catch (e, stackTrace) {
      ErrorHandler.logError('Update product with images', e, stackTrace);
      rethrow;
    }
  }
}