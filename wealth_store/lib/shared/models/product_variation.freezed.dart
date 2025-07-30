// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_variation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProductVariation _$ProductVariationFromJson(Map<String, dynamic> json) {
  return _ProductVariation.fromJson(json);
}

/// @nodoc
mixin _$ProductVariation {
  int get id => throw _privateConstructorUsedError;
  int get productId => throw _privateConstructorUsedError;
  String get name =>
      throw _privateConstructorUsedError; // e.g., "Red - Size 42"
  double get price => throw _privateConstructorUsedError;
  int get stock => throw _privateConstructorUsedError;
  Map<String, String> get attributes =>
      throw _privateConstructorUsedError; // e.g., {"color": "red", "size": "42"}
  String get imageUrl => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this ProductVariation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductVariation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductVariationCopyWith<ProductVariation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductVariationCopyWith<$Res> {
  factory $ProductVariationCopyWith(
          ProductVariation value, $Res Function(ProductVariation) then) =
      _$ProductVariationCopyWithImpl<$Res, ProductVariation>;
  @useResult
  $Res call(
      {int id,
      int productId,
      String name,
      double price,
      int stock,
      Map<String, String> attributes,
      String imageUrl,
      bool isActive});
}

/// @nodoc
class _$ProductVariationCopyWithImpl<$Res, $Val extends ProductVariation>
    implements $ProductVariationCopyWith<$Res> {
  _$ProductVariationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductVariation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? name = null,
    Object? price = null,
    Object? stock = null,
    Object? attributes = null,
    Object? imageUrl = null,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      stock: null == stock
          ? _value.stock
          : stock // ignore: cast_nullable_to_non_nullable
              as int,
      attributes: null == attributes
          ? _value.attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProductVariationImplCopyWith<$Res>
    implements $ProductVariationCopyWith<$Res> {
  factory _$$ProductVariationImplCopyWith(_$ProductVariationImpl value,
          $Res Function(_$ProductVariationImpl) then) =
      __$$ProductVariationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int productId,
      String name,
      double price,
      int stock,
      Map<String, String> attributes,
      String imageUrl,
      bool isActive});
}

/// @nodoc
class __$$ProductVariationImplCopyWithImpl<$Res>
    extends _$ProductVariationCopyWithImpl<$Res, _$ProductVariationImpl>
    implements _$$ProductVariationImplCopyWith<$Res> {
  __$$ProductVariationImplCopyWithImpl(_$ProductVariationImpl _value,
      $Res Function(_$ProductVariationImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductVariation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? name = null,
    Object? price = null,
    Object? stock = null,
    Object? attributes = null,
    Object? imageUrl = null,
    Object? isActive = null,
  }) {
    return _then(_$ProductVariationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      stock: null == stock
          ? _value.stock
          : stock // ignore: cast_nullable_to_non_nullable
              as int,
      attributes: null == attributes
          ? _value._attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductVariationImpl implements _ProductVariation {
  const _$ProductVariationImpl(
      {required this.id,
      required this.productId,
      required this.name,
      required this.price,
      required this.stock,
      required final Map<String, String> attributes,
      this.imageUrl = '',
      this.isActive = true})
      : _attributes = attributes;

  factory _$ProductVariationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductVariationImplFromJson(json);

  @override
  final int id;
  @override
  final int productId;
  @override
  final String name;
// e.g., "Red - Size 42"
  @override
  final double price;
  @override
  final int stock;
  final Map<String, String> _attributes;
  @override
  Map<String, String> get attributes {
    if (_attributes is EqualUnmodifiableMapView) return _attributes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_attributes);
  }

// e.g., {"color": "red", "size": "42"}
  @override
  @JsonKey()
  final String imageUrl;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'ProductVariation(id: $id, productId: $productId, name: $name, price: $price, stock: $stock, attributes: $attributes, imageUrl: $imageUrl, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductVariationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.stock, stock) || other.stock == stock) &&
            const DeepCollectionEquality()
                .equals(other._attributes, _attributes) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      productId,
      name,
      price,
      stock,
      const DeepCollectionEquality().hash(_attributes),
      imageUrl,
      isActive);

  /// Create a copy of ProductVariation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductVariationImplCopyWith<_$ProductVariationImpl> get copyWith =>
      __$$ProductVariationImplCopyWithImpl<_$ProductVariationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductVariationImplToJson(
      this,
    );
  }
}

abstract class _ProductVariation implements ProductVariation {
  const factory _ProductVariation(
      {required final int id,
      required final int productId,
      required final String name,
      required final double price,
      required final int stock,
      required final Map<String, String> attributes,
      final String imageUrl,
      final bool isActive}) = _$ProductVariationImpl;

