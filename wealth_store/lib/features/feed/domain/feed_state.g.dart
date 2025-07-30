// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FeedStateImpl _$$FeedStateImplFromJson(Map<String, dynamic> json) =>
    _$FeedStateImpl(
      promotions: (json['promotions'] as List<dynamic>?)
              ?.map((e) => Promotion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isLoading: json['isLoading'] as bool? ?? false,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$$FeedStateImplToJson(_$FeedStateImpl instance) =>
    <String, dynamic>{
      'promotions': instance.promotions,
      'isLoading': instance.isLoading,
      'error': instance.error,
    };
