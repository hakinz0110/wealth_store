// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_filter_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductFilterStateImpl _$$ProductFilterStateImplFromJson(
        Map<String, dynamic> json) =>
    _$ProductFilterStateImpl(
      categoryId: (json['categoryId'] as num?)?.toInt(),
      categoryName: json['categoryName'] as String?,
      sortOption:
          $enumDecodeNullable(_$ProductSortOptionEnumMap, json['sortOption']) ??
              ProductSortOption.newest,
      minPrice: (json['minPrice'] as num?)?.toDouble() ?? 0.0,
      maxPrice: (json['maxPrice'] as num?)?.toDouble() ?? 1000.0,
      currentMinPrice: (json['currentMinPrice'] as num?)?.toDouble() ?? 0.0,
      currentMaxPrice: (json['currentMaxPrice'] as num?)?.toDouble() ?? 1000.0,
      searchQuery: json['searchQuery'] as String?,
    );

Map<String, dynamic> _$$ProductFilterStateImplToJson(
        _$ProductFilterStateImpl instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'sortOption': _$ProductSortOptionEnumMap[instance.sortOption]!,
      'minPrice': instance.minPrice,
      'maxPrice': instance.maxPrice,
      'currentMinPrice': instance.currentMinPrice,
      'currentMaxPrice': instance.currentMaxPrice,
      'searchQuery': instance.searchQuery,
    };

const _$ProductSortOptionEnumMap = {
  ProductSortOption.priceAsc: 'priceAsc',
  ProductSortOption.priceDesc: 'priceDesc',
  ProductSortOption.newest: 'newest',
  ProductSortOption.popular: 'popular',
  ProductSortOption.nameAsc: 'nameAsc',
  ProductSortOption.nameDesc: 'nameDesc',
};
