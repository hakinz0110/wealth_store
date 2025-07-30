import 'package:flutter/material.dart';
import '../../core/services/pagination_service.dart';

/// Optimized pagination widget for admin interface
class OptimizedPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final Function(int) onPageChanged;
  final bool showItemCount;
  final bool showPageSizeSelector;
  final List<int> pageSizeOptions;
  final Function(int)? onPageSizeChanged;
  final EdgeInsetsGeometry? padding;

  const OptimizedPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.onPageChanged,
    this.showItemCount = true,
    this.showPageSizeSelector = true,
    this.pageSizeOptions = const [10, 20, 50, 100],
    this.onPageSizeChanged,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1 && !showItemCount) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Item count and page size selector
          Row(
            children: [
              if (showItemCount) _buildItemCount(context),
              if (showItemCount && showPageSizeSelector && onPageSizeChanged != null)
                const SizedBox(width: 16),
              if (showPageSizeSelector && onPageSizeChanged != null)
                _buildPageSizeSelector(context),
            ],
          ),
          
          // Pagination controls
          if (totalPages > 1) _buildPaginationControls(context),
        ],
      ),
    );
  }

  Widget _buildItemCount(BuildContext context) {
    final startItem = (currentPage - 1) * itemsPerPage + 1;
    final endItem = (currentPage * itemsPerPage).clamp(0, totalItems);

    return Text(
      'Showing $startItem-$endItem of $totalItems entries',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildPageSizeSelector(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Show',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButton<int>(
            value: itemsPerPage,
            isDense: true,
            underline: const SizedBox.shrink(),
            items: pageSizeOptions.map((size) {
              return DropdownMenuItem<int>(
                value: size,
                child: Text(size.toString()),
              );
            }).toList(),
            onChanged: onPageSizeChanged,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'entries',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPaginationControls(BuildContext context) {
    final paginationService = PaginationService();
    final pageNumbers = paginationService.generatePageNumbers(currentPage, totalPages);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Previous button
        _buildControlButton(
          context,
          'Previous',
          currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
        ),
        
        const SizedBox(width: 8),
        
        // Page number buttons
        ...pageNumbers.map((pageNum) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: _buildPageButton(
            context,
            pageNum.toString(),
            isActive: pageNum == currentPage,
            onPressed: pageNum == currentPage ? null : () => onPageChanged(pageNum),
          ),
        )),
        
        const SizedBox(width: 8),
        
        // Next button
        _buildControlButton(
          context,
          'Next',
          currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
        ),
      ],
    );
  }

  Widget _buildControlButton(
    BuildContext context,
    String text,
    VoidCallback? onPressed,
  ) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(text),
    );
  }

  Widget _buildPageButton(
    BuildContext context,
    String text, {
    bool isActive = false,
    VoidCallback? onPressed,
  }) {
    return Material(
      color: isActive ? Theme.of(context).primaryColor : Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: isActive ? Theme.of(context).primaryColor : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isActive ? Colors.white : Colors.grey[700],
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

/// Data table with built-in pagination
class PaginatedDataTable2 extends StatefulWidget {
  final List<DataColumn> columns;
  final List<DataRow> Function(int startIndex, int count) rowBuilder;
  final int totalItems;
  final int initialPageSize;
  final List<int> availablePageSizes;
  final String? emptyMessage;
  final bool sortAscending;
  final int? sortColumnIndex;
  final Function(int, bool)? onSort;

  const PaginatedDataTable2({
    super.key,
    required this.columns,
    required this.rowBuilder,
    required this.totalItems,
    this.initialPageSize = 20,
    this.availablePageSizes = const [10, 20, 50, 100],
    this.emptyMessage,
    this.sortAscending = true,
    this.sortColumnIndex,
    this.onSort,
  });

  @override
  State<PaginatedDataTable2> createState() => _PaginatedDataTable2State();
}

class _PaginatedDataTable2State extends State<PaginatedDataTable2> {
  late int _currentPage;
  late int _pageSize;
  late int _totalPages;

  @override
  void initState() {
    super.initState();
    _currentPage = 1;
    _pageSize = widget.initialPageSize;
    _updateTotalPages();
  }

  @override
  void didUpdateWidget(PaginatedDataTable2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalItems != widget.totalItems) {
      _updateTotalPages();
    }
  }

  void _updateTotalPages() {
    _totalPages = (widget.totalItems / _pageSize).ceil();
    if (_currentPage > _totalPages && _totalPages > 0) {
      _currentPage = _totalPages;
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _onPageSizeChanged(int? newSize) {
    if (newSize != null && newSize != _pageSize) {
      setState(() {
        _pageSize = newSize;
        _currentPage = 1; // Reset to first page
        _updateTotalPages();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.totalItems == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            widget.emptyMessage ?? 'No data available',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    final startIndex = (_currentPage - 1) * _pageSize;
    final rows = widget.rowBuilder(startIndex, _pageSize);

    return Column(
      children: [
        // Data table
        Expanded(
          child: SingleChildScrollView(
            child: DataTable(
              columns: widget.columns,
              rows: rows,
              sortAscending: widget.sortAscending,
              sortColumnIndex: widget.sortColumnIndex,
              showCheckboxColumn: false,
              dataRowMinHeight: 48,
              dataRowMaxHeight: 64,
            ),
          ),
        ),
        
        // Pagination
        OptimizedPagination(
          currentPage: _currentPage,
          totalPages: _totalPages,
          totalItems: widget.totalItems,
          itemsPerPage: _pageSize,
          onPageChanged: _onPageChanged,
          onPageSizeChanged: _onPageSizeChanged,
          pageSizeOptions: widget.availablePageSizes,
        ),
      ],
    );
  }
}