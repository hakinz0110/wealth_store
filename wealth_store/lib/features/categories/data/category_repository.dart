import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealth_app/core/services/supabase_service.dart';
import 'package:wealth_app/core/utils/app_exceptions.dart';
import 'package:wealth_app/shared/models/category.dart';

part 'category_repository.g.dart';

class CategoryRepository {
  final SupabaseClient _client;

  CategoryRepository(this._client);

  Future<List<Category>> getCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .order('name');
      
      return response.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      throw DataException('Failed to load categories: $e');
    }
  }

  Future<Category> getCategory(int id) async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .eq('id', id)
          .single();
      
      return Category.fromJson(response);
    } catch (e) {
      throw DataException('Failed to load category: $e');
    }
  }

  // For future admin functionality
  Future<Category> createCategory(Category category) async {
    try {
      final response = await _client
          .from('categories')
          .insert(category.toJson())
          .select()
          .single();
      
      return Category.fromJson(response);
    } catch (e) {
      throw DataException('Failed to create category: $e');
    }
  }

  // For future admin functionality
  Future<Category> updateCategory(Category category) async {
    try {
      final response = await _client
          .from('categories')
          .update(category.toJson())
          .eq('id', category.id)
          .select()
          .single();
      
      return Category.fromJson(response);
    } catch (e) {
      throw DataException('Failed to update category: $e');
    }
  }

  // For future admin functionality
  Future<void> deleteCategory(int id) async {
    try {
      await _client
          .from('categories')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw DataException('Failed to delete category: $e');
    }
  }
}

@riverpod
CategoryRepository categoryRepository(CategoryRepositoryRef ref) {
  return CategoryRepository(ref.watch(supabaseProvider));
} 