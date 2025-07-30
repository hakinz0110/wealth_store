import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Optimized cached network image widget with performance enhancements for admin app
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
      alignment: alignment,
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
    );
  }

  /// Generate optimized cache key
  String? _generateCacheKey() {
    if (cacheWidth != null || cacheHeight != null) {
      return '${imageUrl}_${cacheWidth ?? 'auto'}_${cacheHeight ?? 'auto'}';
    }
    return null;
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
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
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
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey[400],
        size: (width != null && height != null) 
            ? (width! < height! ? width! * 0.3 : height! * 0.3)
            : 24,
      ),
    );
  }
}

/// Optimized product image widget for admin interface
class OptimizedProductImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final VoidCallback? onTap;

  const OptimizedProductImage({
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
      // Optimize for admin product images (smaller thumbnails)
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
      filterQuality: FilterQuality.medium,
      fadeInDuration: const Duration(milliseconds: 200),
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

/// Optimized banner image widget for admin interface
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
      // Optimize for admin banner images
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
      filterQuality: FilterQuality.medium,
      fadeInDuration: const Duration(milliseconds: 300),
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

/// Optimized file preview image widget
class OptimizedFilePreview extends StatelessWidget {
  final String imageUrl;
  final double size;
  final VoidCallback? onTap;

  const OptimizedFilePreview({
    super.key,
    required this.imageUrl,
    this.size = 100,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final image = OptimizedCachedImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      // Optimize for small file previews
      cacheWidth: (size * MediaQuery.of(context).devicePixelRatio).toInt(),
      cacheHeight: (size * MediaQuery.of(context).devicePixelRatio).toInt(),
      filterQuality: FilterQuality.low,
      fadeInDuration: const Duration(milliseconds: 150),
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