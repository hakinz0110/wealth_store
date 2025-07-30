import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/features/cart/domain/cart_notifier.dart';
import 'package:wealth_app/features/categories/domain/category_notifier.dart';
import 'package:wealth_app/features/products/domain/product_filter_state.dart';
import 'package:wealth_app/features/products/domain/product_notifier.dart';
import 'package:wealth_app/features/wishlist/domain/wishlist_notifier.dart';
import 'package:wealth_app/features/search/data/search_history_repository.dart';
import 'package:wealth_app/shared/widgets/custom_button.dart';
import 'package:wealth_app/shared/widgets/modern_product_card.dart';
import 'package:wealth_app/shared/widgets/empty_states.dart';
import 'package:wealth_app/shared/widgets/loading_states.dart';
import 'package:wealth_app/shared/widgets/shimmer_loading.dart';
import 'package:wealth_app/shared/widgets/success_animations.dart';
import 'package:wealth_app/shared/widgets/modern_search_bar.dart';
import 'package:wealth_app/shared/widgets/search_results_view.dart';
import 'package:wealth_app/shared/widgets/advanced_filter_sidebar.dart';
import 'package:wealth_app/shared/widgets/staggered_animation_list.dart';
import 'package:wealth_app/shared/widgets/parallax_scroll_effect.dart';
import 'package:wealth_app/shared/widgets/hero_animation_wrapper.dart';
import 'package:wealth_app/shared/widgets/responsive_layout.dart';
import 'package:wealth_app/shared/widgets/orientation_builder.dart';
import 'package:wealth_app/shared/widgets/density_aware_widget.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    
    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);

    // Initial loading
    Future.microtask(() {
      ref.read(productNotifierProvider.notifier).loadProducts();
      ref.read(categoryNotifierProvider.notifier).loadCategories();
      ref.read(wishlistNotifierProvider.notifier).loadWishlist();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final productState = ref.read(productNotifierProvider);
      if (!productState.isLoading && productState.hasMore) {
        ref
            .read(productNotifierProvider.notifier)
            .loadMoreProducts(categoryId: productState.filterState.categoryId);
      }
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        ref.read(productNotifierProvider.notifier).searchProducts('');
      }
    });
  }

  void _showFilterBottomSheet() {
    final productState = ref.read(productNotifierProvider);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterBottomSheet(
        minPrice: productState.minPrice,
        maxPrice: productState.maxPrice,
        currentMin: productState.filterState.currentMinPrice,
        currentMax: productState.filterState.currentMaxPrice,
        sortOption: productState.filterState.sortOption,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productNotifierProvider);
    final categoryState = ref.watch(categoryNotifierProvider);
    final wishlistState = ref.watch(wishlistNotifierProvider);

    // Get the filtered products or all products if no filters
    final products = productState.filteredProducts.isNotEmpty 
        ? productState.filteredProducts 
        : productState.products;

    return Scaffold(
      appBar: _isSearching ? null : AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Categories horizontal list
          if (!_isSearching && !categoryState.isLoading && categoryState.categories.isNotEmpty)
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categoryState.categories.length + 1, // +1 for "All" category
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
                itemBuilder: (context, index) {
                  // First item is "All"
                  if (index == 0) {
                    final isSelected = productState.filterState.categoryId == null;
                    return _CategoryChip(
                      label: 'All',
                      isSelected: isSelected,
                      onTap: () {
                        ref.read(productNotifierProvider.notifier).setCategory(null, null);
                      },
                    );
                  }

                  final category = categoryState.categories[index - 1];
                  final isSelected = productState.filterState.categoryId == category.id;
                  
                  return _CategoryChip(
                    label: category.name,
                    isSelected: isSelected,
                    onTap: () {
                      ref.read(productNotifierProvider.notifier)
                          .setCategory(category.id, category.name);
                    },
                  );
                },
              ),
            ),

          // Filter chips for active filters
          if (productState.filterState.categoryName != null ||
              productState.filterState.currentMinPrice > productState.minPrice ||
              productState.filterState.currentMaxPrice < productState.maxPrice)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Category filter
                    if (productState.filterState.categoryName != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text(productState.filterState.categoryName!),
                          onDeleted: () {
                            ref.read(productNotifierProvider.notifier)
                                .setCategory(null, null);
                          },
                        ),
                      ),
                      
                    // Price filter
                    if (productState.filterState.currentMinPrice > productState.minPrice ||
                        productState.filterState.currentMaxPrice < productState.maxPrice)
                      Chip(
                        label: Text('\$${productState.filterState.currentMinPrice.toInt()}'
                            ' - \$${productState.filterState.currentMaxPrice.toInt()}'),
                        onDeleted: () {
                          ref.read(productNotifierProvider.notifier).setPriceRange(
                            productState.minPrice,
                            productState.maxPrice,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

          // Product grid
          Expanded(
            child: productState.isLoading && products.isEmpty
                ? const ProductGridSkeleton(itemCount: 6)
                : productState.error != null && products.isEmpty
                    ? ErrorState(
                        title: 'Failed to load products',
                        description: productState.error!,
                        onRetry: () {
                          ref.read(productNotifierProvider.notifier).loadProducts();
                        },
                      )
                    : products.isEmpty
                        ? EmptySearchState(
                            searchQuery: _searchController.text.isNotEmpty ? _searchController.text : null,
                            onClearSearch: () {
                              _searchController.clear();
                              ref.read(productNotifierProvider.notifier).updateFilters(
                                    ProductFilterState.initial(),
                                  );
                            },
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await ref
                                  .read(productNotifierProvider.notifier)
                                  .loadProducts(categoryId: productState.filterState.categoryId);
                            },
                            child: _buildAnimatedProductGrid(
                              products,
                              productState,
                              wishlistState,
                              ref,
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedProductGrid(
    List<dynamic> products,
    dynamic productState,
    dynamic wishlistState,
    WidgetRef ref,
  ) {
    // Create list of widgets including loading placeholders
    final allItems = <Widget>[];
    
    // Add product cards
    for (int i = 0; i < products.length; i++) {
      final product = products[i];
      final isWishlisted = wishlistState.productWishlistStatus[product.id] ?? false;
      
      allItems.add(
        StaggeredAnimationItem(
          index: i,
          delay: const Duration(milliseconds: 80),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          slideOffset: 30.0,
          child: HeroAnimationWrapper(
            tag: 'product-${product.id}',
            child: ModernProductCard(
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
                
                // Show success animation
                FloatingSuccessMessage.show(
                  context,
                  message: '${product.name} added to cart',
                  icon: Icons.shopping_cart,
                  color: AppColors.success,
                );
              },
            ),
          ),
        ),
      );
    }
    
    // Add loading placeholders if needed
    if (productState.isLoading && products.isNotEmpty) {
      for (int i = 0; i < 2; i++) {
        allItems.add(
          ShimmerLoading(
            child: ProductCardSkeleton(),
          ),
        );
      }
    }
    
    return ResponsiveGridView(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSpacing.medium),
      compactColumns: 2,
      mediumColumns: 3,
      expandedColumns: 4,
      compactColumnsLandscape: 3,
      mediumColumnsLandscape: 4,
      expandedColumnsLandscape: 5,
      spacing: AppSpacing.medium,
      runSpacing: AppSpacing.medium,
      childAspectRatio: 0.7,
      children: allItems,
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4.0,
        vertical: 8.0,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey[300]!,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : null,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductItem extends StatelessWidget {
  final dynamic product;
  final bool isWishlisted;
  final VoidCallback onWishlistToggle;
  final VoidCallback onTap;
  
  const _ProductItem({
    required this.product,
    required this.isWishlisted,
    required this.onWishlistToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: product.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: onWishlistToggle,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: isWishlisted ? AppColors.error : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
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

class _ProductItemPlaceholder extends StatelessWidget {
  const _ProductItemPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: Colors.grey[300],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 16,
                  width: 80,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBottomSheet extends ConsumerStatefulWidget {
  final double minPrice;
  final double maxPrice;
  final double currentMin;
  final double currentMax;
  final ProductSortOption sortOption;

  const _FilterBottomSheet({
    required this.minPrice,
    required this.maxPrice,
    required this.currentMin,
    required this.currentMax,
    required this.sortOption,
  });

  @override
  ConsumerState<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<_FilterBottomSheet> {
  late double _currentMinPrice;
  late double _currentMaxPrice;
  late ProductSortOption _selectedSortOption;

  @override
  void initState() {
    super.initState();
    _currentMinPrice = widget.currentMin;
    _currentMaxPrice = widget.currentMax;
    _selectedSortOption = widget.sortOption;
  }

  void _applyFilters() {
    ref.read(productNotifierProvider.notifier).setPriceRange(
      _currentMinPrice,
      _currentMaxPrice,
    );
    
    ref.read(productNotifierProvider.notifier).setSortOption(_selectedSortOption);
    
    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      _currentMinPrice = widget.minPrice;
      _currentMaxPrice = widget.maxPrice;
      _selectedSortOption = ProductSortOption.newest;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: _resetFilters,
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          
          // Price Range
          Text(
            'Price Range',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.small),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$${_currentMinPrice.toInt()}'),
              Text('\$${_currentMaxPrice.toInt()}'),
            ],
          ),
          RangeSlider(
            values: RangeValues(_currentMinPrice, _currentMaxPrice),
            min: widget.minPrice,
            max: widget.maxPrice,
            divisions: 100,
            labels: RangeLabels(
              '\$${_currentMinPrice.toInt()}',
              '\$${_currentMaxPrice.toInt()}',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _currentMinPrice = values.start;
                _currentMaxPrice = values.end;
              });
            },
          ),
          
          const SizedBox(height: AppSpacing.medium),
          
          // Sort options
          Text(
            'Sort By',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.small),
          Wrap(
            spacing: 8.0,
            children: ProductSortOption.values.map((option) {
              return ChoiceChip(
                label: Text(option.displayName),
                selected: _selectedSortOption == option,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedSortOption = option;
                    });
                  }
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: AppSpacing.large),
          
          // Apply button
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Apply Filters',
              onPressed: _applyFilters,
            ),
          ),
        ],
      ),
    );
  }
} 