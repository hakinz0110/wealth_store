// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coupon.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Coupon _$CouponFromJson(Map<String, dynamic> json) {
  return _Coupon.fromJson(json);
}

/// @nodoc
mixin _$Coupon {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'discount_type')
  String get discountType =>
      throw _privateConstructorUsedError; // 'percentage' or 'fixed'
  @JsonKey(name: 'discount_value')
  double get discountValue => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_order_amount')
  double? get minOrderAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_uses')
  int? get maxUses => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_uses')
  int get currentUses => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Coupon to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Coupon
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CouponCopyWith<Coupon> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CouponCopyWith<$Res> {
  factory $CouponCopyWith(Coupon value, $Res Function(Coupon) then) =
      _$CouponCopyWithImpl<$Res, Coupon>;
  @useResult
  $Res call(
      {String id,
      String code,
      String? description,
      @JsonKey(name: 'discount_type') String discountType,
      @JsonKey(name: 'discount_value') double discountValue,
      @JsonKey(name: 'min_order_amount') double? minOrderAmount,
      @JsonKey(name: 'max_uses') int? maxUses,
      @JsonKey(name: 'current_uses') int currentUses,
      @JsonKey(name: 'expires_at') DateTime? expiresAt,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$CouponCopyWithImpl<$Res, $Val extends Coupon>
    implements $CouponCopyWith<$Res> {
  _$CouponCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Coupon
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? description = freezed,
    Object? discountType = null,
    Object? discountValue = null,
    Object? minOrderAmount = freezed,
    Object? maxUses = freezed,
    Object? currentUses = null,
    Object? expiresAt = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      discountType: null == discountType
          ? _value.discountType
          : discountType // ignore: cast_nullable_to_non_nullable
              as String,
      discountValue: null == discountValue
          ? _value.discountValue
          : discountValue // ignore: cast_nullable_to_non_nullable
              as double,
      minOrderAmount: freezed == minOrderAmount
          ? _value.minOrderAmount
          : minOrderAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      maxUses: freezed == maxUses
          ? _value.maxUses
          : maxUses // ignore: cast_nullable_to_non_nullable
              as int?,
      currentUses: null == currentUses
          ? _value.currentUses
          : currentUses // ignore: cast_nullable_to_non_nullable
              as int,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CouponImplCopyWith<$Res> implements $CouponCopyWith<$Res> {
  factory _$$CouponImplCopyWith(
          _$CouponImpl value, $Res Function(_$CouponImpl) then) =
      __$$CouponImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String code,
      String? description,
      @JsonKey(name: 'discount_type') String discountType,
      @JsonKey(name: 'discount_value') double discountValue,
      @JsonKey(name: 'min_order_amount') double? minOrderAmount,
      @JsonKey(name: 'max_uses') int? maxUses,
      @JsonKey(name: 'current_uses') int currentUses,
      @JsonKey(name: 'expires_at') DateTime? expiresAt,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$CouponImplCopyWithImpl<$Res>
    extends _$CouponCopyWithImpl<$Res, _$CouponImpl>
    implements _$$CouponImplCopyWith<$Res> {
  __$$CouponImplCopyWithImpl(
      _$CouponImpl _value, $Res Function(_$CouponImpl) _then)
      : super(_value, _then);

  /// Create a copy of Coupon
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? description = freezed,
    Object? discountType = null,
    Object? discountValue = null,
    Object? minOrderAmount = freezed,
    Object? maxUses = freezed,
    Object? currentUses = null,
    Object? expiresAt = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$CouponImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      discountType: null == discountType
          ? _value.discountType
          : discountType // ignore: cast_nullable_to_non_nullable
              as String,
      discountValue: null == discountValue
          ? _value.discountValue
          : discountValue // ignore: cast_nullable_to_non_nullable
              as double,
      minOrderAmount: freezed == minOrderAmount
          ? _value.minOrderAmount
          : minOrderAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      maxUses: freezed == maxUses
          ? _value.maxUses
          : maxUses // ignore: cast_nullable_to_non_nullable
              as int?,
      currentUses: null == currentUses
          ? _value.currentUses
          : currentUses // ignore: cast_nullable_to_non_nullable
              as int,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CouponImpl implements _Coupon {
  const _$CouponImpl(
      {required this.id,
      required this.code,
      this.description,
      @JsonKey(name: 'discount_type') required this.discountType,
      @JsonKey(name: 'discount_value') required this.discountValue,
      @JsonKey(name: 'min_order_amount') this.minOrderAmount,
      @JsonKey(name: 'max_uses') this.maxUses,
      @JsonKey(name: 'current_uses') this.currentUses = 0,
      @JsonKey(name: 'expires_at') this.expiresAt,
      @JsonKey(name: 'is_active') this.isActive = true,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt});

  factory _$CouponImpl.fromJson(Map<String, dynamic> json) =>
      _$$CouponImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final String? description;
  @override
  @JsonKey(name: 'discount_type')
  final String discountType;
// 'percentage' or 'fixed'
  @override
  @JsonKey(name: 'discount_value')
  final double discountValue;
  @override
  @JsonKey(name: 'min_order_amount')
  final double? minOrderAmount;
  @override
  @JsonKey(name: 'max_uses')
  final int? maxUses;
  @override
  @JsonKey(name: 'current_uses')
  final int currentUses;
  @override
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Coupon(id: $id, code: $code, description: $description, discountType: $discountType, discountValue: $discountValue, minOrderAmount: $minOrderAmount, maxUses: $maxUses, currentUses: $currentUses, expiresAt: $expiresAt, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CouponImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.discountType, discountType) ||
                other.discountType == discountType) &&
            (identical(other.discountValue, discountValue) ||
                other.discountValue == discountValue) &&
            (identical(other.minOrderAmount, minOrderAmount) ||
                other.minOrderAmount == minOrderAmount) &&
            (identical(other.maxUses, maxUses) || other.maxUses == maxUses) &&
            (identical(other.currentUses, currentUses) ||
                other.currentUses == currentUses) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      code,
      description,
      discountType,
      discountValue,
      minOrderAmount,
      maxUses,
      currentUses,
      expiresAt,
      isActive,
      createdAt,
      updatedAt);

  /// Create a copy of Coupon
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CouponImplCopyWith<_$CouponImpl> get copyWith =>
      __$$CouponImplCopyWithImpl<_$CouponImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CouponImplToJson(
      this,
    );
  }
}

abstract class _Coupon implements Coupon {
  const factory _Coupon(
      {required final String id,
      required final String code,
      final String? description,
      @JsonKey(name: 'discount_type') required final String discountType,
      @JsonKey(name: 'discount_value') required final double discountValue,
      @JsonKey(name: 'min_order_amount') final double? minOrderAmount,
      @JsonKey(name: 'max_uses') final int? maxUses,
      @JsonKey(name: 'current_uses') final int currentUses,
      @JsonKey(name: 'expires_at') final DateTime? expiresAt,
      @JsonKey(name: 'is_active') final bool isActive,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at') final DateTime? updatedAt}) = _$CouponImpl;

  factory _Coupon.fromJson(Map<String, dynamic> json) = _$CouponImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  String? get description;
  @override
  @JsonKey(name: 'discount_type')
  String get discountType; // 'percentage' or 'fixed'
  @override
  @JsonKey(name: 'discount_value')
  double get discountValue;
  @override
  @JsonKey(name: 'min_order_amount')
  double? get minOrderAmount;
  @override
  @JsonKey(name: 'max_uses')
  int? get maxUses;
  @override
  @JsonKey(name: 'current_uses')
  int get currentUses;
  @override
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of Coupon
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CouponImplCopyWith<_$CouponImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CouponFormData _$CouponFormDataFromJson(Map<String, dynamic> json) {
  return _CouponFormData.fromJson(json);
}

/// @nodoc
mixin _$CouponFormData {
  String get code => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'discount_type')
  String get discountType => throw _privateConstructorUsedError;
  @JsonKey(name: 'discount_value')
  double get discountValue => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_order_amount')
  double? get minOrderAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_uses')
  int? get maxUses => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this CouponFormData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CouponFormData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CouponFormDataCopyWith<CouponFormData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CouponFormDataCopyWith<$Res> {
  factory $CouponFormDataCopyWith(
          CouponFormData value, $Res Function(CouponFormData) then) =
      _$CouponFormDataCopyWithImpl<$Res, CouponFormData>;
  @useResult
  $Res call(
      {String code,
      String? description,
      @JsonKey(name: 'discount_type') String discountType,
      @JsonKey(name: 'discount_value') double discountValue,
      @JsonKey(name: 'min_order_amount') double? minOrderAmount,
      @JsonKey(name: 'max_uses') int? maxUses,
      @JsonKey(name: 'expires_at') DateTime? expiresAt,
      @JsonKey(name: 'is_active') bool isActive});
}

/// @nodoc
class _$CouponFormDataCopyWithImpl<$Res, $Val extends CouponFormData>
    implements $CouponFormDataCopyWith<$Res> {
  _$CouponFormDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CouponFormData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? description = freezed,
    Object? discountType = null,
    Object? discountValue = null,
    Object? minOrderAmount = freezed,
    Object? maxUses = freezed,
    Object? expiresAt = freezed,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      discountType: null == discountType
          ? _value.discountType
          : discountType // ignore: cast_nullable_to_non_nullable
              as String,
      discountValue: null == discountValue
          ? _value.discountValue
          : discountValue // ignore: cast_nullable_to_non_nullable
              as double,
      minOrderAmount: freezed == minOrderAmount
          ? _value.minOrderAmount
          : minOrderAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      maxUses: freezed == maxUses
          ? _value.maxUses
          : maxUses // ignore: cast_nullable_to_non_nullable
              as int?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CouponFormDataImplCopyWith<$Res>
    implements $CouponFormDataCopyWith<$Res> {
  factory _$$CouponFormDataImplCopyWith(_$CouponFormDataImpl value,
          $Res Function(_$CouponFormDataImpl) then) =
      __$$CouponFormDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String code,
      String? description,
      @JsonKey(name: 'discount_type') String discountType,
      @JsonKey(name: 'discount_value') double discountValue,
      @JsonKey(name: 'min_order_amount') double? minOrderAmount,
      @JsonKey(name: 'max_uses') int? maxUses,
      @JsonKey(name: 'expires_at') DateTime? expiresAt,
      @JsonKey(name: 'is_active') bool isActive});
}

/// @nodoc
class __$$CouponFormDataImplCopyWithImpl<$Res>
    extends _$CouponFormDataCopyWithImpl<$Res, _$CouponFormDataImpl>
    implements _$$CouponFormDataImplCopyWith<$Res> {
  __$$CouponFormDataImplCopyWithImpl(
      _$CouponFormDataImpl _value, $Res Function(_$CouponFormDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of CouponFormData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? description = freezed,
    Object? discountType = null,
    Object? discountValue = null,
    Object? minOrderAmount = freezed,
    Object? maxUses = freezed,
    Object? expiresAt = freezed,
    Object? isActive = null,
  }) {
    return _then(_$CouponFormDataImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      discountType: null == discountType
          ? _value.discountType
          : discountType // ignore: cast_nullable_to_non_nullable
              as String,
      discountValue: null == discountValue
          ? _value.discountValue
          : discountValue // ignore: cast_nullable_to_non_nullable
              as double,
      minOrderAmount: freezed == minOrderAmount
          ? _value.minOrderAmount
          : minOrderAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      maxUses: freezed == maxUses
          ? _value.maxUses
          : maxUses // ignore: cast_nullable_to_non_nullable
              as int?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CouponFormDataImpl implements _CouponFormData {
  const _$CouponFormDataImpl(
      {required this.code,
      this.description,
      @JsonKey(name: 'discount_type') required this.discountType,
      @JsonKey(name: 'discount_value') required this.discountValue,
      @JsonKey(name: 'min_order_amount') this.minOrderAmount,
      @JsonKey(name: 'max_uses') this.maxUses,
      @JsonKey(name: 'expires_at') this.expiresAt,
      @JsonKey(name: 'is_active') this.isActive = true});

  factory _$CouponFormDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$CouponFormDataImplFromJson(json);

  @override
  final String code;
  @override
  final String? description;
  @override
  @JsonKey(name: 'discount_type')
  final String discountType;
  @override
  @JsonKey(name: 'discount_value')
  final double discountValue;
  @override
  @JsonKey(name: 'min_order_amount')
  final double? minOrderAmount;
  @override
  @JsonKey(name: 'max_uses')
  final int? maxUses;
  @override
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;

  @override
  String toString() {
    return 'CouponFormData(code: $code, description: $description, discountType: $discountType, discountValue: $discountValue, minOrderAmount: $minOrderAmount, maxUses: $maxUses, expiresAt: $expiresAt, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CouponFormDataImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.discountType, discountType) ||
                other.discountType == discountType) &&
            (identical(other.discountValue, discountValue) ||
                other.discountValue == discountValue) &&
            (identical(other.minOrderAmount, minOrderAmount) ||
                other.minOrderAmount == minOrderAmount) &&
            (identical(other.maxUses, maxUses) || other.maxUses == maxUses) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, code, description, discountType,
      discountValue, minOrderAmount, maxUses, expiresAt, isActive);

  /// Create a copy of CouponFormData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CouponFormDataImplCopyWith<_$CouponFormDataImpl> get copyWith =>
      __$$CouponFormDataImplCopyWithImpl<_$CouponFormDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CouponFormDataImplToJson(
      this,
    );
  }
}

abstract class _CouponFormData implements CouponFormData {
  const factory _CouponFormData(
      {required final String code,
      final String? description,
      @JsonKey(name: 'discount_type') required final String discountType,
      @JsonKey(name: 'discount_value') required final double discountValue,
      @JsonKey(name: 'min_order_amount') final double? minOrderAmount,
      @JsonKey(name: 'max_uses') final int? maxUses,
      @JsonKey(name: 'expires_at') final DateTime? expiresAt,
      @JsonKey(name: 'is_active') final bool isActive}) = _$CouponFormDataImpl;

  factory _CouponFormData.fromJson(Map<String, dynamic> json) =
      _$CouponFormDataImpl.fromJson;

  @override
  String get code;
  @override
  String? get description;
  @override
  @JsonKey(name: 'discount_type')
  String get discountType;
  @override
  @JsonKey(name: 'discount_value')
  double get discountValue;
  @override
  @JsonKey(name: 'min_order_amount')
  double? get minOrderAmount;
  @override
  @JsonKey(name: 'max_uses')
  int? get maxUses;
  @override
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;

  /// Create a copy of CouponFormData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CouponFormDataImplCopyWith<_$CouponFormDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CouponValidationResult {
  bool get isValid => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  double? get discountAmount => throw _privateConstructorUsedError;

  /// Create a copy of CouponValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CouponValidationResultCopyWith<CouponValidationResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CouponValidationResultCopyWith<$Res> {
  factory $CouponValidationResultCopyWith(CouponValidationResult value,
          $Res Function(CouponValidationResult) then) =
      _$CouponValidationResultCopyWithImpl<$Res, CouponValidationResult>;
  @useResult
  $Res call({bool isValid, String? errorMessage, double? discountAmount});
}

/// @nodoc
class _$CouponValidationResultCopyWithImpl<$Res,
        $Val extends CouponValidationResult>
    implements $CouponValidationResultCopyWith<$Res> {
  _$CouponValidationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CouponValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isValid = null,
    Object? errorMessage = freezed,
    Object? discountAmount = freezed,
  }) {
    return _then(_value.copyWith(
      isValid: null == isValid
          ? _value.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      discountAmount: freezed == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CouponValidationResultImplCopyWith<$Res>
    implements $CouponValidationResultCopyWith<$Res> {
  factory _$$CouponValidationResultImplCopyWith(
          _$CouponValidationResultImpl value,
          $Res Function(_$CouponValidationResultImpl) then) =
      __$$CouponValidationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isValid, String? errorMessage, double? discountAmount});
}

/// @nodoc
class __$$CouponValidationResultImplCopyWithImpl<$Res>
    extends _$CouponValidationResultCopyWithImpl<$Res,
        _$CouponValidationResultImpl>
    implements _$$CouponValidationResultImplCopyWith<$Res> {
  __$$CouponValidationResultImplCopyWithImpl(
      _$CouponValidationResultImpl _value,
      $Res Function(_$CouponValidationResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of CouponValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isValid = null,
    Object? errorMessage = freezed,
    Object? discountAmount = freezed,
  }) {
    return _then(_$CouponValidationResultImpl(
      isValid: null == isValid
          ? _value.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      discountAmount: freezed == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc

class _$CouponValidationResultImpl implements _CouponValidationResult {
  const _$CouponValidationResultImpl(
      {required this.isValid, this.errorMessage, this.discountAmount});

  @override
  final bool isValid;
  @override
  final String? errorMessage;
  @override
  final double? discountAmount;

  @override
  String toString() {
    return 'CouponValidationResult(isValid: $isValid, errorMessage: $errorMessage, discountAmount: $discountAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CouponValidationResultImpl &&
            (identical(other.isValid, isValid) || other.isValid == isValid) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isValid, errorMessage, discountAmount);

  /// Create a copy of CouponValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CouponValidationResultImplCopyWith<_$CouponValidationResultImpl>
      get copyWith => __$$CouponValidationResultImplCopyWithImpl<
          _$CouponValidationResultImpl>(this, _$identity);
}

abstract class _CouponValidationResult implements CouponValidationResult {
  const factory _CouponValidationResult(
      {required final bool isValid,
      final String? errorMessage,
      final double? discountAmount}) = _$CouponValidationResultImpl;

  @override
  bool get isValid;
  @override
  String? get errorMessage;
  @override
  double? get discountAmount;

  /// Create a copy of CouponValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CouponValidationResultImplCopyWith<_$CouponValidationResultImpl>
      get copyWith => throw _privateConstructorUsedError;
}
