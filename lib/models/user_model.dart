class UserModel {
  final String id;
  final String name;
  final String email;
  String address;
  String username;
  String phoneNumber;
  String gender;
  String dateOfBirth;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.address = '',
    this.username = '',
    this.phoneNumber = '',
    this.gender = '',
    this.dateOfBirth = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      username: json['username'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'address': address,
      'username': username,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? address,
    String? username,
    String? phoneNumber,
    String? gender,
    String? dateOfBirth,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }
}
