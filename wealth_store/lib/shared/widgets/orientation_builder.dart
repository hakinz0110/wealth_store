import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wealth_app/core/constants/app_breakpoints.dart';
import 'package:wealth_app/shared/widgets/responsive_layout.dart';

class OrientationBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, Orientation orientation) builder;
  final Widget? portrait;
  final Widget? landscape;
  
  const OrientationBuilder({
    super.key,
    required this.builder,
    this.portrait,
    this.landscape,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait
        ? (portrait ?? builder(context, Orientation.portrait))
        : (landscape ?? builder(context, Orientation.landscape));
  }
}

class AdaptiveOrientationBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, Orientation orientation, ScreenSize screenSize) builder;
  
  const AdaptiveOrientationBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize, constraints) {
        final orientation = MediaQuery.of(context).orientation;
        return builder(context, orientation, screenSize);
      },
    );
  }
}

class OrientationLockWidget extends StatefulWidget {
  final Widget child;
  final List<DeviceOrientation>? allowedOrientations;
  final bool lockOnMobile;
  final bool lockOnTablet;
  final bool lockOnDesktop;
  
  const OrientationLockWidget({
    super.key,
    required this.child,
    this.allowedOrientations,
    this.lockOnMobile = false,
    this.lockOnTablet = false,
    this.lockOnDesktop = false,
  });

  @override
  State<OrientationLockWidget> createState() => _OrientationLockWidgetState();
}

class _OrientationLockWidgetState extends State<OrientationLockWidget> {
  List<DeviceOrientation>? _previousOrientations;

  @override
  void initState() {
    super.initState();
    _updateOrientationLock();
  }

  @override
  void didUpdateWidget(OrientationLockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allowedOrientations != widget.allowedOrientations ||
        oldWidget.lockOnMobile != widget.lockOnMobile ||
        oldWidget.lockOnTablet != widget.lockOnTablet ||
        oldWidget.lockOnDesktop != widget.lockOnDesktop) {
      _updateOrientationLock();
    }
  }

  @override
  void dispose() {
    // Restore previous orientations
    if (_previousOrientations != null) {
      SystemChrome.setPreferredOrientations(_previousOrientations!);
    }
    super.dispose();
  }

  void _updateOrientationLock() {
    final screenSize = context.screenSize;
    bool shouldLock = false;
    
    switch (screenSize) {
      case ScreenSize.compact:
        shouldLock = widget.lockOnMobile;
        break;
      case ScreenSize.medium:
        shouldLock = widget.lockOnTablet;
        break;
      case ScreenSize.expanded:
      case ScreenSize.large:
      case ScreenSize.extraLarge:
        shouldLock = widget.lockOnDesktop;
        break;
    }
    
    if (shouldLock && widget.allowedOrientations != null) {
      // Store current orientations before locking
      _previousOrientations ??= [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ];
      
      SystemChrome.setPreferredOrientations(widget.allowedOrientations!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final double spacing;
  final double runSpacing;
  final double? childAspectRatio;
  
  // Responsive column counts
  final int compactColumns;
  final int mediumColumns;
  final int expandedColumns;
  
  // Orientation-specific overrides
  final int? compactColumnsLandscape;
  final int? mediumColumnsLandscape;
  final int? expandedColumnsLandscape;
  
  const ResponsiveGridView({
    super.key,
    required this.children,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.childAspectRatio,
    this.compactColumns = 2,
    this.mediumColumns = 3,
    this.expandedColumns = 4,
    this.compactColumnsLandscape,
    this.mediumColumnsLandscape,
    this.expandedColumnsLandscape,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveOrientationBuilder(
      builder: (context, orientation, screenSize) {
        int columns = _getColumnCount(screenSize, orientation);
        
        return GridView.builder(
          controller: controller,
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: physics,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: childAspectRatio ?? 1.0,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
  
  int _getColumnCount(ScreenSize screenSize, Orientation orientation) {
    final isLandscape = orientation == Orientation.landscape;
    
    switch (screenSize) {
      case ScreenSize.compact:
        return isLandscape 
            ? (compactColumnsLandscape ?? compactColumns + 1)
            : compactColumns;
      case ScreenSize.medium:
        return isLandscape 
            ? (mediumColumnsLandscape ?? mediumColumns + 1)
            : mediumColumns;
      case ScreenSize.expanded:
      case ScreenSize.large:
      case ScreenSize.extraLarge:
        return isLandscape 
            ? (expandedColumnsLandscape ?? expandedColumns + 1)
            : expandedColumns;
    }
  }
}

class AdaptiveListView extends StatelessWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final bool useGridOnLargeScreens;
  final int gridColumns;
  final double gridSpacing;
  final double? gridChildAspectRatio;
  
  const AdaptiveListView({
    super.key,
    required this.children,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.scrollDirection = Axis.vertical,
    this.useGridOnLargeScreens = false,
    this.gridColumns = 2,
    this.gridSpacing = 16.0,
    this.gridChildAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize, constraints) {
        if (useGridOnLargeScreens && screenSize.isDesktop) {
          return GridView.builder(
            controller: controller,
            padding: padding,
            shrinkWrap: shrinkWrap,
            physics: physics,
            scrollDirection: scrollDirection,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridColumns,
              crossAxisSpacing: gridSpacing,
              mainAxisSpacing: gridSpacing,
              childAspectRatio: gridChildAspectRatio ?? 1.0,
            ),
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
          );
        }
        
        return ListView.builder(
          controller: controller,
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: physics,
          scrollDirection: scrollDirection,
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? compact;
  final EdgeInsetsGeometry? medium;
  final EdgeInsetsGeometry? expanded;
  final EdgeInsetsGeometry fallback;
  
  const ResponsivePadding({
    super.key,
    required this.child,
    this.compact,
    this.medium,
    this.expanded,
    this.fallback = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize, constraints) {
        EdgeInsetsGeometry padding;
        
        switch (screenSize) {
          case ScreenSize.compact:
            padding = compact ?? fallback;
            break;
          case ScreenSize.medium:
            padding = medium ?? compact ?? fallback;
            break;
          case ScreenSize.expanded:
          case ScreenSize.large:
          case ScreenSize.extraLarge:
            padding = expanded ?? medium ?? compact ?? fallback;
            break;
        }
        
        return Padding(
          padding: padding,
          child: child,
        );
      },
    );
  }
}