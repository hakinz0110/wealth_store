import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/constants/app_text_styles.dart';

class ModernBottomNavbar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const ModernBottomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  State<ModernBottomNavbar> createState() => _ModernBottomNavbarState();
}

class _ModernBottomNavbarState extends State<ModernBottomNavbar> {
  final List<NavItem> _navItems = [
    NavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    NavItem(
      icon: Icons.shopping_bag_outlined,
      selectedIcon: Icons.shopping_bag,
      label: 'Products',
    ),
    NavItem(
      icon: Icons.shopping_cart_outlined,
      selectedIcon: Icons.shopping_cart,
      label: 'Cart',
    ),
    NavItem(
      icon: Icons.favorite_outline,
      selectedIcon: Icons.favorite,
      label: 'Wishlist',
    ),
    NavItem(
      icon: Icons.feed_outlined,
      selectedIcon: Icons.feed,
      label: 'Feed',
    ),
    NavItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        border: Border(
          top: BorderSide(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
              (index) => _buildNavItem(index, isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, bool isDark) {
    final isSelected = index == widget.selectedIndex;
    final item = _navItems[index];
    
    return Expanded(
      child: StatefulBuilder(
        builder: (context, setState) {
          bool isHovered = false;
          
          return Semantics(
            label: '${item.label} tab',
            hint: isSelected ? 'Currently selected' : 'Double tap to navigate to ${item.label}',
            selected: isSelected,
            button: true,
            enabled: true,
            onTap: () => widget.onDestinationSelected(index),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => isHovered = true),
              onExit: (_) => setState(() => isHovered = false),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onDestinationSelected(index);
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  constraints: const BoxConstraints(
                    minWidth: 44.0,
                    minHeight: 44.0,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.sm,
                  ),
                  // Add hover background effect
                  decoration: BoxDecoration(
                    color: isHovered && !isSelected
                        ? (isDark 
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.05))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  transform: Matrix4.identity()
                    ..scale(isHovered ? 1.05 : 1.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Enhanced pill-shaped container with hover effects
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        width: isSelected ? 56 : (isHovered ? 42 : 36),
                        height: isSelected ? 28 : (isHovered ? 30 : 28),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? AppColors.primary
                              : isHovered
                                  ? (isDark 
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.black.withValues(alpha: 0.08))
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ] : isHovered ? [
                            BoxShadow(
                              color: (isDark ? Colors.white : Colors.black)
                                  .withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ] : null,
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              isSelected ? item.selectedIcon : item.icon,
                              key: ValueKey('${item.label}_$isSelected'),
                              size: isHovered ? 22 : 20,
                              color: isSelected 
                                  ? Colors.white
                                  : isHovered
                                      ? (isDark ? Colors.white : AppColors.textPrimary)
                                      : (isDark 
                                          ? Colors.white70 
                                          : AppColors.textSecondary),
                            ),
                          ),
                        ),
                      )
                        .animate(target: isSelected ? 1 : 0)
                        .scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1.0, 1.0),
                          duration: 200.ms,
                          curve: Curves.easeOutBack,
                        ),
                      
                      const SizedBox(height: 2),
                      
                      // Enhanced label with hover effects
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isSelected 
                              ? AppColors.primary
                              : isHovered
                                  ? (isDark ? Colors.white : AppColors.textPrimary)
                                  : (isDark 
                                      ? Colors.white60 
                                      : AppColors.textSecondary),
                          fontWeight: isSelected 
                              ? FontWeight.w600 
                              : isHovered
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                          fontSize: isHovered ? 11 : 10,
                        ),
                        child: Text(
                          item.label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }


}

class NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}