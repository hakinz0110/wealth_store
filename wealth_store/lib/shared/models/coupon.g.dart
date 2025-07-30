// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CouponImpl _$$CouponImplFromJson(Map<String, dynamic> json) => _$CouponImpl(
      id: json['id'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      discountType: json['discount_type'] as String,
      discountValue: (json['discount_value'] as num).toDouble(),
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble(),
      maxUses: (json['max_uses'] as num?)?.toInt(),
      currentUses: (json['current_uses'] as num?)?.toInt() ?? 0,
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$CouponImplToJson(_$CouponImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'description': instance.description,
      'discount_type': instance.discountType,
      'discount_value': instance.discountValue,
      'min_order_amount': instance.minOrderAmount,
      'max_uses': instance.maxUses,
      'current_uses': instance.currentUses,
      'expires_at': instance.expiresAt?.toIso8601String(),
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_$CouponFormDataImpl _$$CouponFormDataImplFromJson(Map<String, dynamic> json) =>
    _$CouponFormDataImpl(
      code: json['code'] as String,
      description: json['description'] as String?,
      discountType: json['discount_type'] as String,
      discountValue: (json['discount_value'] as num).toDouble(),
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble(),
      maxUses: (json['max_uses'] as num?)?.toInt(),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$$CouponFormDataImplToJson(
        _$CouponFormDataImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'description': instance.description,
      'discount_type': instance.discountType,
      'discount_value': instance.discountValue,
      'min_order_amount': instance.minOrderAmount,
      'max_uses': instance.maxUses,
      'expires_at': instance.expiresAt?.toIso8601String(),
      'is_active': instance.isActive,
    };
