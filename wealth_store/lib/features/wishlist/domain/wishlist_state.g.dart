// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WishlistStateImpl _$$WishlistStateImplFromJson(Map<String, dynamic> json) =>
    _$WishlistStateImpl(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => WishlistItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isLoading: json['isLoading'] as bool? ?? false,
      error: json['error'] as String?,
      productWishlistStatus:
          (json['productWishlistStatus'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(int.parse(k), e as bool),
              ) ??
              const {},
    );

Map<String, dynamic> _$$WishlistStateImplToJson(_$WishlistStateImpl instance) =>
    <String, dynamic>{
      'items': instance.items,
      'isLoading': instance.isLoading,
      'error': instance.error,
      'productWishlistStatus': instance.productWishlistStatus
          .map((k, e) => MapEntry(k.toString(), e)),
    };
