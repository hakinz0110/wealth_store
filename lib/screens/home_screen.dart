import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_activity_provider.dart';
import '../providers/deal_provider.dart';
import '../models/review_model.dart';
import '../models/product_model.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_item.dart';
import '../widgets/product_card.dart';
import '../widgets/deal_of_day_card.dart';
import '../widgets/recently_viewed_section.dart';
import '../widgets/recommended_section.dart';
import '../widgets/seasonal_collection.dart';
import '../widgets/reviews_section.dart';
import '../widgets/quick_filter_bar.dart';
import '../widgets/new_arrivals_section.dart';
import '../widgets/sticky_header_nav.dart';
import '../widgets/skeleton_loading.dart';

import 'search_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInit = true;
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _selectedNavSection = 'featured';

  // Sample banner data - in a real app, this would come from an API or database
  final List<BannerItem> banners = [
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

  // Sample category data with icons
  final List<Map<String, dynamic>> categories = [
    {'name': 'Computers', 'icon': Icons.computer},
    {'name': 'Phones', 'icon': Icons.phone_android},
    {'name': 'Headphones', 'icon': Icons.headphones},
    {'name': 'Gaming', 'icon': Icons.sports_esports},
    {'name': 'Cameras', 'icon': Icons.camera_alt},
    {'name': 'Smart Home', 'icon': Icons.home},
  ];

  // Filter options
  final List<FilterOption> filterOptions = [
    FilterOption(label: 'All', value: 'all', icon: Icons.apps),
    FilterOption(label: 'Popular', value: 'popular', icon: Icons.trending_up),
    FilterOption(label: 'Newest', value: 'newest', icon: Icons.new_releases),
    FilterOption(
      label: 'Price: Low to High',
      value: 'price_asc',
      icon: Icons.arrow_upward,
    ),
    FilterOption(
      label: 'Price: High to Low',
      value: 'price_desc',
      icon: Icons.arrow_downward,
    ),
    FilterOption(label: 'Rating', value: 'rating', icon: Icons.star),
  ];

  // Navigation sections
  final List<NavItem> navItems = [
    NavItem(label: 'Featured', icon: Icons.star, id: 'featured'),
    NavItem(label: 'New Arrivals', icon: Icons.new_releases, id: 'new'),
    NavItem(label: 'Best Sellers', icon: Icons.trending_up, id: 'best'),
    NavItem(label: 'Deals', icon: Icons.local_offer, id: 'deals'),
    NavItem(label: 'Collections', icon: Icons.category, id: 'collections'),
  ];

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      // Fetch products
      Provider.of<ProductProvider>(context).fetchProducts().then((_) {
        final productProvider = Provider.of<ProductProvider>(
          context,
          listen: false,
        );
        final userActivityProvider = Provider.of<UserActivityProvider>(
          context,
          listen: false,
        );
        final dealProvider = Provider.of<DealProvider>(context, listen: false);

        // Load user activity data
        userActivityProvider.loadRecentlyViewedProducts(productProvider);
        userActivityProvider.generateRecommendations(productProvider);

        // Generate deal of the day
        dealProvider.generateDealOfTheDay(productProvider);

        setState(() {
          _isLoading = false;
        });
      });

      _isInit = false;
    }
    super.didChangeDependencies();
  }

  // Filter products based on selected filter
  List<dynamic> _getFilteredProducts(List<dynamic> products) {
    final List<dynamic> filteredProducts = List.from(products);

    switch (_selectedFilter) {
      case 'popular':
        filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'newest':
        // In a real app, you would sort by date added
        filteredProducts.shuffle();
        break;
      case 'price_asc':
        filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        // 'all' - keep original order or shuffle
        filteredProducts.shuffle();
    }

    return filteredProducts;
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userActivityProvider = Provider.of<UserActivityProvider>(context);
    final dealProvider = Provider.of<DealProvider>(context);

    // Get all products
    final products = productProvider.products;

    // Get filtered products
    final filteredProducts = _getFilteredProducts(products);

    // Get recently viewed products
    final recentlyViewedProducts = userActivityProvider.recentlyViewedProducts;

    // Get recommended products
    final recommendedProducts = userActivityProvider.recommendedProducts;

    // Get deal of the day
    final dealOfTheDay = dealProvider.dealOfTheDay;

    // Get new arrivals (in a real app, these would be sorted by date)
    final newArrivals = List.from(products)..shuffle();
    newArrivals.length = newArrivals.length > 5 ? 5 : newArrivals.length;

    // Get sample reviews
    final reviews = ReviewModel.getDummyReviews();

    // Get user's first name from full name
    String firstName = 'User';
    if (authProvider.user != null && authProvider.user!.name.isNotEmpty) {
      firstName = authProvider.user!.name.split(' ')[0];
    }

    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with welcome message, theme toggle, wishlist and search icons
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).appBarTheme.backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Welcome message
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode
                              ? Colors.grey.shade400
                              : Colors.grey,
                        ),
                      ),
                      Text(
                        firstName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  // Icons
                  Row(
                    children: [
                      // Dark mode toggle
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            themeProvider.toggleTheme();
                          },
                          borderRadius: BorderRadius.circular(30),
                          splashColor: Theme.of(
                            context,
                          ).primaryColor.withAlpha(26),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              isDarkMode ? Icons.light_mode : Icons.dark_mode,
                              color: isDarkMode
                                  ? Colors.white
                                  : Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ),
                      // Favorites icon
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // Navigate to favorites screen
                            Navigator.of(context).pushNamed('/favorites');
                          },
                          borderRadius: BorderRadius.circular(30),
                          splashColor: Theme.of(
                            context,
                          ).primaryColor.withAlpha(26),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Icon(
                                  Icons.favorite_border,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.grey.shade800,
                                ),
                                if (favoritesProvider.favorites.isNotEmpty)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Search icon
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // Navigate to search screen
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SearchScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(30),
                          splashColor: Theme.of(
                            context,
                          ).primaryColor.withAlpha(26),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.search,
                              color: isDarkMode
                                  ? Colors.white
                                  : Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Sticky header navigation
            StickyHeaderNav(
              items: navItems,
              onItemSelected: (id) {
                setState(() {
                  _selectedNavSection = id;
                });
              },
              selectedId: _selectedNavSection,
            ),

            // Main content - scrollable with pull-to-refresh
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _isLoading = true;
                  });

                  await productProvider.fetchProducts();

                  final userActivityProvider =
                      Provider.of<UserActivityProvider>(context, listen: false);
                  final dealProvider = Provider.of<DealProvider>(
                    context,
                    listen: false,
                  );

                  // Refresh user activity data
                  await userActivityProvider.loadRecentlyViewedProducts(
                    productProvider,
                  );
                  await userActivityProvider.generateRecommendations(
                    productProvider,
                  );

                  // Regenerate deal of the day
                  await dealProvider.generateDealOfTheDay(productProvider);

                  setState(() {
                    _isLoading = false;
                  });
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner carousel
                      BannerCarousel(banners: banners),

                      const SizedBox(height: 16),

                      // Deal of the day
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: SkeletonLoading(height: 180, borderRadius: 16),
                        )
                      else if (dealOfTheDay != null)
                        DealOfDayCard(
                          deal: dealOfTheDay,
                          onTap: () {
                            // Navigate to product details
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(
                                  product: dealOfTheDay.product,
                                ),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 16),

                      // Recently viewed products
                      if (recentlyViewedProducts.isNotEmpty || _isLoading)
                        RecentlyViewedSection(
                          products: recentlyViewedProducts,
                          onProductTap: (product) {
                            // Track product view
                            userActivityProvider.trackProductView(product);

                            // Navigate to product details
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailScreen(product: product),
                              ),
                            );
                          },
                          isLoading: _isLoading,
                        ),

                      const SizedBox(height: 16),

                      // Seasonal collection
                      SeasonalCollection.getCurrentSeason(
                        onTap: () {
                          // Navigate to seasonal collection
                        },
                        isLoading: _isLoading,
                      ),

                      const SizedBox(height: 16),

                      // Recommended products
                      if (recommendedProducts.isNotEmpty || _isLoading)
                        RecommendedSection(
                          products: recommendedProducts,
                          onProductTap: (product) {
                            // Track product view
                            userActivityProvider.trackProductView(product);

                            // Navigate to product details
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailScreen(product: product),
                              ),
                            );
                          },
                          onAddToCart: (product) {
                            cartProvider.addItem(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} added to cart'),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                              ),
                            );
                          },
                          onAddToWishlist: (product) {
                            favoritesProvider.toggleFavorite(product);
                          },
                          isInWishlist: (product) =>
                              favoritesProvider.isFavorite(product),
                          isLoading: _isLoading,
                        ),

                      const SizedBox(height: 16),

                      // New arrivals
                      NewArrivalsSection(
                        products: newArrivals.cast<ProductModel>(),
                        onProductTap: (product) {
                          // Track product view
                          userActivityProvider.trackProductView(product);

                          // Navigate to product details
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailScreen(product: product),
                            ),
                          );
                        },
                        isLoading: _isLoading,
                      ),

                      const SizedBox(height: 16),

                      // Customer reviews
                      ReviewsSection(
                        reviews: reviews,
                        onSeeAllTap: () {
                          // Navigate to all reviews
                        },
                        isLoading: _isLoading,
                      ),

                      const SizedBox(height: 16),

                      // Categories section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Categories',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to categories screen
                              },
                              child: const Text('See All'),
                            ),
                          ],
                        ),
                      ),

                      // Categories horizontal list
                      SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: categories.length,
                          itemBuilder: (ctx, index) {
                            final category = categories[index];
                            final isSelected =
                                category['name'] ==
                                productProvider.selectedCategory;

                            return CategoryItem(
                              name: category['name'],
                              icon: category['icon'],
                              isSelected: isSelected,
                              onTap: () {
                                productProvider.setCategory(category['name']);
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Quick filter bar
                      QuickFilterBar(
                        options: filterOptions,
                        onFilterSelected: (value) {
                          setState(() {
                            _selectedFilter = value;
                          });
                        },
                        selectedValue: _selectedFilter,
                      ),

                      const SizedBox(height: 16),

                      // All Products section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'All Products',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to all products screen
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const SearchScreen(),
                                  ),
                                );
                              },
                              child: const Text('See All'),
                            ),
                          ],
                        ),
                      ),

                      // Products grid
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _isLoading
                            ? GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.55,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                                itemCount: 4,
                                itemBuilder: (ctx, index) {
                                  return const ProductCardSkeleton();
                                },
                              )
                            : products.isEmpty
                            ? const Center(child: Text('No products found'))
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.55,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                                itemCount: filteredProducts.length,
                                itemBuilder: (ctx, index) {
                                  final product = filteredProducts[index];
                                  final isInWishlist = favoritesProvider
                                      .isFavorite(product);

                                  return ProductCard(
                                    product: product,
                                    onTap: () {
                                      // Track product view
                                      userActivityProvider.trackProductView(
                                        product,
                                      );

                                      // Navigate to product details
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProductDetailScreen(
                                                product: product,
                                              ),
                                        ),
                                      );
                                    },
                                    onAddToCart: () {
                                      cartProvider.addItem(product);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${product.name} added to cart',
                                          ),
                                          duration: const Duration(seconds: 1),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          margin: const EdgeInsets.fromLTRB(
                                            16,
                                            0,
                                            16,
                                            16,
                                          ),
                                        ),
                                      );
                                    },
                                    onAddToWishlist: () {
                                      favoritesProvider.toggleFavorite(product);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isInWishlist
                                                ? '${product.name} removed from favorites'
                                                : '${product.name} added to favorites',
                                          ),
                                          duration: const Duration(seconds: 1),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          margin: const EdgeInsets.fromLTRB(
                                            16,
                                            0,
                                            16,
                                            16,
                                          ),
                                        ),
                                      );
                                    },
                                    isInWishlist: isInWishlist,
                                  );
                                },
                              ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom navigation bar is handled by the MainScreen widget in main.dart
    );
  }
}
