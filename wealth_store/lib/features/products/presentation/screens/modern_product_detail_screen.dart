import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/utils/typography_utils.dart';
import 'package:wealth_app/core/utils/haptic_feedback_utils.dart';
import 'package:wealth_app/features/products/domain/product_notifier.dart';
import 'package:wealth_app/features/cart/domain/cart_notifier.dart';
import 'package:wealth_app/features/wishlist/domain/wishlist_notifier.dart';
import 'package:wealth_app/shared/models/product.dart';
import 'package:wealth_app/shared/models/product_variation.dart';
import 'package:wealth_app/shared/widgets/advanced_feedback_system.dart';

class ModernProductDetailScreen extends ConsumerStatefulWidget {
  final int productId;

  const ModernProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<ModernProductDetailScreen> createState() => _ModernProductDetailScreenState();
}

class _ModernProductDetailScreenState extends ConsumerState<ModernProductDetailScreen> {
  int _quantity = 1;
  int _selectedImageIndex = 0;
  ProductVariation? _selectedVariation;
  Map<String, String> _selectedAttributes = {};
  bool _showDescription = false;

  @override
  void initState() {
    super.initState();
    // Load product details
    Future.microtask(() {
      ref.read(productNotifierProvider.notifier).getProduct(widget.productId);
    });
  }

  void _selectVariation(ProductVariation variation) {
    setState(() {
      _selectedVariation = variation;
      _selectedAttributes = Map.from(variation.attributes);
    });
    HapticFeedbackUtils.lightImpact();
  }

