import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../screens/category_products_screen.dart';
import '../utils/icon_styles.dart';

class SubcategoryScreen extends StatelessWidget {
  final String categoryName;
  final dynamic subCategories;

  const SubcategoryScreen({
    super.key,
    required this.categoryName,
    required this.subCategories,
  });

  List<Map<String, dynamic>> _normalizeSubCategories() {
    // Handle null case
    if (subCategories == null) {
      return [];
    }

    // Handle string list case (most common)
    if (subCategories is List) {
      return List.generate(subCategories.length, (index) {
        final item = subCategories[index];
        if (item is String) {
          return {'name': item, 'icon': _getIconForCategory(item)};
        } else if (item is Map<String, dynamic>) {
          return item;
        } else {
          return {'name': item.toString(), 'icon': Icons.category};
        }
      });
    }

    // Handle single map case
    if (subCategories is Map<String, dynamic>) {
      return [subCategories];
    }

    // Handle single string case
    if (subCategories is String) {
      return [
        {'name': subCategories, 'icon': _getIconForCategory(subCategories)},
      ];
    }

    // Default fallback
    return [
      {'name': subCategories.toString(), 'icon': Icons.category},
    ];
  }

  // Helper method to assign appropriate icons based on category name
  IconData _getIconForCategory(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('phone') || lowerName.contains('smartphone')) {
      return Icons.smartphone;
    } else if (lowerName.contains('laptop')) {
      return Icons.laptop;
    } else if (lowerName.contains('audio') || lowerName.contains('headphone')) {
      return Icons.headphones;
    } else if (lowerName.contains('camera')) {
      return Icons.camera_alt;
    } else if (lowerName.contains('accessory') ||
        lowerName.contains('accessories')) {
      return Icons.cable;
    } else if (lowerName.contains('men')) {
      return Icons.man;
    } else if (lowerName.contains('women')) {
      return Icons.woman;
    } else if (lowerName.contains('kid') || lowerName.contains('child')) {
      return Icons.child_care;
    } else if (lowerName.contains('food') || lowerName.contains('grocery')) {
      return Icons.restaurant;
    } else if (lowerName.contains('beauty') || lowerName.contains('cosmetic')) {
      return Icons.spa;
    } else if (lowerName.contains('home') || lowerName.contains('furniture')) {
      return Icons.chair;
    } else if (lowerName.contains('sport')) {
      return Icons.sports_basketball;
    } else if (lowerName.contains('book')) {
      return Icons.book;
    } else if (lowerName.contains('toy')) {
      return Icons.toys;
    } else if (lowerName.contains('health')) {
      return Icons.health_and_safety;
    } else {
      return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final normalizedSubCategories = _normalizeSubCategories();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final primaryColor = const Color(0xFF6518F4);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          categoryName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        centerTitle: false,
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
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: screenWidth > 600 ? 600 : screenWidth,
          ),
          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section with category icon and description
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor.withOpacity(0.7), primaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getIconForCategory(categoryName),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$categoryName Subcategories',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 18 : 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select a subcategory to browse products',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Subcategories grid in a card
              Expanded(
                child: normalizedSubCategories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 64,
                              color: isDarkMode
                                  ? Colors.grey[600]
                                  : Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No subcategories available',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      )
                    : Card(
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
                                      : (screenWidth < 600 ? 3 : 4),
                                  childAspectRatio: 1.0,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemCount: normalizedSubCategories.length,
                            itemBuilder: (context, index) {
                              final subCategory =
                                  normalizedSubCategories[index];

                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CategoryProductsScreen(
                                            categoryName: categoryName,
                                            subcategoryName:
                                                subCategory['name'] ??
                                                'Unnamed Subcategory',
                                          ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        primaryColor.withOpacity(0.05),
                                        primaryColor.withOpacity(0.15),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: primaryColor.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isDarkMode
                                              ? Colors.grey[800]
                                              : Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          subCategory['icon'] ?? Icons.category,
                                          color: primaryColor,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: Text(
                                          subCategory['name'] ?? 'Unnamed',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: isSmallScreen ? 12 : 14,
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
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
}
