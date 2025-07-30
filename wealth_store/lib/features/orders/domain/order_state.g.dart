// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderStateImpl _$$OrderStateImplFromJson(Map<String, dynamic> json) =>
    _$OrderStateImpl(
      orders: (json['orders'] as List<dynamic>?)
              ?.map((e) => Order.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isLoading: json['isLoading'] as bool? ?? false,
      error: json['error'] as String?,
      selectedOrder: json['selectedOrder'] == null
          ? null
          : Order.fromJson(json['selectedOrder'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$OrderStateImplToJson(_$OrderStateImpl instance) =>
    <String, dynamic>{
      'orders': instance.orders,
      'isLoading': instance.isLoading,
      'error': instance.error,
      'selectedOrder': instance.selectedOrder,
    };
