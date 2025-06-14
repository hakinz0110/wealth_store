import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.name,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon in a circle with ripple effect
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: onTap,
              splashColor: const Color(0xFF6518F4).withOpacity(0.2),
              highlightColor: const Color(0xFF6518F4).withOpacity(0.1),
              child: Ink(
                height: 55,
                width: 55,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6518F4).withOpacity(0.1)
                      : Colors.grey.shade100,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: const Color(0xFF6518F4), width: 2)
                      : null,
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? const Color(0xFF6518F4)
                      : Colors.grey.shade700,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Category name
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF6518F4) : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
