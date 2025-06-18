import 'package:flutter/material.dart';
import '../screens/subcategory_screen.dart'; // We'll create this screen

class CategoryItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  // Make subCategories more flexible
  final dynamic subCategories;

  const CategoryItem({
    super.key,
    required this.name,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
    this.subCategories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
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
                        subCategories: subCategories is List
                            ? subCategories
                            : [subCategories],
                      ),
                    ),
                  );
                } else {
                  onTap();
                }
              },
              splashColor: const Color(0xFF6518F4).withOpacity(0.2),
              highlightColor: const Color(0xFF6518F4).withOpacity(0.1),
              hoverColor: const Color(0xFF6518F4).withOpacity(0.05),
              child: Ink(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6518F4).withOpacity(0.1)
                      : Colors.grey.shade100,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: const Color(0xFF6518F4), width: 2)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: isSelected
                        ? const Color(0xFF6518F4)
                        : Colors.grey.shade700,
                    size: 35,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF6518F4) : Colors.black87,
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
