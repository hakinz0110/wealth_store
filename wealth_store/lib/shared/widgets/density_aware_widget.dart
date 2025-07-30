import 'package:flutter/material.dart';
import 'package:wealth_app/core/constants/app_breakpoints.dart';
import 'package:wealth_app/shared/widgets/responsive_layout.dart';

class DensityAwareWidget extends StatelessWidget {
  final Widget child;
  final double? lowDensityScale;
  final double? mediumDensityScale;
  final double? highDensityScale;
  final double? extraHighDensityScale;
  final bool scaleText;
  final bool scaleIcons;
  final bool scaleTouchTargets;
  
  const DensityAwareWidget({
    super.key,
    required this.child,
    this.lowDensityScale,
    this.mediumDensityScale,
    this.highDensityScale,
    this.extraHighDensityScale,
    this.scaleText = true,
    this.scaleIcons = true,
    this.scaleTouchTargets = true,
  });

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final scale = _getScaleForDensity(devicePixelRatio);
    
    if (scale == 1.0) {
      return child;
    }
    
    return Transform.scale(
      scale: scale,
      child: child,
    );
  }
  
  double _getScaleForDensity(double devicePixelRatio) {
    if (devicePixelRatio <= 1.0) {
      return lowDensityScale ?? 1.0;
    } else if (devicePixelRatio <= 2.0) {
      return mediumDensityScale ?? 1.0;
    } else if (devicePixelRatio <= 3.0) {
      return highDensityScale ?? 1.0;
    } else {
      return extraHighDensityScale ?? 1.0;
    }
  }
}

class AdaptiveTouchTarget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double? minSize;
  final EdgeInsetsGeometry? padding;
  final bool adaptToScreenSize;
  
  const AdaptiveTouchTarget({
    super.key,
    required this.child,
    this.onTap,
    this.minSize,
    this.padding,
    this.adaptToScreenSize = true,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize, constraints) {
        double touchTargetSize = minSize ?? AppBreakpoints.recommendedTouchTarget;
        
        if (adaptToScreenSize) {
          touchTargetSize = screenSize.touchTargetSize;
        }
        
        return GestureDetector(
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(
              minWidth: touchTargetSize,
              minHeight: touchTargetSize,
            ),
            padding: padding,
            child: Center(child: child),
          ),
        );
      },
    );
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? compactScale;
  final double? mediumScale;
  final double? expandedScale;
  
  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.compactScale,
    this.mediumScale,
    this.expandedScale,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize, constraints) {
        double scale = 1.0;
        
        switch (screenSize) {
          case ScreenSize.compact:
            scale = compactScale ?? 1.0;
            break;
          case ScreenSize.medium:
            scale = mediumScale ?? 1.0;
            break;
          case ScreenSize.expanded:
          case ScreenSize.large:
          case ScreenSize.extraLarge:
            scale = expandedScale ?? 1.0;
            break;
        }
        
        TextStyle? effectiveStyle = style;
        if (scale != 1.0 && effectiveStyle != null) {
          effectiveStyle = effectiveStyle.copyWith(
            fontSize: (effectiveStyle.fontSize ?? 14.0) * scale,
          );
        }
        
        return Text(
          text,
          style: effectiveStyle,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

class ResponsiveIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  final double? compactScale;
  final double? mediumScale;
  final double? expandedScale;
  
  const ResponsiveIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.compactScale,
    this.mediumScale,
    this.expandedScale,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize, constraints) {
        double scale = 1.0;
        
        switch (screenSize) {
          case ScreenSize.compact:
            scale = compactScale ?? 1.0;
            break;
          case ScreenSize.medium:
            scale = mediumScale ?? 1.0;
            break;
          case ScreenSize.expanded:
          case ScreenSize.large:
          case ScreenSize.extraLarge:
            scale = expandedScale ?? 1.0;
            break;
        }
        
        final effectiveSize = (size ?? 24.0) * scale;
        
        return Icon(
          icon,
          size: effectiveSize,
          color: color,
          semanticLabel: semanticLabel,
        );
      },
    );
  }
}

class AdaptiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;
  final ShapeBorder? shape;
  final bool adaptMargin;
  final bool adaptPadding;
  final bool adaptElevation;
  
  const AdaptiveCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.color,
    this.elevation,
    this.shape,
    this.adaptMargin = true,
    this.adaptPadding = true,
    this.adaptElevation = false,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize, constraints) {
        EdgeInsetsGeometry? effectiveMargin = margin;
        EdgeInsetsGeometry? effectivePadding = padding;
        double? effectiveElevation = elevation;
        
        if (adaptMargin) {
          effectiveMargin = _getAdaptiveMargin(screenSize);
        }
        
        if (adaptPadding) {
          effectivePadding = _getAdaptivePadding(screenSize);
        }
        
        if (adaptElevation) {
          effectiveElevation = _getAdaptiveElevation(screenSize);
        }
        
        return Card(
          margin: effectiveMargin,
          color: color,
          elevation: effectiveElevation,
          shape: shape,
          child: Padding(
            padding: effectivePadding ?? EdgeInsets.zero,
            child: child,
          ),
        );
      },
    );
  }
  
  EdgeInsetsGeometry _getAdaptiveMargin(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.compact:
        return const EdgeInsets.all(8.0);
      case ScreenSize.medium:
        return const EdgeInsets.all(12.0);
      case ScreenSize.expanded:
      case ScreenSize.large:
      case ScreenSize.extraLarge:
        return const EdgeInsets.all(16.0);
    }
  }
  
  EdgeInsetsGeometry _getAdaptivePadding(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.compact:
        return const EdgeInsets.all(12.0);
      case ScreenSize.medium:
        return const EdgeInsets.all(16.0);
      case ScreenSize.expanded:
      case ScreenSize.large:
      case ScreenSize.extraLarge:
        return const EdgeInsets.all(20.0);
    }
  }
  
  double _getAdaptiveElevation(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.compact:
        return 2.0;
      case ScreenSize.medium:
        return 4.0;
      case ScreenSize.expanded:
      case ScreenSize.large:
      case ScreenSize.extraLarge:
        return 6.0;
    }
  }
}

class ResponsiveSpacing extends StatelessWidget {
  final double? compact;
  final double? medium;
  final double? expanded;
  final double fallback;
  final Axis axis;
  
  const ResponsiveSpacing({
    super.key,
    this.compact,
    this.medium,
    this.expanded,
    this.fallback = 16.0,
    this.axis = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize, constraints) {
        double spacing;
        
        switch (screenSize) {
          case ScreenSize.compact:
            spacing = compact ?? fallback;
            break;
          case ScreenSize.medium:
            spacing = medium ?? compact ?? fallback;
            break;
          case ScreenSize.expanded:
          case ScreenSize.large:
          case ScreenSize.extraLarge:
            spacing = expanded ?? medium ?? compact ?? fallback;
            break;
        }
        
        return axis == Axis.vertical
            ? SizedBox(height: spacing)
            : SizedBox(width: spacing);
      },
    );
  }
}