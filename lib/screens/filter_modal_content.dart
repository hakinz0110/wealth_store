import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class FilterModalContent extends StatefulWidget {
  const FilterModalContent({Key? key}) : super(key: key);

  @override
  _FilterModalContentState createState() => _FilterModalContentState();
}

class _FilterModalContentState extends State<FilterModalContent> {
  String? _selectedSortBy;
  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(0, 1000);

  // Sort options
  final List<String> _sortOptions = [
    'Name',
    'Most Popular',
    'Newest',
    'Lowest Price',
    'Highest Price',
    'Most Suitable',
  ];

  // Category options
  final List<String> _categoryOptions = [
    'Sports',
    'Electronics',
    'Animals',
    'Cosmetics',
    'Sport Shoes',
    'Sport Equipments',
    'Kitchen Furniture',
    'Laptop',
    'Shirts',
    'Furniture',
    'Clothes',
    'Shoes',
    'Jewelry',
    'Track Suits',
    'Bedroom Furniture',
    'Office Furniture',
    'Mobile',
  ];

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title and Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          // Sort By Section
          const SizedBox(height: 16),
          const Text(
            'Sort by',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _sortOptions.map((option) {
              return ChoiceChip(
                label: Text(option),
                selected: _selectedSortBy == option,
                onSelected: (selected) {
                  setState(() {
                    _selectedSortBy = selected ? option : null;
                  });
                },
                selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
                labelStyle: TextStyle(
                  color: _selectedSortBy == option
                      ? Theme.of(context).primaryColor
                      : (isDarkMode ? Colors.white : Colors.black87),
                  fontWeight: _selectedSortBy == option
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: _selectedSortBy == option
                        ? Theme.of(context).primaryColor
                        : (isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade300),
                  ),
                ),
              );
            }).toList(),
          ),

          // Category Section
          const SizedBox(height: 16),
          const Text(
            'Category',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categoryOptions.map((option) {
              return ChoiceChip(
                label: Text(option),
                selected: _selectedCategory == option,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? option : null;
                  });
                },
                selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
                labelStyle: TextStyle(
                  color: _selectedCategory == option
                      ? Theme.of(context).primaryColor
                      : (isDarkMode ? Colors.white : Colors.black87),
                  fontWeight: _selectedCategory == option
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: _selectedCategory == option
                        ? Theme.of(context).primaryColor
                        : (isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade300),
                  ),
                ),
              );
            }).toList(),
          ),

          // Pricing Section
          const SizedBox(height: 16),
          const Text(
            'Pricing',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 1000,
            divisions: 100,
            labels: RangeLabels(
              '\$${_priceRange.start.round()}',
              '\$${_priceRange.end.round()}',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _priceRange = values;
              });
            },
            activeColor: Theme.of(context).primaryColor,
            inactiveColor: isDarkMode
                ? Colors.grey.shade700
                : Colors.grey.shade300,
          ),

          // Apply Button
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Apply filters
                if (_selectedCategory != null) {
                  productProvider.setCategory(_selectedCategory!);
                }
                // You can add more filter logic here for sorting and price range
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Apply',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
