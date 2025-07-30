import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wealth_app/shared/models/app_notification.dart';

part 'notification_state.freezed.dart';
part 'notification_state.g.dart';

@freezed
class NotificationState with _$NotificationState {
  const factory NotificationState({
    @Default([]) List<AppNotification> notifications,
    @Default(0) int unreadCount,
    @Default(false) bool isLoading,
    String? error,
  }) = _NotificationState;

  factory NotificationState.fromJson(Map<String, dynamic> json) => _$NotificationStateFromJson(json);
} 