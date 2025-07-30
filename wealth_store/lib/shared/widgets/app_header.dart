import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:responsive_framework/responsive_framework.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double height;

  const AppHeader({
    super.key,
    this.title = 'Wealth Store',
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
    this.height = 60.0,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).smallerThan(TABLET);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: isMobile ? 18 : 22,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      centerTitle: false,
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: onBackPressed ?? () => context.pop(),
            )
          : null,
      actions: actions,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0.5,
      shadowColor: isDark ? Colors.white24 : Colors.black12,
    );
  }
} 