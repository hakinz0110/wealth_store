import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_design_tokens.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/constants/app_text_styles.dart';
import 'package:wealth_app/core/utils/image_url_helper.dart';
import 'package:wealth_app/core/utils/typography_utils.dart';
import 'package:wealth_app/core/utils/visual_styling_utils.dart';
import 'package:wealth_app/core/utils/haptic_feedback_utils.dart';
import 'package:wealth_app/shared/widgets/optimized_cached_image.dart';
import 'package:wealth_app/core/utils/accessibility_utils.dart';
import 'package:wealth_app/shared/models/product.dart';
import 'package:wealth_app/shared/widgets/animated_icon_button.dart';
import 'package:wealth_app/shared/widgets/add_to_cart_animation.dart';
import 'package:wealth_app/shared/widgets/enhanced_status_badge.dart';

class ModernProductCard extends StatefulWidget {
  final Product product;
  final bool isWishlisted;
  final VoidCallback onWishlistToggle;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;
  final bool showQuickActions;

  const ModernProductCard({
    super.key,
    required this.product,
    required this.isWishlisted,
    required this.onWishlistToggle,
    required this.onTap,
    this.onAddToCart,
    this.showQuickActions = true,
  });

  @override
  State<ModernProductCard> createState() => _ModernProductCardState();
}

