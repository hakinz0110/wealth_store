import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required int id,
    required String name,
    required String description,
    required double price,
    @JsonKey(name: 'category_id') required int categoryId,
    @JsonKey(name: 'brand_id') int? brandId,
    @JsonKey(name: 'image_urls') List<String>? imageUrls,
    Map<String, dynamic>? specifications,
    @Default(0) int stock,
    @Default(0.0) double rating,
    @JsonKey(name: 'review_count') @Default(0) int reviewCount,
    @JsonKey(name: 'is_featured') @Default(false) bool isFeatured,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @Default([]) List<String> tags,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Product;
  
  const Product._();
  
  // Computed property for backward compatibility
  String get imageUrl => imageUrls?.isNotEmpty == true ? imageUrls!.first : '';

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
} 