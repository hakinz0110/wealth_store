import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../models/storage_models.dart';
import '../providers/storage_providers.dart';
import '../constants/storage_constants.dart';
import '../../../shared/constants/app_colors.dart';

/// Storage sidebar widget that displays bucket list with navigation
class StorageSidebar extends HookConsumerWidget {
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;
  final double width;
  final double collapsedWidth;

  const StorageSidebar({
    super.key,
    this.isCollapsed = false,
    this.onToggleCollapse,
    this.width = StorageConstants.sidebarWidth,
    this.collapsedWidth = StorageConstants.collapsedSidebarWidth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchQuery = useState<String>('');
    
    // Watch providers
    final bucketsAsync = ref.watch(storageBucketsProvider);
    final selectedBucketId = ref.watch(selectedBucketProvider);
    final bucketMethods = ref.read(bucketMethodsProvider);
    final isLoading = ref.watch(bucketsLoadingProvider);
    final error = ref.watch(bucketsErrorProvider);
    
    // Responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < StorageConstants.mobileBreakpoint;

    // Filter buckets based on search query
    final filteredBuckets = useMemoized(() {
      return bucketsAsync.when(
        data: (buckets) {
          if (searchQuery.value.isEmpty) return buckets;
          return buckets.where((bucket) =>
            bucket.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            bucket.id.toLowerCase().contains(searchQuery.value.toLowerCase())
          ).toList();
        },
        loading: () => <StorageBucket>[],
        error: (_, __) => <StorageBucket>[],
      );
    }, [bucketsAsync, searchQuery.value]);

    // Handle search input changes
    useEffect(() {
      void onSearchChanged() {
        searchQuery.value = searchController.text;
      }
      
      searchController.addListener(onSearchChanged);
      return () => searchController.removeListener(onSearchChanged);
    }, [searchController]);

    return AnimatedContainer(
      duration: StorageConstants.mediumAnimation,
      width: isCollapsed ? collapsedWidth : width,
      decoration: BoxDecoration(
        color: AppColors.sidebarBackground,
        border: Border(
          right: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        boxShadow: isMobile ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ] : null,
      ),
      child: Column(
        children: [
          // Header with collapse toggle
          _buildHeader(context, isCollapsed, onToggleCollapse, isMobile),
          
          // Search bar (only when expanded)
          if (!isCollapsed) ...[
            _buildSearchBar(context, searchController, isMobile),
            SizedBox(height: isMobile ? 12 : 8),
          ],
          
          // Bucket list
          Expanded(
            child: _buildBucketList(
              context,
              ref,
              filteredBuckets,
              selectedBucketId,
              bucketMethods,
              isCollapsed,
              isLoading,
              error,
              isMobile,
            ),
          ),
          
          // Footer with refresh button
          if (!isCollapsed) _buildFooter(context, ref, bucketMethods, isMobile),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isCollapsed, VoidCallback? onToggle, bool isMobile) {
    return Container(
      height: isMobile ? 64 : 56,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.storage,
            color: AppColors.primaryBlue,
            size: isCollapsed ? (isMobile ? 28 : 24) : (isMobile ? 24 : 20),
          ),
          if (!isCollapsed) ...[
            SizedBox(width: isMobile ? 16 : 12),
            Expanded(
              child: Text(
                'Storage',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
          if (onToggle != null)
            IconButton(
              onPressed: onToggle,
              icon: Icon(
                isCollapsed ? Icons.chevron_right : (isMobile ? Icons.close : Icons.chevron_left),
                color: AppColors.textSecondary,
                size: isMobile ? 24 : 20,
              ),
              tooltip: isCollapsed ? 'Expand sidebar' : (isMobile ? 'Close sidebar' : 'Collapse sidebar'),
              splashRadius: isMobile ? 20 : 16,
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, TextEditingController controller, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 12,
        vertical: isMobile ? 12 : 8,
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search buckets...',
          hintStyle: TextStyle(
            color: AppColors.textMuted,
            fontSize: isMobile ? 16 : 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textMuted,
            size: isMobile ? 24 : 20,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    controller.clear();
                  },
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                  splashRadius: 16,
                )
              : null,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 12,
            vertical: isMobile ? 12 : 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isMobile ? 8 : 6),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isMobile ? 8 : 6),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isMobile ? 8 : 6),
            borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
          filled: true,
          fillColor: AppColors.backgroundLight,
        ),
        style: TextStyle(
          fontSize: isMobile ? 16 : 14,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildBucketList(
    BuildContext context,
    WidgetRef ref,
    List<StorageBucket> buckets,
    String? selectedBucketId,
    BucketMethods bucketMethods,
    bool isCollapsed,
    bool isLoading,
    String? error,
    bool isMobile,
  ) {
    if (isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 20 : 16),
          child: const CircularProgressIndicator(
            color: AppColors.primaryBlue,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (error != null) {
      return _buildErrorState(context, error, () {
        ref.invalidate(storageBucketsProvider);
      });
    }

    if (buckets.isEmpty) {
      return _buildEmptyState(context, isCollapsed, isMobile);
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 8),
      itemCount: buckets.length,
      itemBuilder: (context, index) {
        final bucket = buckets[index];
        final isSelected = bucket.id == selectedBucketId;
        
        return _buildBucketItem(
          context,
          bucket,
          isSelected,
          isCollapsed,
          isMobile,
          () => bucketMethods.selectBucket(bucket.id),
        );
      },
    );
  }

  Widget _buildBucketItem(
    BuildContext context,
    StorageBucket bucket,
    bool isSelected,
    bool isCollapsed,
    bool isMobile,
    VoidCallback onTap,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 8,
        vertical: isMobile ? 4 : 2,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(isMobile ? 8 : 6),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? (isMobile ? 12 : 8) : (isMobile ? 16 : 12),
              vertical: isMobile ? 16 : 12,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : null,
              borderRadius: BorderRadius.circular(isMobile ? 8 : 6),
              border: isSelected
                  ? Border.all(color: AppColors.primaryBlue.withOpacity(0.3))
                  : null,
            ),
            child: Row(
              children: [
                // Bucket icon with visibility indicator
                Stack(
                  children: [
                    Icon(
                      Icons.folder,
                      color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
                      size: isCollapsed 
                          ? (isMobile ? 28 : 24) 
                          : (isMobile ? 24 : 20),
                    ),
                    if (!bucket.isPublic)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: isMobile ? 10 : 8,
                          height: isMobile ? 10 : 8,
                          decoration: const BoxDecoration(
                            color: AppColors.warning,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                
                if (!isCollapsed) ...[
                  SizedBox(width: isMobile ? 16 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bucket.name,
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: isMobile ? 4 : 2),
                        Row(
                          children: [
                            Icon(
                              bucket.isPublic ? Icons.public : Icons.lock,
                              size: isMobile ? 14 : 12,
                              color: AppColors.textMuted,
                            ),
                            SizedBox(width: isMobile ? 6 : 4),
                            Text(
                              bucket.isPublic ? 'Public' : 'Private',
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${bucket.fileCount}',
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildErrorState(BuildContext context, String error, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load buckets',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isCollapsed, bool isMobile) {
    if (isCollapsed) {
      return Center(
        child: Icon(
          Icons.folder_off,
          color: AppColors.textMuted,
          size: isMobile ? 36 : 32,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(isMobile ? 20 : 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_off,
            color: AppColors.textMuted,
            size: isMobile ? 56 : 48,
          ),
          SizedBox(height: isMobile ? 20 : 16),
          Text(
            'No buckets found',
            style: TextStyle(
              fontSize: isMobile ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 12 : 8),
          Text(
            'No storage buckets are available or match your search.',
            style: TextStyle(
              fontSize: isMobile ? 14 : 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref, BucketMethods bucketMethods, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                try {
                  await bucketMethods.refreshBuckets();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Buckets refreshed'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to refresh: ${e.toString()}'),
                        backgroundColor: AppColors.error,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              icon: Icon(Icons.refresh, size: isMobile ? 18 : 16),
              label: const Text('Refresh'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.borderLight),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 12,
                  vertical: isMobile ? 12 : 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}