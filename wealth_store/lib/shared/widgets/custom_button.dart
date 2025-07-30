import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/utils/accessibility_utils.dart';
import 'package:wealth_app/core/utils/haptic_feedback_utils.dart';

enum ButtonType {
  primary,
  secondary,
  outlined,
  text
}

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType type;
  final double? width;
  final double height;
  final IconData? icon;
  final bool enableHapticFeedback;
  final bool enableScaleAnimation;
  
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.width,
    this.height = 50,
    this.icon,
    this.enableHapticFeedback = true,
    this.enableScaleAnimation = true,
  });
  
  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isLoading && widget.onPressed != null) {
      setState(() => _isPressed = true);
      if (widget.enableScaleAnimation) {
        _animationController.forward();
      }
      if (widget.enableHapticFeedback) {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _resetPressState();
  }

  void _handleTapCancel() {
    _resetPressState();
  }

  void _resetPressState() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      if (widget.enableScaleAnimation) {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create semantic label for screen readers
    final semanticLabel = AccessibilityUtils.createSemanticLabel(
      primaryText: widget.text,
      statusText: widget.isLoading ? 'Loading' : null,
      actionHint: widget.onPressed != null ? 'Double tap to activate' : 'Button disabled',
    );

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: widget.onPressed != null && !widget.isLoading,
      onTap: widget.onPressed,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.enableScaleAnimation ? _scaleAnimation.value : 1.0,
              child: SizedBox(
                width: widget.width,
                // Ensure minimum touch target height for accessibility
                height: widget.height < 44.0 ? 44.0 : widget.height,
                child: _buildButton(context),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildButton(BuildContext context) {
    switch (widget.type) {
      case ButtonType.primary:
        return ElevatedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: _isPressed ? 1 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            splashFactory: InkRipple.splashFactory,
          ),
          child: _buildChild(),
        );
      case ButtonType.secondary:
        return ElevatedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            elevation: _isPressed ? 1 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            splashFactory: InkRipple.splashFactory,
          ),
          child: _buildChild(),
        );
      case ButtonType.outlined:
        return OutlinedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(
              color: _isPressed ? AppColors.primary600 : AppColors.primary,
              width: _isPressed ? 2 : 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            splashFactory: InkRipple.splashFactory,
          ),
          child: _buildChild(),
        );
      case ButtonType.text:
        return TextButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            splashFactory: InkRipple.splashFactory,
          ),
          child: _buildChild(),
        );
    }
  }
  
  Widget _buildChild() {
    if (widget.isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
    
    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, size: 20),
          const SizedBox(width: 8),
          Text(widget.text),
        ],
      );
    }
    
    return Text(widget.text);
  }
} 