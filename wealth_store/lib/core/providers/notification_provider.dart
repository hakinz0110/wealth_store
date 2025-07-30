import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for managing notification count
final notificationCountProvider = StateNotifierProvider<NotificationCountNotifier, int>(
  (ref) => NotificationCountNotifier(),
);

class NotificationCountNotifier extends StateNotifier<int> {
  NotificationCountNotifier() : super(3); // Default count for demo
  
  void updateCount(int count) {
    state = count;
  }
  
  void increment() {
    state++;
  }
  
  void decrement() {
    if (state > 0) {
      state--;
    }
  }
  
  void clearAll() {
    state = 0;
  }
}