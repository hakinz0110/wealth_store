import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

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
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: _getResponsiveFontSize(context, 18),
          ),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete_sweep,
              color: isDarkMode ? Colors.white : Colors.grey.shade700,
            ),
            tooltip: 'Clear all favorites',
            onPressed: () {
              // Add confirmation dialog
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(
                    'Clear Favorites',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: _getResponsiveFontSize(context, 18),
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to remove all items from favorites?',
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 16),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: _getResponsiveFontSize(context, 16),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<FavoritesProvider>(
                          context,
                          listen: false,
                        ).clearFavorites();
                        Navigator.of(ctx).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Clear All',
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 16),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          final favoriteItems = favoritesProvider.favoriteItems;

          if (favoriteItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: isSmallScreen ? 64 : 80,
                    color: isDarkMode
                        ? Colors.grey.shade600
                        : Colors.grey.shade400,
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  Text(
                    'No favorite items yet',
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 18),
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? Colors.grey.shade300
                          : Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  Text(
                    'Items you like will appear here',
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 14),
                      color: isDarkMode
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Continue Shopping'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isSmallScreen ? 12 : 16,
                  isSmallScreen ? 12 : 16,
                  isSmallScreen ? 12 : 16,
                  isSmallScreen ? 8 : 12,
                ),
                child: Row(
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
                      '${favoriteItems.length} ${favoriteItems.length == 1 ? 'Item' : 'Items'}',
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(context, 18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Grid of favorite items
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: isSmallScreen ? 0.65 : 0.7,
                    crossAxisSpacing: isSmallScreen ? 12 : 16,
                    mainAxisSpacing: isSmallScreen ? 12 : 16,
                  ),
                  itemCount: favoriteItems.length,
                  itemBuilder: (context, index) {
                    final product = favoriteItems[index];
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
                      },
                      isInWishlist: true, // Always true in favorites screen
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
