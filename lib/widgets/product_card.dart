import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../utils/icon_styles.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback onAddToWishlist;
  final bool isInWishlist;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
    required this.onAddToWishlist,
    this.isInWishlist = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool isHovering) {
    setState(() {
      _isHovering = isHovering;
    });
    if (isHovering) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF6518F4);

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Card(
          elevation: _isHovering ? 4 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: primaryColor.withAlpha(26),
            highlightColor: primaryColor.withAlpha(13),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image with wishlist icon (80% of card height)
                  Expanded(
                    flex: 8,
                    child: Stack(
                      children: [
                        // Product image
                        Hero(
                          tag: 'product_image_${widget.product.id}',
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isDarkMode
                                  ? Colors.grey.shade900
                                  : Colors.grey.shade50,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: Image.asset(
                                  widget.product.imageUrl.startsWith('assets/')
                                      ? widget.product.imageUrl
                                      : 'assets/images/products/cat${_getRandomNumber()}_${_getRandomNumber()}.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: isDarkMode
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade100,
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: isDarkMode
                                            ? Colors.grey.shade600
                                            : Colors.grey.shade400,
                                        size: 40,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Wishlist button
                        Positioned(
                          top: 6,
                          right: 6,
                          child: widget.isInWishlist
                              ? Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        primaryColor.withOpacity(0.8),
                                        primaryColor,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryColor.withOpacity(0.4),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.favorite,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                )
                              : Material(
                                  color: isDarkMode
                                      ? Colors.grey.shade800.withOpacity(0.8)
                                      : Colors.white.withOpacity(0.9),
                                  shape: const CircleBorder(),
                                  elevation: 2,
                                  shadowColor: Colors.black.withOpacity(0.2),
                                  child: InkWell(
                                    onTap: widget.onAddToWishlist,
                                    customBorder: const CircleBorder(),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.favorite_border,
                                        color: primaryColor.withOpacity(0.7),
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                        ),

                        // Category tag
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor.withOpacity(0.7),
                                  primaryColor,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.category,
                                  color: Colors.white,
                                  size: 10,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.product.category,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Discount badge if on sale
                        if (widget.product.discountPercentage > 0)
                          Positioned(
                            bottom: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '-${widget.product.discountPercentage.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Product info (20% of card height)
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                        left: 4.0,
                        right: 4.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Product name
                          Text(
                            widget.product.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 4),

                          // Price row with add to cart button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Price
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Current price
                                  Text(
                                    '\$${widget.product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),

                                  // Original price if discounted
                                  if (widget.product.discountPercentage > 0)
                                    Text(
                                      '\$${_calculateOriginalPrice().toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        decoration: TextDecoration.lineThrough,
                                        color: isDarkMode
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                ],
                              ),

                              // Add to cart button
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryColor.withOpacity(0.8),
                                      primaryColor,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: widget.onAddToCart,
                                    borderRadius: BorderRadius.circular(8),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 6,
                                      ),
                                      child: Icon(
                                        Icons.add_shopping_cart,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _calculateOriginalPrice() {
    // Calculate original price based on discount percentage
    if (widget.product.discountPercentage <= 0) {
      return widget.product.price;
    }
    return widget.product.price / (1 - widget.product.discountPercentage / 100);
  }

  // Helper to get a random number for placeholder images
  int _getRandomNumber() {
    return (widget.product.id.hashCode % 5) + 1;
  }
}
