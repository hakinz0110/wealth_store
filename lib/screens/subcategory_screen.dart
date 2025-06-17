import 'package:flutter/material.dart';
import '../widgets/product_card.dart';
import '../models/product_model.dart';

class SubcategoryScreen extends StatelessWidget {
  final String categoryName;
  final dynamic subCategories;

  const SubcategoryScreen({
    super.key,
    required this.categoryName,
    required this.subCategories,
  });

  List<Map<String, dynamic>> _normalizeSubCategories() {
    if (subCategories == null) return [];

    if (subCategories is List) {
      return List<Map<String, dynamic>>.from(subCategories);
    }

    return [subCategories as Map<String, dynamic>];
  }

  @override
  Widget build(BuildContext context) {
    final normalizedSubCategories = _normalizeSubCategories();

    return Scaffold(
      appBar: AppBar(title: Text(categoryName), centerTitle: false),
      body: normalizedSubCategories.isEmpty
          ? Center(
              child: Text(
                'No subcategories available',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            )
          : ListView.builder(
              itemCount: normalizedSubCategories.length,
              itemBuilder: (context, index) {
                final subCategory = normalizedSubCategories[index];
                return ExpansionTile(
                  title: Text(subCategory['name'] ?? 'Unnamed Subcategory'),
                  leading: Icon(subCategory['icon'] ?? Icons.category),
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                          ),
                      itemCount: (subCategory['items'] as List?)?.length ?? 0,
                      itemBuilder: (context, itemIndex) {
                        final product = subCategory['items'][itemIndex];
                        return ProductCard(
                          product: product is ProductModel
                              ? product
                              : ProductModel(
                                  id: 'temp_${product.hashCode}',
                                  name: product['name'] ?? 'Unknown Product',
                                  category:
                                      subCategory['name'] ?? 'Unknown Category',
                                  price: product['price'] ?? 0.0,
                                  imageUrl: product['imageUrl'] ?? '',
                                  description: product['description'] ?? '',
                                  rating: product['rating'] ?? 0.0,
                                ),
                          onTap: () {
                            // Navigate to product detail
                          },
                          onAddToCart: () {
                            // Add to cart functionality
                          },
                          onAddToWishlist: () {
                            // Add to wishlist functionality
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
    );
  }
}
