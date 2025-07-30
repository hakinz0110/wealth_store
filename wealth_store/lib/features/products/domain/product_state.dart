import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wealth_app/features/products/domain/product_filter_state.dart';
import 'package:wealth_app/shared/models/product.dart';

part 'product_state.freezed.dart';

@freezed
class ProductState with _$ProductState {
  const factory ProductState({
    @Default([]) List<Product> products,
    @Default([]) List<Product> filteredProducts,
    Product? selectedProduct,
    @Default(false) bool isLoading,
    String? error,
    @Default(0) int currentPage,
    @Default(true) bool hasMore,
    @Default(ProductFilterState()) ProductFilterState filterState,
    @Default(0.0) double minPrice,
    @Default(1000.0) double maxPrice,
  }) = _ProductState;

  const ProductState._();

  factory ProductState.initial() => const ProductState();

  factory ProductState.loading() => const ProductState(isLoading: true);

  factory ProductState.error(String message) => ProductState(error: message);
} 