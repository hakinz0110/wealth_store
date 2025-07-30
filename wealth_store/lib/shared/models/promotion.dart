import 'package:freezed_annotation/freezed_annotation.dart';

part 'promotion.freezed.dart';
part 'promotion.g.dart';

@freezed
class Promotion with _$Promotion {
  const factory Promotion({
    required int id,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    String? imageUrl,
    int? productId,
    int? categoryId,
    String? couponCode,
    double? discountPercent,
    @Default(false) bool isActive,
  }) = _Promotion;

  factory Promotion.fromJson(Map<String, dynamic> json) => _$PromotionFromJson(json);
} 