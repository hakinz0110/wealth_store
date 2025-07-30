import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_filter_state.freezed.dart';
part 'product_filter_state.g.dart';

enum ProductSortOption {
  priceAsc,
  priceDesc,
  newest,
  popular,
  nameAsc,
  nameDesc,
}

extension ProductSortOptionExtension on ProductSortOption {
  String get displayName {
    switch (this) {
      case ProductSortOption.priceAsc:
        return 'Price: Low to High';
      case ProductSortOption.priceDesc:
        return 'Price: High to Low';
      case ProductSortOption.newest:
        return 'Newest First';
      case ProductSortOption.popular:
        return 'Most Popular';
      case ProductSortOption.nameAsc:
        return 'Name: A-Z';
      case ProductSortOption.nameDesc:
        return 'Name: Z-A';
    }
  }
}

@freezed
class ProductFilterState with _$ProductFilterState {
  const factory ProductFilterState({
    int? categoryId,
    String? categoryName,
    @Default(ProductSortOption.newest) ProductSortOption sortOption,
    @Default(0.0) double minPrice,
    @Default(1000.0) double maxPrice,
    @Default(0.0) double currentMinPrice,
    @Default(1000.0) double currentMaxPrice,
    String? searchQuery,
  }) = _ProductFilterState;

  const ProductFilterState._();

  factory ProductFilterState.initial() => const ProductFilterState();

  factory ProductFilterState.fromJson(Map<String, dynamic> json) => _$ProductFilterStateFromJson(json);
} 