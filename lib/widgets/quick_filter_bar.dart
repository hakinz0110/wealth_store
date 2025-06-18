import 'package:flutter/material.dart';

class FilterOption {
  final String label;
  final String value;
  final IconData? icon;

  FilterOption({required this.label, required this.value, this.icon});
}

class QuickFilterBar extends StatelessWidget {
  final List<FilterOption> options;
  final String selectedValue;
  final Function(String) onFilterSelected;

  const QuickFilterBar({
    super.key,
    this.options = const [],
    this.selectedValue = '',
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Return an empty container if no options
    return Container();
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
