import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUser {
  final String id;
  final String email;
  final String role;
  final DateTime createdAt;
  final DateTime? lastSignInAt;

  const AdminUser({
    required this.id,
    required this.email,
    required this.role,
    required this.createdAt,
    this.lastSignInAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastSignInAt: json['last_sign_in_at'] != null
          ? DateTime.parse(json['last_sign_in_at'] as String)
          : null,
    );
  }

  factory AdminUser.fromSupabaseUser(User user, String role) {
    return AdminUser(
      id: user.id,
      email: user.email ?? '',
      role: role,
      createdAt: DateTime.parse(user.createdAt),
      lastSignInAt: user.lastSignInAt != null ? DateTime.parse(user.lastSignInAt!) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'last_sign_in_at': lastSignInAt?.toIso8601String(),
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isManager => role == 'manager';
  bool get hasAdminPrivileges => isAdmin || isManager;
}

class AdminAuthState {
  final AdminUser? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AdminAuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AdminAuthState copyWith({
    AdminUser? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AdminAuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class LoginRequest {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'remember_me': rememberMe,
    };
  }
}