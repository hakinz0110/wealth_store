import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../models/storage_models.dart';
import '../providers/search_providers.dart';
import '../constants/storage_constants.dart';
import '../../../shared/constants/app_colors.dart';

/// Advanced filtering widget for storage files
class StorageFilterWidget extends HookConsumerWidget {
  final bool showAsDropdown;
  final VoidCallback? onFiltersChanged;

  const StorageFilterWidget({
    super.key,
    this.showAsDropdown = false,
    this.onFiltersChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchMethods = ref.read(searchMethodsProvider);
    final currentFilters = ref.watch(searchFiltersProvider);
    
    if (showAsDropdown) {
      return _buildDropdownFilters(context, ref, searchMethods, currentFilters);
    } else {
      return _buildExpandedFilters(context, ref, searchMethods, currentFilters);
    }
  }

  Widget _buildDropdownFilters(
    BuildContext context,
    WidgetRef ref,
    SearchMethods searchMethods,
    StorageFilters currentFilters,
  ) {
    return PopupMenuButton<String>(
      icon: Stack(
        children: [
          const Icon(
            Icons.filter_list,
            color: AppColors.textSecondary,
          ),
          if (currentFilters.hasActiveFilters)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      tooltip: 'Filter files',
      itemBuilder: (context) => [
        // File type filter
        PopupMenuItem(
          value: 'file_type',
          child: Row(
            children: [
              const Icon(Icons.category, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              const Text('File Type'),
              const Spacer(),
              if (currentFilters.fileType != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    currentFilters.fileType!.displayName,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Date range filter
        PopupMenuItem(
          value: 'date_range',
          child: Row(
            children: [
              const Icon(Icons.date_range, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              const Text('Date Range'),
              const Spacer(),
              if (currentFilters.uploadedAfter != null || currentFilters.uploadedBefore != null)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
        
        // File size filter
        PopupMenuItem(
          value: 'file_size',
          child: Row(
            children: [
              const Icon(Icons.storage, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              const Text('File Size'),
              const Spacer(),
              if (currentFilters.minSize != null || currentFilters.maxSize != null)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
        
        // Clear filters
        if (currentFilters.hasActiveFilters)
          const PopupMenuDivider(),
        if (currentFilters.hasActiveFilters)
          const PopupMenuItem(
            value: 'clear',
            child: Row(
              children: [
                Icon(Icons.clear, size: 18, color: AppColors.errorRed),
                SizedBox(width: 12),
                Text(
                  'Clear Filters',
                  style: TextStyle(color: AppColors.errorRed),
                ),
              ],
            ),
          ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'file_type':
            _showFileTypeFilter(context, searchMethods, currentFilters);
            break;
          case 'date_range':
            _showDateRangeFilter(context, searchMethods, currentFilters);
            break;
          case 'file_size':
            _showFileSizeFilter(context, searchMethods, currentFilters);
            break;
          case 'clear':
            searchMethods.clearFilters();
            onFiltersChanged?.call();
            break;
        }
      },
    );
  }

  Widget _buildExpandedFilters(
    BuildContext context,
    WidgetRef ref,
    SearchMethods searchMethods,
    StorageFilters currentFilters,
  ) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.filter_list,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (currentFilters.hasActiveFilters)
                  TextButton(
                    onPressed: () {
                      searchMethods.clearFilters();
                      onFiltersChanged?.call();
                    },
                    child: const Text(
                      'Clear All',
                      style: TextStyle(color: AppColors.errorRed),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // File type filter
            _buildFileTypeSection(context, searchMethods, currentFilters),
            
            const SizedBox(height: 16),
            
            // Date range filter
            _buildDateRangeSection(context, searchMethods, currentFilters),
            
            const SizedBox(height: 16),
            
            // File size filter
            _buildFileSizeSection(context, searchMethods, currentFilters),
          ],
        ),
      ),
    );
  }

  Widget _buildFileTypeSection(
    BuildContext context,
    SearchMethods searchMethods,
    StorageFilters currentFilters,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'File Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: StorageFileType.values.map((fileType) {
            final isSelected = currentFilters.fileType == fileType;
            return FilterChip(
              label: Text(fileType.displayName),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  searchMethods.addFileTypeFilter(fileType);
                } else {
                  searchMethods.removeFileTypeFilter();
                }
                onFiltersChanged?.call();
              },
              selectedColor: AppColors.primaryBlue.withOpacity(0.2),
              checkmarkColor: AppColors.primaryBlue,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeSection(
    BuildContext context,
    SearchMethods searchMethods,
    StorageFilters currentFilters,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Date',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showDateRangeFilter(context, searchMethods, currentFilters),
                icon: const Icon(Icons.date_range, size: 16),
                label: Text(
                  _getDateRangeText(currentFilters),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            if (currentFilters.uploadedAfter != null || currentFilters.uploadedBefore != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  searchMethods.addDateRangeFilter(null, null);
                  onFiltersChanged?.call();
                },
                icon: const Icon(
                  Icons.clear,
                  size: 16,
                  color: AppColors.errorRed,
                ),
                tooltip: 'Clear date filter',
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildFileSizeSection(
    BuildContext context,
    SearchMethods searchMethods,
    StorageFilters currentFilters,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'File Size',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showFileSizeFilter(context, searchMethods, currentFilters),
                icon: const Icon(Icons.storage, size: 16),
                label: Text(
                  _getFileSizeText(currentFilters),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            if (currentFilters.minSize != null || currentFilters.maxSize != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  searchMethods.addSizeRangeFilter(null, null);
                  onFiltersChanged?.call();
                },
                icon: const Icon(
                  Icons.clear,
                  size: 16,
                  color: AppColors.errorRed,
                ),
                tooltip: 'Clear size filter',
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _showFileTypeFilter(
    BuildContext context,
    SearchMethods searchMethods,
    StorageFilters currentFilters,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by File Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // All files option
            RadioListTile<StorageFileType?>(
              title: const Text('All Files'),
              value: null,
              groupValue: currentFilters.fileType,
              onChanged: (value) {
                searchMethods.removeFileTypeFilter();
                onFiltersChanged?.call();
                Navigator.of(context).pop();
              },
            ),
            
            // Individual file types
            ...StorageFileType.values.map((fileType) {
              return RadioListTile<StorageFileType?>(
                title: Text(fileType.displayName),
                value: fileType,
                groupValue: currentFilters.fileType,
                onChanged: (value) {
                  if (value != null) {
                    searchMethods.addFileTypeFilter(value);
                  } else {
                    searchMethods.removeFileTypeFilter();
                  }
                  onFiltersChanged?.call();
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDateRangeFilter(
    BuildContext context,
    SearchMethods searchMethods,
    StorageFilters currentFilters,
  ) {
    showDialog(
      context: context,
      builder: (context) => _DateRangeFilterDialog(
        initialStartDate: currentFilters.uploadedAfter,
        initialEndDate: currentFilters.uploadedBefore,
        onDateRangeSelected: (startDate, endDate) {
          searchMethods.addDateRangeFilter(startDate, endDate);
          onFiltersChanged?.call();
        },
      ),
    );
  }

  void _showFileSizeFilter(
    BuildContext context,
    SearchMethods searchMethods,
    StorageFilters currentFilters,
  ) {
    showDialog(
      context: context,
      builder: (context) => _FileSizeFilterDialog(
        initialMinSize: currentFilters.minSize,
        initialMaxSize: currentFilters.maxSize,
        onSizeRangeSelected: (minSize, maxSize) {
          searchMethods.addSizeRangeFilter(minSize, maxSize);
          onFiltersChanged?.call();
        },
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

/// Date range filter dialog
class _DateRangeFilterDialog extends HookWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function(DateTime?, DateTime?) onDateRangeSelected;

  const _DateRangeFilterDialog({
    this.initialStartDate,
    this.initialEndDate,
    required this.onDateRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final startDate = useState<DateTime?>(initialStartDate);
    final endDate = useState<DateTime?>(initialEndDate);

    return AlertDialog(
      title: const Text('Filter by Upload Date'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick date options
          const Text(
            'Quick Options:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildQuickDateChip(
                context,
                'Today',
                () {
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  startDate.value = today;
                  endDate.value = today.add(const Duration(days: 1));
                },
              ),
              _buildQuickDateChip(
                context,
                'Last 7 days',
                () {
                  final now = DateTime.now();
                  startDate.value = now.subtract(const Duration(days: 7));
                  endDate.value = now;
                },
              ),
              _buildQuickDateChip(
                context,
                'Last 30 days',
                () {
                  final now = DateTime.now();
                  startDate.value = now.subtract(const Duration(days: 30));
                  endDate.value = now;
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Custom date range
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startDate.value ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      startDate.value = date;
                    }
                  },
                  child: Text(
                    startDate.value != null
                        ? '${startDate.value!.day}/${startDate.value!.month}/${startDate.value!.year}'
                        : 'Start Date',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('to'),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: endDate.value ?? DateTime.now(),
                      firstDate: startDate.value ?? DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      endDate.value = date;
                    }
                  },
                  child: Text(
                    endDate.value != null
                        ? '${endDate.value!.day}/${endDate.value!.month}/${endDate.value!.year}'
                        : 'End Date',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            onDateRangeSelected(startDate.value, endDate.value);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildQuickDateChip(BuildContext context, String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
    );
  }
}

/// File size filter dialog
class _FileSizeFilterDialog extends HookWidget {
  final int? initialMinSize;
  final int? initialMaxSize;
  final Function(int?, int?) onSizeRangeSelected;

  const _FileSizeFilterDialog({
    this.initialMinSize,
    this.initialMaxSize,
    required this.onSizeRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final minSizeController = useTextEditingController(
      text: initialMinSize != null ? (initialMinSize! / 1024).toString() : '',
    );
    final maxSizeController = useTextEditingController(
      text: initialMaxSize != null ? (initialMaxSize! / 1024).toString() : '',
    );
    final sizeUnit = useState<String>('KB');

    return AlertDialog(
      title: const Text('Filter by File Size'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick size options
          const Text(
            'Quick Options:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildQuickSizeChip(
                context,
                'Small (< 1MB)',
                () {
                  minSizeController.text = '';
                  maxSizeController.text = '1024';
                  sizeUnit.value = 'KB';
                },
              ),
              _buildQuickSizeChip(
                context,
                'Medium (1-10MB)',
                () {
                  minSizeController.text = '1';
                  maxSizeController.text = '10';
                  sizeUnit.value = 'MB';
                },
              ),
              _buildQuickSizeChip(
                context,
                'Large (> 10MB)',
                () {
                  minSizeController.text = '10';
                  maxSizeController.text = '';
                  sizeUnit.value = 'MB';
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Custom size range
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: minSizeController,
                  decoration: const InputDecoration(
                    labelText: 'Min Size',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              const Text('to'),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: maxSizeController,
                  decoration: const InputDecoration(
                    labelText: 'Max Size',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Size unit selector
          DropdownButton<String>(
            value: sizeUnit.value,
            items: const [
              DropdownMenuItem(value: 'B', child: Text('Bytes')),
              DropdownMenuItem(value: 'KB', child: Text('KB')),
              DropdownMenuItem(value: 'MB', child: Text('MB')),
              DropdownMenuItem(value: 'GB', child: Text('GB')),
            ],
            onChanged: (value) {
              if (value != null) {
                sizeUnit.value = value;
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final minSize = _parseSize(minSizeController.text, sizeUnit.value);
            final maxSize = _parseSize(maxSizeController.text, sizeUnit.value);
            onSizeRangeSelected(minSize, maxSize);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildQuickSizeChip(BuildContext context, String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
    );
  }

  int? _parseSize(String text, String unit) {
    if (text.isEmpty) return null;
    
    final value = double.tryParse(text);
    if (value == null) return null;
    
    switch (unit) {
      case 'B':
        return value.round();
      case 'KB':
        return (value * 1024).round();
      case 'MB':
        return (value * 1024 * 1024).round();
      case 'GB':
        return (value * 1024 * 1024 * 1024).round();
      default:
        return value.round();
    }
  }
}