import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for managing scroll controllers across the app
final scrollControllerProvider = Provider.family<ScrollController, String>((ref, key) {
  final controller = ScrollController();
  
  // Dispose the controller when the provider is disposed
  ref.onDispose(() {
    controller.dispose();
  });
  
  return controller;
});

/// Provider for tracking scroll position
final scrollPositionProvider = StateNotifierProvider.family<ScrollPositionNotifier, double, String>(
  (ref, key) {
    final controller = ref.watch(scrollControllerProvider(key));
    return ScrollPositionNotifier(controller);
  },
);

class ScrollPositionNotifier extends StateNotifier<double> {
  final ScrollController _controller;
  
  ScrollPositionNotifier(this._controller) : super(0.0) {
    _controller.addListener(_updatePosition);
  }
  
  void _updatePosition() {
    if (_controller.hasClients) {
      state = _controller.offset;
    }
  }
  
  @override
  void dispose() {
    _controller.removeListener(_updatePosition);
    super.dispose();
  }
}