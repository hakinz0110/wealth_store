// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wishlist_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WishlistState _$WishlistStateFromJson(Map<String, dynamic> json) {
  return _WishlistState.fromJson(json);
}

/// @nodoc
mixin _$WishlistState {
  List<WishlistItem> get items => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  Map<int, bool> get productWishlistStatus =>
      throw _privateConstructorUsedError;

  /// Serializes this WishlistState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WishlistState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WishlistStateCopyWith<WishlistState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WishlistStateCopyWith<$Res> {
  factory $WishlistStateCopyWith(
          WishlistState value, $Res Function(WishlistState) then) =
      _$WishlistStateCopyWithImpl<$Res, WishlistState>;
  @useResult
  $Res call(
      {List<WishlistItem> items,
      bool isLoading,
      String? error,
      Map<int, bool> productWishlistStatus});
}

/// @nodoc
class _$WishlistStateCopyWithImpl<$Res, $Val extends WishlistState>
    implements $WishlistStateCopyWith<$Res> {
  _$WishlistStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WishlistState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? productWishlistStatus = null,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<WishlistItem>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      productWishlistStatus: null == productWishlistStatus
          ? _value.productWishlistStatus
          : productWishlistStatus // ignore: cast_nullable_to_non_nullable
              as Map<int, bool>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WishlistStateImplCopyWith<$Res>
    implements $WishlistStateCopyWith<$Res> {
  factory _$$WishlistStateImplCopyWith(
          _$WishlistStateImpl value, $Res Function(_$WishlistStateImpl) then) =
      __$$WishlistStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<WishlistItem> items,
      bool isLoading,
      String? error,
      Map<int, bool> productWishlistStatus});
}

/// @nodoc
class __$$WishlistStateImplCopyWithImpl<$Res>
    extends _$WishlistStateCopyWithImpl<$Res, _$WishlistStateImpl>
    implements _$$WishlistStateImplCopyWith<$Res> {
  __$$WishlistStateImplCopyWithImpl(
      _$WishlistStateImpl _value, $Res Function(_$WishlistStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of WishlistState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? productWishlistStatus = null,
  }) {
    return _then(_$WishlistStateImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<WishlistItem>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      productWishlistStatus: null == productWishlistStatus
          ? _value._productWishlistStatus
          : productWishlistStatus // ignore: cast_nullable_to_non_nullable
              as Map<int, bool>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WishlistStateImpl extends _WishlistState {
  const _$WishlistStateImpl(
      {final List<WishlistItem> items = const [],
      this.isLoading = false,
      this.error,
      final Map<int, bool> productWishlistStatus = const {}})
      : _items = items,
        _productWishlistStatus = productWishlistStatus,
        super._();

  factory _$WishlistStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$WishlistStateImplFromJson(json);

  final List<WishlistItem> _items;
  @override
  @JsonKey()
  List<WishlistItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  final Map<int, bool> _productWishlistStatus;
  @override
  @JsonKey()
  Map<int, bool> get productWishlistStatus {
    if (_productWishlistStatus is EqualUnmodifiableMapView)
      return _productWishlistStatus;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_productWishlistStatus);
  }

  @override
  String toString() {
    return 'WishlistState(items: $items, isLoading: $isLoading, error: $error, productWishlistStatus: $productWishlistStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WishlistStateImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality()
                .equals(other._productWishlistStatus, _productWishlistStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_items),
      isLoading,
      error,
      const DeepCollectionEquality().hash(_productWishlistStatus));

  /// Create a copy of WishlistState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WishlistStateImplCopyWith<_$WishlistStateImpl> get copyWith =>
      __$$WishlistStateImplCopyWithImpl<_$WishlistStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WishlistStateImplToJson(
      this,
    );
  }
}

abstract class _WishlistState extends WishlistState {
  const factory _WishlistState(
      {final List<WishlistItem> items,
      final bool isLoading,
      final String? error,
      final Map<int, bool> productWishlistStatus}) = _$WishlistStateImpl;
  const _WishlistState._() : super._();

  factory _WishlistState.fromJson(Map<String, dynamic> json) =
      _$WishlistStateImpl.fromJson;

  @override
  List<WishlistItem> get items;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  Map<int, bool> get productWishlistStatus;

  /// Create a copy of WishlistState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WishlistStateImplCopyWith<_$WishlistStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
