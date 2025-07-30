import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../models/product_models.dart';
import '../../../services/product_service.dart';
// Media service removed - using storage service instead

// Product service provider
final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

// Media service provider
// Media service provider removed - using storage service instead

// Product filters state provider
final productFiltersProvider = StateProvider<ProductFilters>((ref) {
  return const ProductFilters();
});

// Products list provider
final productsProvider = FutureProvider.family<List<Product>, int>((ref, page) async {
  final service = ref.read(productServiceProvider);
  final filters = ref.watch(productFiltersProvider);
  
  return await service.getProducts(
    page: page,
    limit: 20,
    filters: filters,
  );
});

// Categories provider
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final service = ref.read(productServiceProvider);
  return await service.getCategories();
});

// Brands provider
final brandsProvider = FutureProvider<List<Brand>>((ref) async {
  final service = ref.read(productServiceProvider);
  return await service.getBrands();
});

// Product by ID provider
final productByIdProvider = FutureProvider.family<Product?, String>((ref, id) async {
  final service = ref.read(productServiceProvider);
  return await service.getProductById(id);
});

// Low stock products provider
final lowStockProductsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.read(productServiceProvider);
  return await service.getLowStockProducts();
});

// Product statistics providers
final totalProductCountProvider = FutureProvider<int>((ref) async {
  final service = ref.read(productServiceProvider);
  return await service.getTotalProductCount();
});

final lowStockCountProvider = FutureProvider<int>((ref) async {
  final service = ref.read(productServiceProvider);
  return await service.getLowStockCount();
});

final outOfStockCountProvider = FutureProvider<int>((ref) async {
  final service = ref.read(productServiceProvider);
  return await service.getOutOfStockCount();
});

// Search products provider
final searchProductsProvider = FutureProvider.family<List<Product>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  
  final service = ref.read(productServiceProvider);
  return await service.searchProducts(query);
});

// Product CRUD operations provider
final productCrudProvider = Provider<ProductCrudOperations>((ref) {
  return ProductCrudOperations(ref.read(productServiceProvider));
});

class ProductCrudOperations {
  final ProductService _service;
  
  ProductCrudOperations(this._service);
  
  Future<Product> createProduct(ProductFormData data) async {
    return await _service.createProduct(data);
  }
  
  Future<Product> updateProduct(String id, ProductFormData data) async {
    return await _service.updateProduct(id, data);
  }
  
  Future<void> deleteProduct(String id) async {
    return await _service.deleteProduct(id);
  }
}