import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wealth_app/shared/models/promotion.dart';

part 'feed_state.freezed.dart';
part 'feed_state.g.dart';

@freezed
class FeedState with _$FeedState {
  const factory FeedState({
    @Default([]) List<Promotion> promotions,
    @Default(false) bool isLoading,
    String? error,
  }) = _FeedState;

  factory FeedState.fromJson(Map<String, dynamic> json) => _$FeedStateFromJson(json);
} 