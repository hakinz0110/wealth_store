import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// Optimized cached network image widget with performance enhancements
class OptimizedCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Duration fadeInDuration;
  final Duration placeholderFadeInDuration;
  final bool useOldImageOnUrlChange;
  final Color? color;
  final BlendMode? colorBlendMode;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final bool matchTextDirection;
  final Map<String, String>? httpHeaders;
  final int? cacheWidth;
  final int? cacheHeight;
  final FilterQuality filterQuality;
  final bool enableMemoryCache;
  final bool enableDiskCache;
  final Duration? maxCacheAge;
  final int? maxCacheSize;

  const OptimizedCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.placeholderFadeInDuration = const Duration(milliseconds: 300),
    this.useOldImageOnUrlChange = false,
    this.color,
    this.colorBlendMode,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    this.httpHeaders,
    this.cacheWidth,
    this.cacheHeight,
    this.filterQuality = FilterQuality.low,
    this.enableMemoryCache = true,
    this.enableDiskCache = true,
    this.maxCacheAge,
    this.maxCacheSize,
  });

  @override
  Widget build(BuildContext context) {
    // Return empty container for empty URLs
    if (imageUrl.isEmpty) {
      return _buildErrorWidget(context);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
      alignment: alignment as Alignment,
      repeat: repeat,
      matchTextDirection: matchTextDirection,
      httpHeaders: httpHeaders,
      cacheKey: _generateCacheKey(),
      fadeInDuration: fadeInDuration,
      placeholderFadeInDuration: placeholderFadeInDuration,
      useOldImageOnUrlChange: useOldImageOnUrlChange,
      filterQuality: filterQuality,
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
      placeholder: (context, url) => _buildPlaceholder(context),
      errorWidget: (context, url, error) => _buildErrorWidget(context),
      cacheManager: _getCacheManager(),
    );
  }

  /// Generate optimized cache key
  String? _generateCacheKey() {
    if (cacheWidth != null || cacheHeight != null) {
      return '${imageUrl}_${cacheWidth ?? 'auto'}_${cacheHeight ?? 'auto'}';
    }
    return null;
  }

  /// Get optimized cache manager
  dynamic _getCacheManager() {
    // Use default cache manager with optimizations
    return null; // CachedNetworkImage will use DefaultCacheManager
  }

  /// Build optimized placeholder widget
  Widget _buildPlaceholder(BuildContext context) {
    if (placeholder != null) {
      return placeholder!;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        highlightColor: Theme.of(context).colorScheme.surface,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  /// Build optimized error widget
  Widget _buildErrorWidget(BuildContext context) {
    if (errorWidget != null) {
      return errorWidget!;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Theme.of(context).colorScheme.onErrorContainer,
        size: (width != null && height != null) 
            ? (width! < height! ? width! * 0.3 : height! * 0.3)
            : 24,
      ),
    );
  }
}

/// Optimized product image widget with specific sizing
class OptimizedProductImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool isHero;
  final String? heroTag;

  const OptimizedProductImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.isHero = false,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final image = OptimizedCachedImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      // Optimize for product images
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
      filterQuality: FilterQuality.medium,
      fadeInDuration: const Duration(milliseconds: 200),
    );

    if (isHero && heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: image,
      );
    }

    return image;
  }
}

/// Optimized banner image widget
class OptimizedBannerImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final VoidCallback? onTap;

  const OptimizedBannerImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final image = OptimizedCachedImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      // Optimize for banner images (usually wider)
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
      filterQuality: FilterQuality.high, // Banners need higher quality
      fadeInDuration: const Duration(milliseconds: 400),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: image,
      );
    }

    return image;
  }
}

/// Optimized avatar image widget
class OptimizedAvatarImage extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final Color? backgroundColor;

  const OptimizedAvatarImage({
    super.key,
    required this.imageUrl,
    this.radius = 20,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ClipOval(
        child: OptimizedCachedImage(
          imageUrl: imageUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          // Optimize for small avatar images
          cacheWidth: (radius * 2 * MediaQuery.of(context).devicePixelRatio).toInt(),
          cacheHeight: (radius * 2 * MediaQuery.of(context).devicePixelRatio).toInt(),
          filterQuality: FilterQuality.medium,
          fadeInDuration: const Duration(milliseconds: 150),
        ),
      ),
    );
  }
}