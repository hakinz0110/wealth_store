import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/constants/app_text_styles.dart';
import 'package:wealth_app/core/utils/image_url_helper.dart';
import 'package:wealth_app/core/utils/typography_utils.dart';
import 'package:wealth_app/features/cart/domain/cart_notifier.dart';
import 'package:wealth_app/features/wishlist/domain/wishlist_notifier.dart';

class ModernCartScreen extends ConsumerStatefulWidget {
  const ModernCartScreen({super.key});

  @override
  ConsumerState<ModernCartScreen> createState() => _ModernCartScreenState();
}

class _ModernCartScreenState extends ConsumerState<ModernCartScreen>
    with TickerProviderStateMixin {
  bool _isPricingExpanded = false;
  bool _isCheckingOut = false;
  late AnimationController _checkoutController;

  @override
  void initState() {
    super.initState();
    _checkoutController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _checkoutController.dispose();
    super.dispose();
  }

  void _togglePricingBreakdown() {
    setState(() {
      _isPricingExpanded = !_isPricingExpanded;
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _proceedToCheckout() async {
    setState(() {
      _isCheckingOut = true;
    });
    
    _checkoutController.forward();
    HapticFeedback.mediumImpact();
    
    // Simulate checkout process
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      context.push('/checkout');
      setState(() {
        _isCheckingOut = false;
      });
      _checkoutController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartNotifierProvider);
    
    return Scaffold(
      body: SafeArea(
        child: cartState.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : cartState.error != null
            ? _buildErrorState(cartState.error!)
            : _buildCartContent(cartState),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TypographyUtils.getHeadingStyle(
              context,
              HeadingLevel.h4,
              isEmphasis: true,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TypographyUtils.getBodyStyle(
              context,
              size: BodySize.medium,
              isSecondary: true,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(cartNotifierProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(dynamic cartState) {
    if (cartState.items.isEmpty) {
      return _buildEmptyCart();
    }
    
    return Column(
      children: [
        // Header
        _buildHeader(cartState),
        
        // Cart items list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(cartNotifierProvider);
            },
            child: ListView.builder(
              padding: EdgeInsets.all(AppSpacing.md),
              itemCount: cartState.items.length,
              itemBuilder: (context, index) {
                final item = cartState.items[index];
                return ModernCartItem(
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
                  onSaveForLater: () {
                    // Add to wishlist and remove from cart
                    ref.read(wishlistNotifierProvider.notifier).toggleWishlist(item.productId);
                    ref.read(cartNotifierProvider.notifier).removeItem(item.productId);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.name} saved for later'),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'View Wishlist',
                          onPressed: () => context.go('/wishlist'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        
        // Cart summary and checkout
        _buildCartSummary(cartState),
      ],
    );
  }

  Widget _buildHeader(dynamic cartState) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.neutral100,
              foregroundColor: AppColors.neutral700,
              padding: const EdgeInsets.all(8),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Your Cart',
            style: TypographyUtils.getHeadingStyle(
              context,
              HeadingLevel.h3,
              isEmphasis: true,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${cartState.itemCount} items',
                  style: TypographyUtils.getLabelStyle(
                    context,
                    size: LabelSize.medium,
                  ).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 60,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
            )
                .animate()
                .scale(
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 400.ms),
            
            const SizedBox(height: 32),
            
            Text(
              'Your cart is empty',
              style: TypographyUtils.getHeadingStyle(
                context,
                HeadingLevel.h3,
                isEmphasis: true,
              ),
            )
                .animate(delay: 200.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 12),
            
            Text(
              'Looks like you haven\'t added any items to your cart yet.\nStart shopping to fill it up!',
              style: TypographyUtils.getBodyStyle(
                context,
                size: BodySize.large,
                isSecondary: true,
              ),
              textAlign: TextAlign.center,
            )
                .animate(delay: 400.ms)
                .fadeIn(duration: 400.ms),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.go('/products');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Start Shopping',
                  style: TypographyUtils.getButtonStyle(
                    context,
                    size: ButtonSize.large,
                    type: ButtonType.primary,
                  ),
                ),
              ),
            )
                .animate(delay: 600.ms)
                .slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary(dynamic cartState) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Expandable pricing breakdown
            _buildPricingBreakdown(cartState),
            
            // Checkout button
            _buildCheckoutButton(cartState),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingBreakdown(dynamic cartState) {
    final subtotal = cartState.total;
    final shipping = subtotal > 50 ? 0.0 : 5.99;
    final tax = subtotal * 0.08; // 8% tax
    final total = subtotal + shipping + tax;

    return Column(
      children: [
        // Toggle button
        InkWell(
          onTap: _togglePricingBreakdown,
          child: Container(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Summary',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _isPricingExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Expandable content
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isPricingExpanded ? null : 0,
          child: _isPricingExpanded
              ? Container(
                  padding: EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                  child: Column(
                    children: [
                      const Divider(),
                      _buildSummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
                      _buildSummaryRow(
                        'Shipping', 
                        shipping == 0 ? 'Free' : '\$${shipping.toStringAsFixed(2)}',
                        subtitle: shipping == 0 ? 'Free shipping on orders over \$50' : null,
                      ),
                      _buildSummaryRow('Tax', '\$${tax.toStringAsFixed(2)}'),
                      const Divider(),
                      _buildSummaryRow(
                        'Total', 
                        '\$${total.toStringAsFixed(2)}', 
                        isTotal: true,
                      ),
                    ],
                  ),
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: isTotal
                    ? AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)
                    : AppTextStyles.bodyMedium,
              ),
              Text(
                value,
                style: isTotal
                    ? AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      )
                    : AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  Text(
                    subtitle,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(dynamic cartState) {
    final subtotal = cartState.total;
    final shipping = subtotal > 50 ? 0.0 : 5.99;
    final tax = subtotal * 0.08;
    final total = subtotal + shipping + tax;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Quick total display
          if (!_isPricingExpanded)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          
          // Checkout button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isCheckingOut ? null : _proceedToCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
              ),
              child: _isCheckingOut
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Processing...',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Proceed to Checkout',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class ModernCartItem extends StatefulWidget {
  final dynamic item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemovePressed;
  final VoidCallback onSaveForLater;
  
  const ModernCartItem({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemovePressed,
    required this.onSaveForLater,
  });

  @override
  State<ModernCartItem> createState() => _ModernCartItemState();
}

class _ModernCartItemState extends State<ModernCartItem> {
  void _handleRemove() async {
    HapticFeedback.mediumImpact();
    
    // Add a small delay for animation
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (mounted) {
      widget.onRemovePressed();
    }
  }

  void _incrementQuantity() {
    widget.onQuantityChanged(widget.item.quantity + 1);
    HapticFeedback.lightImpact();
  }

  void _decrementQuantity() {
    if (widget.item.quantity > 1) {
      widget.onQuantityChanged(widget.item.quantity - 1);
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key('cart_item_${widget.item.productId}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                'Remove',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.favorite_outline,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                'Save',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            _handleRemove();
            return false; // Don't auto-dismiss, we handle it manually
          } else {
            widget.onSaveForLater();
            return true;
          }
        },
        child: Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: AppColors.neutral200.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              // Product image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: CachedNetworkImage(
                    imageUrl: ImageUrlHelper.getProductImageUrl(widget.item.imageUrl ?? ''),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.name,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      '\$${widget.item.price.toStringAsFixed(2)}',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Quantity controls with haptic feedback
                    Row(
                      children: [
                        _buildQuantityButton(
                          Icons.remove,
                          widget.item.quantity > 1 ? _decrementQuantity : null,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            '${widget.item.quantity}',
                            style: AppTextStyles.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildQuantityButton(Icons.add, _incrementQuantity),
                        
                        const Spacer(),
                        
                        // Total price for this item
                        Text(
                          '\$${(widget.item.price * widget.item.quantity).toStringAsFixed(2)}',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback? onPressed) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(
          color: onPressed == null ? Colors.grey[300]! : AppColors.primary.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
        color: onPressed == null ? Colors.grey[50] : AppColors.primary.withValues(alpha: 0.1),
      ),
      child: IconButton(
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        color: onPressed == null ? Colors.grey[400] : AppColors.primary,
        padding: EdgeInsets.zero,
      ),
    );
  }
}