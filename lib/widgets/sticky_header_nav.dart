import 'package:flutter/material.dart';

class NavItem {
  final String label;
  final IconData icon;
  final String id;

  NavItem({required this.label, required this.icon, required this.id});
}

class StickyHeaderNav extends StatefulWidget {
  final List<NavItem> items;
  final Function(String) onItemSelected;
  final String selectedId;
  final bool showShadow;

  const StickyHeaderNav({
    super.key,
    required this.items,
    required this.onItemSelected,
    required this.selectedId,
    this.showShadow = true,
  });

  @override
  State<StickyHeaderNav> createState() => _StickyHeaderNavState();
}

class _StickyHeaderNavState extends State<StickyHeaderNav> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: widget.showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final isSelected = item.id == widget.selectedId;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => widget.onItemSelected(item.id),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withAlpha(26)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 16,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : isDarkMode
                            ? Colors.white
                            : Colors.black87,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : isDarkMode
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Scroll to the selected item
  void scrollToSelected() {
    if (_scrollController.hasClients) {
      final selectedIndex = widget.items.indexWhere(
        (item) => item.id == widget.selectedId,
      );
      if (selectedIndex >= 0) {
        final scrollPosition = (selectedIndex * 100.0).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );

        _scrollController.animateTo(
          scrollPosition,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }
}
