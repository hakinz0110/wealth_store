import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wealth_app/features/categories/data/category_repository.dart';
import 'package:wealth_app/features/home/domain/home_category_model.dart';
import 'package:wealth_app/shared/models/category.dart';

part 'home_category_service.g.dart';

class HomeCategoryService {
  final CategoryRepository _categoryRepository;

  HomeCategoryService(this._categoryRepository);

  /// Get popular categories for home screen display
  /// Falls back to default categories if database categories are not available
  Future<List<HomeCategory>> getPopularCategories() async {
    try {
      // Try to get categories from database
      final categories = await _categoryRepository.getCategories();
      
      if (categories.isEmpty) {
        // Return default categories if no categories in database
        return PopularCategories.defaultCategories;
      }

      // Convert database categories to home categories and take first 6
      final homeCategories = categories
          .take(6)
          .map((category) => HomeCategory.fromCategory(category))
          .toList();

      // If we have fewer than 6 categories, fill with defaults
      if (homeCategories.length < 6) {
        final remainingCount = 6 - homeCategories.length;
        final defaultsToAdd = PopularCategories.defaultCategories
            .take(remainingCount)
            .where((defaultCat) => 
                !homeCategories.any((homeCat) => 
                    homeCat.name.toLowerCase() == defaultCat.name.toLowerCase()))
            .toList();
        
        homeCategories.addAll(defaultsToAdd);
      }

      return homeCategories;
    } catch (e) {
      // Return default categories on error
      return PopularCategories.defaultCategories;
    }
  }

  /// Get category by ID for navigation
  Future<Category?> getCategoryById(int id) async {
    try {
      return await _categoryRepository.getCategory(id);
    } catch (e) {
      return null;
    }
  }

  /// Check if a category name matches popular categories
  bool isPopularCategory(String categoryName) {
    final name = categoryName.toLowerCase();
    return PopularCategories.defaultCategories
        .any((cat) => cat.name.toLowerCase() == name);
  }
}

@riverpod
HomeCategoryService homeCategoryService(HomeCategoryServiceRef ref) {
  return HomeCategoryService(ref.watch(categoryRepositoryProvider));
}

@riverpod
Future<List<HomeCategory>> popularCategories(PopularCategoriesRef ref) async {
  final service = ref.watch(homeCategoryServiceProvider);
  return service.getPopularCategories();
}