import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../constants/app_colors.dart';
import 'sidebar_navigation.dart';
import 'top_navigation.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final List<String> breadcrumbs;
  final String currentRoute;

  const AdminLayout({
    super.key,
    required this.child,
    required this.title,
    required this.currentRoute,
    this.breadcrumbs = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: ResponsiveBreakpoints.of(context).isMobile
          ? _buildMobileLayout(context)
          : _buildDesktopLayout(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Sidebar
        SidebarNavigation(currentRoute: currentRoute),
        
        // Main content area
        Expanded(
          child: Column(
            children: [
              // Top navigation
              TopNavigation(
                title: title,
                breadcrumbs: breadcrumbs,
              ),
              
              // Content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: TopNavigation(
        title: title,
        breadcrumbs: breadcrumbs,
      ),
      drawer: Drawer(
        child: SidebarNavigation(currentRoute: currentRoute),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}