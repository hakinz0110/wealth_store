import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/user_activity_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/voice_search_button.dart';
import '../widgets/skeleton_loading.dart';
import 'product_detail_screen.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        _searchQuery = query;
        _isSearching = true;
        _isLoading = true;
        
        // Add to recent searches if not already there
        if (!_recentSearches.contains(query)) {
          _recentSearches.insert(0, query);
          if (_recentSearches.length > 5) {
            _recentSearches.removeLast();
          }
        }
      });

      // Apply search filter
    Provider.of<ProductProvider>(context, listen: false).setSearchQuery(query);
      
      // Simulate search delay for better UX
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _isSearching = false;
    });
    Provider.of<ProductProvider>(context, listen: false).setSearchQuery('');
  }
  
  void _handleVoiceSearchResult(String result) {
    if (result.isNotEmpty) {
      _searchController.text = result;
      _onSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final userActivityProvider = Provider.of<UserActivityProvider>(context, listen: false);
    final products = productProvider.filteredProducts;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Products',
          style: TextStyle(fontWeight: FontWeight.bold),
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
            // Search bar with voice search
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Search text field
                  Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                        hintText: 'Search for products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                                onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        filled: true,
                        fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _onSearch(),
            ),
          ),

                  // Voice search button
                  const SizedBox(width: 8),
                  VoiceSearchButton(
                    size: 48,
                    onSearchResult: _handleVoiceSearchResult,
                  ),
                ],
              ),
            ),

            // Categories chips
            if (!_isSearching)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: productProvider.categories.map((category) {
                    final isSelected = category == productProvider.selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          productProvider.setCategory(category);
                        },
                        backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                        selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        labelStyle: TextStyle(
                          color: isSelected 
                              ? Theme.of(context).primaryColor 
                              : isDarkMode ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected 
                                ? Theme.of(context).primaryColor 
                                : isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                          ),
                        ),
                        checkmarkColor: Theme.of(context).primaryColor,
                      ),
                    );
                  }).toList(),
                ),
              ),

            // Recent searches
            if (!_isSearching && _recentSearches.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Searches',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _recentSearches.clear();
                            });
                          },
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      children: _recentSearches.map((search) {
                        return ActionChip(
                          label: Text(search),
                          avatar: const Icon(Icons.history, size: 16),
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

            // Search results or all products
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
                                size: 80,
                                color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
                          ),
                              const SizedBox(height: 16),
                              Text(
                                'No results found for "$_searchQuery"',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _clearSearch,
                                child: const Text('Clear Search'),
                        ),
                      ],
                    ),
                  )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                              childAspectRatio: 0.55, // Adjusted for 80/20 proportions
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: products.length,
                    itemBuilder: (ctx, index) {
                      final product = products[index];
                              final isInWishlist = favoritesProvider.isFavorite(product);
                              
                              return ProductCard(
                                product: product,
                                onTap: () {
                                  // Track product view
                                  userActivityProvider.trackProductView(product);
                                  
                                  // Navigate to product details
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailScreen(
                        product: product,
                                      ),
                                    ),
                                  );
                                },
                                onAddToCart: () {
                                  cartProvider.addItem(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${product.name} added to cart'),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                                            : '${product.name} added to favorites'
                                      ),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                    ),
                      );
                    },
                                isInWishlist: isInWishlist,
                              );
                            },
                          ),
                  ),
          ),
        ],
        ),
      ),
    );
  }
  
  Widget _buildLoadingGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.55,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (ctx, index) {
          return const ProductCardSkeleton();
        },
      ),
    );
  }
}
