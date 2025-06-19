import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/responsive.dart';
import '../providers/product_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product_model.dart';
import '../widgets/product_card.dart';
import '../utils/icon_styles.dart';
import 'product_detail_screen.dart';

class CategoryTabScreen extends StatelessWidget {
  final String tabName;
  final IconData tabIcon;

  const CategoryTabScreen({
    super.key,
    required this.tabName,
    required this.tabIcon,
  });

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

  // Get products based on tab name
  List<ProductModel> _getFilteredProducts(List<ProductModel> allProducts) {
    switch (tabName) {
      case 'New':
        return allProducts.where((p) => p.isNew).toList();
      case 'Popular':
        return allProducts.where((p) => p.isPopular).toList();
      case 'Deals':
        return allProducts.where((p) => p.isDeal).toList();
      default: // Featured
        return allProducts.where((p) => p.isFeatured).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    final products = _getFilteredProducts(productProvider.products);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(tabIcon, size: _getResponsiveFontSize(context, 20)),
            const SizedBox(width: 8),
            Text(
              tabName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: _getResponsiveFontSize(context, 18),
              ),
            ),
          ],
        ),
        elevation: 0,
        leading: IconButton(
          icon: ModernIconStyles.circularButton(
            icon: Icons.arrow_back_ios_new,
            onPressed: () => Navigator.of(context).pop(),
            context: context,
            size: 36,
            backgroundColor: isDarkMode
                ? Colors.grey.shade800
                : Colors.grey.shade100,
            iconColor: isDarkMode
                ? Colors.white
                : Theme.of(context).primaryColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              // Show filter options
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                backgroundColor: Theme.of(context).cardColor,
                builder: (ctx) => Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      Text(
                        'Sort & Filter',
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Simple filter options
                      Text(
                        'Sort by',
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 16),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildFilterChip(context, 'Newest', true),
                          _buildFilterChip(
                            context,
                            'Price: Low to High',
                            false,
                          ),
                          _buildFilterChip(
                            context,
                            'Price: High to Low',
                            false,
                          ),
                          _buildFilterChip(context, 'Popularity', false),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                            child: Text(
                              'Reset',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: isSmallScreen ? 64 : 80,
                    color: isDarkMode
                        ? Colors.grey.shade600
                        : Colors.grey.shade400,
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  Text(
                    'No products found',
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
                    'No products available in $tabName',
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
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
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
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with count
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
                        '${products.length} ${products.length == 1 ? 'Product' : 'Products'}',
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Product grid
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: isSmallScreen ? 0.5 : 0.55,
                        crossAxisSpacing: isSmallScreen ? 12 : 16,
                        mainAxisSpacing: isSmallScreen ? 12 : 16,
                      ),
                      itemCount: products.length,
                      itemBuilder: (ctx, index) {
                        final product = products[index];
                        final isInWishlist = favoritesProvider.isFavorite(
                          product,
                        );

                        return ProductCard(
                          product: product,
                          onTap: () {
                            Navigator.push(
                              context,
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
                          },
                          isInWishlist: isInWishlist,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        // Would implement the filter logic here
      },
      backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).primaryColor
            : isDarkMode
            ? Colors.white
            : Colors.black87,
        fontSize: _getResponsiveFontSize(context, 14),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).primaryColor
              : isDarkMode
              ? Colors.grey.shade700
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
    );
  }
}
