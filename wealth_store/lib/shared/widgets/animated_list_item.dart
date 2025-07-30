import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum AnimationType {
  fadeIn,
  slideFromBottom,
  slideFromRight,
  scale,
  combined,
}

class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final AnimationType animationType;
  final Duration? delay;
  final Duration? duration;
  final Curve? curve;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.animationType = AnimationType.combined,
    this.delay,
    this.duration,
    this.curve,
  });

  @override
  Widget build(BuildContext context) {
    // Base delay calculation - items appear sequentially
    final baseDelay = delay ?? Duration(milliseconds: 60 * index);
    final animDuration = duration ?? const Duration(milliseconds: 400);
    final animCurve = curve ?? Curves.easeOutQuad;

    switch (animationType) {
      case AnimationType.fadeIn:
        return child
            .animate()
            .fadeIn(
              delay: baseDelay,
              duration: animDuration,
              curve: animCurve,
            );
      
      case AnimationType.slideFromBottom:
        return child
            .animate()
            .slideY(
              begin: 0.2,
              delay: baseDelay,
              duration: animDuration,
              curve: animCurve,
            )
            .fadeIn(
              delay: baseDelay,
              duration: animDuration,
              curve: animCurve,
            );
      
      case AnimationType.slideFromRight:
        return child
            .animate()
            .slideX(
              begin: 0.2,
              delay: baseDelay,
              duration: animDuration,
              curve: animCurve,
            )
            .fadeIn(
              delay: baseDelay,
              duration: animDuration,
              curve: animCurve,
            );
      
      case AnimationType.scale:
        return child
            .animate()
            .scale(
              begin: const Offset(0.8, 0.8),
              delay: baseDelay,
              duration: animDuration,
              curve: animCurve,
            )
            .fadeIn(
              delay: baseDelay,
              duration: animDuration,
              curve: animCurve,
            );
      
      case AnimationType.combined:
        return child
            .animate()
            .fadeIn(
              delay: baseDelay,
              duration: animDuration,
              curve: animCurve,
            )
            .slideY(
              begin: 0.1,
              delay: baseDelay,
              duration: animDuration,
              curve: animCurve,
            )
            .scale(
              begin: const Offset(0.95, 0.95),
              delay: baseDelay,
              duration: animDuration,
              curve: animCurve,
            );
    }
  }
} 