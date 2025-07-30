import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/features/wishlist/domain/wishlist_notifier.dart';
import 'package:wealth_app/shared/models/wishlist_item.dart';
import 'package:wealth_app/shared/widgets/base_screen.dart';
import 'package:wealth_app/shared/widgets/product_card.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistState = ref.watch(wishlistNotifierProvider);
    
    return BaseScreen(
      title: 'My Wishlist',
      actions: [
        if (wishlistState.items.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareWishlist(context, wishlistState.items),
          ),
      ],
      body: wishlistState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : wishlistState.items.isEmpty
              ? _buildEmptyState(context)
              : _buildWishlistGrid(context, ref, wishlistState.items),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'Your wishlist is empty',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'Add items to your wishlist by tapping the heart icon',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.large),
          ElevatedButton(
            onPressed: () => context.go('/products'),
            child: const Text('Browse Products'),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistGrid(BuildContext context, WidgetRef ref, List<WishlistItem> items) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(wishlistNotifierProvider.notifier).loadWishlist();
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.small),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: AppSpacing.small,
          mainAxisSpacing: AppSpacing.small,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final wishlistItem = items[index];
          // Skip items without product data
          if (wishlistItem.product == null) {
            return const SizedBox.shrink();
          }
          
          final product = wishlistItem.product!;
          return Stack(
            children: [
              ProductCard(
                product: product,
                onTap: () => context.push('/product/${product.id}'),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.favorite,
                      color: AppColors.primary,
                    ),
                    onPressed: () {
                      ref.read(wishlistNotifierProvider.notifier).removeFromWishlist(product.id);
                    },
                    constraints: const BoxConstraints(
                      minHeight: 36,
                      minWidth: 36,
                    ),
                    padding: EdgeInsets.zero,
                    iconSize: 20,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _shareWishlist(BuildContext context, List<WishlistItem> items) {
    final productNames = items
        .where((item) => item.product != null)
        .map((item) => item.product!.name)
        .join('\n- ');
    
    final shareText = 'Check out my wishlist from Wealth App:\n\n- $productNames';
    
    Share.share(
      shareText,
      subject: 'My Wealth App Wishlist',
    );
  }
} 