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
import 'favorites_screen.dart';
import 'subcategory_screen.dart';
import 'category_products_screen.dart';

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
    {'name': 'Sports', 'icon': Icons.sports_soccer},
    {'name': 'Electronics', 'icon': Icons.electrical_services},
    {'name': 'Animals', 'icon': Icons.pets},
    {'name': 'Cosmetics', 'icon': Icons.brush},
    {'name': 'Sport Shoes', 'icon': Icons.directions_run},
    {'name': 'Sports Equipments', 'icon': Icons.sports_basketball},
    {'name': 'Kitchen furniture', 'icon': Icons.kitchen},
    {'name': 'Laptop', 'icon': Icons.laptop},
    {'name': 'Shirts', 'icon': Icons.checkroom},
    {'name': 'Furniture', 'icon': Icons.chair},
    {'name': 'Clothes', 'icon': Icons.checkroom},
    {'name': 'Shoes', 'icon': Icons.hiking},
    {'name': 'Jewellery', 'icon': Icons.watch},
    {'name': 'Track suits', 'icon': Icons.sports_mma},
    {'name': 'Bedroom furniture', 'icon': Icons.bed},
    {'name': 'Office furniture', 'icon': Icons.desk},
    {'name': 'Mobile', 'icon': Icons.smartphone},
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
                  backgroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.15),
                  flexibleSpace: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const FavoritesScreen(),
                        ),
                      ),
                    ),
                  ],
                ),

                // Responsive Sections
                SliverList(
                  delegate: SliverChildListDelegate([
                    // Adaptive Banner Carousel
                    AspectRatio(
                      aspectRatio: Responsive.getResponsiveValue(
                        context: context,
                        mobile: 16.0 / 7.0,
                        tablet: 21.0 / 6.0,
                        desktop: 25.0 / 5.0,
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

                    // Recently Viewed Section
                  ]),
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
      {
        'name': 'Computers',
        'icon': Icons.computer,
        'subCategories': [
          {
            'name': 'Laptops',
            'icon': Icons.laptop,
            'items': [
              ProductModel(
                id: 'laptop1',
                name: 'MacBook Pro',
                category: 'Laptops',
                price: 1299.0,
                imageUrl: 'assets/images/products/laptop1.png',
                description: 'High-performance laptop for professionals',
                rating: 4.5,
              ),
              ProductModel(
                id: 'laptop2',
                name: 'Dell XPS',
                category: 'Laptops',
                price: 1099.0,
                imageUrl: 'assets/images/products/laptop2.png',
                description: 'Sleek and powerful laptop',
                rating: 4.3,
              ),
            ],
          },
          {
            'name': 'Desktops',
            'icon': Icons.desktop_windows,
            'items': [
              ProductModel(
                id: 'desktop1',
                name: 'Gaming Desktop',
                category: 'Desktops',
                price: 1500.0,
                imageUrl: 'assets/images/products/desktop1.png',
                description: 'High-end gaming desktop computer',
                rating: 4.7,
              ),
            ],
          },
        ],
      },
      {
        'name': 'Phones',
        'icon': Icons.phone_android,
        'subCategories': [
          {
            'name': 'Smartphones',
            'icon': Icons.smartphone,
            'items': [
              ProductModel(
                id: 'phone1',
                name: 'iPhone 13',
                category: 'Smartphones',
                price: 799.0,
                imageUrl: 'assets/images/products/phone1.png',
                description: 'Latest iPhone model',
                rating: 4.6,
              ),
              ProductModel(
                id: 'phone2',
                name: 'Samsung Galaxy S21',
                category: 'Smartphones',
                price: 699.0,
                imageUrl: 'assets/images/products/phone2.png',
                description: 'Flagship Android smartphone',
                rating: 4.4,
              ),
            ],
          },
        ],
      },
      {
        'name': 'Headphones',
        'icon': Icons.headphones,
        'subCategories': [
          {
            'name': 'Wireless',
            'icon': Icons.bluetooth,
            'items': [
              ProductModel(
                id: 'headphone1',
                name: 'AirPods Pro',
                category: 'Wireless Headphones',
                price: 249.0,
                imageUrl: 'assets/images/products/headphone1.png',
                description: 'Noise-cancelling wireless earbuds',
                rating: 4.5,
              ),
            ],
          },
        ],
      },
      {
        'name': 'Gaming',
        'icon': Icons.sports_esports,
        'subCategories': [
          {
            'name': 'Consoles',
            'icon': Icons.gamepad,
            'items': [
              ProductModel(
                id: 'gaming1',
                name: 'PlayStation 5',
                category: 'Gaming Consoles',
                price: 499.0,
                imageUrl: 'assets/images/products/gaming1.png',
                description: 'Latest gaming console from Sony',
                rating: 4.8,
              ),
            ],
          },
        ],
      },
      {
        'name': 'Cameras',
        'icon': Icons.camera_alt,
        'subCategories': [
          {
            'name': 'Digital',
            'icon': Icons.camera,
            'items': [
              ProductModel(
                id: 'camera1',
                name: 'Canon EOS R6',
                category: 'Digital Cameras',
                price: 2499.0,
                imageUrl: 'assets/images/products/camera1.png',
                description: 'Professional mirrorless camera',
                rating: 4.7,
              ),
            ],
          },
        ],
      },
      {
        'name': 'Smart Home',
        'icon': Icons.home,
        'subCategories': [
          {
            'name': 'Assistants',
            'icon': Icons.speaker,
            'items': [
              ProductModel(
                id: 'smarthome1',
                name: 'Google Nest Hub',
                category: 'Smart Home Assistants',
                price: 89.0,
                imageUrl: 'assets/images/products/smarthome1.png',
                description: 'Smart display with Google Assistant',
                rating: 4.3,
              ),
            ],
          },
        ],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
        ),

        // Categories ListView
        Container(
          height: 140,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: CategoryItem(
                  name: categories[index]['name'] as String,
                  icon: categories[index]['icon'] as IconData,
                  subCategories: categories[index]['subCategories'] ?? [],
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CategoryProductsScreen(
                          categoryName: categories[index]['name'] as String,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
