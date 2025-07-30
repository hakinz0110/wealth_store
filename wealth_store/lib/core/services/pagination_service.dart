import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pagination_service.g.dart';

@riverpod
PaginationService paginationService(Ref ref) {
  return PaginationService();
}

class PaginationService {
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  /// Calculate pagination parameters
  PaginationParams calculatePagination({
    required int page,
    int? pageSize,
  }) {
    final size = (pageSize ?? defaultPageSize).clamp(1, maxPageSize);
    final offset = (page - 1) * size;
    
    return PaginationParams(
      page: page,
      pageSize: size,
      offset: offset,
      limit: size,
    );
  }
  
  /// Calculate total pages from total count
  int calculateTotalPages(int totalCount, int pageSize) {
    return (totalCount / pageSize).ceil();
  }
  
  /// Check if there are more pages
  bool hasNextPage(int currentPage, int totalPages) {
    return currentPage < totalPages;
  }
  
  /// Check if there are previous pages
  bool hasPreviousPage(int currentPage) {
    return currentPage > 1;
  }
  
  /// Generate page numbers for pagination UI
  List<int> generatePageNumbers(int currentPage, int totalPages, {int maxVisible = 5}) {
    if (totalPages <= maxVisible) {
      return List.generate(totalPages, (index) => index + 1);
    }
    
    final half = maxVisible ~/ 2;
    int start = (currentPage - half).clamp(1, totalPages - maxVisible + 1);
    int end = (start + maxVisible - 1).clamp(maxVisible, totalPages);
    
    // Adjust start if end is at maximum
    if (end == totalPages) {
      start = (totalPages - maxVisible + 1).clamp(1, totalPages);
    }
    
    return List.generate(end - start + 1, (index) => start + index);
  }
}

class PaginationParams {
  final int page;
  final int pageSize;
  final int offset;
  final int limit;
  
  const PaginationParams({
    required this.page,
    required this.pageSize,
    required this.offset,
    required this.limit,
  });
  
  @override
  String toString() {
    return 'PaginationParams(page: $page, pageSize: $pageSize, offset: $offset, limit: $limit)';
  }
}

class PaginatedResult<T> {
  final List<T> data;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;
  
  const PaginatedResult({
    required this.data,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });
  
  factory PaginatedResult.fromData({
    required List<T> data,
    required int totalCount,
    required int currentPage,
    required int pageSize,
  }) {
    final totalPages = (totalCount / pageSize).ceil();
    return PaginatedResult(
      data: data,
      totalCount: totalCount,
      currentPage: currentPage,
      pageSize: pageSize,
      totalPages: totalPages,
      hasNextPage: currentPage < totalPages,
      hasPreviousPage: currentPage > 1,
    );
  }
  
  @override
  String toString() {
    return 'PaginatedResult(data: ${data.length} items, totalCount: $totalCount, currentPage: $currentPage, totalPages: $totalPages)';
  }
}