  factory _ProductVariation.fromJson(Map<String, dynamic> json) =
      _$ProductVariationImpl.fromJson;

  @override
  int get id;
  @override
  int get productId;
  @override
  String get name; // e.g., "Red - Size 42"
  @override
  double get price;
  @override
  int get stock;
  @override
  Map<String, String> get attributes; // e.g., {"color": "red", "size": "42"}
  @override
  String get imageUrl;
  @override
  bool get isActive;

  /// Create a copy of ProductVariation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductVariationImplCopyWith<_$ProductVariationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProductAttribute _$ProductAttributeFromJson(Map<String, dynamic> json) {
  return _ProductAttribute.fromJson(json);
}

/// @nodoc
mixin _$ProductAttribute {
  String get name =>
      throw _privateConstructorUsedError; // e.g., "Color", "Size"
  List<String> get values =>
      throw _privateConstructorUsedError; // e.g., ["Red", "Blue", "Green"]
  AttributeType get type => throw _privateConstructorUsedError;

  /// Serializes this ProductAttribute to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductAttribute
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductAttributeCopyWith<ProductAttribute> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductAttributeCopyWith<$Res> {
  factory $ProductAttributeCopyWith(
          ProductAttribute value, $Res Function(ProductAttribute) then) =
      _$ProductAttributeCopyWithImpl<$Res, ProductAttribute>;
  @useResult
  $Res call({String name, List<String> values, AttributeType type});
}

/// @nodoc
class _$ProductAttributeCopyWithImpl<$Res, $Val extends ProductAttribute>
    implements $ProductAttributeCopyWith<$Res> {
  _$ProductAttributeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductAttribute
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? values = null,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      values: null == values
          ? _value.values
          : values // ignore: cast_nullable_to_non_nullable
              as List<String>,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AttributeType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProductAttributeImplCopyWith<$Res>
    implements $ProductAttributeCopyWith<$Res> {
  factory _$$ProductAttributeImplCopyWith(_$ProductAttributeImpl value,
          $Res Function(_$ProductAttributeImpl) then) =
      __$$ProductAttributeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, List<String> values, AttributeType type});
}

