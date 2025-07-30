import 'package:freezed_annotation/freezed_annotation.dart';

part 'banner.freezed.dart';
part 'banner.g.dart';

@freezed
class Banner with _$Banner {
  const factory Banner({
    required String id,
    required String title,
    String? description,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'link_url') String? linkUrl,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Banner;

  factory Banner.fromJson(Map<String, dynamic> json) => _$BannerFromJson(json);
}

@freezed
class BannerFormData with _$BannerFormData {
  const factory BannerFormData({
    required String title,
    String? description,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'link_url') String? linkUrl,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _BannerFormData;

  factory BannerFormData.fromJson(Map<String, dynamic> json) => _$BannerFormDataFromJson(json);
  
  factory BannerFormData.empty() {
    return const BannerFormData(
      title: '',
      imageUrl: '',
      sortOrder: 0,
    );
  }
  
  factory BannerFormData.fromBanner(Banner banner) {
    return BannerFormData(
      title: banner.title,
      description: banner.description,
      imageUrl: banner.imageUrl,
      linkUrl: banner.linkUrl,
      sortOrder: banner.sortOrder,
      isActive: banner.isActive,
    );
  }
}