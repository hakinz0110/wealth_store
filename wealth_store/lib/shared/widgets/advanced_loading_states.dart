import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_design_tokens.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/utils/typography_utils.dart';
import 'package:wealth_app/core/utils/visual_styling_utils.dart';

/// Advanced loading states that provide contextual feedback without blocking UI
class AdvancedLoadingStates {
  
  /// Contextual skeleton loader that matches expected content layout
  static Widget skeletonLoader({
    required SkeletonType type,
    int itemCount = 3,
    EdgeInsets? padding,
  }) {
    switch (type) {
      case SkeletonType.productCard:
        return _ProductCardSkeleton(itemCount: itemCount, padding: padding);
      case SkeletonType.listItem:
        return _ListItemSkeleton(itemCount: itemCount, padding: padding);
      case SkeletonType.profileHeader:
        return _ProfileHeaderSkeleton(padding: padding);
      case SkeletonType.textBlock:
        return _TextBlockSkeleton(itemCount: itemCount, padding: padding);
      case SkeletonType.imageGallery:
        return _ImageGallerySkeleton(itemCount: itemCount, padding: padding);
    }
  }
  
  /// Non-blocking loading overlay that allows interaction with background
  static Widget nonBlockingLoader({
    required Widget child,
    required bool isLoading,
    String? loadingText,
    Color? backgroundColor,
  }) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: (backgroundColor ?? Colors.white).withValues(alpha: 0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PulsingLoadingIndicator(),
                    if (loadingText != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        loadingText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 200.ms),
          ),
      ],
    );
  }
  
  /// Inline loading indicator for buttons and small components
  static Widget inlineLoader({
    double size = 16,
    Color? color,
    String? text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppColors.primary,
            ),
          ),
        ),
        if (text != null) ...[
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: color ?? AppColors.primary,
            ),
          ),
        ],
      ],
    );
  }
  
  /// Progressive loading indicator for multi-step processes
  static Widget progressiveLoader({
    required int currentStep,
    required int totalSteps,
    required List<String> stepLabels,
    Color? activeColor,
    Color? inactiveColor,
  }) {
    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: currentStep / totalSteps,
          backgroundColor: inactiveColor ?? AppColors.neutral200,
          valueColor: AlwaysStoppedAnimation<Color>(
            activeColor ?? AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        // Step indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(totalSteps, (index) {
            final isActive = index < currentStep;
            final isCurrent = index == currentStep - 1;
            
            return Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive 
                        ? (activeColor ?? AppColors.primary)
                        : (inactiveColor ?? AppColors.neutral200),
                    border: isCurrent 
                        ? Border.all(
                            color: activeColor ?? AppColors.primary,
                            width: 2,
                          )
                        : null,
                  ),
                  child: isActive
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.white : AppColors.neutral600,
                          ),
                        ),
                ),
                const SizedBox(height: 4),
                if (index < stepLabels.length)
                  Text(
                    stepLabels[index],
                    style: TextStyle(
                      fontSize: 10,
                      color: isActive 
                          ? (activeColor ?? AppColors.primary)
                          : AppColors.neutral600,
                    ),
                  ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

/// Pulsing loading indicator with modern animation
class PulsingLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  
  const PulsingLoadingIndicator({
    super.key,
    this.size = 40,
    this.color,
  });
  
  @override
  State<PulsingLoadingIndicator> createState() => _PulsingLoadingIndicatorState();
}

class _PulsingLoadingIndicatorState extends State<PulsingLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                (widget.color ?? AppColors.primary).withValues(alpha: 0.8),
                (widget.color ?? AppColors.primary).withValues(alpha: 0.2),
              ],
            ),
          ),
        ).animate(
          onPlay: (controller) => controller.repeat(),
        ).scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.2, 1.2),
          duration: 750.ms,
          curve: Curves.easeInOut,
        ).then().scale(
          begin: const Offset(1.2, 1.2),
          end: const Offset(0.8, 0.8),
          duration: 750.ms,
          curve: Curves.easeInOut,
        );
      },
    );
  }
}

