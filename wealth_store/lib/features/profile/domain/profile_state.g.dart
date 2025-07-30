// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileStateImpl _$$ProfileStateImplFromJson(Map<String, dynamic> json) =>
    _$ProfileStateImpl(
      customer: json['customer'] == null
          ? null
          : Customer.fromJson(json['customer'] as Map<String, dynamic>),
      addresses: (json['addresses'] as List<dynamic>?)
              ?.map((e) => Address.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isLoading: json['isLoading'] as bool? ?? false,
      error: json['error'] as String?,
      isUpdating: json['isUpdating'] as bool? ?? false,
      isUploadingAvatar: json['isUploadingAvatar'] as bool? ?? false,
    );

Map<String, dynamic> _$$ProfileStateImplToJson(_$ProfileStateImpl instance) =>
    <String, dynamic>{
      'customer': instance.customer,
      'addresses': instance.addresses,
      'isLoading': instance.isLoading,
      'error': instance.error,
      'isUpdating': instance.isUpdating,
      'isUploadingAvatar': instance.isUploadingAvatar,
    };
