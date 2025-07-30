import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_design_tokens.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/utils/typography_utils.dart';
import 'package:wealth_app/core/utils/visual_styling_utils.dart';
import 'package:wealth_app/shared/widgets/enhanced_interactive_button.dart';

/// Enhanced empty states with engaging illustrations and helpful guidance
class EnhancedEmptyStates {
  
  /// Empty cart state
  static Widget emptyCart({
    VoidCallback? onStartShopping,
    String? customMessage,
  }) {
    return EnhancedEmptyStateWidget(
      icon: Icons.shopping_cart_outlined,
      title: 'Your cart is empty',
      description: customMessage ?? 
          'Looks like you haven\'t added any items to your cart yet.\nStart shopping to fill it up!',
      illustration: _buildShoppingCartIllustration(),
      primaryAction: onStartShopping != null
          ? EmptyStateAction(
              label: 'Start Shopping',
              onPressed: onStartShopping,
              icon: Icons.shopping_bag_outlined,
            )
          : null,
      animationType: EmptyStateAnimationType.bounce,
    );
  }
  
  /// Empty wishlist state
  static Widget emptyWishlist({
    VoidCallback? onBrowseProducts,
    String? customMessage,
  }) {
    return EnhancedEmptyStateWidget(
      icon: Icons.favorite_outline,
      title: 'No favorites yet',
      description: customMessage ?? 
          'Save items you love by tapping the heart icon.\nThey\'ll appear here for easy access.',
      illustration: _buildWishlistIllustration(),
      primaryAction: onBrowseProducts != null
          ? EmptyStateAction(
              label: 'Browse Products',
              onPressed: onBrowseProducts,
              icon: Icons.explore_outlined,
            )
          : null,
      animationType: EmptyStateAnimationType.pulse,
    );
  }
  
  /// Empty orders state
  static Widget emptyOrders({
    VoidCallback? onStartShopping,
    String? customMessage,
  }) {
    return EnhancedEmptyStateWidget(
      icon: Icons.receipt_long_outlined,
      title: 'No orders yet',
      description: customMessage ?? 
          'When you place your first order, it will appear here.\nStart shopping to see your order history.',
      illustration: _buildOrdersIllustration(),
      primaryAction: onStartShopping != null
          ? EmptyStateAction(
              label: 'Start Shopping',
              onPressed: onStartShopping,
              icon: Icons.shopping_bag_outlined,
            )
          : null,
      animationType: EmptyStateAnimationType.slideUp,
    );
  }
  
  /// Empty search results state
  static Widget emptySearchResults({
    required String searchQuery,
    VoidCallback? onClearSearch,
    VoidCallback? onBrowseCategories,
    String? customMessage,
  }) {
    return EnhancedEmptyStateWidget(
      icon: Icons.search_off_outlined,
      title: 'No results found',
      description: customMessage ?? 
          'We couldn\'t find anything matching "$searchQuery".\nTry adjusting your search or browse our categories.',
      illustration: _buildSearchIllustration(),
      primaryAction: onClearSearch != null
          ? EmptyStateAction(
              label: 'Clear Search',
              onPressed: onClearSearch,
              icon: Icons.clear,
            )
          : null,
      secondaryAction: onBrowseCategories != null
          ? EmptyStateAction(
              label: 'Browse Categories',
              onPressed: onBrowseCategories,
              icon: Icons.category_outlined,
            )
          : null,
      animationType: EmptyStateAnimationType.fadeIn,
    );
  }
  
  /// Empty notifications state
  static Widget emptyNotifications({
    VoidCallback? onEnableNotifications,
    String? customMessage,
  }) {
    return EnhancedEmptyStateWidget(
      icon: Icons.notifications_none_outlined,
      title: 'No notifications',
      description: customMessage ?? 
          'You\'re all caught up! We\'ll notify you about\norders, offers, and important updates.',
      illustration: _buildNotificationsIllustration(),
      primaryAction: onEnableNotifications != null
          ? EmptyStateAction(
              label: 'Enable Notifications',
              onPressed: onEnableNotifications,
              icon: Icons.notifications_active_outlined,
            )
          : null,
      animationType: EmptyStateAnimationType.bounce,
    );
  }
  
