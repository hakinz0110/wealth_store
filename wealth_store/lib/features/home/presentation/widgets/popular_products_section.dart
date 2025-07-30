import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/utils/typography_utils.dart';
import 'package:wealth_app/core/utils/haptic_feedback_utils.dart';
import 'package:wealth_app/features/products/domain/product_notifier.dart';
import 'package:wealth_app/features/wishlist/domain/wishlist_notifier.dart';
import 'package:wealth_app/features/cart/domain/cart_notifier.dart';
import 'package:wealth_app/shared/widgets/modern_product_card.dart';
import 'package:wealth_app/shared/widgets/shimmer_loading.dart';
import 'package:wealth_app/shared/widgets/advanced_feedback_system.dart';

class PopularProductsSection extends ConsumerWidget {
  const PopularProductsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productNotifierProvider);
    final wishlistState = ref.watch(wishlistNotifierProvider);
    
    // Get first 4 products for home screen display
    final popularProducts = productState.products.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Products',
                style: TypographyUtils.getHeadingStyle(
                  context,
                  HeadingLevel.h4,
                  isEmphasis: true,
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.push('/products');
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View all',
                      style: TypographyUtils.getBodyStyle(
                        context,
                        size: BodySize.medium,
                      ).copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Products grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: productState.isLoading && popularProducts.isEmpty
              ? _buildLoadingGrid(context)
              : productState.error != null && popularProducts.isEmpty
                  ? _buildErrorState(context, ref)
                  : popularProducts.isEmpty
                      ? _buildEmptyState(context)
                      : _buildProductsGrid(context, ref, popularProducts, wishlistState),
        ),
      ],
    );
  }

  Widget _buildProductsGrid(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> products,
    dynamic wishlistState,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid: 4 columns on large devices, 2 on mobile
        final screenWidth = constraints.maxWidth;
        final crossAxisCount = screenWidth > 840 ? 4 : 2;
        final childAspectRatio = screenWidth > 840 ? 0.8 : 0.75;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final isWishlisted = wishlistState.productWishlistStatus[product.id] ?? false;
            
            return ModernProductCard(
              product: product,
              isWishlisted: isWishlisted,
              onWishlistToggle: () {
                ref.read(wishlistNotifierProvider.notifier)
                    .toggleWishlist(product.id);
              },
              onTap: () {
                context.push('/product/${product.id}');
              },
              onAddToCart: () {
                ref.read(cartNotifierProvider.notifier)
                    .addItem(product, quantity: 1);
                
                // Show success feedback
                AdvancedFeedbackSystem.showSuccess(
                  context: context,
                  message: '${product.name} added to cart',
                  icon: Icons.shopping_cart,
                  enableHaptic: false, // Disable haptic for better performance
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid: 4 columns on large devices, 2 on mobile
        final screenWidth = constraints.maxWidth;
        final crossAxisCount = screenWidth > 840 ? 4 : 2;
        final childAspectRatio = screenWidth > 840 ? 0.8 : 0.75;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
          ),
          itemCount: crossAxisCount == 4 ? 8 : 4, // Show more skeletons on larger screens
          itemBuilder: (context, index) {
            return const ProductCardSkeleton();
          },
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load products',
            style: TypographyUtils.getBodyStyle(
              context,
              size: BodySize.medium,
              isEmphasis: true,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again',
            style: TypographyUtils.getBodyStyle(
              context,
              size: BodySize.small,
              isSecondary: true,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(productNotifierProvider.notifier).loadProducts();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No products available',
            style: TypographyUtils.getBodyStyle(
              context,
              size: BodySize.medium,
              isEmphasis: true,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new products',
            style: TypographyUtils.getBodyStyle(
              context,
              size: BodySize.small,
              isSecondary: true,
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          Expanded(
            flex: 3,
            child: ShimmerLoading(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          
          // Content skeleton
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title skeleton
                  ShimmerLoading(
                    child: Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Price skeleton
                  ShimmerLoading(
                    child: Container(
                      width: 80,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}