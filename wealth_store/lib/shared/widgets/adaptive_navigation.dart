import 'package:flutter/material.dart';
import 'package:wealth_app/core/constants/app_breakpoints.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/shared/widgets/responsive_layout.dart';

class AdaptiveNavigation extends StatelessWidget {
  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final Widget? leading;
  final Widget? trailing;
  final Color? backgroundColor;
  final double? elevation;
  
  const AdaptiveNavigation({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    this.onDestinationSelected,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize, constraints) {
        switch (screenSize) {
          case ScreenSize.compact:
            return _buildBottomNavigation(context);
          case ScreenSize.medium:
            return _buildNavigationRail(context);
          case ScreenSize.expanded:
          case ScreenSize.large:
          case ScreenSize.extraLarge:
            return _buildNavigationDrawer(context);
        }
      },
    );
  }
  
  Widget _buildBottomNavigation(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: backgroundColor,
      elevation: elevation,
      destinations: destinations,
    );
  }
  
  Widget _buildNavigationRail(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: backgroundColor,
      elevation: elevation,
      leading: leading,
      trailing: trailing,
      labelType: NavigationRailLabelType.selected,
      destinations: destinations.map((dest) => NavigationRailDestination(
        icon: dest.icon,
        selectedIcon: dest.selectedIcon,
        label: Text(dest.label),
      )).toList(),
    );
  }
  
  Widget _buildNavigationDrawer(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: backgroundColor,
      elevation: elevation,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(height: AppSpacing.lg),
        ],
        ...destinations.asMap().entries.map((entry) {
          final index = entry.key;
          final dest = entry.value;
          return NavigationDrawerDestination(
            icon: dest.icon,
            selectedIcon: dest.selectedIcon,
            label: Text(dest.label),
          );
        }),
        if (trailing != null) ...[
          const SizedBox(height: AppSpacing.lg),
          trailing!,
        ],
      ],
    );
  }
}

class AdaptiveScaffold extends StatelessWidget {
  final Widget body;
  final List<NavigationDestination>? destinations;
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  
  const AdaptiveScaffold({
    super.key,
    required this.body,
    this.destinations,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    if (destinations == null) {
      return Scaffold(
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        drawer: drawer,
        endDrawer: endDrawer,
        backgroundColor: backgroundColor,
        extendBody: extendBody,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
      );
    }
    
    return ResponsiveBuilder(
      builder: (context, screenSize, constraints) {
        switch (screenSize) {
          case ScreenSize.compact:
            return _buildMobileScaffold(context);
          case ScreenSize.medium:
            return _buildTabletScaffold(context);
          case ScreenSize.expanded:
          case ScreenSize.large:
          case ScreenSize.extraLarge:
            return _buildDesktopScaffold(context);
        }
      },
    );
  }
  
  Widget _buildMobileScaffold(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: AdaptiveNavigation(
        destinations: destinations!,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }
  
  Widget _buildTabletScaffold(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Row(
        children: [
          AdaptiveNavigation(
            destinations: destinations!,
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
          ),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }
  
  Widget _buildDesktopScaffold(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AdaptiveNavigation(
            destinations: destinations!,
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
          ),
          Expanded(
            child: Column(
              children: [
                if (appBar != null) appBar!,
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }
}

class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool centerTitle;
  
  const AdaptiveAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize, constraints) {
        // Adjust app bar height based on screen size
        final height = screenSize.isDesktop ? 64.0 : 56.0;
        
        return AppBar(
          title: title,
          actions: actions,
          leading: leading,
          automaticallyImplyLeading: automaticallyImplyLeading,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: elevation,
          centerTitle: centerTitle,
          toolbarHeight: height,
        );
      },
    );
  }

  @override
  Size get preferredSize {
    return const Size.fromHeight(kToolbarHeight);
  }
}

class ResponsiveDialog extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? contentPadding;
  final bool barrierDismissible;
  
  const ResponsiveDialog({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.contentPadding,
    this.barrierDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize, constraints) {
        if (screenSize.isMobile) {
          // Full screen dialog on mobile
          return Dialog.fullscreen(
            child: Scaffold(
              appBar: AppBar(
                title: title != null ? Text(title!) : null,
                actions: actions,
              ),
              body: Padding(
                padding: contentPadding ?? const EdgeInsets.all(AppSpacing.lg),
                child: child,
              ),
            ),
          );
        } else {
          // Regular dialog on larger screens
          return AlertDialog(
            title: title != null ? Text(title!) : null,
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: screenSize.isTablet ? 400 : 600,
                maxHeight: constraints.maxHeight * 0.8,
              ),
              child: child,
            ),
            actions: actions,
            contentPadding: contentPadding,
          );
        }
      },
    );
  }
  
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    List<Widget>? actions,
    EdgeInsetsGeometry? contentPadding,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => ResponsiveDialog(
        title: title,
        actions: actions,
        contentPadding: contentPadding,
        barrierDismissible: barrierDismissible,
        child: child,
      ),
    );
  }
}