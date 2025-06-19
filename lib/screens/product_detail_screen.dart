import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/user_activity_provider.dart';
import '../models/review_model.dart';
import '../widgets/reviews_section.dart';
import '../utils/responsive.dart'; // Import responsive utilities
import '../utils/icon_styles.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isExpanded = false;
  int _quantity = 1;

  // For variations
  String? _selectedColor;
  String? _selectedSize;
  ProductVariation? _selectedVariation;

  // For image carousel
  late PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();

    // Track product view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserActivityProvider>(
        context,
        listen: false,
      ).trackProductView(widget.product);
    });

    // Initialize variation selection if needed
    if (widget.product.type == 'variation' &&
        widget.product.variations != null &&
        widget.product.variations!.isNotEmpty) {
      _selectedColor = widget.product.variations!.first.color;
      _selectedSize = widget.product.variations!.first.size;
      _selectedVariation = widget.product.variations!.first;
    }
  }

  void _onSelectColor(String color) {
    setState(() {
      _selectedColor = color;
      // Update size to first available for this color
      final sizes = widget.product.variations!
          .where((v) => v.color == color)
          .map((v) => v.size)
          .toSet();
      _selectedSize = sizes.isNotEmpty ? sizes.first : null;
      _selectedVariation = widget.product.variations!.firstWhere(
        (v) => v.color == _selectedColor && v.size == _selectedSize,
        orElse: () => widget.product.variations!.first,
      );
    });
  }

  void _onSelectSize(String size) {
    setState(() {
      _selectedSize = size;
      _selectedVariation = widget.product.variations!.firstWhere(
        (v) => v.color == _selectedColor && v.size == size,
        orElse: () => widget.product.variations!.first,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Get responsive font size
  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return baseSize * 0.8; // Smaller font for very small devices
    } else if (screenWidth < 600) {
      return baseSize * 0.9; // Slightly smaller font for phones
    } else {
      return baseSize; // Default size for larger devices
    }
  }

  // Get responsive padding
  EdgeInsets _getResponsivePadding(
    BuildContext context, {
    bool isSmall = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return EdgeInsets.all(isSmall ? 8.0 : 12.0);
    } else {
      return EdgeInsets.all(isSmall ? 12.0 : 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isInWishlist = favoritesProvider.isFavorite(widget.product);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final reviews = ReviewModel.getDummyReviews();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Price range for variations
    double? minPrice, maxPrice;
    if (widget.product.type == 'variation' &&
        widget.product.variations != null &&
        widget.product.variations!.isNotEmpty) {
      minPrice = widget.product.variations!
          .map((v) => v.price)
          .reduce((a, b) => a < b ? a : b);
      maxPrice = widget.product.variations!
          .map((v) => v.price)
          .reduce((a, b) => a > b ? a : b);
    }

    // Product images: support multiple images if available
    List<String> images = [];
    if (widget.product.imageUrl.contains(',')) {
      images = widget.product.imageUrl.split(',').map((e) => e.trim()).toList();
    } else {
      images = [widget.product.imageUrl];
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App bar with modern design
            Container(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12),
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button with modern design
                  ModernIconStyles.circularButton(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: () => Navigator.of(context).pop(),
                    context: context,
                    size: 38,
                    backgroundColor: isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade100,
                    iconColor: isDarkMode
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                  ),
                  // Title
                  Text(
                    'Product Details',
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Action buttons
                  Row(
                    children: [
                      // Wishlist button with modern animation
                      isInWishlist
                          ? Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.redAccent.withOpacity(0.8),
                                    Colors.red,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  favoritesProvider.toggleFavorite(
                                    widget.product,
                                  );
                                },
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            )
                          : ModernIconStyles.circularButton(
                              icon: Icons.favorite_border_outlined,
                              onPressed: () {
                                favoritesProvider.toggleFavorite(
                                  widget.product,
                                );
                              },
                              context: context,
                              size: 38,
                              backgroundColor: isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade100,
                              iconColor: isDarkMode
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                    ],
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product image carousel
                    SizedBox(
                      height: isSmallScreen ? 260 : 300,
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: images.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Container(
                                color: isDarkMode
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade100,
                                child: Image.asset(
                                  images[index],
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const SizedBox.shrink();
                                  },
                                ),
                              );
                            },
                          ),
                          if (images.length > 1)
                            Positioned(
                              bottom: 12,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(images.length, (index) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: _currentImageIndex == index ? 16 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _currentImageIndex == index
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  );
                                }),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Product info
                    Padding(
                      padding: _getResponsivePadding(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name and price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name
                              Expanded(
                                child: Text(
                                  widget.product.name,
                                  style: TextStyle(
                                    fontSize: _getResponsiveFontSize(
                                      context,
                                      24,
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Price
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (widget.product.type == 'variation' &&
                                      minPrice != null &&
                                      maxPrice != null)
                                    Text(
                                      '\$${minPrice.toStringAsFixed(2)} - \$${maxPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: _getResponsiveFontSize(
                                          context,
                                          22,
                                        ),
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    )
                                  else
                                    Text(
                                      '\$${widget.product.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: _getResponsiveFontSize(
                                          context,
                                          22,
                                        ),
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  if (widget.product.rating > 0)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          widget.product.rating.toString(),
                                          style: TextStyle(
                                            color: isDarkMode
                                                ? Colors.grey.shade300
                                                : Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(height: isSmallScreen ? 12 : 16),

                          // Category
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.product.category,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: _getResponsiveFontSize(context, 14),
                              ),
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 16 : 24),

                          // Tab bar with modern design
                          Container(
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey.shade800.withOpacity(0.3)
                                  : Colors.grey.shade200.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              labelColor: Theme.of(context).primaryColor,
                              unselectedLabelColor: isDarkMode
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                              indicator: BoxDecoration(
                                color: isDarkMode
                                    ? Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.2)
                                    : Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              dividerColor: Colors.transparent,
                              labelStyle: TextStyle(
                                fontSize: _getResponsiveFontSize(context, 14),
                                fontWeight: FontWeight.bold,
                              ),
                              tabs: const [
                                Tab(text: 'Description'),
                                Tab(text: 'Specs'),
                                Tab(text: 'Reviews'),
                              ],
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 12 : 16),

                          // Tab content
                          SizedBox(
                            height: 200,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // Description tab
                                SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.product.description.isEmpty
                                            ? 'No description available for this product.'
                                            : widget.product.description,
                                        style: TextStyle(
                                          fontSize: _getResponsiveFontSize(
                                            context,
                                            15,
                                          ),
                                          color: isDarkMode
                                              ? Colors.grey.shade300
                                              : Colors.grey.shade700,
                                        ),
                                      ),
                                      if (widget.product.description.length >
                                              100 &&
                                          !_isExpanded) ...[
                                        const SizedBox(height: 8),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _isExpanded = true;
                                            });
                                          },
                                          child: Text(
                                            'Read more',
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                // Specifications tab
                                ListView(
                                  children: [
                                    _buildSpecificationRow(
                                      'Brand',
                                      'Wealth Tech',
                                    ),
                                    _buildSpecificationRow(
                                      'Model',
                                      widget.product.name,
                                    ),
                                    _buildSpecificationRow(
                                      'Category',
                                      widget.product.category,
                                    ),
                                    _buildSpecificationRow(
                                      'Rating',
                                      '${widget.product.rating}/5',
                                    ),
                                    _buildSpecificationRow('In Stock', 'Yes'),
                                  ],
                                ),

                                // Reviews tab
                                ListView(
                                  children: [
                                    for (final review in reviews)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 16.0,
                                        ),
                                        child: _buildReviewItem(review),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 16 : 24),

                          // Similar products with modern header
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Similar Products',
                                style: TextStyle(
                                  fontSize: _getResponsiveFontSize(context, 18),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: isSmallScreen ? 6 : 8),

                          // Placeholder for similar products
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey.shade800.withOpacity(0.3)
                                  : Colors.grey.shade200.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Similar products will appear here',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                  fontSize: _getResponsiveFontSize(context, 14),
                                ),
                              ),
                            ),
                          ),

                          // Customer reviews section
                          ReviewsSection(
                            reviews: reviews,
                            onSeeAllTap: () {
                              // Navigate to all reviews
                              _tabController.animateTo(2);
                            },
                            isLoading: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom bar with add to cart button
            Container(
              padding: _getResponsivePadding(context, isSmall: true),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Quantity selector with modern design
                  ModernIconStyles.quantityControl(
                    onDecrement: () {
                      if (_quantity > 1) {
                        setState(() {
                          _quantity--;
                        });
                      }
                    },
                    onIncrement: () {
                      setState(() {
                        _quantity++;
                      });
                    },
                    quantity: _quantity,
                    context: context,
                  ),

                  SizedBox(width: isSmallScreen ? 12 : 16),

                  // Add to cart button with modern design
                  Expanded(
                    child: Container(
                      height: isSmallScreen ? 45 : 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(0.8),
                            Theme.of(context).primaryColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap:
                              (widget.product.type == 'variation' &&
                                  (_selectedVariation == null ||
                                      !_selectedVariation!.inStock))
                              ? null
                              : () {
                                  // For variation, add selected variation; for single, add product
                                  if (widget.product.type == 'variation' &&
                                      _selectedVariation != null) {
                                    // Add quantity times
                                    for (int i = 0; i < _quantity; i++) {
                                      cartProvider.addItem(
                                        widget.product.copyWith(
                                          price: _selectedVariation!.price,
                                          color: _selectedVariation!.color,
                                          size: _selectedVariation!.size,
                                        ),
                                      );
                                    }
                                  } else {
                                    // Add quantity times
                                    for (int i = 0; i < _quantity; i++) {
                                      cartProvider.addItem(widget.product);
                                    }
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${widget.product.name} added to cart',
                                      ),
                                      duration: const Duration(seconds: 2),
                                      action: SnackBarAction(
                                        label: 'VIEW CART',
                                        onPressed: () {
                                          Navigator.of(
                                            context,
                                          ).popUntil((route) => route.isFirst);
                                        },
                                      ),
                                    ),
                                  );
                                },
                          borderRadius: BorderRadius.circular(14),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  widget.product.type == 'variation'
                                      ? Icons.shopping_bag_outlined
                                      : Icons.add_shopping_cart_outlined,
                                  color: Colors.white,
                                  size: isSmallScreen ? 18 : 20,
                                ),
                                SizedBox(width: isSmallScreen ? 8 : 10),
                                Text(
                                  widget.product.type == 'variation'
                                      ? 'CHECKOUT'
                                      : 'ADD TO CART',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: _getResponsiveFontSize(
                                      context,
                                      16,
                                    ),
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildSpecificationRow(String label, String value) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 6.0 : 8.0),
      padding: EdgeInsets.all(isSmallScreen ? 8.0 : 10.0),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.grey.shade800.withOpacity(0.3)
            : Colors.grey.shade100.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
                fontSize: _getResponsiveFontSize(context, 14),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: _getResponsiveFontSize(context, 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(ReviewModel review) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final avatarColor = ReviewModel.getAvatarColor(review.userName);
    final avatarText = review.userName.isNotEmpty
        ? review.userName[0].toUpperCase()
        : '?';
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 10),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.grey.shade800.withOpacity(0.3)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                backgroundColor: avatarColor,
                radius: 16,
                child: Text(
                  avatarText,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: _getResponsiveFontSize(context, 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Name and date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: _getResponsiveFontSize(context, 14),
                      ),
                    ),
                    Text(
                      review.formattedDate,
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(context, 12),
                        color: isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Rating
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating.floor()
                        ? Icons.star
                        : index < review.rating
                        ? Icons.star_half
                        : Icons.star_border,
                    color: Colors.amber,
                    size: isSmallScreen ? 14 : 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Review text
          Text(
            review.comment,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 14),
              color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
