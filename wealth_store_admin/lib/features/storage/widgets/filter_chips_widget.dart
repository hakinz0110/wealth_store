import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/storage_models.dart';
import '../providers/search_providers.dart';
import '../../../shared/constants/app_colors.dart';

/// Widget to display active filter chips
class FilterChipsWidget extends ConsumerWidget {
  final VoidCallback? onFiltersChanged;
  final bool showClearAll;

  const FilterChipsWidget({
    super.key,
    this.onFiltersChanged,
    this.showClearAll = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchMethods = ref.read(searchMethodsProvider);
    final currentFilters = ref.watch(searchFiltersProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    
    final activeChips = <Widget>[];
    
    // Search query chip
    if (searchQuery.isNotEmpty) {
      activeChips.add(
        _buildFilterChip(
          context,
          label: 'Search: "$searchQuery"',
          icon: Icons.search,
          onDeleted: () {
            searchMethods.clearSearchQuery();
            onFiltersChanged?.call();
          },
        ),
      );
    }
    
    // File type chip
    if (currentFilters.fileType != null) {
      activeChips.add(
        _buildFilterChip(
          context,
          label: 'Type: ${currentFilters.fileType!.displayName}',
          icon: Icons.category,
          onDeleted: () {
            searchMethods.removeFileTypeFilter();
            onFiltersChanged?.call();
          },
        ),
      );
    }
    
    // Date range chip
    if (currentFilters.uploadedAfter != null || currentFilters.uploadedBefore != null) {
      activeChips.add(
        _buildFilterChip(
          context,
          label: 'Date: ${_getDateRangeText(currentFilters)}',
          icon: Icons.date_range,
          onDeleted: () {
            searchMethods.addDateRangeFilter(null, null);
            onFiltersChanged?.call();
          },
        ),
      );
    }
    
    // File size chip
    if (currentFilters.minSize != null || currentFilters.maxSize != null) {
      activeChips.add(
        _buildFilterChip(
          context,
          label: 'Size: ${_getFileSizeText(currentFilters)}',
          icon: Icons.storage,
          onDeleted: () {
            searchMethods.addSizeRangeFilter(null, null);
            onFiltersChanged?.call();
          },
        ),
      );
    }
    
    // If no active filters, return empty widget
    if (activeChips.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Active Filters:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              if (showClearAll && (activeChips.length > 1 || currentFilters.hasActiveFilters))
                TextButton(
                  onPressed: () {
                    searchMethods.clearSearchQuery();
                    searchMethods.clearFilters();
                    onFiltersChanged?.call();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Clear All',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.errorRed,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: activeChips,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onDeleted,
  }) {
    return Chip(
      avatar: Icon(
        icon,
        size: 16,
        color: AppColors.primaryBlue,
      ),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textPrimary,
        ),
      ),
      deleteIcon: const Icon(
        Icons.close,
        size: 16,
        color: AppColors.textMuted,
      ),
      onDeleted: onDeleted,
      backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
      deleteIconColor: AppColors.textMuted,
      side: BorderSide(
        color: AppColors.primaryBlue.withOpacity(0.3),
        width: 1,
      ),
    );
  }

  String _getDateRangeText(StorageFilters filters) {
    if (filters.uploadedAfter == null && filters.uploadedBefore == null) {
      return 'Any date';
    }
    
    final startText = filters.uploadedAfter != null
        ? '${filters.uploadedAfter!.day}/${filters.uploadedAfter!.month}/${filters.uploadedAfter!.year}'
        : 'Any';
    
    final endText = filters.uploadedBefore != null
        ? '${filters.uploadedBefore!.day}/${filters.uploadedBefore!.month}/${filters.uploadedBefore!.year}'
        : 'Any';
    
    return '$startText - $endText';
  }

  String _getFileSizeText(StorageFilters filters) {
    if (filters.minSize == null && filters.maxSize == null) {
      return 'Any size';
    }
    
    final minText = filters.minSize != null
        ? _formatFileSize(filters.minSize!)
        : '0B';
    
    final maxText = filters.maxSize != null
        ? _formatFileSize(filters.maxSize!)
        : '∞';
    
    return '$minText - $maxText';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}