class _ModernProductCardState extends State<ModernProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 150), // Reduced duration for better performance
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    if (_isHovered == isHovered) return; // Prevent unnecessary rebuilds
    
    setState(() {
      _isHovered = isHovered;
    });
    
    if (isHovered) {
      _hoverController.forward();
      HapticFeedbackUtils.lightImpact();
    } else {
      _hoverController.reverse();
    }
  }



  String _getImageUrl(String imageUrl) {
    return ImageUrlHelper.getProductImageUrl(imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Create comprehensive semantic label for screen readers
    final semanticLabel = AccessibilityUtils.createSemanticLabel(
      primaryText: widget.product.name,
      secondaryText: AccessibilityUtils.createPriceSemanticLabel(widget.product.price),
      statusText: widget.product.rating > 0 
          ? AccessibilityUtils.createRatingSemanticLabel(widget.product.rating, widget.product.reviewCount)
          : null,
      actionHint: 'Double tap to view product details',
    );
    
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: true,
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _hoverController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_hoverController.value * 0.02),
                child: Container(
                  // Ensure minimum touch target size for accessibility
                  constraints: const BoxConstraints(
                    minWidth: 44.0,
                    minHeight: 44.0,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20), // More rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.08),
                        blurRadius: _isHovered ? 12 : 8,
                        offset: Offset(0, _isHovered ? 6 : 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product image with improved aspect ratio
                      Expanded(
                        flex: 5, // Increased for better image display
                        child: _buildProductImage(isDark),
                      ),
                      
                      // Product details with better spacing
                      Expanded(
                        flex: 3,
                        child: _buildProductDetails(isDark),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(bool isDark) {
    return Stack(
      children: [
        // Main product image with improved sizing and aspect ratio
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey[50]!,
                  Colors.grey[100]!,
                ],
              ),
            ),
            child: AspectRatio(
              aspectRatio: 1.0, // Square aspect ratio for consistent display
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Add padding to prevent image cutoff
                child: OptimizedCachedImage(
                  imageUrl: _getImageUrl(widget.product.imageUrl),
                  fit: BoxFit.contain, // Ensure full image is visible
                  placeholder: _buildShimmerPlaceholder(),
                  errorWidget: _buildErrorPlaceholder(),
                ),
              ),
            ),
          ),
        ),
        
        // Enhanced wishlist heart icon with hover and click effects
        Positioned(
          top: 12,
          right: 12,
          child: _buildWishlistButton(),
        ),
        
        // Quick action buttons (shown on hover/long-press) - Simplified for performance
        if (widget.showQuickActions && _isHovered)
          Positioned(
            bottom: 12,
            right: 12,
            child: AnimatedOpacity(
              opacity: _isHovered ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 150),
              child: _buildQuickActions(),
            ),
          ),
        
        // Featured badge
        if (widget.product.isFeatured)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Featured',
                style: TypographyUtils.getStatusStyle(
                  context,
                  StatusType.info,
                ).copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductDetails(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(12.0), // Optimized padding to prevent overflow
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Prevent overflow by using minimum space
        children: [
          // Product name with enhanced typography
          Flexible(
            child: Text(
              widget.product.name,
              style: TypographyUtils.getProductTitleStyle(
                context,
                size: ProductTitleSize.medium,
                isEmphasis: true,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          const SizedBox(height: 6), // Optimized spacing
          
          // Rating and review count
          if (widget.product.rating > 0) ...[
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < widget.product.rating.floor()
                        ? Icons.star
                        : index < widget.product.rating
                            ? Icons.star_half
                            : Icons.star_border,
                    size: 14, // Optimized size to prevent overflow
                    color: AppColors.warning,
                  );
                }),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '(${widget.product.reviewCount})',
                    style: TypographyUtils.getLabelStyle(
                      context,
                      size: LabelSize.small,
                      isSecondary: true,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          
          const Spacer(),
          
          // Price with enhanced emphasis treatment
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
              Text(
                '\$${widget.product.price.toStringAsFixed(2)}',
                style: TypographyUtils.getPriceStyle(
                  context,
                  size: PriceSize.medium,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              

            ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistButton() {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isButtonHovered = false;
        
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => isButtonHovered = true),
          onExit: (_) => setState(() => isButtonHovered = false),
          child: GestureDetector(
            onTap: () {
              HapticFeedbackUtils.buttonPress();
              widget.onWishlistToggle();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: isButtonHovered ? 1.0 : 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isButtonHovered ? 0.15 : 0.1),
                    blurRadius: isButtonHovered ? 12 : 8,
                    offset: Offset(0, isButtonHovered ? 4 : 2),
                  ),
                ],
              ),
              child: Transform.scale(
                scale: isButtonHovered ? 1.1 : 1.0,
                child: Icon(
                  widget.isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: widget.isWishlisted ? AppColors.error : AppColors.neutral600,
                  size: 20,
                ),
              ),
            )
              .animate(target: widget.isWishlisted ? 1 : 0)
              .scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.2, 1.2),
                duration: 200.ms,
                curve: Curves.elasticOut,
              )
              .then()
              .scale(
                begin: const Offset(1.2, 1.2),
                end: const Offset(1.0, 1.0),
                duration: 200.ms,
                curve: Curves.elasticOut,
              ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.onAddToCart != null && widget.product.stock > 0)
          _buildQuickActionButton(
            icon: Icons.add_shopping_cart,
            onTap: widget.onAddToCart!,
            tooltip: 'Add to Cart',
          ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isActionHovered = false;
        bool isActionPressed = false;
        
        return Semantics(
          label: tooltip,
          hint: 'Double tap to $tooltip for ${widget.product.name}',
          button: true,
          enabled: true,
          onTap: onTap,
          child: Tooltip(
            message: tooltip,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => isActionHovered = true),
              onExit: (_) => setState(() => isActionHovered = false),
              child: GestureDetector(
                onTapDown: (_) => setState(() => isActionPressed = true),
                onTapUp: (_) => setState(() => isActionPressed = false),
                onTapCancel: () => setState(() => isActionPressed = false),
                onTap: () {
                  HapticFeedbackUtils.addItem();
                  onTap();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOutCubic,
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(left: 8),
                  transform: Matrix4.identity()
                    ..scale(isActionPressed ? 0.9 : isActionHovered ? 1.05 : 1.0),
                  decoration: BoxDecoration(
                    color: isActionPressed 
                        ? AppColors.primary.withValues(alpha: 0.8)
                        : isActionHovered 
                            ? AppColors.primary.withValues(alpha: 0.9)
                            : AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: isActionHovered ? 0.4 : 0.3),
                        blurRadius: isActionHovered ? 12 : 8,
                        offset: Offset(0, isActionHovered ? 4 : 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Image not available',
            style: TypographyUtils.getLabelStyle(
              context,
              size: LabelSize.small,
              isSecondary: true,
            ),
          ),
        ],
      ),
    );
  }
}