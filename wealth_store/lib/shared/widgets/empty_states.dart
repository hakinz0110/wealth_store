import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/constants/app_text_styles.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Color? iconColor;
  final double iconSize;
  final bool showAnimation;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionText,
    this.onActionPressed,
    this.iconColor,
    this.iconSize = 80,
    this.showAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.primary.withValues(alpha: 0.6);
    
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container with background
            Container(
              width: iconSize + 40,
              height: iconSize + 40,
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: effectiveIconColor,
              ),
            )
                .animate(target: showAnimation ? 1 : 0)
                .scale(
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 400.ms),
            
            SizedBox(height: AppSpacing.xl),
            
            // Title
            Text(
              title,
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neutral800,
              ),
              textAlign: TextAlign.center,
            )
                .animate(target: showAnimation ? 1 : 0, delay: 200.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.2, end: 0),
            
            SizedBox(height: AppSpacing.md),
            
            // Description
            Text(
              description,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.neutral600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            )
                .animate(target: showAnimation ? 1 : 0, delay: 400.ms)
                .fadeIn(duration: 400.ms),
            
            if (actionText != null && onActionPressed != null) ...[
              SizedBox(height: AppSpacing.xl),
              
              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onActionPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    actionText!,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
                  .animate(target: showAnimation ? 1 : 0, delay: 600.ms)
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 400.ms),
            ],
          ],
        ),
      ),
    );
  }
}

// Specific empty states for different screens
class EmptyCartState extends StatelessWidget {
  final VoidCallback? onStartShopping;

  const EmptyCartState({
    super.key,
    this.onStartShopping,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.shopping_cart_outlined,
      title: 'Your cart is empty',
      description: 'Looks like you haven\'t added any items to your cart yet.\nStart shopping to fill it up!',
      actionText: 'Start Shopping',
      onActionPressed: onStartShopping,
      iconColor: AppColors.primary,
    );
  }
}

class EmptyWishlistState extends StatelessWidget {
  final VoidCallback? onBrowseProducts;

  const EmptyWishlistState({
    super.key,
    this.onBrowseProducts,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.favorite_outline,
      title: 'No favorites yet',
      description: 'Save items you love to your wishlist.\nTap the heart icon on any product to add it here.',
      actionText: 'Browse Products',
      onActionPressed: onBrowseProducts,
      iconColor: AppColors.secondary,
    );
  }
}

class EmptyOrdersState extends StatelessWidget {
  final VoidCallback? onStartShopping;

  const EmptyOrdersState({
    super.key,
    this.onStartShopping,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'No orders yet',
      description: 'When you place your first order,\nit will appear here for easy tracking.',
      actionText: 'Start Shopping',
      onActionPressed: onStartShopping,
      iconColor: AppColors.tertiary,
    );
  }
}

class EmptySearchState extends StatelessWidget {
  final String? searchQuery;
  final VoidCallback? onClearSearch;

  const EmptySearchState({
    super.key,
    this.searchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off_outlined,
      title: searchQuery != null 
          ? 'No results for "$searchQuery"'
          : 'No search results',
      description: 'Try adjusting your search terms or\nbrowse our categories to find what you\'re looking for.',
      actionText: searchQuery != null ? 'Clear Search' : null,
      onActionPressed: onClearSearch,
      iconColor: AppColors.warning,
    );
  }
}

class EmptyNotificationsState extends StatelessWidget {
  const EmptyNotificationsState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.notifications_none_outlined,
      title: 'No notifications',
      description: 'You\'re all caught up!\nWe\'ll notify you when there\'s something new.',
      iconColor: AppColors.success,
    );
  }
}

// Network/Connection empty state
class NoConnectionState extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoConnectionState({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.wifi_off_outlined,
      title: 'No internet connection',
      description: 'Please check your connection and try again.\nMake sure you\'re connected to Wi-Fi or mobile data.',
      actionText: 'Try Again',
      onActionPressed: onRetry,
      iconColor: AppColors.error,
    );
  }
}

// Generic error state
class ErrorState extends StatelessWidget {
  final String? title;
  final String? description;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorState({
    super.key,
    this.title,
    this.description,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: icon,
      title: title ?? 'Something went wrong',
      description: description ?? 'We encountered an unexpected error.\nPlease try again or contact support if the problem persists.',
      actionText: onRetry != null ? 'Try Again' : null,
      onActionPressed: onRetry,
      iconColor: AppColors.error,
    );
  }
}