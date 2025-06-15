import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/responsive.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_activity_provider.dart';
import '../providers/deal_provider.dart';
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

  // Sample banner data
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
    super.didChangeDependencies();
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    // Only fetch products if they haven't been loaded yet
    if (productProvider.products.isEmpty) {
      productProvider.fetchProducts();
    }
  }

  // Filter products based on selected filter
  List<ProductModel> _getFilteredProducts(List<ProductModel> products) {
    // Simply return the original list without filtering
    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wealth Store'), centerTitle: true),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          // Handle different states
          if (productProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading products...'),
                ],
              ),
            );
          }

          // Check if products list is empty
          if (productProvider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    'No products found',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      productProvider.fetchProducts();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Main content
          return RefreshIndicator(
            onRefresh: () async {
              await productProvider.fetchProducts();
            },
            child: CustomScrollView(
              slivers: [
                // Adaptive App Bar
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  snap: false,
                  centerTitle: false,
                  title: Row(
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
                      Text(
                        'Wealth Store',
                        style: TextStyle(
                          fontSize: Responsive.responsiveFontSize(context, 20),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      ),
                    ),
                  ],
                ),

                // Responsive Sections
                SliverPadding(
                  padding: Responsive.responsivePadding(context),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Adaptive Banner Carousel
                      AspectRatio(
                        aspectRatio: Responsive.getResponsiveValue(
                          context: context,
                          mobile: 16 / 9,
                          tablet: 21 / 9,
                          desktop: 25 / 9,
                        ),
                        child: BannerCarousel(
                          banners: banners,
                          onBannerTap: (index) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Banner ${index + 1} tapped'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ),

                      // Categories Section
                      _buildCategoriesSection(context),

                      // Placeholder for Deal of the Day
                      const SizedBox(height: 16),

                      // Recently Viewed Section
                      const SizedBox(
                        height: 16,
                      ), // Add a spacer instead of the section
                    ]),
                  ),
                ),

                // Adaptive Product Grid
                SliverPadding(
                  padding: Responsive.responsivePadding(context),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: Responsive.getGridColumnCount(context),
                      childAspectRatio: Responsive.getResponsiveValue(
                        context: context,
                        mobile: 0.7,
                        tablet: 0.8,
                        desktop: 0.9,
                      ),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final products = productProvider.products;
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailScreen(product: product),
                          ),
                        ),
                        onAddToCart: () {
                          Provider.of<CartProvider>(
                            context,
                            listen: false,
                          ).addItem(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to cart'),
                              duration: const Duration(seconds: 1),
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
                    }, childCount: productProvider.products.length),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Categories Section with Responsive Layout
  Widget _buildCategoriesSection(BuildContext context) {
    final categories = [
      {'name': 'Computers', 'icon': Icons.computer},
      {'name': 'Phones', 'icon': Icons.phone_android},
      {'name': 'Headphones', 'icon': Icons.headphones},
      {'name': 'Gaming', 'icon': Icons.sports_esports},
      {'name': 'Cameras', 'icon': Icons.camera_alt},
      {'name': 'Smart Home', 'icon': Icons.home},
    ];

    return SizedBox(
      height: Responsive.getResponsiveValue(
        context: context,
        mobile: 100,
        tablet: 120,
        desktop: 140,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return CategoryItem(
            name: categories[index]['name'] as String,
            icon: categories[index]['icon'] as IconData,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${categories[index]['name']} category tapped'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
