// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationStateImpl _$$NotificationStateImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationStateImpl(
      notifications: (json['notifications'] as List<dynamic>?)
              ?.map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isLoading: json['isLoading'] as bool? ?? false,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$$NotificationStateImplToJson(
        _$NotificationStateImpl instance) =>
    <String, dynamic>{
      'notifications': instance.notifications,
      'unreadCount': instance.unreadCount,
      'isLoading': instance.isLoading,
      'error': instance.error,
    };