  void _updateAttribute(String attributeName, String value) {
    setState(() {
      _selectedAttributes[attributeName] = value;
    });
    HapticFeedbackUtils.lightImpact();
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
    HapticFeedbackUtils.lightImpact();
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
      HapticFeedbackUtils.lightImpact();
    }
  }

  void _addToCart(Product product) {
    HapticFeedbackUtils.mediumImpact();
    ref.read(cartNotifierProvider.notifier).addItem(product, quantity: _quantity);
    
    AdvancedFeedbackSystem.showSuccess(
      context: context,
      message: '${product.name} added to cart',
      icon: Icons.shopping_cart,
      enableHaptic: true,
    );
  }

  void _toggleWishlist(int productId) {
    HapticFeedbackUtils.lightImpact();
    ref.read(wishlistNotifierProvider.notifier).toggleWishlist(productId);
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productNotifierProvider);
    final wishlistState = ref.watch(wishlistNotifierProvider);
    final product = productState.selectedProduct;

    if (productState.isLoading || product == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isWishlisted = wishlistState.productWishlistStatus[product.id] ?? false;
    
    // For demo purposes, create a mock enhanced product
    // In real implementation, this would come from your database
    final enhancedProduct = _createMockEnhancedProduct(product);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: isWishlisted ? Colors.red : Colors.black,
            ),
            onPressed: () => _toggleWishlist(product.id),
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Images
                  _buildProductImages(enhancedProduct),
                  
                  // Product Info
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rating and Share
                        _buildRatingAndShare(enhancedProduct),
                        
                        const SizedBox(height: AppSpacing.sm),
                        
                        // Discount Badge and Price
                        _buildPriceSection(enhancedProduct),
                        
                        const SizedBox(height: AppSpacing.sm),
                        
                        // Product Name
                        Text(
                          enhancedProduct.name,
                          style: TypographyUtils.getHeadingStyle(
                            context,
                            HeadingLevel.h4,
                            isEmphasis: true,
                          ),
                        ),
                        
                        const SizedBox(height: AppSpacing.xs),
                        
                        // Stock Status
                        _buildStockStatus(enhancedProduct),
                        
                        const SizedBox(height: AppSpacing.sm),
                        
                        // Brand
                        _buildBrandSection(),
                        
                        const SizedBox(height: AppSpacing.lg),
                        
                        // Variations (if product has variations)
                        if (enhancedProduct.hasVariations) ...[
                          _buildVariationsSection(enhancedProduct),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        
                        // Quantity and Add to Bag
                        _buildQuantityAndAddToBag(product),
                        
                        const SizedBox(height: AppSpacing.lg),
                        
                        // Description
                        _buildDescriptionSection(enhancedProduct),
                        
                        const SizedBox(height: AppSpacing.lg),
                        
                        // Reviews
                        _buildReviewsSection(enhancedProduct),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Checkout Button
          _buildCheckoutButton(product),
        ],
      ),
    );
  }

  Widget _buildProductImages(EnhancedProduct product) {
    final images = product.imageUrls.isNotEmpty ? product.imageUrls : [product.imageUrl];
    
    return Container(
      height: 400, // Increased height for better image display
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Stack(
        children: [
          // Main Image with improved styling
          PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _selectedImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[50], // Light background
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md), // Add padding around image
                    child: CachedNetworkImage(
                      imageUrl: images[index],
                      fit: BoxFit.contain, // Changed to contain for better image display
                      placeholder: (context, url) => Container(
                        color: Colors.grey[100],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[100],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Image not available',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Page indicators (if multiple images)
          if (images.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _selectedImageIndex
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThumbnailStrip(List<String> images) {
    return Container(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: images.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedImageIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedImageIndex = index;
              });
            },
            child: Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingAndShare(EnhancedProduct product) {
    return Row(
      children: [
        Icon(Icons.star, color: Colors.amber, size: 20),
        const SizedBox(width: 4),
        Text(
          '${product.rating.toStringAsFixed(1)} (${product.reviewCount})',
          style: TypographyUtils.getBodyStyle(context, size: BodySize.medium),
        ),
        const Spacer(),
        Icon(Icons.share, color: Colors.grey[600], size: 20),
      ],
    );
  }

  Widget _buildPriceSection(EnhancedProduct product) {
    return Row(
      children: [
        // Discount Badge
        if (product.hasVariations)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '78%', // Mock discount
              style: TypographyUtils.getLabelStyle(
                context,
                size: LabelSize.small,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        const SizedBox(width: 8),
        
        // Price
        Text(
          product.priceRange,
          style: TypographyUtils.getHeadingStyle(
            context,
            HeadingLevel.h3,
            isEmphasis: true,
          ),
        ),
      ],
    );
  }

  Widget _buildStockStatus(EnhancedProduct product) {
    return Row(
      children: [
        Text(
          'Stock: ',
          style: TypographyUtils.getBodyStyle(context, size: BodySize.medium, isSecondary: true),
        ),
        Text(
          product.isInStock ? 'In Stock' : 'Out of Stock',
          style: TypographyUtils.getBodyStyle(
            context,
            size: BodySize.medium,
          ).copyWith(
            color: product.isInStock ? Colors.green : Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBrandSection() {
    return Row(
      children: [
        Icon(Icons.verified, color: Colors.blue, size: 16),
        const SizedBox(width: 4),
        Text(
          'Nike',
          style: TypographyUtils.getBodyStyle(
            context,
            size: BodySize.medium,
          ).copyWith(color: Colors.blue, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildVariationsSection(EnhancedProduct product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedVariation != null) ...[
          Text(
            'Variation:',
            style: TypographyUtils.getHeadingStyle(context, HeadingLevel.h5),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Text(
                'Price: ',
                style: TypographyUtils.getBodyStyle(context, size: BodySize.medium),
              ),
              Text(
                '\$${_selectedVariation!.price.toStringAsFixed(2)}',
                style: TypographyUtils.getBodyStyle(
                  context,
                  size: BodySize.medium,
                  isEmphasis: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Text(
                'Stock: ',
                style: TypographyUtils.getBodyStyle(context, size: BodySize.medium),
              ),
              Text(
                _selectedVariation!.stock > 0 ? 'In Stock' : 'Out of Stock',
                style: TypographyUtils.getBodyStyle(
                  context,
                  size: BodySize.medium,
                ).copyWith(
                  color: _selectedVariation!.stock > 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        
        // Color Selection
        if (product.attributes.any((attr) => attr.name.toLowerCase() == 'color'))
          _buildColorSelection(product),
        
        // Size Selection
        if (product.attributes.any((attr) => attr.name.toLowerCase() == 'size'))
          _buildSizeSelection(product),
      ],
    );
  }

  Widget _buildColorSelection(EnhancedProduct product) {
    final colorAttr = product.attributes.firstWhere(
      (attr) => attr.name.toLowerCase() == 'color',
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: TypographyUtils.getHeadingStyle(context, HeadingLevel.h5),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: colorAttr.values.map((color) {
            final isSelected = _selectedAttributes['color'] == color;
            return GestureDetector(
              onTap: () => _updateAttribute('color', color),
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getColorFromName(color),
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey[300]!,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _buildSizeSelection(EnhancedProduct product) {
    final sizeAttr = product.attributes.firstWhere(
      (attr) => attr.name.toLowerCase() == 'size',
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Size',
          style: TypographyUtils.getHeadingStyle(context, HeadingLevel.h5),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          children: sizeAttr.values.map((size) {
            final isSelected = _selectedAttributes['size'] == size;
            return GestureDetector(
              onTap: () => _updateAttribute('size', size),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  size,
                  style: TypographyUtils.getBodyStyle(
                    context,
                    size: BodySize.medium,
                  ).copyWith(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantityAndAddToBag(Product product) {
    return Row(
      children: [
        // Quantity Selector
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
                color: _quantity > 1 ? Colors.black : Colors.grey,
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
                color: Colors.black,
              ),
            ],
          ),
        ),
        
        const SizedBox(width: AppSpacing.md),
        
        // Add to Bag Button
        Expanded(
          child: ElevatedButton(
            onPressed: product.stock > 0 ? () => _addToCart(product) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Add to Bag',
                  style: TypographyUtils.getBodyStyle(
                    context,
                    size: BodySize.medium,
                    isEmphasis: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(EnhancedProduct product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _showDescription = !_showDescription;
            });
          },
          child: Row(
            children: [
              Text(
                'Description',
                style: TypographyUtils.getHeadingStyle(context, HeadingLevel.h5),
              ),
              const Spacer(),
              Icon(
                _showDescription ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
        if (_showDescription) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            product.description,
            style: TypographyUtils.getBodyStyle(context, size: BodySize.medium),
          ),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: () {
              setState(() {
                _showDescription = false;
              });
            },
            child: Text(
              'Show less',
              style: TypographyUtils.getBodyStyle(
                context,
                size: BodySize.medium,
              ).copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${product.description.substring(0, product.description.length > 100 ? 100 : product.description.length)}...',
            style: TypographyUtils.getBodyStyle(context, size: BodySize.medium),
          ),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: () {
              setState(() {
                _showDescription = true;
              });
            },
            child: Text(
              'Show more',
              style: TypographyUtils.getBodyStyle(
                context,
                size: BodySize.medium,
              ).copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewsSection(EnhancedProduct product) {
    return GestureDetector(
      onTap: () {
        // Navigate to reviews screen
      },
      child: Row(
        children: [
          Text(
            'Reviews (${product.reviewCount})',
            style: TypographyUtils.getHeadingStyle(context, HeadingLevel.h5),
          ),
          const Spacer(),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey[600],
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(Product product) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: product.stock > 0 ? () {
            // Navigate to checkout
            context.push('/checkout');
          } : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Checkout',
            style: TypographyUtils.getHeadingStyle(
              context,
              HeadingLevel.h5,
            ).copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  // Helper methods
  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Mock data creation (replace with real data from your database)
  EnhancedProduct _createMockEnhancedProduct(Product product) {
    // For demo purposes, randomly decide if product has variations
    final hasVariations = product.id % 2 == 0; // Even IDs have variations
    
    if (hasVariations) {
      return EnhancedProduct(
        id: product.id,
        name: product.name,
        description: product.description,
        basePrice: product.price,
        imageUrl: product.imageUrl,
        categoryId: product.categoryId,
        baseStock: product.stock,
        rating: product.rating,
        reviewCount: product.reviewCount,
        isFeatured: product.isFeatured,
        hasVariations: true,
        tags: product.tags,
        imageUrls: [product.imageUrl], // In real app, fetch multiple images
        variations: [
          ProductVariation(
            id: 1,
            productId: product.id,
            name: 'Red - EU 34',
            price: product.price + 10,
            stock: 5,
            attributes: {'color': 'red', 'size': 'EU 34'},
          ),
          ProductVariation(
            id: 2,
            productId: product.id,
            name: 'Green - EU 32',
            price: product.price,
            stock: 0,
            attributes: {'color': 'green', 'size': 'EU 32'},
          ),
          ProductVariation(
            id: 3,
            productId: product.id,
            name: 'Black - EU 30',
            price: product.price - 5,
            stock: 10,
            attributes: {'color': 'black', 'size': 'EU 30'},
          ),
        ],
        attributes: [
          const ProductAttribute(
            name: 'Color',
            values: ['red', 'green', 'black'],
            type: AttributeType.color,
          ),
          const ProductAttribute(
            name: 'Size',
            values: ['EU 30', 'EU 32', 'EU 34'],
            type: AttributeType.size,
          ),
        ],
        createdAt: product.createdAt,
      );
    } else {
      return EnhancedProduct(
        id: product.id,
        name: product.name,
        description: product.description,
        basePrice: product.price,
        imageUrl: product.imageUrl,
        categoryId: product.categoryId,
        baseStock: product.stock,
        rating: product.rating,
        reviewCount: product.reviewCount,
        isFeatured: product.isFeatured,
        hasVariations: false,
        tags: product.tags,
        imageUrls: [product.imageUrl],
        createdAt: product.createdAt,
      );
    }
  }
}