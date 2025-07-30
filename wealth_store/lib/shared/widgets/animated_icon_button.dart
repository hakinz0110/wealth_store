import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';

class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final IconData? activeIcon;
  final VoidCallback? onPressed;
  final bool isActive;
  final Color? color;
  final Color? activeColor;
  final Color? backgroundColor;
  final Color? activeBackgroundColor;
  final double size;
  final EdgeInsetsGeometry? padding;
  final bool enableHapticFeedback;
  final Duration animationDuration;
  final String? tooltip;
  
  const AnimatedIconButton({
    super.key,
    required this.icon,
    this.activeIcon,
    this.onPressed,
    this.isActive = false,
    this.color,
    this.activeColor,
    this.backgroundColor,
    this.activeBackgroundColor,
    this.size = 24,
    this.padding,
    this.enableHapticFeedback = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.tooltip,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: widget.color ?? AppColors.neutral600,
      end: widget.activeColor ?? AppColors.primary,
    ).animate(_controller);

    _backgroundColorAnimation = ColorTween(
      begin: widget.backgroundColor ?? Colors.transparent,
      end: widget.activeBackgroundColor ?? AppColors.primary.withValues(alpha: 0.1),
    ).animate(_controller);

    if (widget.isActive) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed == null) return;

    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }

    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    Widget button = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 3.14159 * 2,
            child: Container(
              padding: widget.padding ?? const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: _backgroundColorAnimation.value,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(
                widget.isActive && widget.activeIcon != null
                    ? widget.activeIcon!
                    : widget.icon,
                size: widget.size,
                color: _colorAnimation.value,
              ),
            ),
          ),
        );
      },
    );

    button = GestureDetector(
      onTap: _handleTap,
      child: button,
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}

class WishlistAnimatedIcon extends StatefulWidget {
  final bool isWishlisted;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final Color? activeColor;
  
  const WishlistAnimatedIcon({
    super.key,
    required this.isWishlisted,
    this.onPressed,
    this.size = 24,
    this.color,
    this.activeColor,
  });

  @override
  State<WishlistAnimatedIcon> createState() => _WishlistAnimatedIconState();
}

class _WishlistAnimatedIconState extends State<WishlistAnimatedIcon>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    if (widget.isWishlisted) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(WishlistAnimatedIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isWishlisted != oldWidget.isWishlisted) {
      if (widget.isWishlisted) {
        _controller.forward();
        _pulseController.forward().then((_) => _pulseController.reverse());
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed == null) return;

    HapticFeedback.lightImpact();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_controller, _pulseController]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Pulse effect when added to wishlist
              if (widget.isWishlisted)
                Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Icon(
                    Icons.favorite,
                    size: widget.size,
                    color: (widget.activeColor ?? AppColors.error)
                        .withValues(alpha: 1.0 - _pulseController.value),
                  ),
                ),
              
              // Main heart icon
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Icon(
                  widget.isWishlisted ? Icons.favorite : Icons.favorite_border,
                  size: widget.size,
                  color: widget.isWishlisted
                      ? (widget.activeColor ?? AppColors.error)
                      : (widget.color ?? AppColors.neutral600),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AnimatedToggleButton extends StatefulWidget {
  final bool isToggled;
  final VoidCallback? onPressed;
  final IconData icon;
  final IconData toggledIcon;
  final String label;
  final String toggledLabel;
  final Color? color;
  final Color? toggledColor;
  final Color? backgroundColor;
  final Color? toggledBackgroundColor;
  
  const AnimatedToggleButton({
    super.key,
    required this.isToggled,
    this.onPressed,
    required this.icon,
    required this.toggledIcon,
    required this.label,
    required this.toggledLabel,
    this.color,
    this.toggledColor,
    this.backgroundColor,
    this.toggledBackgroundColor,
  });

  @override
  State<AnimatedToggleButton> createState() => _AnimatedToggleButtonState();
}

class _AnimatedToggleButtonState extends State<AnimatedToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );



    _colorAnimation = ColorTween(
      begin: widget.color ?? AppColors.neutral600,
      end: widget.toggledColor ?? AppColors.primary,
    ).animate(_controller);

    _backgroundColorAnimation = ColorTween(
      begin: widget.backgroundColor ?? AppColors.neutral100,
      end: widget.toggledBackgroundColor ?? AppColors.primary.withValues(alpha: 0.1),
    ).animate(_controller);

    if (widget.isToggled) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isToggled != oldWidget.isToggled) {
      if (widget.isToggled) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onPressed?.call();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: _backgroundColorAnimation.value,
              borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
              border: Border.all(
                color: _colorAnimation.value ?? Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.isToggled ? widget.toggledIcon : widget.icon,
                  color: _colorAnimation.value,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.xs),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    widget.isToggled ? widget.toggledLabel : widget.label,
                    key: ValueKey(widget.isToggled),
                    style: TextStyle(
                      color: _colorAnimation.value,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}