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

class CategoryProductsScreen extends StatelessWidget {
  final String categoryName;
  final String? subcategoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryName,
    this.subcategoryName,
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

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // Get products filtered by category and subcategory if provided
    final List<ProductModel> products;
    if (subcategoryName != null) {
      products = productProvider.getProductsByCategoryAndSubcategory(
        categoryName,
        subcategoryName!,
      );
    } else {
      products = productProvider.getProductsByCategory(categoryName);
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final primaryColor = const Color(0xFF6518F4);

    // Determine the title to display
    final String title = subcategoryName != null
        ? subcategoryName!
        : categoryName;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: _getResponsiveFontSize(context, 18),
          ),
        ),
        elevation: 0,
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
        leading: IconButton(
          icon: ModernIconStyles.circularButton(
            icon: Icons.arrow_back_ios_new,
            onPressed: () => Navigator.of(context).pop(),
            context: context,
            size: 36,
            backgroundColor: isDarkMode
                ? Colors.grey.shade800
                : Colors.grey.shade100,
            iconColor: isDarkMode ? Colors.white : primaryColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.filter_list, color: primaryColor, size: 20),
            ),
            onPressed: () {
              // Show filter options
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
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
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: screenWidth > 600 ? 600 : screenWidth,
          ),
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 24),
          child: products.isEmpty
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
                        subcategoryName != null
                            ? 'No products available for $subcategoryName'
                            : 'No products available for $categoryName',
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 14),
                          color: isDarkMode
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header with product count and sort options
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: isDarkMode ? Colors.grey[850] : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${products.length} items',
                                  style: TextStyle(
                                    fontSize: _getResponsiveFontSize(
                                      context,
                                      13,
                                    ),
                                    fontWeight: FontWeight.w500,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Sort: ',
                                style: TextStyle(
                                  fontSize: _getResponsiveFontSize(context, 14),
                                  color: isDarkMode
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade700,
                                ),
                              ),
                              DropdownButton<String>(
                                value: 'Newest',
                                underline: Container(),
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: primaryColor,
                                  size: 18,
                                ),
                                items:
                                    <String>[
                                      'Newest',
                                      'Price: Low to High',
                                      'Price: High to Low',
                                      'Popularity',
                                    ].map<DropdownMenuItem<String>>((
                                      String value,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: TextStyle(
                                            fontSize: _getResponsiveFontSize(
                                              context,
                                              13,
                                            ),
                                            color: primaryColor,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (String? newValue) {
                                  // Implement sorting logic
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Products grid
                    Expanded(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: isDarkMode ? Colors.grey[850] : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: screenWidth < 400
                                      ? 2
                                      : (screenWidth < 600 ? 2 : 3),
                                  childAspectRatio: screenWidth < 360
                                      ? 0.6
                                      : 0.7,
                                  crossAxisSpacing: isSmallScreen ? 8 : 12,
                                  mainAxisSpacing: isSmallScreen ? 8 : 12,
                                ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
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
                                  cartProvider.addItem(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${product.name} added to cart',
                                      ),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      backgroundColor: primaryColor,
                                    ),
                                  );
                                },
                                onAddToWishlist: () {
                                  favoritesProvider.toggleFavorite(product);
                                },
                                isInWishlist: favoritesProvider.isFavorite(
                                  product,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected) {
    final primaryColor = const Color(0xFF6518F4);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        // Implement filter logic
      },
      selectedColor: primaryColor.withOpacity(0.2),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade800
          : Colors.grey.shade200,
      checkmarkColor: primaryColor,
      labelStyle: TextStyle(
        color: isSelected
            ? primaryColor
            : Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black87,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }
}
