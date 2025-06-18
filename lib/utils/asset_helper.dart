import 'package:flutter/material.dart';

class AssetHelper {
  /// Loads an image asset with a fallback icon if the image fails to load
  static Widget loadImage({
    required String path,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Color fallbackColor = Colors.grey,
    IconData fallbackIcon = Icons.image,
    double? fallbackIconSize,
  }) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading image asset: $path');
        debugPrint('Error details: $error');

        return Container(
          width: width,
          height: height,
          color: fallbackColor.withOpacity(0.3),
          child: Icon(
            fallbackIcon,
            size: fallbackIconSize ?? (height != null ? height / 2 : 24),
            color: fallbackColor,
          ),
        );
      },
    );
  }
}
