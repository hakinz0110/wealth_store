import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_text_styles.dart';
import 'package:wealth_app/core/utils/image_url_helper.dart';
import 'package:wealth_app/core/utils/typography_utils.dart';
import 'package:wealth_app/features/cart/domain/cart_notifier.dart';
import 'package:wealth_app/features/products/domain/product_notifier.dart';
import 'package:wealth_app/features/wishlist/domain/wishlist_notifier.dart';

class EnhancedProductDetailsScreen extends ConsumerStatefulWidget {
  final int productId;

  const EnhancedProductDetailsScreen({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<EnhancedProductDetailsScreen> createState() => _EnhancedProductDetailsScreenState();
}

class _EnhancedProductDetailsScreenState extends ConsumerState<EnhancedProductDetailsScreen>
    with TickerProviderStateMixin {
  int _quantity = 1;
  int _selectedImageIndex = 0;
  
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  
  // Collapsible sections state
  bool _isDescriptionExpanded = true;
  bool _isSpecsExpanded = false;
  bool _isShippingExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load product details
    Future.microtask(() {
      ref.read(productNotifierProvider.notifier).getProduct(widget.productId);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
    HapticFeedback.lightImpact();
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _addToCart() {
    final productState = ref.read(productNotifierProvider);
    final product = productState.selectedProduct;

    if (product == null) return;

    ref.read(cartNotifierProvider.notifier).addItem(product, quantity: _quantity).then((_) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} added to cart'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'View Cart',
            onPressed: () => context.go('/cart'),
          ),
        ),
      );
    });
  }

  void _toggleWishlist() {
    final productState = ref.read(productNotifierProvider);
    final product = productState.selectedProduct;

    if (product == null) return;

    ref.read(wishlistNotifierProvider.notifier).toggleWishlist(product.id);
    HapticFeedback.lightImpact();
  }

  List<String> _getProductImages(String mainImageUrl) {
    // Generate multiple views of the product
    final baseUrl = ImageUrlHelper.getProductImageUrl(mainImageUrl);
    return [
      baseUrl,
      baseUrl, // In a real app, these would be different angles
      baseUrl,
      baseUrl,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productNotifierProvider);
    final wishlistState = ref.watch(wishlistNotifierProvider);
    final product = productState.selectedProduct;
    
    final isWishlisted = product != null ? 
        wishlistState.productWishlistStatus[product.id] ?? false : false;

    if (productState.isLoading || product == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Product Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final images = _getProductImages(product.imageUrl);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Custom app bar with image background
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted ? AppColors.error : Colors.white,
                  ),
                  onPressed: _toggleWishlist,
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {
                    // TODO: Implement share functionality
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageCarousel(images),
            ),
          ),
          
          // Product content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Thumbnail strip
                _buildThumbnailStrip(images),
                
                // Product info
                _buildProductInfo(product),
                
                // Tabbed interface
                _buildTabbedInterface(product),
                
                // Add some bottom padding for the floating action button
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      
      // Floating add to cart button
      floatingActionButton: _buildFloatingAddToCart(product),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildImageCarousel(List<String> images) {
    return Stack(
      children: [
        // Main image carousel with pinch-to-zoom
        PageView.builder(
          controller: _pageController,
          itemCount: images.length,
          onPageChanged: (index) {
            setState(() {
              _selectedImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
            );
          },
        ),
        
        // Page indicators
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _selectedImageIndex == index ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _selectedImageIndex == index
                      ? AppColors.primary
                      : Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnailStrip(List<String> images) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: images.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedImageIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedImageIndex = index;
              });
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              HapticFeedback.lightImpact();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              height: 60,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 20),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductInfo(dynamic product) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name and price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: TypographyUtils.getProductTitleStyle(
                    context,
                    size: ProductTitleSize.large,
                    isEmphasis: true,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TypographyUtils.getPriceStyle(
                      context,
                      size: PriceSize.large,
                    ),
                  ),
                  if (product.stock <= 5 && product.stock > 0)
                    Text(
                      'Only ${product.stock} left',
                      style: TypographyUtils.getStatusStyle(
                        context,
                        StatusType.warning,
                      ),
                    ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Rating
          if (product.rating > 0)
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < product.rating.floor()
                        ? Icons.star
                        : index < product.rating
                            ? Icons.star_half
                            : Icons.star_border,
                    size: 20,
                    color: AppColors.warning,
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  '${product.rating.toStringAsFixed(1)} (${product.reviewCount} reviews)',
                  style: TypographyUtils.getBodyStyle(
                    context,
                    size: BodySize.medium,
                    isSecondary: true,
                  ),
                ),
              ],
            ),
          
          const SizedBox(height: 24),
          
          // Quantity selector
          _buildQuantitySelector(),
          
          const SizedBox(height: 24),
          
          // Collapsible information cards
          _buildCollapsibleCard(
            'Description',
            product.description,
            _isDescriptionExpanded,
            () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
          ),
          
          _buildCollapsibleCard(
            'Specifications',
            _buildSpecifications(product),
            _isSpecsExpanded,
            () => setState(() => _isSpecsExpanded = !_isSpecsExpanded),
          ),
          
          _buildCollapsibleCard(
            'Shipping & Returns',
            _buildShippingInfo(),
            _isShippingExpanded,
            () => setState(() => _isShippingExpanded = !_isShippingExpanded),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        Text(
          'Quantity:',
          style: TypographyUtils.getLabelStyle(
            context,
            size: LabelSize.large,
            isSecondary: false,
          ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _decrementQuantity,
                color: _quantity > 1 ? AppColors.primary : Colors.grey,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$_quantity',
                  style: TypographyUtils.getBodyStyle(
                    context,
                    size: BodySize.medium,
                    isEmphasis: true,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _incrementQuantity,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsibleCard(String title, Widget content, bool isExpanded, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            title: Text(
              title,
              style: TypographyUtils.getHeadingStyle(
                context,
                HeadingLevel.h5,
                isEmphasis: true,
              ),
            ),
            trailing: AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.keyboard_arrow_down),
            ),
            onTap: onTap,
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isExpanded ? null : 0,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: content,
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecifications(dynamic product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSpecRow('Category', 'Category ${product.categoryId}'),
        _buildSpecRow('Stock', '${product.stock} units'),
        _buildSpecRow('Rating', '${product.rating}/5.0'),
        if (product.tags.isNotEmpty)
          _buildSpecRow('Tags', product.tags.join(', ')),
      ],
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TypographyUtils.getLabelStyle(
                context,
                size: LabelSize.medium,
                isSecondary: true,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TypographyUtils.getBodyStyle(
                context,
                size: BodySize.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShippingRow(Icons.local_shipping, 'Free shipping on orders over \$50'),
        _buildShippingRow(Icons.schedule, 'Delivery in 3-5 business days'),
        _buildShippingRow(Icons.refresh, '30-day return policy'),
        _buildShippingRow(Icons.security, 'Secure payment processing'),
      ],
    );
  }

  Widget _buildShippingRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabbedInterface(dynamic product) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Reviews'),
              Tab(text: 'Q&A'),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
          ),
          SizedBox(
            height: 200,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(product),
                _buildReviewsTab(product),
                _buildQATab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(dynamic product) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Text(
          product.description,
          style: AppTextStyles.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildReviewsTab(dynamic product) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '${product.rating.toStringAsFixed(1)}',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < product.rating.floor() ? Icons.star : Icons.star_border,
                        size: 16,
                        color: AppColors.warning,
                      );
                    }),
                  ),
                  Text(
                    '${product.reviewCount} reviews',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Text(
                'No reviews yet. Be the first to review!',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQATab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          'No questions yet. Ask the first question!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingAddToCart(dynamic product) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: product.stock > 0 ? _addToCart : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
        ),
        child: Text(
          product.stock > 0 ? 'Add to Cart - \$${(product.price * _quantity).toStringAsFixed(2)}' : 'Out of Stock',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    )
        .animate()
        .slideY(
          begin: 1,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 300.ms);
  }
}