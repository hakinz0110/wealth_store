import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wealth_app/core/constants/app_colors.dart';

class AddToCartAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isAdded;
  final Duration animationDuration;
  
  const AddToCartAnimation({
    super.key,
    required this.child,
    this.onPressed,
    this.isLoading = false,
    this.isAdded = false,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  @override
  State<AddToCartAnimation> createState() => _AddToCartAnimationState();
}

class _AddToCartAnimationState extends State<AddToCartAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late AnimationController _rippleController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _rippleAnimation;
  
  bool _showCheck = false;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
    
    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );
    
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    if (widget.onPressed == null || widget.isLoading) return;
    
    // Haptic feedback
    HapticFeedback.mediumImpact();
    
    // Scale animation
    await _scaleController.forward();
    await _scaleController.reverse();
    
    // Call the callback
    widget.onPressed!();
    
    // Show success animation
    setState(() => _showCheck = true);
    _checkController.forward();
    _rippleController.forward();
    
    // Hide check after delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _showCheck = false);
        _checkController.reset();
        _rippleController.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleController, _checkController, _rippleController]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Ripple effect
              if (_showCheck)
                Container(
                  width: 60 * _rippleAnimation.value,
                  height: 60 * _rippleAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success.withValues(
                      alpha: (1.0 - _rippleAnimation.value) * 0.3,
                    ),
                  ),
                ),
              
              // Main button with scale animation
              Transform.scale(
                scale: _scaleAnimation.value,
                child: widget.child,
              ),
              
              // Success checkmark
              if (_showCheck)
                Transform.scale(
                  scale: _checkAnimation.value,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class FloatingAddToCartButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;
  final IconData icon;
  
  const FloatingAddToCartButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.text = 'Add to Cart',
    this.icon = Icons.shopping_cart_outlined,
  });

  @override
  State<FloatingAddToCartButton> createState() => _FloatingAddToCartButtonState();
}

class _FloatingAddToCartButtonState extends State<FloatingAddToCartButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  bool _isAdded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePressed() async {
    if (widget.onPressed == null || widget.isLoading) return;
    
    setState(() => _isAdded = true);
    await _controller.forward();
    
    widget.onPressed!();
    
    // Reset after delay
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() => _isAdded = false);
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 3.14159,
            child: FloatingActionButton.extended(
              onPressed: _handlePressed,
              backgroundColor: _isAdded ? AppColors.success : AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: Icon(
                _isAdded ? Icons.check : widget.icon,
                size: 24,
              ),
              label: Text(
                _isAdded ? 'Added!' : widget.text,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CartIconWithBadge extends StatefulWidget {
  final int itemCount;
  final VoidCallback? onPressed;
  final Color? badgeColor;
  final Color? iconColor;
  final double iconSize;
  
  const CartIconWithBadge({
    super.key,
    required this.itemCount,
    this.onPressed,
    this.badgeColor,
    this.iconColor,
    this.iconSize = 24,
  });

  @override
  State<CartIconWithBadge> createState() => _CartIconWithBadgeState();
}

class _CartIconWithBadgeState extends State<CartIconWithBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    _previousCount = widget.itemCount;
  }

  @override
  void didUpdateWidget(CartIconWithBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.itemCount > _previousCount) {
      _controller.forward().then((_) => _controller.reverse());
    }
    _previousCount = widget.itemCount;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _bounceAnimation.value,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: widget.iconSize,
                  color: widget.iconColor ?? Theme.of(context).iconTheme.color,
                ),
                if (widget.itemCount > 0)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: widget.badgeColor ?? AppColors.error,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowMedium,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        widget.itemCount > 99 ? '99+' : widget.itemCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}