import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/user_activity_provider.dart';
import '../models/review_model.dart';
import '../widgets/reviews_section.dart';

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

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isInWishlist = favoritesProvider.isFavorite(widget.product);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final reviews = ReviewModel.getDummyReviews();

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
            // App bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button with hero animation
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(30),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.arrow_back),
                      ),
                    ),
                  ),
                  // Title
                  const Text(
                    'Product Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // Action buttons
                  Row(
                    children: [
                      // Wishlist button with animation
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            favoritesProvider.toggleFavorite(widget.product);
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: child,
                                );
                              },
                              child: Icon(
                                isInWishlist
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                key: ValueKey<bool>(isInWishlist),
                                color: isInWishlist ? Colors.red : null,
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

            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product image carousel
                    SizedBox(
                      height: 300,
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
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
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
                      padding: const EdgeInsets.all(16.0),
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
                                  style: const TextStyle(
                                    fontSize: 24,
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
                                      '\$24${minPrice.toStringAsFixed(2)} - \$24${maxPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    )
                                  else
                                    Text(
                                      '\$24${widget.product.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 24,
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

                          const SizedBox(height: 16),

                          // Category
                          Container(
                            padding: const EdgeInsets.symmetric(
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
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Tab bar
                          TabBar(
                            controller: _tabController,
                            labelColor: Theme.of(context).primaryColor,
                            unselectedLabelColor: isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                            indicatorColor: Theme.of(context).primaryColor,
                            tabs: const [
                              Tab(text: 'Description'),
                              Tab(text: 'Specifications'),
                              Tab(text: 'Reviews'),
                            ],
                          ),

                          const SizedBox(height: 16),

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
                                          fontSize: 16,
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

                          const SizedBox(height: 24),

                          // Similar products
                          const Text(
                            'Similar Products',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Placeholder for similar products
                          SizedBox(
                            height: 200,
                            child: Center(
                              child: Text(
                                'Similar products will appear here',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
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
              padding: const EdgeInsets.all(16),
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
                  // Quantity selector (placeholder)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Qty: $_quantity',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Add to cart button
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          (widget.product.type == 'variation' &&
                              (_selectedVariation == null ||
                                  !_selectedVariation!.inStock))
                          ? null
                          : () {
                              // For variation, add selected variation; for single, add product
                              if (widget.product.type == 'variation' &&
                                  _selectedVariation != null) {
                                // You may want to pass variation info to cart
                                cartProvider.addItem(
                                  widget.product.copyWith(
                                    price: _selectedVariation!.price,
                                    color: _selectedVariation!.color,
                                    size: _selectedVariation!.size,
                                  ),
                                );
                              } else {
                                cartProvider.addItem(widget.product);
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        widget.product.type == 'variation'
                            ? 'CHECKOUT'
                            : 'ADD TO CART',
                        style: const TextStyle(fontWeight: FontWeight.bold),
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.grey.shade800.withOpacity(0.3)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      review.formattedDate,
                      style: TextStyle(
                        fontSize: 12,
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
                    size: 16,
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
              color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
