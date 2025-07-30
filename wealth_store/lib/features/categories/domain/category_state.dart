import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wealth_app/shared/models/category.dart';

part 'category_state.freezed.dart';
part 'category_state.g.dart';

@freezed
class CategoryState with _$CategoryState {
  const factory CategoryState({
    @Default([]) List<Category> categories,
    Category? selectedCategory,
    @Default(false) bool isLoading,
    String? error,
  }) = _CategoryState;

  const CategoryState._();

  factory CategoryState.initial() => const CategoryState();

  factory CategoryState.loading() => const CategoryState(isLoading: true);

  factory CategoryState.error(String message) => CategoryState(error: message);

  factory CategoryState.loaded(List<Category> categories) => CategoryState(categories: categories);

  factory CategoryState.fromJson(Map<String, dynamic> json) => _$CategoryStateFromJson(json);
} 