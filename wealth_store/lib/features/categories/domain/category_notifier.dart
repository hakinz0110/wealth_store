import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wealth_app/core/utils/app_exceptions.dart';
import 'package:wealth_app/features/categories/data/category_repository.dart';
import 'package:wealth_app/features/categories/domain/category_state.dart';

part 'category_notifier.g.dart';

@riverpod
class CategoryNotifier extends _$CategoryNotifier {
  @override
  CategoryState build() {
    loadCategories();
    return CategoryState.initial();
  }

  Future<void> loadCategories() async {
    state = CategoryState.loading();
    try {
      final categories = await ref.read(categoryRepositoryProvider).getCategories();
      state = CategoryState.loaded(categories);
    } on DataException catch (e) {
      state = CategoryState.error(e.message);
    } catch (e) {
      state = CategoryState.error("Failed to load categories");
    }
  }

  void selectCategory(int? categoryId) {
    if (categoryId == null) {
      state = state.copyWith(selectedCategory: null);
      return;
    }
    
    final category = state.categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => throw DataException('Category not found'),
    );
    
    state = state.copyWith(selectedCategory: category);
  }

  Future<void> getCategory(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      final category = await ref.read(categoryRepositoryProvider).getCategory(id);
      state = state.copyWith(
        selectedCategory: category,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to load category details",
      );
    }
  }
} 