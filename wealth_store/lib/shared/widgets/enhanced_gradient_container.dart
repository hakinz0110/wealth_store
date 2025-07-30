import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wealth_app/core/utils/visual_styling_utils.dart';
import 'package:wealth_app/core/constants/app_design_tokens.dart';

/// Enhanced gradient container with modern visual effects
class EnhancedGradientContainer extends StatefulWidget {
  final Widget child;
  final GradientType gradientType;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final List<BoxShadow>? boxShadow;
  final bool enableHoverEffect;
  final bool enablePulseEffect;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  
  const EnhancedGradientContainer({
    super.key,
    required this.child,
    this.gradientType = GradientType.primary,
    this.borderRadius,
    this.padding,
    this.margin,
    this.boxShadow,
    this.enableHoverEffect = false,
    this.enablePulseEffect = false,
    this.onTap,
    this.width,
    this.height,
  });
  
  @override
  State<EnhancedGradientContainer> createState() => _EnhancedGradientContainerState();
}

class _EnhancedGradientContainerState extends State<EnhancedGradientContainer>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pulseController;
  bool _isHovered = false;
  
  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    if (widget.enablePulseEffect) {
      _pulseController.repeat();
    }
  }
  
  @override
  void dispose() {
    _hoverController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  void _handleHover(bool isHovered) {
    if (widget.enableHoverEffect) {
      setState(() => _isHovered = isHovered);
      if (isHovered) {
        _hoverController.forward();
      } else {
        _hoverController.reverse();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    Widget container = AnimatedBuilder(
      animation: Listenable.merge([_hoverController, _pulseController]),
      builder: (context, child) {
        final hoverScale = 1.0 + (_hoverController.value * 0.02);
        final pulseScale = widget.enablePulseEffect 
            ? 1.0 + ((_pulseController.value * 0.05) * (1.0 + 0.5 * (1.0 - _pulseController.value)))
            : 1.0;
        
        return Transform.scale(
          scale: hoverScale * pulseScale,
          child: Container(
            width: widget.width,
            height: widget.height,
            margin: widget.margin,
            padding: widget.padding ?? AppDesignTokens.paddingMd,
            decoration: VisualStylingUtils.getGradientDecoration(
              type: widget.gradientType,
              borderRadius: widget.borderRadius ?? AppDesignTokens.radiusMd,
              boxShadow: widget.boxShadow,
            ),
            child: widget.child,
          ),
        );
      },
    );
    
    // Add hover effect if enabled
    if (widget.enableHoverEffect) {
      container = MouseRegion(
        onEnter: (_) => _handleHover(true),
        onExit: (_) => _handleHover(false),
        child: container,
      );
    }
    
    // Add tap functionality if provided
    if (widget.onTap != null) {
      container = GestureDetector(
        onTap: widget.onTap,
        child: container,
      );
    }
    
    return container;
  }
}

/// Enhanced frosted glass container with backdrop blur effect
class EnhancedFrostedGlassContainer extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double opacity;
  final bool enableHoverEffect;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  
  const EnhancedFrostedGlassContainer({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.margin,
    this.opacity = 0.8,
    this.enableHoverEffect = false,
    this.onTap,
    this.width,
    this.height,
  });
  
  @override
  State<EnhancedFrostedGlassContainer> createState() => _EnhancedFrostedGlassContainerState();
}

class _EnhancedFrostedGlassContainerState extends State<EnhancedFrostedGlassContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _isHovered = false;
  
  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }
  
  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }
  
  void _handleHover(bool isHovered) {
    if (widget.enableHoverEffect) {
      setState(() => _isHovered = isHovered);
      if (isHovered) {
        _hoverController.forward();
      } else {
        _hoverController.reverse();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    Widget container = AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        final hoverOpacity = widget.opacity + (_hoverController.value * 0.1);
        
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          padding: widget.padding ?? AppDesignTokens.paddingMd,
          decoration: VisualStylingUtils.getFrostedGlassDecoration(
            backgroundColor: widget.backgroundColor,
            borderRadius: widget.borderRadius ?? AppDesignTokens.radiusMd,
            opacity: hoverOpacity.clamp(0.0, 1.0),
          ),
          child: widget.child,
        );
      },
    );
    
    // Add hover effect if enabled
    if (widget.enableHoverEffect) {
      container = MouseRegion(
        onEnter: (_) => _handleHover(true),
        onExit: (_) => _handleHover(false),
        child: container,
      );
    }
    
    // Add tap functionality if provided
    if (widget.onTap != null) {
      container = GestureDetector(
        onTap: widget.onTap,
        child: container,
      );
    }
    
    return container;
  }
}

/// Enhanced shimmer container for loading states
class EnhancedShimmerContainer extends StatefulWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;
  final bool isLoading;
  
  const EnhancedShimmerContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
    this.isLoading = true,
  });
  
  @override
  State<EnhancedShimmerContainer> createState() => _EnhancedShimmerContainerState();
}

class _EnhancedShimmerContainerState extends State<EnhancedShimmerContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  
  @override
  void initState() {
    super.initState();
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    if (widget.isLoading) {
      _shimmerController.repeat();
    }
  }
  
  @override
  void didUpdateWidget(EnhancedShimmerContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _shimmerController.repeat();
      } else {
        _shimmerController.stop();
      }
    }
  }
  
  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading && widget.child != null) {
      return widget.child!;
    }
    
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: VisualStylingUtils.getGradientDecoration(
            type: GradientType.shimmer,
            borderRadius: widget.borderRadius ?? AppDesignTokens.radiusSm,
          ),
          child: widget.child,
        );
      },
    );
  }
}