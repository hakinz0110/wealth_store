import '../models/product_models.dart';
import '../shared/utils/logger.dart';
import '../shared/utils/error_handler.dart';
import 'supabase_service.dart';

class CategoryFormData {
  final String name;
  final String? description;
  final String? imageUrl;

  const CategoryFormData({
    required this.name,
    this.description,
    this.imageUrl,
  });

  factory CategoryFormData.empty() {
    return const CategoryFormData(name: '');
  }

  factory CategoryFormData.fromCategory(Category category) {
    return CategoryFormData(
      name: category.name,
      description: category.description,
      imageUrl: category.imageUrl,
    );
  }

  CategoryFormData copyWith({
    String? name,
    String? description,
    String? imageUrl,
  }) {
    return CategoryFormData(
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'image_url': imageUrl,
    };
  }
}

class CategoryValidationError {
  final String field;
  final String message;

  const CategoryValidationError({
    required this.field,
    required this.message,
  });
}

class CategoryService {
  static const String _tableName = 'categories';

  // Get all categories from Supabase
  Future<List<Category>> getCategories() async {
    try {
      Logger.info('Fetching categories from Supabase');
      
      final response = await SupabaseService.client
          .from(_tableName)
          .select('*')
          .order('created_at', ascending: false);

      return response.map<Category>((json) => Category.fromJson(json)).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get categories', e, stackTrace);
      rethrow;
    }
  }

  // Get category by ID from Supabase
  Future<Category?> getCategoryById(String id) async {
    try {
      Logger.info('Fetching category by ID: $id');
      
      final response = await SupabaseService.client
          .from(_tableName)
          .select('*')
          .eq('id', id)
          .single();

      return Category.fromJson(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get category by ID', e, stackTrace);
      return null;
    }
  }

  // Create new category in Supabase
  Future<Category> createCategory(CategoryFormData data) async {
    try {
      Logger.info('Creating new category: ${data.name}');

      // Validate data
      final errors = validateCategoryData(data);
      if (errors.isNotEmpty) {
        throw Exception('Validation failed: ${errors.map((e) => e.message).join(', ')}');
      }

      // Check if category with same name exists
      final existingCategories = await SupabaseService.client
          .from(_tableName)
          .select('id')
          .eq('name', data.name);

      if (existingCategories.isNotEmpty) {
        throw Exception('Category with this name already exists');
      }

      // Insert new category
      final response = await SupabaseService.client
          .from(_tableName)
          .insert({
            'name': data.name,
            'description': data.description,
            'image_url': data.imageUrl,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      Logger.info('Category created successfully: ${data.name}');
      return Category.fromJson(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Create category', e, stackTrace);
      rethrow;
    }
  }

  // Update category in Supabase
  Future<Category> updateCategory(String id, CategoryFormData data) async {
    try {
      Logger.info('Updating category: $id');

      // Validate data
      final errors = validateCategoryData(data);
      if (errors.isNotEmpty) {
        throw Exception('Validation failed: ${errors.map((e) => e.message).join(', ')}');
      }

      // Check if category with same name exists (excluding current category)
      final existingCategories = await SupabaseService.client
          .from(_tableName)
          .select('id')
          .eq('name', data.name)
          .neq('id', id);

      if (existingCategories.isNotEmpty) {
        throw Exception('Category with this name already exists');
      }

      // Update category
      final response = await SupabaseService.client
          .from(_tableName)
          .update({
            'name': data.name,
            'description': data.description,
            'image_url': data.imageUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      Logger.info('Category updated successfully: $id');
      return Category.fromJson(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Update category', e, stackTrace);
      rethrow;
    }
  }

  // Delete category from Supabase
  Future<void> deleteCategory(String id) async {
    try {
      Logger.info('Deleting category: $id');

      // Check if category has products
      final productCount = await SupabaseService.client
          .from('products')
          .select('id')
          .eq('category_id', id)
          .count();

      if (productCount.count > 0) {
        throw Exception('Cannot delete category with existing products. Please move or delete products first.');
      }

      // Delete category
      await SupabaseService.client
          .from(_tableName)
          .delete()
          .eq('id', id);

      Logger.info('Category deleted successfully: $id');
    } catch (e, stackTrace) {
      ErrorHandler.logError('Delete category', e, stackTrace);
      rethrow;
    }
  }

  // Get categories with product count
  Future<List<Category>> getCategoriesWithProductCount() async {
    try {
      Logger.info('Fetching categories with product count');
      
      final response = await SupabaseService.client
          .from(_tableName)
          .select('*, products(count)')
          .order('created_at', ascending: false);

      return response.map<Category>((json) {
        final productCount = json['products']?.length ?? 0;
        final categoryData = Map<String, dynamic>.from(json);
        categoryData['product_count'] = productCount;
        categoryData.remove('products');
        return Category.fromJson(categoryData);
      }).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get categories with product count', e, stackTrace);
      rethrow;
    }
  }

  // Search categories
  Future<List<Category>> searchCategories(String query) async {
    try {
      Logger.info('Searching categories: $query');
      
      final response = await SupabaseService.client
          .from(_tableName)
          .select('*')
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false)
          .limit(50);

      return response.map<Category>((json) => Category.fromJson(json)).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Search categories', e, stackTrace);
      rethrow;
    }
  }

  // Validate category data
  List<CategoryValidationError> validateCategoryData(CategoryFormData data) {
    final errors = <CategoryValidationError>[];

    // Name validation
    if (data.name.trim().isEmpty) {
      errors.add(const CategoryValidationError(
        field: 'name',
        message: 'Category name is required',
      ));
    } else if (data.name.trim().length < 2) {
      errors.add(const CategoryValidationError(
        field: 'name',
        message: 'Category name must be at least 2 characters long',
      ));
    } else if (data.name.trim().length > 50) {
      errors.add(const CategoryValidationError(
        field: 'name',
        message: 'Category name cannot exceed 50 characters',
      ));
    }

    // Description validation
    if (data.description != null && data.description!.trim().length > 500) {
      errors.add(const CategoryValidationError(
        field: 'description',
        message: 'Description cannot exceed 500 characters',
      ));
    }

    // Image URL validation
    if (data.imageUrl != null && data.imageUrl!.trim().isNotEmpty) {
      final urlPattern = RegExp(r'^https?://');
      if (!urlPattern.hasMatch(data.imageUrl!.trim())) {
        errors.add(const CategoryValidationError(
          field: 'imageUrl',
          message: 'Please enter a valid URL starting with http:// or https://',
        ));
      }
    }

    return errors;
  }
}