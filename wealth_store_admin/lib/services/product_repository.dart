import '../models/product_models.dart';

abstract class ProductRepository {
  // Product CRUD operations
  Future<List<Product>> getProducts({
    int page = 1,
    int limit = 20,
    ProductFilters? filters,
  });
  
  Future<Product?> getProductById(String id);
  
  Future<Product> createProduct(ProductFormData data);
  
  Future<Product> updateProduct(String id, ProductFormData data);
  
  Future<void> deleteProduct(String id);
  
  // Category operations
  Future<List<Category>> getCategories();
  
  Future<Category?> getCategoryById(String id);
  
  // Brand operations
  Future<List<Brand>> getBrands();
  
  Future<Brand?> getBrandById(String id);
  
  // Search and filtering
  Future<List<Product>> searchProducts(String query, {
    int page = 1,
    int limit = 20,
  });
  
  Future<List<Product>> getProductsByCategory(String categoryId, {
    int page = 1,
    int limit = 20,
  });
  
  Future<List<Product>> getProductsByBrand(String brandId, {
    int page = 1,
    int limit = 20,
  });
  
  Future<List<Product>> getLowStockProducts({
    int threshold = 10,
    int page = 1,
    int limit = 20,
  });
  
  // Statistics
  Future<int> getTotalProductCount();
  
  Future<int> getLowStockCount({int threshold = 10});
  
  Future<int> getOutOfStockCount();
}