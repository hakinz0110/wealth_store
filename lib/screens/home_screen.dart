import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../utils/responsive.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_activity_provider.dart';
import '../providers/deal_provider.dart';
import '../providers/category_provider.dart';
import '../models/review_model.dart';
import '../models/product_model.dart';
import '../models/deal_model.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_item.dart';
import '../widgets/product_card.dart';
import '../widgets/deal_of_day_card.dart';
import '../widgets/recently_viewed_section.dart';
import '../widgets/reviews_section.dart';
import '../widgets/quick_filter_bar.dart';
import '../widgets/sticky_header_nav.dart';
import '../widgets/skeleton_loading.dart';
import '../widgets/theme_toggle.dart';

import 'search_screen.dart';
import 'product_detail_screen.dart';
import 'favorites_screen.dart';
import 'subcategory_screen.dart';
import 'category_products_screen.dart';
import 'category_tab_screen.dart';
import 'cart_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String _selectedNavSection = 'featured';
  List<BannerItem> _banners = [];
  bool _isLoadingBanners = true;
  StreamSubscription<QuerySnapshot>? _bannersSubscription;

  // Tab items
  final List<Map<String, dynamic>> _tabs = [
    {'title': 'Featured', 'icon': Icons.star},
    {'title': 'New', 'icon': Icons.new_releases},
    {'title': 'Popular', 'icon': Icons.trending_up},
    {'title': 'Deals', 'icon': Icons.local_offer},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    // Only fetch products if they haven't been loaded yet
    if (productProvider.products.isEmpty) {
      productProvider.fetchProducts();
    }

    // Fetch banners from Firestore
    _fetchBanners();
  }

  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    _bannersSubscription?.cancel();
    super.dispose();
  }

  void _fetchBanners() {
    setState(() {
      _isLoadingBanners = true;
    });

    try {
      // Create a real-time stream for all banners (removed isActive filter), ordered by the order field
      final bannersStream = FirebaseFirestore.instance
          .collection('banners')
          // Temporarily remove the active filter to see all banners
          // .where('isActive', isEqualTo: true)
          .orderBy('order')
          .snapshots();

      print('Setting up banners stream...');

      // Subscribe to the stream
      _bannersSubscription = bannersStream.listen(
        (snapshot) {
          // Debug information
          print(
            'Banner snapshot received with ${snapshot.docs.length} documents',
          );
          for (var doc in snapshot.docs) {
            print(
              'Banner: ${doc.id} - ${doc.data()['title']} - Active: ${doc.data()['isActive']}',
            );
          }

          // Convert all documents to BannerItem objects (including inactive ones for debugging)
          final fetchedBanners = snapshot.docs.map((doc) {
            final data = doc.data();
            // Parse color from hex string
            final colorHex = data['backgroundColor'] as String? ?? '#6518F4';
            final color = Color(
              int.parse(colorHex.substring(1), radix: 16) + 0xFF000000,
            );

            return BannerItem(
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              buttonText: data['buttonText'] ?? 'Shop Now',
              backgroundColor: color,
              imageUrl: data['imageUrl'] ?? 'assets/images/products/cat2_1.png',
            );
          }).toList();

          // Update state with the fetched banners
          if (mounted) {
            setState(() {
              _banners = fetchedBanners;
              _isLoadingBanners = false;
              print('Updated banners list with ${_banners.length} banners');
            });
          }
        },
        onError: (error) {
          print('Error streaming banners: $error');
          _setDefaultBanners();
        },
      );
    } catch (e) {
      print('Error setting up banners stream: $e');
      _setDefaultBanners();
    }
  }

  void _setDefaultBanners() {
    // Fallback to default banners if there's an error
    if (mounted) {
      setState(() {
        _banners = [
          BannerItem(
            title: 'New Collection',
            description: 'Discount 30% for first transaction',
            buttonText: 'Shop Now',
            backgroundColor: const Color(0xFF6518F4),
            imageUrl: 'assets/images/products/cat2_1.png',
          ),
          BannerItem(
            title: 'Summer Sale',
            description: 'Up to 50% off on selected items',
            buttonText: 'View Offers',
            backgroundColor: const Color(0xFF2E7D32),
            imageUrl: 'assets/images/products/loptop2.png',
          ),
          BannerItem(
            title: 'Tech Deals',
            description: 'Latest gadgets at special prices',
            buttonText: 'Explore',
            backgroundColor: const Color(0xFF1565C0),
            imageUrl: 'assets/images/products/cat3_3.png',
          ),
        ];
        _isLoadingBanners = false;
      });
    }
  }

  // Get font size based on screen width
  double _getResponsiveFontSize(double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return size * 0.8;
    } else if (screenWidth < 600) {
      return size * 0.9;
    } else {
      return size;
    }
  }

  // Get adaptive padding based on screen size
  EdgeInsets _getResponsivePadding({double small = 8.0, double normal = 16.0}) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return EdgeInsets.all(small);
    } else {
      return EdgeInsets.all(normal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    final currentUserDisplayName = authProvider.user?.name ?? '';
    final cartItemCount = cartProvider.itemCount;
    final primaryColor = const Color(0xFF6518F4);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
        automaticallyImplyLeading: false,
        leadingWidth: 0,
        titleSpacing: isSmallScreen ? 16 : 20,
        title: Row(
          children: [
            ClipOval(
              child: Container(
                color: primaryColor,
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: isSmallScreen ? 16 : 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Wealth Store',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: _getResponsiveFontSize(isSmallScreen ? 18 : 20),
              ),
            ),
          ],
        ),
        actions: [
          // Theme toggle
          const ThemeToggle(compact: true),

          IconButton(
            icon: Icon(Icons.search, size: isSmallScreen ? 20 : 24),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            ),
          ),
          IconButton(
            icon: Icon(Icons.favorite_border, size: isSmallScreen ? 20 : 24),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const FavoritesScreen()),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.shopping_cart_outlined,
                  size: isSmallScreen ? 20 : 24,
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                ),
              ),
              if (cartItemCount > 0)
                Positioned(
                  top: isSmallScreen ? 6 : 8,
                  right: isSmallScreen ? 6 : 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: isSmallScreen ? 14 : 16,
                      minHeight: isSmallScreen ? 14 : 16,
                    ),
                    child: Text(
                      cartItemCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 8 : 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
        ],
      ),
      body: productProvider.isLoading
          ? _buildLoadingState(context)
          : _buildMainContent(productProvider, isDarkMode),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildMainContent(ProductProvider productProvider, bool isDarkMode) {
    return Column(
      children: [
        // Tab Bar (now navigation buttons)
        _buildTabNavBar(isDarkMode),

        // Main scrollable content
        Expanded(child: _buildHomeContent(productProvider)),
      ],
    );
  }

  Widget _buildTabNavBar(bool isDarkMode) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _tabs.map((tab) {
            final isSelected =
                _selectedNavSection == tab['title'].toString().toLowerCase();
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 8),
              child: TextButton.icon(
                onPressed: () {
                  // Navigate to the appropriate category screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryTabScreen(
                        tabName: tab['title'],
                        tabIcon: tab['icon'],
                      ),
                    ),
                  );
                },
                icon: Icon(
                  tab['icon'],
                  size: isSelected
                      ? (isSmallScreen ? 16 : 20)
                      : (isSmallScreen ? 14 : 18),
                  color: isSelected
                      ? const Color(0xFF6518F4)
                      : isDarkMode
                      ? Colors.white70
                      : Colors.grey[600],
                ),
                label: Text(
                  tab['title'],
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(isSmallScreen ? 13 : 14),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? const Color(0xFF6518F4)
                        : isDarkMode
                        ? Colors.white70
                        : Colors.grey[600],
                  ),
                ),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: isSmallScreen ? 12 : 16,
                    ),
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: isSelected
                          ? const BorderSide(
                              color: Color(0xFF6518F4),
                              width: 1.5,
                            )
                          : BorderSide.none,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHomeContent(ProductProvider productProvider) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Banner carousel
        SliverToBoxAdapter(child: _buildBannerCarousel()),

        // Categories section
        SliverToBoxAdapter(child: _buildCategoriesSection(context)),

        // Featured products section
        SliverToBoxAdapter(child: _buildSectionHeader('Featured Products')),

        // Products grid (show featured products on the home screen)
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width < 360 ? 8 : 16,
            vertical: 8,
          ),
          sliver: _buildProductsGrid(
            _getFeaturedProducts(productProvider.products),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerCarousel() {
    if (_isLoadingBanners) {
      return const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_banners.isEmpty) {
      return const SizedBox.shrink(); // Hide if no banners
    }

    return BannerCarousel(
      banners: _banners,
      onBannerTap: (index) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Banner ${index + 1} tapped'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 12 : 16,
      ),
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[850]
          : Colors.white,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF6518F4),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(isSmallScreen ? 16 : 18),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Method to get featured products
  List<ProductModel> _getFeaturedProducts(List<ProductModel> products) {
    // Return products marked as featured
    return products.where((product) => product.isFeatured).toList();
  }

  SliverGrid _buildProductsGrid(List<ProductModel> products) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine grid parameters based on screen size
    int crossAxisCount;
    double childAspectRatio;
    double crossAxisSpacing;
    double mainAxisSpacing;

    if (screenWidth < 360) {
      // Very small phones
      crossAxisCount = 2;
      childAspectRatio = 0.6;
      crossAxisSpacing = 8;
      mainAxisSpacing = 8;
    } else if (screenWidth < 600) {
      // Regular phones
      crossAxisCount = 2;
      childAspectRatio = 0.7;
      crossAxisSpacing = 12;
      mainAxisSpacing = 12;
    } else if (screenWidth < 900) {
      // Tablets
      crossAxisCount = 3;
      childAspectRatio = 0.8;
      crossAxisSpacing = 12;
      mainAxisSpacing = 12;
    } else {
      // Large tablets and desktops
      crossAxisCount = 4;
      childAspectRatio = 0.9;
      crossAxisSpacing = 16;
      mainAxisSpacing = 16;
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          ),
          onAddToCart: () {
            Provider.of<CartProvider>(context, listen: false).addItem(product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${product.name} added to cart'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          onAddToWishlist: () {
            Provider.of<FavoritesProvider>(
              context,
              listen: false,
            ).toggleFavorite(product);
          },
          isInWishlist: Provider.of<FavoritesProvider>(
            context,
            listen: false,
          ).isFavorite(product),
        );
      }, childCount: products.length),
    );
  }

  // Categories Section with Responsive Layout
  Widget _buildCategoriesSection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Container(
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 8 : 12,
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6518F4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(isSmallScreen ? 16 : 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (categoryProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (categoryProvider.categories.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No categories available',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12,
                ),
                itemCount: categoryProvider.categories.length,
                itemBuilder: (context, index) {
                  final category = categoryProvider.categories[index];
                  return CategoryItem(
                    name: category.name,
                    icon: category.getIconData(),
                    accentColor: category.getColor(),
                    subCategories: category.subcategories,
                    isSelected: false,
                    imageUrl: category.imageUrl,
                    onTap: () {
                      // This won't be called since we're using subCategories navigation
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
