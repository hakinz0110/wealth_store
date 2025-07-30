import 'package:json_annotation/json_annotation.dart';

part 'admin.g.dart';

@JsonSerializable()
class Admin {
  final String id;
  final String email;
  final String role;
  final DateTime createdAt;

  const Admin({
    required this.id,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory Admin.fromJson(Map<String, dynamic> json) => _$AdminFromJson(json);
  Map<String, dynamic> toJson() => _$AdminToJson(this);
} 