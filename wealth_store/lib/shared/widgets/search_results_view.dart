import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/constants/app_text_styles.dart';
import 'package:wealth_app/core/constants/app_shadows.dart';
import 'package:wealth_app/shared/models/product.dart';
import 'package:wealth_app/shared/widgets/modern_product_card.dart';

enum ViewType { grid, list }

class SearchResultsView extends StatefulWidget {
  final List<Product> products;
  final bool isLoading;
  final String? searchQuery;
  final ViewType initialViewType;
  final Function(Product)? onProductTap;
  final Function(Product)? onAddToCart;
  final Function(Product)? onToggleWishlist;
  final Map<int, bool>? wishlistStatus;
  final VoidCallback? onLoadMore;
  final bool hasMore;

  const SearchResultsView({
    super.key,
    required this.products,
    this.isLoading = false,
    this.searchQuery,
    this.initialViewType = ViewType.grid,
    this.onProductTap,
    this.onAddToCart,
    this.onToggleWishlist,
    this.wishlistStatus,
    this.onLoadMore,
    this.hasMore = false,
  });

  @override
  State<SearchResultsView> createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<SearchResultsView>
    with TickerProviderStateMixin {
  late ViewType _currentViewType;
  late AnimationController _toggleController;
  late Animation<double> _toggleAnimation;

  @override
  void initState() {
    super.initState();
    _currentViewType = widget.initialViewType;
    _toggleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _toggleAnimation = CurvedAnimation(
      parent: _toggleController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _toggleController.dispose();
    super.dispose();
  }

  void _toggleViewType() {
    setState(() {
      _currentViewType = _currentViewType == ViewType.grid ? ViewType.list : ViewType.grid;
    });
    
    _toggleController.forward().then((_) {
      _toggleController.reverse();
    });
    
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Results header with view toggle
        _buildResultsHeader(),
        
        // Results content
        Expanded(
          child: _buildResultsContent(),
        ),
      ],
    );
  }

  Widget _buildResultsHeader() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppShadows.elevation1,
      ),
      child: Row(
        children: [
          // Results count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty)
                  Text(
                    'Results for "${widget.searchQuery}"',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                Text(
                  '${widget.products.length} products found',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
          
          // View toggle buttons
          Container(
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildViewToggleButton(
                  icon: Icons.grid_view,
                  isSelected: _currentViewType == ViewType.grid,
                  onPressed: () {
                    if (_currentViewType != ViewType.grid) {
                      _toggleViewType();
                    }
                  },
                ),
                _buildViewToggleButton(
                  icon: Icons.view_list,
                  isSelected: _currentViewType == ViewType.list,
                  onPressed: () {
                    if (_currentViewType != ViewType.list) {
                      _toggleViewType();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return AnimatedBuilder(
      animation: _toggleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected ? 1.0 + (_toggleAnimation.value * 0.1) : 1.0,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                boxShadow: isSelected ? AppShadows.elevation1 : null,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.primary : AppColors.neutral600,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultsContent() {
    if (widget.isLoading && widget.products.isEmpty) {
      return _buildLoadingState();
    }

    if (widget.products.isEmpty) {
      return _buildEmptyState();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _currentViewType == ViewType.grid
          ? _buildGridView()
          : _buildListView(),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      key: const ValueKey('grid'),
      padding: EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: widget.products.length + (widget.hasMore ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.products.length) {
          // Load more trigger
          if (index == widget.products.length && widget.onLoadMore != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.onLoadMore!();
            });
          }
          return _buildLoadingCard();
        }

        final product = widget.products[index];
        final isWishlisted = widget.wishlistStatus?[product.id] ?? false;

        return ModernProductCard(
          product: product,
          isWishlisted: isWishlisted,
          onTap: () => widget.onProductTap?.call(product),
          onAddToCart: () => widget.onAddToCart?.call(product),
          onWishlistToggle: () => widget.onToggleWishlist?.call(product),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: (index * 50).ms)
            .slideY(begin: 0.1, end: 0, duration: 300.ms);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      key: const ValueKey('list'),
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: widget.products.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.products.length) {
          // Load more trigger
          if (widget.onLoadMore != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.onLoadMore!();
            });
          }
          return _buildLoadingListItem();
        }

        final product = widget.products[index];
        final isWishlisted = widget.wishlistStatus?[product.id] ?? false;

        return ProductListItem(
          product: product,
          isWishlisted: isWishlisted,
          onTap: () => widget.onProductTap?.call(product),
          onAddToCart: () => widget.onAddToCart?.call(product),
          onWishlistToggle: () => widget.onToggleWishlist?.call(product),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: (index * 30).ms)
            .slideX(begin: 0.1, end: 0, duration: 300.ms);
      },
    );
  }

  Widget _buildLoadingState() {
    return GridView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _buildLoadingCard(),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusMd),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.neutral200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Container(
                    height: 14,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.neutral200,
                      borderRadius: BorderRadius.circular(7),
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

  Widget _buildLoadingListItem() {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppShadows.elevation1,
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.neutral200,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.neutral200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Container(
                  height: 14,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppColors.neutral200,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Container(
                  height: 18,
                  width: 60,
                  decoration: BoxDecoration(
                    color: AppColors.neutral200,
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.neutral400,
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            widget.searchQuery != null && widget.searchQuery!.isNotEmpty
                ? 'No results for "${widget.searchQuery}"'
                : 'No products found',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Try adjusting your search terms or filters',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.neutral600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Product list item for list view
class ProductListItem extends StatelessWidget {
  final Product product;
  final bool isWishlisted;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onWishlistToggle;

  const ProductListItem({
    super.key,
    required this.product,
    this.isWishlisted = false,
    this.onTap,
    this.onAddToCart,
    this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.md),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: AppShadows.productCard,
          border: Border.all(
            color: AppColors.neutral200.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Container(
                width: 80,
                height: 80,
                color: AppColors.neutral100,
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_not_supported,
                            color: AppColors.neutral400,
                          );
                        },
                      )
                    : Icon(
                        Icons.image_not_supported,
                        color: AppColors.neutral400,
                      ),
              ),
            ),
            
            SizedBox(width: AppSpacing.md),
            
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: AppSpacing.xs),
                  
                  if (product.description.isNotEmpty)
                    Text(
                      product.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.neutral600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  SizedBox(height: AppSpacing.sm),
                  
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Action buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              onWishlistToggle?.call();
                            },
                            icon: Icon(
                              isWishlisted ? Icons.favorite : Icons.favorite_border,
                              color: isWishlisted ? AppColors.error : AppColors.neutral500,
                              size: 20,
                            ),
                          ),
                          
                          IconButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              onAddToCart?.call();
                            },
                            icon: Icon(
                              Icons.add_shopping_cart,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}