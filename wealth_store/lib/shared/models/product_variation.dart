import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_variation.freezed.dart';
part 'product_variation.g.dart';

@freezed
class ProductVariation with _$ProductVariation {
  const factory ProductVariation({
    required int id,
    required int productId,
    required String name, // e.g., "Red - Size 42"
    required double price,
    required int stock,
    required Map<String, String> attributes, // e.g., {"color": "red", "size": "42"}
    @Default('') String imageUrl,
    @Default(true) bool isActive,
  }) = _ProductVariation;

  factory ProductVariation.fromJson(Map<String, dynamic> json) => _$ProductVariationFromJson(json);
}

@freezed
class ProductAttribute with _$ProductAttribute {
  const factory ProductAttribute({
    required String name, // e.g., "Color", "Size"
    required List<String> values, // e.g., ["Red", "Blue", "Green"]
    @Default(AttributeType.text) AttributeType type,
  }) = _ProductAttribute;

  factory ProductAttribute.fromJson(Map<String, dynamic> json) => _$ProductAttributeFromJson(json);
}

enum AttributeType {
  text,
  color,
  size,
  image,
}

@freezed
class EnhancedProduct with _$EnhancedProduct {
  const factory EnhancedProduct({
    required int id,
    required String name,
    required String description,
    required double basePrice, // Base price for simple products
    required String imageUrl,
    required int categoryId,
    @Default(0) int baseStock, // Base stock for simple products
    @Default(0.0) double rating,
    @Default(0) int reviewCount,
    @Default(false) bool isFeatured,
    @Default(false) bool hasVariations,
    @Default([]) List<String> tags,
    @Default([]) List<ProductVariation> variations,
    @Default([]) List<ProductAttribute> attributes,
    @Default([]) List<String> imageUrls, // Multiple product images
    DateTime? createdAt,
  }) = _EnhancedProduct;

  const EnhancedProduct._();

  factory EnhancedProduct.fromJson(Map<String, dynamic> json) => _$EnhancedProductFromJson(json);

  // Helper methods
  double get minPrice {
    if (!hasVariations || variations.isEmpty) return basePrice;
    return variations.map((v) => v.price).reduce((a, b) => a < b ? a : b);
  }

  double get maxPrice {
    if (!hasVariations || variations.isEmpty) return basePrice;
    return variations.map((v) => v.price).reduce((a, b) => a > b ? a : b);
  }

  int get totalStock {
    if (!hasVariations || variations.isEmpty) return baseStock;
    return variations.fold(0, (sum, v) => sum + v.stock);
  }

  bool get isInStock {
    if (!hasVariations || variations.isEmpty) return baseStock > 0;
    return variations.any((v) => v.stock > 0);
  }

  String get priceRange {
    if (!hasVariations || variations.isEmpty) {
      return '\$${basePrice.toStringAsFixed(2)}';
    }
    if (minPrice == maxPrice) {
      return '\$${minPrice.toStringAsFixed(2)}';
    }
    return '\$${minPrice.toStringAsFixed(2)} - \$${maxPrice.toStringAsFixed(2)}';
  }
}