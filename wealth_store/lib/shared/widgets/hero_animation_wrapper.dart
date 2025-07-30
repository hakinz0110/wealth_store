import 'package:flutter/material.dart';

class HeroAnimationWrapper extends StatelessWidget {
  final String tag;
  final Widget child;
  final bool enabled;
  final Duration? transitionDuration;
  
  const HeroAnimationWrapper({
    super.key,
    required this.tag,
    required this.child,
    this.enabled = true,
    this.transitionDuration,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    return Hero(
      tag: tag,
      transitionOnUserGestures: true,
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (animation.value * 0.1),
              child: Material(
                color: Colors.transparent,
                child: child,
              ),
            );
          },
          child: toHeroContext.widget,
        );
      },
      child: child,
    );
  }
}

class HeroPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  @override
  final Duration transitionDuration;
  @override
  final Duration reverseTransitionDuration;

  HeroPageRoute({
    required this.child,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: transitionDuration,
          reverseTransitionDuration: reverseTransitionDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}