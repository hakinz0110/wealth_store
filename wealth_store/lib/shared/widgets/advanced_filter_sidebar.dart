import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/constants/app_text_styles.dart';
import 'package:wealth_app/core/constants/app_shadows.dart';

class AdvancedFilterSidebar extends StatefulWidget {
  final FilterState initialState;
  final List<FilterCategory> categories;
  final List<FilterBrand> brands;
  final double minPrice;
  final double maxPrice;
  final Function(FilterState) onFiltersChanged;
  final VoidCallback? onReset;
  final VoidCallback? onClose;

  const AdvancedFilterSidebar({
    super.key,
    required this.initialState,
    required this.categories,
    required this.brands,
    required this.minPrice,
    required this.maxPrice,
    required this.onFiltersChanged,
    this.onReset,
    this.onClose,
  });

  @override
  State<AdvancedFilterSidebar> createState() => _AdvancedFilterSidebarState();
}

class _AdvancedFilterSidebarState extends State<AdvancedFilterSidebar>
    with TickerProviderStateMixin {
  late FilterState _currentState;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _currentState = widget.initialState.copyWith();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _updateFilters() {
    widget.onFiltersChanged(_currentState);
  }

  void _resetFilters() {
    setState(() {
      _currentState = FilterState.initial();
    });
    _updateFilters();
    widget.onReset?.call();
    HapticFeedback.mediumImpact();
  }

  void _closeFilter() async {
    await _slideController.reverse();
    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: AppShadows.elevation16,
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Filters content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categories
                    _buildCategoriesSection(),
                    
                    SizedBox(height: AppSpacing.xl),
                    
                    // Price range
                    _buildPriceRangeSection(),
                    
                    SizedBox(height: AppSpacing.xl),
                    
                    // Brands
                    _buildBrandsSection(),
                    
                    SizedBox(height: AppSpacing.xl),
                    
                    // Rating
                    _buildRatingSection(),
                    
                    SizedBox(height: AppSpacing.xl),
                    
                    // Sort options
                    _buildSortSection(),
                    
                    SizedBox(height: AppSpacing.xl),
                    
                    // Availability
                    _buildAvailabilitySection(),
                  ],
                ),
              ),
            ),
            
            // Apply button
            _buildApplyButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        MediaQuery.of(context).padding.top + AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppShadows.elevation1,
      ),
      child: Row(
        children: [
          Text(
            'Filters',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const Spacer(),
          
          TextButton(
            onPressed: _resetFilters,
            child: Text(
              'Reset',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          IconButton(
            onPressed: _closeFilter,
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.neutral100,
              foregroundColor: AppColors.neutral700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return _buildFilterSection(
      title: 'Categories',
      child: Column(
        children: widget.categories.map((category) {
          final isSelected = _currentState.selectedCategories.contains(category.id);
          return _buildCheckboxTile(
            title: category.name,
            subtitle: '${category.productCount} products',
            isSelected: isSelected,
            onChanged: (selected) {
              setState(() {
                if (selected) {
                  _currentState.selectedCategories.add(category.id);
                } else {
                  _currentState.selectedCategories.remove(category.id);
                }
              });
              _updateFilters();
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceRangeSection() {
    return _buildFilterSection(
      title: 'Price Range',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${_currentState.minPrice.toInt()}',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\$${_currentState.maxPrice.toInt()}',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppSpacing.sm),
          
          RangeSlider(
            values: RangeValues(_currentState.minPrice, _currentState.maxPrice),
            min: widget.minPrice,
            max: widget.maxPrice,
            divisions: 50,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.primary.withValues(alpha: 0.2),
            onChanged: (values) {
              setState(() {
                _currentState.minPrice = values.start;
                _currentState.maxPrice = values.end;
              });
            },
            onChangeEnd: (values) {
              _updateFilters();
              HapticFeedback.lightImpact();
            },
          ),
          
          SizedBox(height: AppSpacing.sm),
          
          Row(
            children: [
              Expanded(
                child: _buildPriceInput(
                  label: 'Min',
                  value: _currentState.minPrice,
                  onChanged: (value) {
                    setState(() {
                      _currentState.minPrice = value.clamp(widget.minPrice, _currentState.maxPrice);
                    });
                    _updateFilters();
                  },
                ),
              ),
              
              SizedBox(width: AppSpacing.md),
              
              Expanded(
                child: _buildPriceInput(
                  label: 'Max',
                  value: _currentState.maxPrice,
                  onChanged: (value) {
                    setState(() {
                      _currentState.maxPrice = value.clamp(_currentState.minPrice, widget.maxPrice);
                    });
                    _updateFilters();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrandsSection() {
    return _buildFilterSection(
      title: 'Brands',
      child: Column(
        children: widget.brands.map((brand) {
          final isSelected = _currentState.selectedBrands.contains(brand.id);
          return _buildCheckboxTile(
            title: brand.name,
            subtitle: '${brand.productCount} products',
            isSelected: isSelected,
            onChanged: (selected) {
              setState(() {
                if (selected) {
                  _currentState.selectedBrands.add(brand.id);
                } else {
                  _currentState.selectedBrands.remove(brand.id);
                }
              });
              _updateFilters();
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRatingSection() {
    return _buildFilterSection(
      title: 'Customer Rating',
      child: Column(
        children: [5, 4, 3, 2, 1].map((rating) {
          final isSelected = _currentState.minRating == rating;
          return _buildRadioTile(
            title: Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: AppColors.warning,
                  );
                }),
                SizedBox(width: AppSpacing.sm),
                Text('& up'),
              ],
            ),
            isSelected: isSelected,
            onChanged: () {
              setState(() {
                _currentState.minRating = isSelected ? 0 : rating;
              });
              _updateFilters();
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSortSection() {
    return _buildFilterSection(
      title: 'Sort By',
      child: Column(
        children: SortOption.values.map((option) {
          final isSelected = _currentState.sortOption == option;
          return _buildRadioTile(
            title: Text(option.displayName),
            isSelected: isSelected,
            onChanged: () {
              setState(() {
                _currentState.sortOption = option;
              });
              _updateFilters();
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    return _buildFilterSection(
      title: 'Availability',
      child: Column(
        children: [
          _buildCheckboxTile(
            title: 'In Stock',
            isSelected: _currentState.inStockOnly,
            onChanged: (selected) {
              setState(() {
                _currentState.inStockOnly = selected;
              });
              _updateFilters();
            },
          ),
          _buildCheckboxTile(
            title: 'On Sale',
            isSelected: _currentState.onSaleOnly,
            onChanged: (selected) {
              setState(() {
                _currentState.onSaleOnly = selected;
              });
              _updateFilters();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        SizedBox(height: AppSpacing.md),
        
        child,
      ],
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    String? subtitle,
    required bool isSelected,
    required Function(bool) onChanged,
  }) {
    return InkWell(
      onTap: () {
        onChanged(!isSelected);
        HapticFeedback.lightImpact();
      },
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (value) => onChanged(value ?? false),
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            
            SizedBox(width: AppSpacing.sm),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioTile({
    required Widget title,
    required bool isSelected,
    required VoidCallback onChanged,
  }) {
    return InkWell(
      onTap: () {
        onChanged();
        HapticFeedback.lightImpact();
      },
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onChanged(),
              activeColor: AppColors.primary,
            ),
            
            SizedBox(width: AppSpacing.sm),
            
            Expanded(child: title),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInput({
    required String label,
    required double value,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        
        SizedBox(height: AppSpacing.xs),
        
        TextFormField(
          initialValue: value.toInt().toString(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: '\$',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              borderSide: BorderSide(color: AppColors.neutral300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
          onChanged: (text) {
            final newValue = double.tryParse(text) ?? value;
            onChanged(newValue);
          },
        ),
      ],
    );
  }

  Widget _buildApplyButton() {
    final activeFiltersCount = _getActiveFiltersCount();
    
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppShadows.elevation8,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _closeFilter,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Apply Filters',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (activeFiltersCount > 0) ...[
                  SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      activeFiltersCount.toString(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getActiveFiltersCount() {
    int count = 0;
    
    if (_currentState.selectedCategories.isNotEmpty) count++;
    if (_currentState.selectedBrands.isNotEmpty) count++;
    if (_currentState.minPrice > widget.minPrice || _currentState.maxPrice < widget.maxPrice) count++;
    if (_currentState.minRating > 0) count++;
    if (_currentState.inStockOnly) count++;
    if (_currentState.onSaleOnly) count++;
    
    return count;
  }
}

// Data models
class FilterState {
  List<int> selectedCategories;
  List<int> selectedBrands;
  double minPrice;
  double maxPrice;
  int minRating;
  SortOption sortOption;
  bool inStockOnly;
  bool onSaleOnly;

  FilterState({
    required this.selectedCategories,
    required this.selectedBrands,
    required this.minPrice,
    required this.maxPrice,
    required this.minRating,
    required this.sortOption,
    required this.inStockOnly,
    required this.onSaleOnly,
  });

  factory FilterState.initial() {
    return FilterState(
      selectedCategories: [],
      selectedBrands: [],
      minPrice: 0,
      maxPrice: 1000,
      minRating: 0,
      sortOption: SortOption.relevance,
      inStockOnly: false,
      onSaleOnly: false,
    );
  }

  FilterState copyWith({
    List<int>? selectedCategories,
    List<int>? selectedBrands,
    double? minPrice,
    double? maxPrice,
    int? minRating,
    SortOption? sortOption,
    bool? inStockOnly,
    bool? onSaleOnly,
  }) {
    return FilterState(
      selectedCategories: selectedCategories ?? List.from(this.selectedCategories),
      selectedBrands: selectedBrands ?? List.from(this.selectedBrands),
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      sortOption: sortOption ?? this.sortOption,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      onSaleOnly: onSaleOnly ?? this.onSaleOnly,
    );
  }
}

class FilterCategory {
  final int id;
  final String name;
  final int productCount;

  const FilterCategory({
    required this.id,
    required this.name,
    required this.productCount,
  });
}

class FilterBrand {
  final int id;
  final String name;
  final int productCount;

  const FilterBrand({
    required this.id,
    required this.name,
    required this.productCount,
  });
}

enum SortOption {
  relevance,
  priceLowToHigh,
  priceHighToLow,
  newest,
  rating,
  popularity;

  String get displayName {
    switch (this) {
      case SortOption.relevance:
        return 'Relevance';
      case SortOption.priceLowToHigh:
        return 'Price: Low to High';
      case SortOption.priceHighToLow:
        return 'Price: High to Low';
      case SortOption.newest:
        return 'Newest First';
      case SortOption.rating:
        return 'Customer Rating';
      case SortOption.popularity:
        return 'Most Popular';
    }
  }
}