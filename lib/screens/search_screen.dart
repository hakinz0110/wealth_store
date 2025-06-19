import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/user_activity_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/skeleton_loading.dart';
import 'product_detail_screen.dart';
import 'filter_modal_content.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  bool _isLoading = false;
  final List<String> _recentSearches = [
    'Headphones',
    'Laptop',
    'Smartphone',
    'Gaming',
  ];

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    final userActivityProvider = Provider.of<UserActivityProvider>(
      context,
      listen: false,
    );

    // Trim and validate search query
    final searchQuery = _searchController.text.trim();

    // Only proceed if search query is not empty
    if (searchQuery.isNotEmpty) {
      // Add to recent searches if not already present
      if (!_recentSearches.contains(searchQuery)) {
        setState(() {
          if (_recentSearches.length >= 5) {
            _recentSearches.removeAt(0);
          }
          _recentSearches.add(searchQuery);
        });
      }

      // Set search query and filter products
      setState(() {
        _searchQuery = searchQuery;
        _isSearching = true; // Explicitly set searching to true
      });

      // Perform search
      productProvider.searchProducts(searchQuery);

      // Log user activity
      userActivityProvider.addSearchActivity(searchQuery);

      // Unfocus the keyboard
      FocusScope.of(context).unfocus();
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _isSearching = false; // Reset searching flag
    });

    // Reset product filtering
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    productProvider.resetFilter();
  }

  void _showFilterModal(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).cardColor,
      builder: (BuildContext context) {
        return const FilterModalContent();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final userActivityProvider = Provider.of<UserActivityProvider>(
      context,
      listen: false,
    );
    final products = productProvider.filteredProducts;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Products',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: _getResponsiveFontSize(context, 18),
          ),
        ),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _isLoading = true;
          });
          await productProvider.fetchProducts();
          setState(() {
            _isLoading = false;
          });
        },
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for products...',
                  hintStyle: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 14),
                    color: isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: isSmallScreen ? 16 : 18,
                              color: isDarkMode ? Colors.white : Colors.black54,
                            ),
                            onPressed: _clearSearch,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDarkMode
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDarkMode
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade50,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 12 : 14,
                    horizontal: 16,
                  ),
                ),
                style: TextStyle(fontSize: _getResponsiveFontSize(context, 16)),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _onSearch(),
              ),
            ),

            // Recent searches
            if (!_isSearching && _recentSearches.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isSmallScreen ? 12 : 16,
                  isSmallScreen ? 12 : 16,
                  isSmallScreen ? 12 : 16,
                  isSmallScreen ? 6 : 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                              'Recent Searches',
                              style: TextStyle(
                                fontSize: _getResponsiveFontSize(context, 16),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _recentSearches.clear();
                            });
                          },
                          icon: Icon(
                            Icons.delete_outline,
                            size: isSmallScreen ? 18 : 20,
                            color: Theme.of(context).primaryColor,
                          ),
                          label: Text(
                            'Clear All',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: _getResponsiveFontSize(context, 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _recentSearches.map((search) {
                        return ActionChip(
                          label: Text(
                            search,
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(context, 13),
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          avatar: Icon(
                            Icons.history,
                            size: isSmallScreen ? 14 : 16,
                            color: Theme.of(context).primaryColor,
                          ),
                          backgroundColor: isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isDarkMode
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 8 : 12,
                            vertical: isSmallScreen ? 4 : 8,
                          ),
                          onPressed: () {
                            _searchController.text = search;
                            _onSearch();
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

            // Search results
            Expanded(
              child: _isLoading
                  ? _buildLoadingGrid()
                  : _isSearching && _searchQuery.isNotEmpty && products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: isSmallScreen ? 64 : 80,
                            color: isDarkMode
                                ? Colors.grey.shade600
                                : Colors.grey.shade400,
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          Text(
                            'No results found for "$_searchQuery"',
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(context, 16),
                              color: isDarkMode
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 6 : 8),
                          ElevatedButton.icon(
                            onPressed: _clearSearch,
                            icon: const Icon(Icons.clear),
                            label: const Text('Clear Search'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12.0 : 16.0,
                      ),
                      child: Column(
                        children: [
                          // Filter icon only appears after search
                          if (_isSearching)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: isSmallScreen ? 8.0 : 12.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Found ${products.length} ${products.length == 1 ? 'result' : 'results'}',
                                    style: TextStyle(
                                      fontSize: _getResponsiveFontSize(
                                        context,
                                        14,
                                      ),
                                      color: isDarkMode
                                          ? Colors.grey.shade300
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => _showFilterModal(context),
                                    icon: Icon(
                                      Icons.filter_list_rounded,
                                      size: isSmallScreen ? 16 : 18,
                                    ),
                                    label: Text(
                                      'Filter',
                                      style: TextStyle(
                                        fontSize: _getResponsiveFontSize(
                                          context,
                                          14,
                                        ),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: isDarkMode
                                          ? Colors.white
                                          : Theme.of(context).primaryColor,
                                      backgroundColor: isDarkMode
                                          ? Theme.of(
                                              context,
                                            ).primaryColor.withOpacity(0.2)
                                          : Theme.of(
                                              context,
                                            ).primaryColor.withOpacity(0.1),
                                      elevation: 0,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isSmallScreen ? 12 : 16,
                                        vertical: isSmallScreen ? 8 : 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Expanded(child: _buildProductsGrid(products)),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine grid parameters based on screen size - same as product grid
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

    // Number of skeleton items to show based on screen size
    int itemCount = crossAxisCount * 3; // 3 rows of items

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth < 360 ? 12.0 : 16.0,
      ),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
        ),
        itemCount: itemCount,
        itemBuilder: (ctx, index) {
          return const ProductCardSkeleton();
        },
      ),
    );
  }

  // Build product grid with responsive layout similar to HomeScreen
  Widget _buildProductsGrid(List<dynamic> products) {
    final screenWidth = MediaQuery.of(context).size.width;
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

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

    return GridView.builder(
      padding: EdgeInsets.zero, // Remove padding as it's handled by parent
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: products.length,
      itemBuilder: (ctx, index) {
        final product = products[index];
        final isInWishlist = favoritesProvider.isFavorite(product);

        return ProductCard(
          product: product,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          ),
          onAddToCart: () {
            cartProvider.addItem(product);
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
            favoritesProvider.toggleFavorite(product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isInWishlist
                      ? '${product.name} removed from favorites'
                      : '${product.name} added to favorites',
                ),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          isInWishlist: isInWishlist,
        );
      },
    );
  }
}

class FilterOptions {
  final String sortBy;
  final String category;
  final RangeValues priceRange;
  FilterOptions({
    required this.sortBy,
    required this.category,
    required this.priceRange,
  });
}
