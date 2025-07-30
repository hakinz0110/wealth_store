// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryStateImpl _$$CategoryStateImplFromJson(Map<String, dynamic> json) =>
    _$CategoryStateImpl(
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      selectedCategory: json['selectedCategory'] == null
          ? null
          : Category.fromJson(json['selectedCategory'] as Map<String, dynamic>),
      isLoading: json['isLoading'] as bool? ?? false,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$$CategoryStateImplToJson(_$CategoryStateImpl instance) =>
    <String, dynamic>{
      'categories': instance.categories,
      'selectedCategory': instance.selectedCategory,
      'isLoading': instance.isLoading,
      'error': instance.error,
    };
