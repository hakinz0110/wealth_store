import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealth_app/shared/models/customer.dart';

part 'auth_state.freezed.dart';

// Note: Removed JSON serialization for simplicity since User class is not easily serializable
// part 'auth_state.g.dart';

@freezed
class AppAuthState with _$AppAuthState {
  const factory AppAuthState({
    User? user,
    Customer? customer,
    @Default(false) bool isAuthenticated,
    @Default(false) bool isLoading,
    String? error,
  }) = _AppAuthState;

  const AppAuthState._();

  factory AppAuthState.initial() => const AppAuthState();

  factory AppAuthState.loading() => const AppAuthState(isLoading: true);

  factory AppAuthState.authenticated(User user, Customer customer) => AppAuthState(
        user: user,
        customer: customer,
        isAuthenticated: true,
      );

  factory AppAuthState.error(String message) => AppAuthState(error: message);
} 