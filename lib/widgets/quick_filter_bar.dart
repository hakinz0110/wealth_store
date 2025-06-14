import 'package:flutter/material.dart';

class FilterOption {
  final String label;
  final String value;
  final IconData? icon;

  FilterOption({required this.label, required this.value, this.icon});
}

class QuickFilterBar extends StatefulWidget {
  final List<FilterOption> options;
  final Function(String) onFilterSelected;
  final String selectedValue;

  const QuickFilterBar({
    super.key,
    required this.options,
    required this.onFilterSelected,
    required this.selectedValue,
  });

  @override
  State<QuickFilterBar> createState() => _QuickFilterBarState();
}

class _QuickFilterBarState extends State<QuickFilterBar> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: widget.options.length,
        itemBuilder: (context, index) {
          final option = widget.options[index];
          final isSelected = option.value == widget.selectedValue;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : isDarkMode
                  ? Colors.grey.shade800
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(25),
              child: InkWell(
                onTap: () => widget.onFilterSelected(option.value),
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (option.icon != null) ...[
                        Icon(
                          option.icon,
                          size: 16,
                          color: isSelected
                              ? Colors.white
                              : isDarkMode
                              ? Colors.white
                              : Colors.black87,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        option.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
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
}

// Price range filter
class PriceRangeFilter extends StatefulWidget {
  final double minValue;
  final double maxValue;
  final RangeValues currentRange;
  final Function(RangeValues) onChanged;

  const PriceRangeFilter({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.currentRange,
    required this.onChanged,
  });

  @override
  State<PriceRangeFilter> createState() => _PriceRangeFilterState();
}

class _PriceRangeFilterState extends State<PriceRangeFilter> {
  late RangeValues _currentRange;

  @override
  void initState() {
    super.initState();
    _currentRange = widget.currentRange;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price Range',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
              Text(
                '\$${_currentRange.start.toInt()} - \$${_currentRange.end.toInt()}',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        RangeSlider(
          values: _currentRange,
          min: widget.minValue,
          max: widget.maxValue,
          divisions: ((widget.maxValue - widget.minValue) / 10).round(),
          labels: RangeLabels(
            '\$${_currentRange.start.toInt()}',
            '\$${_currentRange.end.toInt()}',
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _currentRange = values;
            });
          },
          onChangeEnd: (RangeValues values) {
            widget.onChanged(values);
          },
          activeColor: Theme.of(context).primaryColor,
          inactiveColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade700
              : Colors.grey.shade300,
        ),
      ],
    );
  }
}
