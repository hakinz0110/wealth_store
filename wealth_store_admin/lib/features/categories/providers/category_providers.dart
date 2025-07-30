import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../models/product_models.dart';
import '../../../services/category_service.dart';

// Category service provider
final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService();
});

// Categories list provider
final categoriesProvider = StateNotifierProvider<CategoriesNotifier, CategoriesState>((ref) {
  final categoryService = ref.watch(categoryServiceProvider);
  return CategoriesNotifier(categoryService);
});

// Search query provider
final categorySearchQueryProvider = StateProvider<String>((ref) => '');

// Category by ID provider
final categoryByIdProvider = FutureProvider.family<Category?, String>((ref, id) async {
  final service = ref.read(categoryServiceProvider);
  return await service.getCategoryById(id);
});

// Category form data provider
final categoryFormDataProvider = StateProvider<CategoryFormData>((ref) {
  return CategoryFormData.empty();
});

// Categories state
class CategoriesState {
  final List<Category> categories;
  final bool isLoading;
  final String? error;

  const CategoriesState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  CategoriesState copyWith({
    List<Category>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error : this.error,
    );
  }

  CategoriesState withError(String error) {
    return copyWith(
      isLoading: false,
      error: error,
    );
  }

  CategoriesState withLoading() {
    return copyWith(
      isLoading: true,
      error: null,
    );
  }

  CategoriesState withCategories(List<Category> categories) {
    return copyWith(
      categories: categories,
      isLoading: false,
      error: null,
    );
  }
}

// Categories notifier
class CategoriesNotifier extends StateNotifier<CategoriesState> {
  final CategoryService _categoryService;
  
  CategoriesNotifier(this._categoryService) : super(const CategoriesState()) {
    loadCategories();
  }
  
  Future<void> loadCategories({String? searchQuery}) async {
    state = state.withLoading();
    
    try {
      final categories = searchQuery == null || searchQuery.isEmpty
          ? await _categoryService.getCategories()
          : await _categoryService.searchCategories(searchQuery);
      
      state = state.withCategories(categories);
    } catch (e) {
      state = state.withError(e.toString());
    }
  }
  
  Future<void> createCategory(CategoryFormData data) async {
    try {
      await _categoryService.createCategory(data);
      await loadCategories();
    } catch (e) {
      state = state.withError(e.toString());
      rethrow;
    }
  }
  
  Future<void> updateCategory(String id, CategoryFormData data) async {
    try {
      await _categoryService.updateCategory(id, data);
      await loadCategories();
    } catch (e) {
      state = state.withError(e.toString());
      rethrow;
    }
  }
  
  Future<void> deleteCategory(String id) async {
    try {
      await _categoryService.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      state = state.withError(e.toString());
      rethrow;
    }
  }
  
  Future<void> refresh() async {
    await loadCategories();
  }
}