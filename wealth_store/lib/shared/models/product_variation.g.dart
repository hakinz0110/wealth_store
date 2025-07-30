// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_variation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductVariationImpl _$$ProductVariationImplFromJson(
        Map<String, dynamic> json) =>
    _$ProductVariationImpl(
      id: (json['id'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      stock: (json['stock'] as num).toInt(),
      attributes: Map<String, String>.from(json['attributes'] as Map),
      imageUrl: json['imageUrl'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$ProductVariationImplToJson(
        _$ProductVariationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'name': instance.name,
      'price': instance.price,
      'stock': instance.stock,
      'attributes': instance.attributes,
      'imageUrl': instance.imageUrl,
      'isActive': instance.isActive,
    };

_$ProductAttributeImpl _$$ProductAttributeImplFromJson(
        Map<String, dynamic> json) =>
    _$ProductAttributeImpl(
      name: json['name'] as String,
      values:
          (json['values'] as List<dynamic>).map((e) => e as String).toList(),
      type: $enumDecodeNullable(_$AttributeTypeEnumMap, json['type']) ??
          AttributeType.text,
    );

Map<String, dynamic> _$$ProductAttributeImplToJson(
        _$ProductAttributeImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'values': instance.values,
      'type': _$AttributeTypeEnumMap[instance.type]!,
    };

const _$AttributeTypeEnumMap = {
  AttributeType.text: 'text',
  AttributeType.color: 'color',
  AttributeType.size: 'size',
  AttributeType.image: 'image',
};

_$EnhancedProductImpl _$$EnhancedProductImplFromJson(
        Map<String, dynamic> json) =>
    _$EnhancedProductImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      basePrice: (json['basePrice'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      categoryId: (json['categoryId'] as num).toInt(),
      baseStock: (json['baseStock'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      hasVariations: json['hasVariations'] as bool? ?? false,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      variations: (json['variations'] as List<dynamic>?)
              ?.map((e) => ProductVariation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      attributes: (json['attributes'] as List<dynamic>?)
              ?.map((e) => ProductAttribute.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$EnhancedProductImplToJson(
        _$EnhancedProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'basePrice': instance.basePrice,
      'imageUrl': instance.imageUrl,
      'categoryId': instance.categoryId,
      'baseStock': instance.baseStock,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'isFeatured': instance.isFeatured,
      'hasVariations': instance.hasVariations,
      'tags': instance.tags,
      'variations': instance.variations,
      'attributes': instance.attributes,
      'imageUrls': instance.imageUrls,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
