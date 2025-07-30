import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/constants/app_text_styles.dart';

class SuccessAnimation extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color? color;
  final Duration duration;
  final VoidCallback? onComplete;
  final bool showBackground;

  const SuccessAnimation({
    super.key,
    required this.message,
    this.icon = Icons.check_circle,
    this.color,
    this.duration = const Duration(milliseconds: 2000),
    this.onComplete,
    this.showBackground = true,
  });

  @override
  State<SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    // Start animations
    _scaleController.forward();
    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });

    // Haptic feedback
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? AppColors.success;
    
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: widget.showBackground
                  ? BoxDecoration(
                      color: effectiveColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(
                        color: effectiveColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    )
                  : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    color: effectiveColor,
                    size: 24,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      widget.message,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: effectiveColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Floating success message
class FloatingSuccessMessage extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? color;

  const FloatingSuccessMessage({
    super.key,
    required this.message,
    this.icon = Icons.check_circle,
    this.color,
  });

  static void show(
    BuildContext context, {
    required String message,
    IconData icon = Icons.check_circle,
    Color? color,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: FloatingSuccessMessage(
            message: message,
            icon: icon,
            color: color,
          )
              .animate()
              .slideY(
                begin: -1,
                end: 0,
                duration: 300.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 200.ms)
              .then(delay: 2000.ms)
              .slideY(
                begin: 0,
                end: -1,
                duration: 300.ms,
                curve: Curves.easeInBack,
              )
              .fadeOut(duration: 200.ms)
              .callback(callback: (_) => entry.remove()),
        ),
      ),
    );
    
    overlay.insert(entry);
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.success;
    
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: effectiveColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: effectiveColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: effectiveColor,
              size: 20,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Add to cart success animation
class AddToCartSuccess extends StatefulWidget {
  final VoidCallback? onComplete;

  const AddToCartSuccess({
    super.key,
    this.onComplete,
  });

  @override
  State<AddToCartSuccess> createState() => _AddToCartSuccessState();
}

class _AddToCartSuccessState extends State<AddToCartSuccess>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.25,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.8, curve: Curves.easeInOut),
    ));

    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });

    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.shopping_cart,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Checkmark animation
class CheckmarkAnimation extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;

  const CheckmarkAnimation({
    super.key,
    this.size = 60,
    this.color,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<CheckmarkAnimation> createState() => _CheckmarkAnimationState();
}

class _CheckmarkAnimationState extends State<CheckmarkAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pathAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _pathAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? AppColors.success;
    
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _pathAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: CheckmarkPainter(
              progress: _pathAnimation.value,
              color: effectiveColor,
            ),
          );
        },
      ),
    );
  }
}

class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  CheckmarkPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Draw circle
    canvas.drawCircle(center, radius, paint);

    // Draw checkmark
    if (progress > 0.5) {
      final checkProgress = (progress - 0.5) * 2;
      final checkPath = Path();
      
      final startPoint = Offset(size.width * 0.3, size.height * 0.5);
      final midPoint = Offset(size.width * 0.45, size.height * 0.65);
      final endPoint = Offset(size.width * 0.7, size.height * 0.35);
      
      checkPath.moveTo(startPoint.dx, startPoint.dy);
      
      if (checkProgress <= 0.5) {
        final currentPoint = Offset.lerp(
          startPoint,
          midPoint,
          checkProgress * 2,
        )!;
        checkPath.lineTo(currentPoint.dx, currentPoint.dy);
      } else {
        checkPath.lineTo(midPoint.dx, midPoint.dy);
        final currentPoint = Offset.lerp(
          midPoint,
          endPoint,
          (checkProgress - 0.5) * 2,
        )!;
        checkPath.lineTo(currentPoint.dx, currentPoint.dy);
      }
      
      canvas.drawPath(checkPath, paint);
    }
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}