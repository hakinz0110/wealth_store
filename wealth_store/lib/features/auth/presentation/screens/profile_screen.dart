import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_text_styles.dart';
import 'package:wealth_app/core/utils/typography_utils.dart';
import 'package:wealth_app/core/utils/visual_styling_utils.dart';
import 'package:wealth_app/core/theme/theme_transition_manager.dart';
import 'package:wealth_app/features/auth/domain/auth_notifier.dart';
import 'package:wealth_app/features/orders/domain/order_notifier.dart';
import 'package:wealth_app/features/profile/domain/profile_notifier.dart';
import 'package:wealth_app/shared/widgets/custom_button.dart';
import 'package:wealth_app/shared/widgets/enhanced_gradient_container.dart';


class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final profileState = ref.watch(profileNotifierProvider);
    final customer = profileState.customer ?? authState.customer;
    
    // Trigger profile data load if not already loaded
    if (profileState.customer == null && authState.isAuthenticated) {
      ref.read(profileNotifierProvider.notifier).refreshProfile();
    }
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern profile header with large avatar
          SliverToBoxAdapter(
            child: _buildProfileHeader(context, customer),
          ),
          
          // User stats section
          SliverToBoxAdapter(
            child: _buildUserStats(context, ref),
          ),
          
          // Menu sections with clear hierarchy
          SliverToBoxAdapter(
            child: _buildMenuSections(context, ref),
          ),
          
          // Theme selector section
          SliverToBoxAdapter(
            child: _buildThemeSelector(context, ref),
          ),
          
          // Logout button
          SliverToBoxAdapter(
            child: _buildLogoutSection(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic customer) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppSpacing.xxl),
          bottomRight: Radius.circular(AppSpacing.xxl),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),
            // Large avatar with edit overlay
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.onPrimary.withValues(alpha: 0.3),
                      width: 4,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.onPrimary.withValues(alpha: 0.2),
                    backgroundImage: customer?.avatarUrl != null
                        ? CachedNetworkImageProvider(customer!.avatarUrl!)
                        : null,
                    child: customer?.avatarUrl == null
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: AppColors.onPrimary.withValues(alpha: 0.8),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.onPrimary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowMedium,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => context.push('/profile/edit'),
                      icon: const Icon(
                        Icons.edit,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            // User name and info
            Text(
              customer?.fullName ?? 'User',
              style: TypographyUtils.getHeadingStyle(
                context,
                HeadingLevel.h3,
                isEmphasis: true,
              ).copyWith(
                color: AppColors.onPrimary,
              ),
            ),
            if (customer?.phoneNumber != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                customer!.phoneNumber!,
                style: TypographyUtils.getBodyStyle(
                  context,
                  size: BodySize.medium,
                  isSecondary: true,
                ).copyWith(
                  color: AppColors.onPrimary.withValues(alpha: 0.8),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.onPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
              ),
              child: Text(
                'Premium Member',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStats(BuildContext context, WidgetRef ref) {
    // Get order count from order provider
    final orderState = ref.watch(orderNotifierProvider);
    final orderCount = orderState.orders.length.toString();
    
    final stats = [
      {'label': 'Orders', 'value': orderCount, 'icon': Icons.shopping_bag_outlined},
      {'label': 'Wishlist', 'value': '8', 'icon': Icons.favorite_outline},
      {'label': 'Reviews', 'value': '5', 'icon': Icons.star_outline},
    ];

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: VisualStylingUtils.getElevatedCardDecoration(
        context: context,
        elevation: 2,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats.map((stat) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  stat['icon'] as IconData,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                stat['value'] as String,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                stat['label'] as String,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuSections(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account section
          _buildSectionHeader(context, 'Account'),
          _buildMenuGroup(context, [
            _MenuItemData(
              title: 'Edit Profile',
              subtitle: 'Update your personal information',
              icon: Icons.person_outline,
              onTap: () => context.push('/profile/edit'),
            ),
            _MenuItemData(
              title: 'Shipping Addresses',
              subtitle: 'Manage your delivery addresses',
              icon: Icons.location_on_outlined,
              onTap: () => context.push('/profile/addresses'),
            ),
            _MenuItemData(
              title: 'Payment Methods',
              subtitle: 'Manage cards and payment options',
              icon: Icons.payment_outlined,
              onTap: () {
                // Navigate to payment methods
              },
            ),
          ]),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Orders & Activity section
          _buildSectionHeader(context, 'Orders & Activity'),
          _buildMenuGroup(context, [
            _MenuItemData(
              title: 'My Orders',
              subtitle: 'Track and manage your orders',
              icon: Icons.shopping_bag_outlined,
              onTap: () => context.go('/profile/orders'),
            ),
            _MenuItemData(
              title: 'Wishlist',
              subtitle: 'Your saved favorite items',
              icon: Icons.favorite_outline,
              onTap: () => context.go('/wishlist'),
            ),
            _MenuItemData(
              title: 'Reviews',
              subtitle: 'Your product reviews and ratings',
              icon: Icons.star_outline,
              onTap: () {
                // Navigate to reviews
              },
            ),
          ]),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Support section
          _buildSectionHeader(context, 'Support'),
          _buildMenuGroup(context, [
            _MenuItemData(
              title: 'Help Center',
              subtitle: 'Get help and support',
              icon: Icons.help_outline,
              onTap: () {
                // Navigate to help
              },
            ),
            _MenuItemData(
              title: 'Contact Us',
              subtitle: 'Reach out to our support team',
              icon: Icons.chat_outlined,
              onTap: () {
                // Navigate to contact
              },
            ),
            _MenuItemData(
              title: 'Settings',
              subtitle: 'App preferences and notifications',
              icon: Icons.settings_outlined,
              onTap: () => context.push('/profile/settings'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildMenuGroup(BuildContext context, List<_MenuItemData> items) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;
          
          return _buildMenuItem(
            context,
            item: item,
            showDivider: !isLast,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required _MenuItemData item,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          leading: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              item.icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          title: Text(
            item.title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          subtitle: item.subtitle != null
              ? Text(
                  item.subtitle!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
              : null,
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onTap: item.onTap,
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: AppSpacing.lg + 40 + AppSpacing.sm, // Leading icon width + padding
            endIndent: AppSpacing.lg,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
      ],
    );
  }

  Widget _buildThemeSelector(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(
                  Icons.palette_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Choose your preferred theme',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Theme options with live preview
          Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  context,
                  title: 'Light',
                  icon: Icons.light_mode_outlined,
                  isSelected: Theme.of(context).brightness == Brightness.light,
                  onTap: () {
                    ref.read(profileNotifierProvider.notifier)
                        .updateThemePreference('light');
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildThemeOption(
                  context,
                  title: 'Dark',
                  icon: Icons.dark_mode_outlined,
                  isSelected: Theme.of(context).brightness == Brightness.dark,
                  onTap: () {
                    ref.read(profileNotifierProvider.notifier)
                        .updateThemePreference('dark');
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildThemeOption(
                  context,
                  title: 'System',
                  icon: Icons.settings_system_daydream_outlined,
                  isSelected: false, // Would check system theme preference
                  onTap: () {
                    ref.read(profileNotifierProvider.notifier)
                        .updateThemePreference('system');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              title,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          CustomButton(
            text: 'Log Out',
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
              context.go('/auth');
            },
          ),
          const SizedBox(height: AppSpacing.huge),
        ],
      ),
    );
  }
}

class _MenuItemData {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuItemData({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTap,
  });
} 