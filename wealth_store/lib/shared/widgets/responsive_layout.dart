import 'package:flutter/material.dart';
import 'package:wealth_app/core/constants/app_breakpoints.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget? compact;
  final Widget? medium;
  final Widget? expanded;
  final Widget? large;
  final Widget? extraLarge;
  final Widget? fallback;
  
  const ResponsiveLayout({
    super.key,
    this.compact,
    this.medium,
    this.expanded,
    this.large,
    this.extraLarge,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = ScreenSize.fromWidth(constraints.maxWidth);
        
        switch (screenSize) {
          case ScreenSize.compact:
            return compact ?? medium ?? expanded ?? large ?? extraLarge ?? fallback ?? const SizedBox.shrink();
          case ScreenSize.medium:
            return medium ?? compact ?? expanded ?? large ?? extraLarge ?? fallback ?? const SizedBox.shrink();
          case ScreenSize.expanded:
            return expanded ?? large ?? extraLarge ?? medium ?? compact ?? fallback ?? const SizedBox.shrink();
          case ScreenSize.large:
            return large ?? expanded ?? extraLarge ?? medium ?? compact ?? fallback ?? const SizedBox.shrink();
          case ScreenSize.extraLarge:
            return extraLarge ?? large ?? expanded ?? medium ?? compact ?? fallback ?? const SizedBox.shrink();
        }
      },
    );
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenSize screenSize, BoxConstraints constraints) builder;
  
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = ScreenSize.fromWidth(constraints.maxWidth);
        return builder(context, screenSize, constraints);
      },
    );
  }
}

class ResponsiveValue<T> {
  final T? compact;
  final T? medium;
  final T? expanded;
  final T? large;
  final T? extraLarge;
  final T fallback;
  
  const ResponsiveValue({
    this.compact,
    this.medium,
    this.expanded,
    this.large,
    this.extraLarge,
    required this.fallback,
  });
  
  T getValue(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.compact:
        return compact ?? medium ?? expanded ?? large ?? extraLarge ?? fallback;
      case ScreenSize.medium:
        return medium ?? compact ?? expanded ?? large ?? extraLarge ?? fallback;
      case ScreenSize.expanded:
        return expanded ?? large ?? extraLarge ?? medium ?? compact ?? fallback;
      case ScreenSize.large:
        return large ?? expanded ?? extraLarge ?? medium ?? compact ?? fallback;
      case ScreenSize.extraLarge:
        return extraLarge ?? large ?? expanded ?? medium ?? compact ?? fallback;
    }
  }
}

extension ResponsiveContext on BuildContext {
  ScreenSize get screenSize {
    final width = MediaQuery.of(this).size.width;
    return ScreenSize.fromWidth(width);
  }
  
  bool get isMobile => screenSize.isMobile;
  bool get isTablet => screenSize.isTablet;
  bool get isDesktop => screenSize.isDesktop;
  
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;
  bool get isPortrait => MediaQuery.of(this).orientation == Orientation.portrait;
  
  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
  
  double get devicePixelRatio => MediaQuery.of(this).devicePixelRatio;
  
  T responsive<T>(ResponsiveValue<T> value) {
    return value.getValue(screenSize);
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? compactColumns;
  final int? mediumColumns;
  final int? expandedColumns;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.compactColumns,
    this.mediumColumns,
    this.expandedColumns,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize, constraints) {
        int columns;
        switch (screenSize) {
          case ScreenSize.compact:
            columns = compactColumns ?? 1;
            break;
          case ScreenSize.medium:
            columns = mediumColumns ?? 2;
            break;
          case ScreenSize.expanded:
          case ScreenSize.large:
          case ScreenSize.extraLarge:
            columns = expandedColumns ?? 3;
            break;
        }
        
        return GridView.builder(
          padding: padding,
          physics: physics,
          shrinkWrap: shrinkWrap,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: 1.0,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool centerContent;
  
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.margin,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      child: centerContent
          ? Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth ?? AppBreakpoints.maxContentWidth,
                ),
                child: Padding(
                  padding: padding ?? EdgeInsets.zero,
                  child: child,
                ),
              ),
            )
          : ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth ?? AppBreakpoints.maxContentWidth,
              ),
              child: Padding(
                padding: padding ?? EdgeInsets.zero,
                child: child,
              ),
            ),
    );
  }
}