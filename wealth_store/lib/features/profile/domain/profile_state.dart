import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wealth_app/shared/models/address.dart';
import 'package:wealth_app/shared/models/customer.dart';

part 'profile_state.freezed.dart';
part 'profile_state.g.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    Customer? customer,
    @Default([]) List<Address> addresses,
    @Default(false) bool isLoading,
    String? error,
    @Default(false) bool isUpdating,
    @Default(false) bool isUploadingAvatar,
  }) = _ProfileState;

  factory ProfileState.fromJson(Map<String, dynamic> json) => _$ProfileStateFromJson(json);
} 