/// @nodoc
class __$$ProductAttributeImplCopyWithImpl<$Res>
    extends _$ProductAttributeCopyWithImpl<$Res, _$ProductAttributeImpl>
    implements _$$ProductAttributeImplCopyWith<$Res> {
  __$$ProductAttributeImplCopyWithImpl(_$ProductAttributeImpl _value,
      $Res Function(_$ProductAttributeImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductAttribute
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? values = null,
    Object? type = null,
  }) {
    return _then(_$ProductAttributeImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      values: null == values
          ? _value._values
          : values // ignore: cast_nullable_to_non_nullable
              as List<String>,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AttributeType,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductAttributeImpl implements _ProductAttribute {
  const _$ProductAttributeImpl(
      {required this.name,
      required final List<String> values,
      this.type = AttributeType.text})
      : _values = values;

  factory _$ProductAttributeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductAttributeImplFromJson(json);

  @override
  final String name;
// e.g., "Color", "Size"
  final List<String> _values;
// e.g., "Color", "Size"
  @override
  List<String> get values {
    if (_values is EqualUnmodifiableListView) return _values;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_values);
  }

// e.g., ["Red", "Blue", "Green"]
  @override
  @JsonKey()
  final AttributeType type;

  @override
  String toString() {
    return 'ProductAttribute(name: $name, values: $values, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductAttributeImpl &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._values, _values) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, name, const DeepCollectionEquality().hash(_values), type);

  /// Create a copy of ProductAttribute
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductAttributeImplCopyWith<_$ProductAttributeImpl> get copyWith =>
      __$$ProductAttributeImplCopyWithImpl<_$ProductAttributeImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductAttributeImplToJson(
      this,
    );
  }
}

abstract class _ProductAttribute implements ProductAttribute {
  const factory _ProductAttribute(
      {required final String name,
      required final List<String> values,
      final AttributeType type}) = _$ProductAttributeImpl;

  factory _ProductAttribute.fromJson(Map<String, dynamic> json) =
      _$ProductAttributeImpl.fromJson;

  @override
  String get name; // e.g., "Color", "Size"
  @override
  List<String> get values; // e.g., ["Red", "Blue", "Green"]
  @override
  AttributeType get type;

  /// Create a copy of ProductAttribute
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductAttributeImplCopyWith<_$ProductAttributeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EnhancedProduct _$EnhancedProductFromJson(Map<String, dynamic> json) {
  return _EnhancedProduct.fromJson(json);
}

/// @nodoc
mixin _$EnhancedProduct {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get basePrice =>
      throw _privateConstructorUsedError; // Base price for simple products
  String get imageUrl => throw _privateConstructorUsedError;
  int get categoryId => throw _privateConstructorUsedError;
  int get baseStock =>
      throw _privateConstructorUsedError; // Base stock for simple products
  double get rating => throw _privateConstructorUsedError;
  int get reviewCount => throw _privateConstructorUsedError;
  bool get isFeatured => throw _privateConstructorUsedError;
  bool get hasVariations => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  List<ProductVariation> get variations => throw _privateConstructorUsedError;
  List<ProductAttribute> get attributes => throw _privateConstructorUsedError;
  List<String> get imageUrls =>
      throw _privateConstructorUsedError; // Multiple product images
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this EnhancedProduct to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EnhancedProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EnhancedProductCopyWith<EnhancedProduct> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EnhancedProductCopyWith<$Res> {
  factory $EnhancedProductCopyWith(
          EnhancedProduct value, $Res Function(EnhancedProduct) then) =
      _$EnhancedProductCopyWithImpl<$Res, EnhancedProduct>;
  @useResult
  $Res call(
      {int id,
      String name,
      String description,
      double basePrice,
      String imageUrl,
      int categoryId,
      int baseStock,
      double rating,
      int reviewCount,
      bool isFeatured,
      bool hasVariations,
      List<String> tags,
      List<ProductVariation> variations,
      List<ProductAttribute> attributes,
      List<String> imageUrls,
      DateTime? createdAt});
}

/// @nodoc
class _$EnhancedProductCopyWithImpl<$Res, $Val extends EnhancedProduct>
    implements $EnhancedProductCopyWith<$Res> {
  _$EnhancedProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EnhancedProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? basePrice = null,
    Object? imageUrl = null,
    Object? categoryId = null,
    Object? baseStock = null,
    Object? rating = null,
    Object? reviewCount = null,
    Object? isFeatured = null,
    Object? hasVariations = null,
    Object? tags = null,
    Object? variations = null,
    Object? attributes = null,
    Object? imageUrls = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      basePrice: null == basePrice
          ? _value.basePrice
          : basePrice // ignore: cast_nullable_to_non_nullable
              as double,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int,
      baseStock: null == baseStock
          ? _value.baseStock
          : baseStock // ignore: cast_nullable_to_non_nullable
              as int,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      reviewCount: null == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      hasVariations: null == hasVariations
          ? _value.hasVariations
          : hasVariations // ignore: cast_nullable_to_non_nullable
              as bool,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      variations: null == variations
          ? _value.variations
          : variations // ignore: cast_nullable_to_non_nullable
              as List<ProductVariation>,
      attributes: null == attributes
          ? _value.attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as List<ProductAttribute>,
      imageUrls: null == imageUrls
          ? _value.imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EnhancedProductImplCopyWith<$Res>
    implements $EnhancedProductCopyWith<$Res> {
  factory _$$EnhancedProductImplCopyWith(_$EnhancedProductImpl value,
          $Res Function(_$EnhancedProductImpl) then) =
      __$$EnhancedProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String description,
      double basePrice,
      String imageUrl,
      int categoryId,
      int baseStock,
      double rating,
      int reviewCount,
      bool isFeatured,
      bool hasVariations,
      List<String> tags,
      List<ProductVariation> variations,
      List<ProductAttribute> attributes,
      List<String> imageUrls,
      DateTime? createdAt});
}

/// @nodoc
class __$$EnhancedProductImplCopyWithImpl<$Res>
    extends _$EnhancedProductCopyWithImpl<$Res, _$EnhancedProductImpl>
    implements _$$EnhancedProductImplCopyWith<$Res> {
  __$$EnhancedProductImplCopyWithImpl(
      _$EnhancedProductImpl _value, $Res Function(_$EnhancedProductImpl) _then)
      : super(_value, _then);

  /// Create a copy of EnhancedProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? basePrice = null,
    Object? imageUrl = null,
    Object? categoryId = null,
    Object? baseStock = null,
    Object? rating = null,
    Object? reviewCount = null,
    Object? isFeatured = null,
    Object? hasVariations = null,
    Object? tags = null,
    Object? variations = null,
    Object? attributes = null,
    Object? imageUrls = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$EnhancedProductImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      basePrice: null == basePrice
          ? _value.basePrice
          : basePrice // ignore: cast_nullable_to_non_nullable
              as double,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int,
      baseStock: null == baseStock
          ? _value.baseStock
          : baseStock // ignore: cast_nullable_to_non_nullable
              as int,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      reviewCount: null == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      hasVariations: null == hasVariations
          ? _value.hasVariations
          : hasVariations // ignore: cast_nullable_to_non_nullable
              as bool,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      variations: null == variations
          ? _value._variations
          : variations // ignore: cast_nullable_to_non_nullable
              as List<ProductVariation>,
      attributes: null == attributes
          ? _value._attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as List<ProductAttribute>,
      imageUrls: null == imageUrls
          ? _value._imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EnhancedProductImpl extends _EnhancedProduct {
  const _$EnhancedProductImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.basePrice,
      required this.imageUrl,
      required this.categoryId,
      this.baseStock = 0,
      this.rating = 0.0,
      this.reviewCount = 0,
      this.isFeatured = false,
      this.hasVariations = false,
      final List<String> tags = const [],
      final List<ProductVariation> variations = const [],
      final List<ProductAttribute> attributes = const [],
      final List<String> imageUrls = const [],
      this.createdAt})
      : _tags = tags,
        _variations = variations,
        _attributes = attributes,
        _imageUrls = imageUrls,
        super._();

  factory _$EnhancedProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$EnhancedProductImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String description;
  @override
  final double basePrice;
// Base price for simple products
  @override
  final String imageUrl;
  @override
  final int categoryId;
  @override
  @JsonKey()
  final int baseStock;
// Base stock for simple products
  @override
  @JsonKey()
  final double rating;
  @override
  @JsonKey()
  final int reviewCount;
  @override
  @JsonKey()
  final bool isFeatured;
  @override
  @JsonKey()
  final bool hasVariations;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  final List<ProductVariation> _variations;
  @override
  @JsonKey()
  List<ProductVariation> get variations {
    if (_variations is EqualUnmodifiableListView) return _variations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_variations);
  }

  final List<ProductAttribute> _attributes;
  @override
  @JsonKey()
  List<ProductAttribute> get attributes {
    if (_attributes is EqualUnmodifiableListView) return _attributes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attributes);
  }

  final List<String> _imageUrls;
  @override
  @JsonKey()
  List<String> get imageUrls {
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imageUrls);
  }