  /// Network error state
  static Widget networkError({
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    return EnhancedEmptyStateWidget(
      icon: Icons.wifi_off_outlined,
      title: 'Connection problem',
      description: customMessage ?? 
          'Please check your internet connection\nand try again.',
      illustration: _buildNetworkErrorIllustration(),
      primaryAction: onRetry != null
          ? EmptyStateAction(
              label: 'Try Again',
              onPressed: onRetry,
              icon: Icons.refresh,
            )
          : null,
      animationType: EmptyStateAnimationType.shake,
      colorScheme: EmptyStateColorScheme.error,
    );
  }
  
  /// Server error state
  static Widget serverError({
    VoidCallback? onRetry,
    VoidCallback? onContactSupport,
    String? customMessage,
  }) {
    return EnhancedEmptyStateWidget(
      icon: Icons.error_outline,
      title: 'Something went wrong',
      description: customMessage ?? 
          'We\'re experiencing technical difficulties.\nPlease try again or contact support.',
      illustration: _buildServerErrorIllustration(),
      primaryAction: onRetry != null
          ? EmptyStateAction(
              label: 'Try Again',
              onPressed: onRetry,
              icon: Icons.refresh,
            )
          : null,
      secondaryAction: onContactSupport != null
          ? EmptyStateAction(
              label: 'Contact Support',
              onPressed: onContactSupport,
              icon: Icons.support_agent_outlined,
            )
          : null,
      animationType: EmptyStateAnimationType.shake,
      colorScheme: EmptyStateColorScheme.error,
    );
  }
  
  /// Maintenance mode state
  static Widget maintenanceMode({
    DateTime? estimatedCompletion,
    String? customMessage,
  }) {
    final completionText = estimatedCompletion != null
        ? 'Expected completion: ${_formatDateTime(estimatedCompletion)}'
        : 'We\'ll be back soon!';
    
    return EnhancedEmptyStateWidget(
      icon: Icons.build_outlined,
      title: 'Under maintenance',
      description: customMessage ?? 
          'We\'re making improvements to serve you better.\n$completionText',
      illustration: _buildMaintenanceIllustration(),
      animationType: EmptyStateAnimationType.pulse,
      colorScheme: EmptyStateColorScheme.warning,
    );
  }
  
  /// Custom empty state
  static Widget custom({
    required IconData icon,
    required String title,
    required String description,
    Widget? illustration,
    EmptyStateAction? primaryAction,
    EmptyStateAction? secondaryAction,
    EmptyStateAnimationType animationType = EmptyStateAnimationType.fadeIn,
    EmptyStateColorScheme colorScheme = EmptyStateColorScheme.neutral,
  }) {
    return EnhancedEmptyStateWidget(
      icon: icon,
      title: title,
      description: description,
      illustration: illustration,
      primaryAction: primaryAction,
      secondaryAction: secondaryAction,
      animationType: animationType,
      colorScheme: colorScheme,
    );
  }
  
  // Helper methods for illustrations
  static Widget _buildShoppingCartIllustration() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.shopping_cart_outlined,
        size: 60,
        color: AppColors.primary.withValues(alpha: 0.7),
      ),
    );
  }
  
  static Widget _buildWishlistIllustration() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.favorite_outline,
        size: 60,
        color: AppColors.error.withValues(alpha: 0.7),
      ),
    );
  }
  
  static Widget _buildOrdersIllustration() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.receipt_long_outlined,
        size: 60,
        color: AppColors.secondary.withValues(alpha: 0.7),
      ),
    );
  }
  
  static Widget _buildSearchIllustration() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.neutral400.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.search_off_outlined,
        size: 60,
        color: AppColors.neutral400.withValues(alpha: 0.7),
      ),
    );
  }
  
  static Widget _buildNotificationsIllustration() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.tertiary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.notifications_none_outlined,
        size: 60,
        color: AppColors.tertiary.withValues(alpha: 0.7),
      ),
    );
  }
  
  static Widget _buildNetworkErrorIllustration() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.wifi_off_outlined,
        size: 60,
        color: AppColors.warning.withValues(alpha: 0.7),
      ),
    );
  }
  
  static Widget _buildServerErrorIllustration() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.error_outline,
        size: 60,
        color: AppColors.error.withValues(alpha: 0.7),
      ),
    );
  }
  
  static Widget _buildMaintenanceIllustration() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.build_outlined,
        size: 60,
        color: AppColors.warning.withValues(alpha: 0.7),
      ),
    );
  }
  
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Enhanced empty state widget with animations and actions
class EnhancedEmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget? illustration;
  final EmptyStateAction? primaryAction;
  final EmptyStateAction? secondaryAction;
  final EmptyStateAnimationType animationType;
  final EmptyStateColorScheme colorScheme;
  
  const EnhancedEmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.illustration,
    this.primaryAction,
    this.secondaryAction,
    this.animationType = EmptyStateAnimationType.fadeIn,
    this.colorScheme = EmptyStateColorScheme.neutral,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color primaryColor;
    switch (colorScheme) {
      case EmptyStateColorScheme.neutral:
        primaryColor = isDark ? AppColors.neutral400 : AppColors.neutral600;
        break;
      case EmptyStateColorScheme.error:
        primaryColor = AppColors.error;
        break;
      case EmptyStateColorScheme.warning:
        primaryColor = AppColors.warning;
        break;
      case EmptyStateColorScheme.success:
        primaryColor = AppColors.success;
        break;
    }
    
    Widget content = Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration or icon
            if (illustration != null)
              illustration!
            else
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 60,
                  color: primaryColor.withValues(alpha: 0.7),
                ),
              ),
            
            const SizedBox(height: 32),
            
            // Title
            Text(
              title,
              style: TypographyUtils.getHeadingStyle(
                context,
                HeadingLevel.h3,
                isEmphasis: true,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Description
            Text(
              description,
              style: TypographyUtils.getBodyStyle(
                context,
                size: BodySize.large,
                isSecondary: true,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // Actions
            if (primaryAction != null || secondaryAction != null) ...[
              if (primaryAction != null)
                SizedBox(
                  width: double.infinity,
                  child: EnhancedInteractiveButton(
                    text: primaryAction!.label,
                    onPressed: primaryAction!.onPressed,
                    variant: ButtonVariant.primary,
                    size: ButtonSize.large,
                    icon: primaryAction!.icon,
                  ),
                ),
              
              if (secondaryAction != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: EnhancedInteractiveButton(
                    text: secondaryAction!.label,
                    onPressed: secondaryAction!.onPressed,
                    variant: ButtonVariant.secondary,
                    size: ButtonSize.large,
                    icon: secondaryAction!.icon,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
    
    // Apply animation based on type
    switch (animationType) {
      case EmptyStateAnimationType.fadeIn:
        content = content.animate().fadeIn(duration: 600.ms);
        break;
      case EmptyStateAnimationType.slideUp:
        content = content.animate().slideY(
          begin: 0.3,
          end: 0,
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        ).fadeIn(duration: 400.ms);
        break;
      case EmptyStateAnimationType.bounce:
        content = content.animate().scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 600.ms,
          curve: Curves.elasticOut,
        ).fadeIn(duration: 400.ms);
        break;
      case EmptyStateAnimationType.pulse:
        content = content.animate().scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0),
          duration: 800.ms,
          curve: Curves.easeInOut,
        ).fadeIn(duration: 400.ms);
        break;
      case EmptyStateAnimationType.shake:
        content = content.animate().shake(
          duration: 500.ms,
          hz: 4,
        ).fadeIn(duration: 400.ms);
        break;
    }
    
    return content;
  }
}

/// Empty state action model
class EmptyStateAction {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  
  const EmptyStateAction({
    required this.label,
    required this.onPressed,
    this.icon,
  });
}

/// Animation types for empty states
enum EmptyStateAnimationType {
  fadeIn,
  slideUp,
  bounce,
  pulse,
  shake,
}

/// Color schemes for empty states
enum EmptyStateColorScheme {
  neutral,
  error,
  warning,
  success,
}