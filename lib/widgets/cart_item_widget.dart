import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/cart_item_model.dart';
import '../utils/icon_styles.dart';

class CartItemWidget extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Product Image
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: kIsWeb
                      ? Image.network(
                          item.product.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                              child: const Icon(Icons.error),
                            );
                          },
                        )
                      : CachedNetworkImage(
                          imageUrl: item.product.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: isDarkMode
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: isDarkMode
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                            child: const Icon(Icons.error),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total: \$${item.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Quantity Controls
            Column(
              children: [
                ModernIconStyles.quantityControl(
                  onDecrement: onDecrement,
                  onIncrement: onIncrement,
                  quantity: item.quantity,
                  context: context,
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                    iconSize: 20,
                    tooltip: 'Remove from cart',
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
