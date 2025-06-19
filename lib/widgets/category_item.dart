import 'package:flutter/material.dart';
import '../screens/subcategory_screen.dart'; // We'll create this screen
import 'package:cached_network_image/cached_network_image.dart';

class CategoryItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final dynamic subCategories;
  final Color? accentColor;
  final String? imageUrl; // New property for image-based categories

  const CategoryItem({
    super.key,
    required this.name,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
    this.subCategories,
    this.accentColor,
    this.imageUrl, // Add imageUrl parameter
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final defaultAccentColor = const Color(0xFF6518F4);
    final iconColor = accentColor ?? defaultAccentColor;

    return SizedBox(
      width: 85,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () {
                if (subCategories != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SubcategoryScreen(
                        categoryName: name,
                        subCategories: subCategories,
                      ),
                    ),
                  );
                } else {
                  onTap();
                }
              },
              splashColor: iconColor.withOpacity(0.2),
              highlightColor: iconColor.withOpacity(0.1),
              hoverColor: iconColor.withOpacity(0.05),
              child: Ink(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [iconColor.withOpacity(0.7), iconColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected
                      ? null
                      : isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade100,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? iconColor.withOpacity(0.3)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  // Use either network image or icon
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: imageUrl!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: iconColor,
                                ),
                            errorWidget: (context, url, error) => Icon(
                              icon,
                              color: isSelected
                                  ? Colors.white
                                  : isDarkMode
                                  ? Colors.white
                                  : iconColor,
                              size: 32,
                            ),
                          ),
                        )
                      : Icon(
                          icon,
                          color: isSelected
                              ? Colors.white
                              : isDarkMode
                              ? Colors.white
                              : iconColor,
                          size: 32,
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 15,
            child: Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? iconColor
                    : isDarkMode
                    ? Colors.white
                    : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
