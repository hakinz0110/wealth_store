import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wealth_app/shared/models/product.dart';

part 'wishlist_item.freezed.dart';
part 'wishlist_item.g.dart';

@freezed
class WishlistItem with _$WishlistItem {
  const factory WishlistItem({
    required int id,
    required String userId,
    required int productId,
    DateTime? createdAt,
    @JsonKey(includeToJson: false, includeFromJson: false) Product? product,
  }) = _WishlistItem;

  factory WishlistItem.fromJson(Map<String, dynamic> json) => _$WishlistItemFromJson(json);
} 