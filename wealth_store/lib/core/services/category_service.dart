import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/category.dart';
import 'supabase_service.dart';

part 'category_service.g.dart';

@riverpod
CategoryService categoryService(CategoryServiceRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return CategoryService(supabase);
}

class CategoryService {
  final SupabaseClient _client;
  
  CategoryService(this._client);
  
  // Get categories with optional filtering and sorting
  Future<List<Category>> getCategories({
    int? limit,
    int? offset,
    String? searchQuery,
    bool? isActive,
    String sortBy = 'created_at',
    bool ascending = false,
  }) async {
    try {
      var query = _client.from('categories').select('*');
      
      // Apply filters
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('name.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }
      
      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }
      
      // Apply sorting and pagination
      var transformQuery = query.order(sortBy, ascending: ascending);
      
      if (limit != null) {
        transformQuery = transformQuery.limit(limit);
      }
      
      if (offset != null) {
        transformQuery = transformQuery.range(offset, offset + (limit ?? 10) - 1);
      }
      
      final response = await transformQuery;
      
      return (response as List<dynamic>)
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }
  
  // Get a single category by ID
  Future<Category?> getCategoryById(String id) async {
    try {
      final response = await _client
          .from('categories')
          .select('*')
          .eq('id', id)
          .single();
      
      return Category.fromJson(response);
    } catch (e) {
      if (e is PostgrestException && e.code == 'PGRST116') {
        return null; // Category not found
      }
      throw Exception('Failed to fetch category: $e');
    }
  }
  
  // Get categories with product count
  Future<List<Category>> getCategoriesWithProductCount() async {
    try {
      final response = await _client
          .from('categories')
          .select('*, products(count)')
          .order('created_at', ascending: false);
      
      return (response as List<dynamic>).map((json) {
        final productCount = json['products']?.length ?? 0;
        final categoryData = Map<String, dynamic>.from(json);
        categoryData['product_count'] = productCount;
        categoryData.remove('products');
        return Category.fromJson(categoryData);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories with product count: $e');
    }
  }
  
  // Search categories
  Future<List<Category>> searchCategories(String query, {
    int? limit,
    int? offset,
  }) async {
    return getCategories(
      searchQuery: query,
      limit: limit,
      offset: offset,
    );
  }
  
  // Get active categories only
  Future<List<Category>> getActiveCategories({int? limit}) async {
    return getCategories(
      isActive: true,
      limit: limit,
      sortBy: 'name',
      ascending: true,
    );
  }
  
  // Create a new category (Admin only)
  Future<Category> createCategory(Category category) async {
    try {
      final categoryData = category.toJson();
      // Remove id and timestamps for creation
      categoryData.remove('id');
      categoryData.remove('created_at');
      categoryData.remove('updated_at');
      categoryData.remove('product_count');
      
      // Add timestamps
      final now = DateTime.now().toIso8601String();
      categoryData['created_at'] = now;
      categoryData['updated_at'] = now;
      
      final response = await _client
          .from('categories')
          .insert(categoryData)
          .select()
          .single();
      
      return Category.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }
  
  // Update an existing category (Admin only)
  Future<Category> updateCategory(String id, Category category) async {
    try {
      final categoryData = category.toJson();
      // Remove id, created_at, and product_count for update
      categoryData.remove('id');
      categoryData.remove('created_at');
      categoryData.remove('product_count');
      
      // Update timestamp
      categoryData['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _client
          .from('categories')
          .update(categoryData)
          .eq('id', id)
          .select()
          .single();
      
      return Category.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }
  
  // Delete a category (Admin only)
  Future<void> deleteCategory(String id) async {
    try {
      // Check if category has products
      final products = await _client
          .from('products')
          .select('id')
          .eq('category_id', id);
      
      if (products.isNotEmpty) {
        throw Exception('Cannot delete category with existing products. Please move or delete products first.');
      }
      
      await _client
          .from('categories')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
  
  // Toggle category active status (Admin only)
  Future<Category> toggleActiveStatus(String id) async {
    try {
      // First get the current status
      final current = await getCategoryById(id);
      if (current == null) {
        throw Exception('Category not found');
      }
      
      final response = await _client
          .from('categories')
          .update({
            'is_active': !current.isActive,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();
      
      return Category.fromJson(response);
    } catch (e) {
      throw Exception('Failed to toggle active status: $e');
    }
  }
  
  // Get category count for pagination
  Future<int> getCategoryCount({
    String? searchQuery,
    bool? isActive,
  }) async {
    try {
      // Simple count by getting all categories and counting them
      final categories = await getCategories(
        searchQuery: searchQuery,
        isActive: isActive,
      );
      return categories.length;
    } catch (e) {
      throw Exception('Failed to get category count: $e');
    }
  }
  
  // Batch operations for admin
  Future<List<Category>> createMultipleCategories(List<Category> categories) async {
    try {
      final categoriesData = categories.map((c) {
        final data = c.toJson();
        data.remove('id');
        data.remove('created_at');
        data.remove('updated_at');
        data.remove('product_count');
        
        final now = DateTime.now().toIso8601String();
        data['created_at'] = now;
        data['updated_at'] = now;
        
        return data;
      }).toList();
      
      final response = await _client
          .from('categories')
          .insert(categoriesData)
          .select();
      
      return (response as List<dynamic>)
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to create multiple categories: $e');
    }
  }
  
  Future<void> deleteMultipleCategories(List<String> ids) async {
    try {
      // Check each category for products before deletion
      for (final id in ids) {
        final products = await _client
            .from('products')
            .select('id')
            .eq('category_id', id);
        
        if (products.isNotEmpty) {
          throw Exception('Cannot delete category $id with existing products.');
        }
      }
      
      // Delete categories one by one for now
      for (final id in ids) {
        await deleteCategory(id);
      }
    } catch (e) {
      throw Exception('Failed to delete multiple categories: $e');
    }
  }
  
  // Validation methods
  List<String> validateCategory(Category category) {
    final errors = <String>[];
    
    // Name validation
    if (category.name.trim().isEmpty) {
      errors.add('Category name is required');
    } else if (category.name.trim().length < 2) {
      errors.add('Category name must be at least 2 characters long');
    } else if (category.name.trim().length > 50) {
      errors.add('Category name cannot exceed 50 characters');
    }
    
    // Description validation
    if (category.description != null && category.description!.trim().length > 500) {
      errors.add('Description cannot exceed 500 characters');
    }
    
    // Image URL validation
    if (category.imageUrl != null && category.imageUrl!.trim().isNotEmpty) {
      final urlPattern = RegExp(r'^https?://');
      if (!urlPattern.hasMatch(category.imageUrl!.trim())) {
        errors.add('Please enter a valid URL starting with http:// or https://');
      }
    }
    
    return errors;
  }
  
  // Check if category name exists (for validation)
  Future<bool> categoryNameExists(String name, {String? excludeId}) async {
    try {
      var query = _client
          .from('categories')
          .select('id')
          .eq('name', name);
      
      if (excludeId != null) {
        query = query.neq('id', excludeId);
      }
      
      final response = await query;
      return response.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check category name: $e');
    }
  }
  
  // Real-time subscription for categories
  Stream<List<Category>> watchCategories({
    bool? isActive,
  }) {
    // For now, return a simple stream that fetches categories periodically
    // This can be enhanced later with proper real-time subscriptions
    return Stream.periodic(const Duration(seconds: 5), (_) async {
      return await getCategories(isActive: isActive);
    }).asyncMap((future) => future);
  }
  
  // Connection health check
  Future<bool> checkConnection() async {
    try {
      await _client.from('categories').select('id').limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }
}