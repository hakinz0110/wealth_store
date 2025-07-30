import 'package:flutter/material.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/shared/widgets/skeleton_loader.dart';

class PaginatedGridView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Future<void> Function() onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final int crossAxisCount;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final ScrollController? scrollController;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final String? errorMessage;

  const PaginatedGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.hasMore,
    this.isLoading = false,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.7,
    this.padding,
    this.physics,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.scrollController,
    this.emptyWidget,
    this.loadingWidget,
    this.errorWidget,
    this.errorMessage,
  });

  @override
  State<PaginatedGridView<T>> createState() => _PaginatedGridViewState<T>();
}

class _PaginatedGridViewState<T> extends State<PaginatedGridView<T>> {
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
    if (_isLoadingMore || !widget.hasMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    // Load more when user scrolls to 80% of the list
    if (currentScroll >= maxScroll * 0.8) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !widget.hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    await widget.onLoadMore();

    if (mounted) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && widget.isLoading) {
      return widget.loadingWidget ?? const ProductGridSkeleton();
    }

    if (widget.items.isEmpty && widget.errorMessage != null) {
      return widget.errorWidget ?? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: AppSpacing.medium),
            Text(
              widget.errorMessage!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.medium),
            ElevatedButton(
              onPressed: () => widget.onLoadMore(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (widget.items.isEmpty) {
      return widget.emptyWidget ?? const Center(
        child: Text('No items found'),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: widget.padding ?? const EdgeInsets.all(AppSpacing.small),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        childAspectRatio: widget.childAspectRatio,
        crossAxisSpacing: widget.crossAxisSpacing,
        mainAxisSpacing: widget.mainAxisSpacing,
      ),
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      physics: widget.physics,
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          // This is the loading indicator at the bottom
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.medium),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        return widget.itemBuilder(context, widget.items[index], index);
      },
    );
  }
} 