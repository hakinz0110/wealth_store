import 'package:hooks_riverpod/hooks_riverpod.dart';

// Simple developer authentication state
final developerAuthProvider = StateNotifierProvider<DeveloperAuthNotifier, bool>((ref) {
  return DeveloperAuthNotifier();
});

class DeveloperAuthNotifier extends StateNotifier<bool> {
  DeveloperAuthNotifier() : super(false);

  void signIn() {
    state = true;
  }

  void signOut() {
    state = false;
  }

  bool get isAuthenticated => state;
}