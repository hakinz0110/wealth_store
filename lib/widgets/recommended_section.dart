import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'product_card.dart';
import 'skeleton_loading.dart';

class RecommendedSection extends StatelessWidget {
  final List<ProductModel> products;
  final Function(ProductModel) onProductTap;
  final Function(ProductModel) onAddToCart;
  final Function(ProductModel) onAddToWishlist;
  final bool Function(ProductModel) isInWishlist;
  final bool isLoading;

  const RecommendedSection({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
    required this.onAddToWishlist,
    required this.isInWishlist,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty && !isLoading) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recommended For You',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // Show all recommendations
                },
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 260,
          child: isLoading
              ? _buildLoadingList()
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: products.length > 5 ? 5 : products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return SizedBox(
                      width: 180,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ProductCard(
                          product: product,
                          onTap: () => onProductTap(product),
                          onAddToCart: () => onAddToCart(product),
                          onAddToWishlist: () => onAddToWishlist(product),
                          isInWishlist: isInWishlist(product),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          width: 180,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: const ProductCardSkeleton(),
        );
      },
    );
  }
}
