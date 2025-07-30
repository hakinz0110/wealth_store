// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WishlistItemImpl _$$WishlistItemImplFromJson(Map<String, dynamic> json) =>
    _$WishlistItemImpl(
      id: (json['id'] as num).toInt(),
      userId: json['userId'] as String,
      productId: (json['productId'] as num).toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$WishlistItemImplToJson(_$WishlistItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'productId': instance.productId,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
