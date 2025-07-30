import 'package:flutter/material.dart';
import '../../core/services/pagination_service.dart';

/// Optimized pagination widget with performance enhancements
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
  final Color? activeColor;
  final Color? inactiveColor;

  const OptimizedPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.onPageChanged,
    this.showItemCount = true,
    this.showPageSizeSelector = false,
    this.pageSizeOptions = const [10, 20, 50, 100],
    this.onPageSizeChanged,
    this.padding,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) {
      return showItemCount ? _buildItemCount(context) : const SizedBox.shrink();
    }

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showItemCount) _buildItemCount(context),
          if (showItemCount) const SizedBox(height: 8),
          _buildPaginationControls(context),
          if (showPageSizeSelector && onPageSizeChanged != null) ...[
            const SizedBox(height: 8),
            _buildPageSizeSelector(context),
          ],
        ],
      ),
    );
  }

  Widget _buildItemCount(BuildContext context) {
    final startItem = (currentPage - 1) * itemsPerPage + 1;
    final endItem = (currentPage * itemsPerPage).clamp(0, totalItems);

    return Text(
      'Showing $startItem-$endItem of $totalItems items',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildPaginationControls(BuildContext context) {
    final paginationService = PaginationService();
    final pageNumbers = paginationService.generatePageNumbers(currentPage, totalPages);
    
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      children: [
        // First page button
        if (currentPage > 1) ...[
          _buildPageButton(
            context,
            icon: Icons.first_page,
            onPressed: () => onPageChanged(1),
            tooltip: 'First page',
          ),
          _buildPageButton(
            context,
            icon: Icons.chevron_left,
            onPressed: () => onPageChanged(currentPage - 1),
            tooltip: 'Previous page',
          ),
        ],
        
        // Page number buttons
        ...pageNumbers.map((pageNum) => _buildPageButton(
          context,
          text: pageNum.toString(),
          isActive: pageNum == currentPage,
          onPressed: pageNum == currentPage ? null : () => onPageChanged(pageNum),
        )),
        
        // Last page button
        if (currentPage < totalPages) ...[
          _buildPageButton(
            context,
            icon: Icons.chevron_right,
            onPressed: () => onPageChanged(currentPage + 1),
            tooltip: 'Next page',
          ),
          _buildPageButton(
            context,
            icon: Icons.last_page,
            onPressed: () => onPageChanged(totalPages),
            tooltip: 'Last page',
          ),
        ],
      ],
    );
  }

  Widget _buildPageButton(
    BuildContext context, {
    String? text,
    IconData? icon,
    bool isActive = false,
    VoidCallback? onPressed,
    String? tooltip,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final backgroundColor = isActive 
        ? (activeColor ?? colorScheme.primary)
        : (inactiveColor ?? colorScheme.surfaceContainerHighest);
    
    final foregroundColor = isActive 
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;

    Widget button = Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: icon != null
              ? Icon(icon, size: 18, color: foregroundColor)
              : Text(
                  text ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: foregroundColor,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip,
        child: button,
      );
    }

    return button;
  }

  Widget _buildPageSizeSelector(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Items per page:',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: 8),
        DropdownButton<int>(
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
      ],
    );
  }
}

/// Compact pagination widget for mobile/small screens
class CompactPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final EdgeInsetsGeometry? padding;

  const CompactPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          IconButton(
            onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous page',
          ),
          
          // Page indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$currentPage of $totalPages',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          
          // Next button
          IconButton(
            onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next page',
          ),
        ],
      ),
    );
  }
}

/// Infinite scroll pagination helper
class InfiniteScrollPagination extends StatefulWidget {
  final Widget Function(BuildContext context, int index) itemBuilder;
  final int itemCount;
  final bool hasNextPage;
  final bool isLoading;
  final VoidCallback onLoadMore;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final ScrollController? scrollController;
  final double loadMoreThreshold;

  const InfiniteScrollPagination({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    required this.hasNextPage,
    required this.isLoading,
    required this.onLoadMore,
    this.loadingWidget,
    this.emptyWidget,
    this.scrollController,
    this.loadMoreThreshold = 200.0,
  });

  @override
  State<InfiniteScrollPagination> createState() => _InfiniteScrollPaginationState();
}

class _InfiniteScrollPaginationState extends State<InfiniteScrollPagination> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || !widget.hasNextPage) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll - currentScroll <= widget.loadMoreThreshold) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    widget.onLoadMore();
    
    // Reset loading state after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount == 0 && !widget.isLoading) {
      return widget.emptyWidget ?? const Center(
        child: Text('No items found'),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.itemCount + (widget.hasNextPage ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < widget.itemCount) {
          return widget.itemBuilder(context, index);
        } else {
          // Loading indicator at the end
          return Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: widget.loadingWidget ?? const CircularProgressIndicator(),
          );
        }
      },
    );
  }
}