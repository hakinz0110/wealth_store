import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/features/cart/domain/cart_notifier.dart';
import 'package:wealth_app/shared/widgets/custom_button.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: cartState.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : cartState.error != null
            ? Center(child: Text('Error: ${cartState.error}'))
            : _buildCartContent(context, ref, cartState),
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, WidgetRef ref, cartState) {
    if (cartState.items.isEmpty) {
      return _buildEmptyCart(context);
    }
    
    return Column(
      children: [
        // Cart items list - scrollable
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(cartNotifierProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.medium),
              itemCount: cartState.items.length,
              separatorBuilder: (context, index) => const Divider(height: 32),
              itemBuilder: (context, index) {
                final item = cartState.items[index];
                return _CartItem(
                  item: item,
                  onQuantityChanged: (quantity) {
                    ref.read(cartNotifierProvider.notifier).updateQuantity(
                      item.productId, 
                      quantity,
                    );
                  },
                  onRemovePressed: () {
                    ref.read(cartNotifierProvider.notifier).removeItem(
                      item.productId,
                    );
                  },
                );
              },
            ),
          ),
        ),
        
        // Cart summary and checkout button
        _CartSummary(
          cartState: cartState,
          onCheckoutPressed: () => context.push('/checkout'),
        ),
      ],
    );
  }
  
  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppSpacing.large),
            Text(
              'Your cart is empty',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[700],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              'Looks like you haven\'t added any items to your cart yet.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.extraLarge),
            CustomButton(
              text: 'Continue Shopping',
              onPressed: () {
                context.go('/products');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  final dynamic item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemovePressed;
  
  const _CartItem({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product image
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 100,
            height: 100,
            child: item.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: item.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  )
                : Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: AppSpacing.medium),
        
        // Product details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                '\$${item.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              
              // Quantity controls
              Row(
                children: [
                  _QuantityButton(
                    icon: Icons.remove,
                    onPressed: item.quantity > 1
                        ? () => onQuantityChanged(item.quantity - 1)
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Text(
                      '${item.quantity}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _QuantityButton(
                    icon: Icons.add,
                    onPressed: () => onQuantityChanged(item.quantity + 1),
                  ),
                  
                  const Spacer(),
                  
                  // Remove item
                  IconButton(
                    onPressed: onRemovePressed,
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.grey[600],
                    tooltip: 'Remove from cart',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  
  const _QuantityButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: IconButton(
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        color: onPressed == null ? Colors.grey[400] : AppColors.primary,
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final dynamic cartState;
  final VoidCallback onCheckoutPressed;
  
  const _CartSummary({
    required this.cartState,
    required this.onCheckoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subtotal
            _SummaryRow(
              label: 'Subtotal',
              value: '\$${cartState.total.toStringAsFixed(2)}',
            ),
            
            const Divider(height: 24),
            
            // Total
            _SummaryRow(
              label: 'Total',
              value: '\$${cartState.total.toStringAsFixed(2)}',
              isTotal: true,
            ),
            
            const SizedBox(height: AppSpacing.medium),
            
            // Checkout button
            CustomButton(
              text: 'Proceed to Checkout',
              onPressed: onCheckoutPressed,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = isTotal
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            )
        : Theme.of(context).textTheme.bodyMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textStyle),
        Text(value, style: textStyle),
      ],
    );
  }
} 