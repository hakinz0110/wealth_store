// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PromotionImpl _$$PromotionImplFromJson(Map<String, dynamic> json) =>
    _$PromotionImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      imageUrl: json['imageUrl'] as String?,
      productId: (json['productId'] as num?)?.toInt(),
      categoryId: (json['categoryId'] as num?)?.toInt(),
      couponCode: json['couponCode'] as String?,
      discountPercent: (json['discountPercent'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool? ?? false,
    );

Map<String, dynamic> _$$PromotionImplToJson(_$PromotionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'imageUrl': instance.imageUrl,
      'productId': instance.productId,
      'categoryId': instance.categoryId,
      'couponCode': instance.couponCode,
      'discountPercent': instance.discountPercent,
      'isActive': instance.isActive,
    };
