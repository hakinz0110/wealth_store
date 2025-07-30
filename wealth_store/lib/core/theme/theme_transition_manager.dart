import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Theme transition manager for smooth theme switching animations
class ThemeTransitionManager extends StateNotifier<ThemeTransitionState> {
  ThemeTransitionManager() : super(const ThemeTransitionState());
  
  /// Duration for theme transition animations
  static const Duration transitionDuration = Duration(milliseconds: 300);
  
  /// Curve for theme transition animations
  static const Curve transitionCurve = Curves.easeInOut;
  
  /// Start theme transition
  void startTransition(ThemeMode newTheme) {
    state = state.copyWith(
      isTransitioning: true,
      targetTheme: newTheme,
    );
    
    // Complete transition after animation duration
    Future.delayed(transitionDuration, () {
      if (mounted) {
        completeTransition();
      }
    });
  }
  
  /// Complete theme transition
  void completeTransition() {
    state = state.copyWith(
      isTransitioning: false,
      currentTheme: state.targetTheme,
      targetTheme: null,
    );
  }
  
  /// Set theme without animation
  void setTheme(ThemeMode theme) {
    state = state.copyWith(
      currentTheme: theme,
      isTransitioning: false,
      targetTheme: null,
    );
  }
}

/// State class for theme transitions
class ThemeTransitionState {
  final ThemeMode currentTheme;
  final ThemeMode? targetTheme;
  final bool isTransitioning;
  
  const ThemeTransitionState({
    this.currentTheme = ThemeMode.system,
    this.targetTheme,
    this.isTransitioning = false,
  });
  
  ThemeTransitionState copyWith({
    ThemeMode? currentTheme,
    ThemeMode? targetTheme,
    bool? isTransitioning,
  }) {
    return ThemeTransitionState(
      currentTheme: currentTheme ?? this.currentTheme,
      targetTheme: targetTheme,
      isTransitioning: isTransitioning ?? this.isTransitioning,
    );
  }
}

/// Provider for theme transition manager
final themeTransitionProvider = StateNotifierProvider<ThemeTransitionManager, ThemeTransitionState>(
  (ref) => ThemeTransitionManager(),
);

/// Animated theme transition widget
class AnimatedThemeTransition extends ConsumerWidget {
  final Widget child;
  final Duration? duration;
  final Curve? curve;
  
  const AnimatedThemeTransition({
    super.key,
    required this.child,
    this.duration,
    this.curve,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeTransitionProvider);
    
    return AnimatedContainer(
      duration: duration ?? ThemeTransitionManager.transitionDuration,
      curve: curve ?? ThemeTransitionManager.transitionCurve,
      child: AnimatedSwitcher(
        duration: duration ?? ThemeTransitionManager.transitionDuration,
        switchInCurve: curve ?? ThemeTransitionManager.transitionCurve,
        switchOutCurve: curve ?? ThemeTransitionManager.transitionCurve,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: Container(
          key: ValueKey(themeState.currentTheme),
          child: child,
        ),
      ),
    );
  }
}

/// Smooth color transition widget
class SmoothColorTransition extends StatelessWidget {
  final Color color;
  final Widget child;
  final Duration? duration;
  final Curve? curve;
  
  const SmoothColorTransition({
    super.key,
    required this.color,
    required this.child,
    this.duration,
    this.curve,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration ?? ThemeTransitionManager.transitionDuration,
      curve: curve ?? ThemeTransitionManager.transitionCurve,
      color: color,
      child: child,
    );
  }
}

/// Smooth decoration transition widget
class SmoothDecorationTransition extends StatelessWidget {
  final Decoration decoration;
  final Widget child;
  final Duration? duration;
  final Curve? curve;
  
  const SmoothDecorationTransition({
    super.key,
    required this.decoration,
    required this.child,
    this.duration,
    this.curve,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration ?? ThemeTransitionManager.transitionDuration,
      curve: curve ?? ThemeTransitionManager.transitionCurve,
      decoration: decoration,
      child: child,
    );
  }
}