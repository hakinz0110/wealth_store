// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AppAuthState {
  User? get user => throw _privateConstructorUsedError;
  Customer? get customer => throw _privateConstructorUsedError;
  bool get isAuthenticated => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of AppAuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppAuthStateCopyWith<AppAuthState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppAuthStateCopyWith<$Res> {
  factory $AppAuthStateCopyWith(
          AppAuthState value, $Res Function(AppAuthState) then) =
      _$AppAuthStateCopyWithImpl<$Res, AppAuthState>;
  @useResult
  $Res call(
      {User? user,
      Customer? customer,
      bool isAuthenticated,
      bool isLoading,
      String? error});
}

/// @nodoc
class _$AppAuthStateCopyWithImpl<$Res, $Val extends AppAuthState>
    implements $AppAuthStateCopyWith<$Res> {
  _$AppAuthStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppAuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = freezed,
    Object? customer = freezed,
    Object? isAuthenticated = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
      customer: freezed == customer
          ? _value.customer
          : customer // ignore: cast_nullable_to_non_nullable
              as Customer?,
      isAuthenticated: null == isAuthenticated
          ? _value.isAuthenticated
          : isAuthenticated // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppAuthStateImplCopyWith<$Res>
    implements $AppAuthStateCopyWith<$Res> {
  factory _$$AppAuthStateImplCopyWith(
          _$AppAuthStateImpl value, $Res Function(_$AppAuthStateImpl) then) =
      __$$AppAuthStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {User? user,
      Customer? customer,
      bool isAuthenticated,
      bool isLoading,
      String? error});
}

/// @nodoc
class __$$AppAuthStateImplCopyWithImpl<$Res>
    extends _$AppAuthStateCopyWithImpl<$Res, _$AppAuthStateImpl>
    implements _$$AppAuthStateImplCopyWith<$Res> {
  __$$AppAuthStateImplCopyWithImpl(
      _$AppAuthStateImpl _value, $Res Function(_$AppAuthStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppAuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = freezed,
    Object? customer = freezed,
    Object? isAuthenticated = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$AppAuthStateImpl(
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
      customer: freezed == customer
          ? _value.customer
          : customer // ignore: cast_nullable_to_non_nullable
              as Customer?,
      isAuthenticated: null == isAuthenticated
          ? _value.isAuthenticated
          : isAuthenticated // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$AppAuthStateImpl extends _AppAuthState {
  const _$AppAuthStateImpl(
      {this.user,
      this.customer,
      this.isAuthenticated = false,
      this.isLoading = false,
      this.error})
      : super._();

  @override
  final User? user;
  @override
  final Customer? customer;
  @override
  @JsonKey()
  final bool isAuthenticated;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'AppAuthState(user: $user, customer: $customer, isAuthenticated: $isAuthenticated, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppAuthStateImpl &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.isAuthenticated, isAuthenticated) ||
                other.isAuthenticated == isAuthenticated) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, user, customer, isAuthenticated, isLoading, error);

  /// Create a copy of AppAuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppAuthStateImplCopyWith<_$AppAuthStateImpl> get copyWith =>
      __$$AppAuthStateImplCopyWithImpl<_$AppAuthStateImpl>(this, _$identity);
}

abstract class _AppAuthState extends AppAuthState {
  const factory _AppAuthState(
      {final User? user,
      final Customer? customer,
      final bool isAuthenticated,
      final bool isLoading,
      final String? error}) = _$AppAuthStateImpl;
  const _AppAuthState._() : super._();

  @override
  User? get user;
  @override
  Customer? get customer;
  @override
  bool get isAuthenticated;
  @override
  bool get isLoading;
  @override
  String? get error;

  /// Create a copy of AppAuthState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppAuthStateImplCopyWith<_$AppAuthStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
