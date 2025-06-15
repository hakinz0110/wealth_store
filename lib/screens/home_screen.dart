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
import '../widgets/reviews_section.dart';
import '../widgets/quick_filter_bar.dart';
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

      // Store context references before async operation
      final productProviderRef = Provider.of<ProductProvider>(context);
      final userActivityProviderRef = Provider.of<UserActivityProvider>(
        context,
        listen: false,
      );
      final dealProviderRef = Provider.of<DealProvider>(context, listen: false);

      // Fetch products
      productProviderRef.fetchProducts().then((_) {
        // Check if the widget is still mounted before using setState
        if (!mounted) return;

        // Load user activity data
        userActivityProviderRef.loadRecentlyViewedProducts(productProviderRef);
        userActivityProviderRef.generateRecommendations(productProviderRef);

        // Generate deal of the day
        dealProviderRef.generateDealOfTheDay(productProviderRef);

        setState(() {
          _isLoading = false;
        });
      });

      _isInit = false;
    }
    super.didChangeDependencies();
  }

  // Filter products based on selected filter
  List<ProductModel> _getFilteredProducts(List<ProductModel> products) {
    // Simply return the original list without filtering
    return products;
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

    // Get deal of the day
    final dealOfTheDay = dealProvider.dealOfTheDay;

    // Get new arrivals (in a real app, these would be sorted by date)
    final newArrivals = List<ProductModel>.from(products)..shuffle();
    newArrivals.length = newArrivals.length > 5 ? 5 : newArrivals.length;

    // Get sample reviews
    final reviews = ReviewModel.getDummyReviews();

    // Get user's first name from full name
    final firstName = authProvider.user?.name.split(' ').first ?? 'Guest';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App bar with logo, search, and toggle theme
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo/App name
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Wealth Store',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Search and theme toggle
                  Row(
                    children: [
                      // Search button
                      Material(
                        color: Colors.transparent,
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SearchScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.search),
                          tooltip: 'Search',
                        ),
                      ),

                      // Theme toggle
                      Material(
                        color: Colors.transparent,
                        child: IconButton(
                          onPressed: () {
                            themeProvider.toggleTheme();
                          },
                          icon: Icon(
                            themeProvider.isDarkMode
                                ? Icons.light_mode
                                : Icons.dark_mode,
                          ),
                          tooltip: themeProvider.isDarkMode
                              ? 'Switch to Light Mode'
                              : 'Switch to Dark Mode',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await productProvider.fetchProducts();
                  userActivityProvider.loadRecentlyViewedProducts(
                    productProvider,
                  );
                  userActivityProvider.generateRecommendations(productProvider);
                  dealProvider.generateDealOfTheDay(productProvider);
                },
                child: _isLoading
                    ? const SkeletonLoading(height: 200)
                    : ListView(
                        children: [
                          // Welcome message
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back, $firstName!',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Discover the latest products just for you',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey.shade300
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Banner carousel
                          BannerCarousel(
                            banners: banners,
                            height: 180,
                            onBannerTap: (index) {
                              // Handle banner tap
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Banner ${index + 1} tapped'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          // Categories
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Categories',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: categories.length,
                                    itemBuilder: (context, index) {
                                      return CategoryItem(
                                        name: categories[index]['name'],
                                        icon: categories[index]['icon'],
                                        onTap: () {
                                          // Handle category tap
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${categories[index]['name']} category tapped',
                                              ),
                                              duration: const Duration(
                                                seconds: 1,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Quick filter bar
                          QuickFilterBar(
                            options: [],
                            selectedValue: '',
                            onFilterSelected: (filter) {
                              // Handle filter selection
                            },
                          ),

                          const SizedBox(height: 16),

                          // Deal of the day
                          if (dealOfTheDay != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.local_fire_department,
                                        color: Colors.orange,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Deal of the Day',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  DealOfDayCard(
                                    deal: dealOfTheDay,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProductDetailScreen(
                                                product: dealOfTheDay.product,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 24),

                          // Sticky header navigation
                          StickyHeaderNav(
                            items: navItems,
                            selectedId: _selectedNavSection,
                            onItemSelected: (section) {
                              setState(() {
                                _selectedNavSection = section;
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          // Display different sections based on selected nav
                          if (_selectedNavSection == 'featured')
                            _buildFeaturedProductsGrid(
                              filteredProducts,
                              cartProvider,
                              favoritesProvider,
                              context,
                            ),

                          const SizedBox(height: 24),

                          // Recently viewed products
                          if (recentlyViewedProducts.isNotEmpty)
                            RecentlyViewedSection(
                              products: List<ProductModel>.from(
                                recentlyViewedProducts,
                              ),
                              onProductTap: (product) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductDetailScreen(product: product),
                                  ),
                                );
                              },
                              isLoading: false,
                            ),

                          const SizedBox(height: 24),

                          // Customer reviews
                          ReviewsSection(
                            reviews: reviews,
                            onSeeAllTap: () {
                              // Navigate to all reviews
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('See all reviews tapped'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedProductsGrid(
    List<ProductModel> products,
    CartProvider cartProvider,
    FavoritesProvider favoritesProvider,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Featured Products',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length > 6 ? 6 : products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailScreen(product: product),
                    ),
                  );
                },
                onAddToCart: () {
                  cartProvider.addItem(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} added to cart'),
                      duration: const Duration(seconds: 1),
                      action: SnackBarAction(
                        label: 'View Cart',
                        onPressed: () {
                          // Navigate to cart screen
                        },
                      ),
                    ),
                  );
                },
                onAddToWishlist: () {
                  favoritesProvider.toggleFavorite(product);
                },
                isInWishlist: favoritesProvider.isFavorite(product),
              );
            },
          ),
        ],
      ),
    );
  }
}
