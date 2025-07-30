import 'package:freezed_annotation/freezed_annotation.dart';

part 'address.freezed.dart';
part 'address.g.dart';

@freezed
class Address with _$Address {
  const factory Address({
    required int id,
    required String userId,
    required String name,
    required String street,
    required String city,
    required String state,
    required String zipCode,
    required String country,
    @Default(false) bool isDefault,
    String? phoneNumber,
    String? additionalInfo,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);
} 