// Multiple product images
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'EnhancedProduct(id: $id, name: $name, description: $description, basePrice: $basePrice, imageUrl: $imageUrl, categoryId: $categoryId, baseStock: $baseStock, rating: $rating, reviewCount: $reviewCount, isFeatured: $isFeatured, hasVariations: $hasVariations, tags: $tags, variations: $variations, attributes: $attributes, imageUrls: $imageUrls, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EnhancedProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.basePrice, basePrice) ||
                other.basePrice == basePrice) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.baseStock, baseStock) ||
                other.baseStock == baseStock) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            (identical(other.hasVariations, hasVariations) ||
                other.hasVariations == hasVariations) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality()
                .equals(other._variations, _variations) &&
            const DeepCollectionEquality()
                .equals(other._attributes, _attributes) &&
            const DeepCollectionEquality()
                .equals(other._imageUrls, _imageUrls) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      basePrice,
      imageUrl,
      categoryId,
      baseStock,
      rating,
      reviewCount,
      isFeatured,
      hasVariations,
      const DeepCollectionEquality().hash(_tags),
      const DeepCollectionEquality().hash(_variations),
      const DeepCollectionEquality().hash(_attributes),
      const DeepCollectionEquality().hash(_imageUrls),
      createdAt);

  /// Create a copy of EnhancedProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EnhancedProductImplCopyWith<_$EnhancedProductImpl> get copyWith =>
      __$$EnhancedProductImplCopyWithImpl<_$EnhancedProductImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EnhancedProductImplToJson(
      this,
    );
  }
}

abstract class _EnhancedProduct extends EnhancedProduct {
  const factory _EnhancedProduct(
      {required final int id,
      required final String name,
      required final String description,
      required final double basePrice,
      required final String imageUrl,
      required final int categoryId,
      final int baseStock,
      final double rating,
      final int reviewCount,
      final bool isFeatured,
      final bool hasVariations,
      final List<String> tags,
      final List<ProductVariation> variations,
      final List<ProductAttribute> attributes,
      final List<String> imageUrls,
      final DateTime? createdAt}) = _$EnhancedProductImpl;
  const _EnhancedProduct._() : super._();

  factory _EnhancedProduct.fromJson(Map<String, dynamic> json) =
      _$EnhancedProductImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get description;
  @override
  double get basePrice; // Base price for simple products
  @override
  String get imageUrl;
  @override
  int get categoryId;
  @override
  int get baseStock; // Base stock for simple products
  @override
  double get rating;
  @override
  int get reviewCount;
  @override
  bool get isFeatured;
  @override
  bool get hasVariations;
  @override
  List<String> get tags;
  @override
  List<ProductVariation> get variations;
  @override
  List<ProductAttribute> get attributes;
  @override
  List<String> get imageUrls; // Multiple product images
  @override
  DateTime? get createdAt;

  /// Create a copy of EnhancedProduct
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EnhancedProductImplCopyWith<_$EnhancedProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