/// Skeleton loading widgets for different content types
class _ProductCardSkeleton extends StatelessWidget {
  final int itemCount;
  final EdgeInsets? padding;
  
  const _ProductCardSkeleton({
    required this.itemCount,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.all(AppSpacing.md),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            decoration: VisualStylingUtils.getElevatedCardDecoration(
              context: context,
              elevation: 1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image skeleton
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.neutral200,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                  ).animate(onPlay: (controller) => controller.repeat())
                      .shimmer(duration: 1500.ms),
                ),
                // Content skeleton
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title skeleton
                        Container(
                          height: 16,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.neutral200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ).animate(onPlay: (controller) => controller.repeat())
                            .shimmer(duration: 1500.ms),
                        const SizedBox(height: 8),
                        // Price skeleton
                        Container(
                          height: 14,
                          width: 80,
                          decoration: BoxDecoration(
                            color: AppColors.neutral200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ).animate(onPlay: (controller) => controller.repeat())
                            .shimmer(duration: 1500.ms),
                      ],
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

class _ListItemSkeleton extends StatelessWidget {
  final int itemCount;
  final EdgeInsets? padding;
  
  const _ListItemSkeleton({
    required this.itemCount,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: List.generate(itemCount, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: VisualStylingUtils.getElevatedCardDecoration(
              context: context,
              elevation: 1,
            ),
            child: Row(
              children: [
                // Avatar skeleton
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.neutral200,
                    shape: BoxShape.circle,
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 1500.ms),
                const SizedBox(width: 16),
                // Content skeleton
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.neutral200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ).animate(onPlay: (controller) => controller.repeat())
                          .shimmer(duration: 1500.ms),
                      const SizedBox(height: 8),
                      Container(
                        height: 14,
                        width: 120,
                        decoration: BoxDecoration(
                          color: AppColors.neutral200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ).animate(onPlay: (controller) => controller.repeat())
                          .shimmer(duration: 1500.ms),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ProfileHeaderSkeleton extends StatelessWidget {
  final EdgeInsets? padding;
  
  const _ProfileHeaderSkeleton({this.padding});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // Large avatar skeleton
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: AppColors.neutral200,
              shape: BoxShape.circle,
            ),
          ).animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1500.ms),
          const SizedBox(height: 16),
          // Name skeleton
          Container(
            height: 24,
            width: 200,
            decoration: BoxDecoration(
              color: AppColors.neutral200,
              borderRadius: BorderRadius.circular(4),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1500.ms),
          const SizedBox(height: 8),
          // Email skeleton
          Container(
            height: 16,
            width: 160,
            decoration: BoxDecoration(
              color: AppColors.neutral200,
              borderRadius: BorderRadius.circular(4),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1500.ms),
        ],
      ),
    );
  }
}

class _TextBlockSkeleton extends StatelessWidget {
  final int itemCount;
  final EdgeInsets? padding;
  
  const _TextBlockSkeleton({
    required this.itemCount,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(itemCount, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            height: 16,
            width: double.infinity * (0.7 + (index % 3) * 0.1),
            decoration: BoxDecoration(
              color: AppColors.neutral200,
              borderRadius: BorderRadius.circular(4),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1500.ms);
        }),
      ),
    );
  }
}

class _ImageGallerySkeleton extends StatelessWidget {
  final int itemCount;
  final EdgeInsets? padding;
  
  const _ImageGallerySkeleton({
    required this.itemCount,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.all(AppSpacing.md),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.neutral200,
              borderRadius: BorderRadius.circular(8),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1500.ms);
        },
      ),
    );
  }
}

/// Enum for different skeleton types
enum SkeletonType {
  productCard,
  listItem,
  profileHeader,
  textBlock,
  imageGallery,
}