import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../models/storage_models.dart';
import '../providers/storage_providers.dart';
import '../providers/search_providers.dart';
import '../constants/storage_constants.dart';
import '../../../shared/constants/app_colors.dart';
import 'storage_search_widget.dart';
import 'storage_filter_widget.dart';
import 'filter_chips_widget.dart';
import 'filter_presets_widget.dart';

/// Storage header widget with breadcrumbs, actions, and search
class StorageHeader extends HookConsumerWidget {
  final VoidCallback? onUpload;
  final VoidCallback? onCreateFolder;
  final Function(ViewMode)? onViewModeChanged;
  final Function(String)? onSearch;
  final ViewMode viewMode;
  final bool showSearch;
  final bool showActions;

  const StorageHeader({
    super.key,
    this.onUpload,
    this.onCreateFolder,
    this.onViewModeChanged,
    this.onSearch,
    this.viewMode = ViewMode.grid,
    this.showSearch = true,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();
    final isSearchExpanded = useState<bool>(false);
    
    // Watch providers
    final selectedBucketId = ref.watch(selectedBucketProvider);
    final selectedBucket = ref.watch(selectedBucketDetailsProvider);
    final bucketMethods = ref.read(bucketMethodsProvider);
    final breadcrumbs = bucketMethods.getCurrentBreadcrumbs();
    
    // Handle search input changes with debouncing
    useEffect(() {
      void onSearchChanged() {
        onSearch?.call(searchController.text);
      }
      
      searchController.addListener(onSearchChanged);
      return () => searchController.removeListener(onSearchChanged);
    }, [searchController]);

    // Handle responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < StorageConstants.mobileBreakpoint;
    final isTablet = screenWidth < StorageConstants.tabletBreakpoint;
    final isDesktop = screenWidth >= StorageConstants.desktopBreakpoint;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Main header row
          Row(
            children: [
              // Breadcrumbs
              Expanded(
                child: _buildBreadcrumbs(
                  context,
                  breadcrumbs,
                  selectedBucket,
                  bucketMethods,
                  isMobile,
                ),
              ),
              
              // Search toggle (mobile)
              if (isMobile && showSearch) ...[
                IconButton(
                  onPressed: () {
                    isSearchExpanded.value = !isSearchExpanded.value;
                    if (isSearchExpanded.value) {
                      searchFocusNode.requestFocus();
                    }
                  },
                  icon: Icon(
                    isSearchExpanded.value ? Icons.close : Icons.search,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: isSearchExpanded.value ? 'Close search' : 'Search files',
                ),
              ],
              
              // View mode toggle (tablet and desktop)
              if (!isMobile && onViewModeChanged != null) ...[
                const SizedBox(width: 8),
                _buildViewModeToggle(context, viewMode, onViewModeChanged!),
              ],
            ],
          ),
          
          // Search bar and actions row
          if (!isMobile || isSearchExpanded.value) ...[
            const SizedBox(height: 12),
            _buildSecondaryRow(
              context,
              searchController,
              searchFocusNode,
              onUpload,
              onCreateFolder,
              onViewModeChanged,
              viewMode,
              selectedBucketId,
              showSearch,
              showActions,
              isMobile,
              isTablet,
              isDesktop,
            ),
          ],
        ],
      ),
    );
  }
}

/// Enhanced storage header with filter chips
class StorageHeaderWithFilters extends StatelessWidget {
  final StorageHeader header;
  final VoidCallback? onFiltersChanged;

  const StorageHeaderWithFilters({
    super.key,
    required this.header,
    this.onFiltersChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        header,
        FilterChipsWidget(
          onFiltersChanged: onFiltersChanged,
        ),
      ],
    );
  }
}

extension StorageHeaderExtensions on StorageHeader {
  Widget withFilterChips({VoidCallback? onFiltersChanged}) {
    return StorageHeaderWithFilters(
      header: this,
      onFiltersChanged: onFiltersChanged,
    );
  }

  Widget _buildSecondaryRow(
    BuildContext context,
    TextEditingController searchController,
    FocusNode searchFocusNode,
    VoidCallback? onUpload,
    VoidCallback? onCreateFolder,
    Function(ViewMode)? onViewModeChanged,
    ViewMode viewMode,
    String? selectedBucketId,
    bool showSearch,
    bool showActions,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    if (isMobile) {
      // Mobile: Stack search and filters vertically
      return Column(
        children: [
          // Search bar
          if (showSearch)
            _buildSearchBar(
              context,
              searchController,
              searchFocusNode,
              isMobile,
            ),
          
          // Filters row
          if (showSearch) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(child: StorageFilterWidget(showAsDropdown: true)),
                const SizedBox(width: 8),
                const Expanded(child: FilterPresetsWidget(showAsDropdown: true)),
              ],
            ),
          ],
        ],
      );
    }
    
    // Tablet and Desktop: Horizontal layout
    return Row(
      children: [
        // Search bar
        if (showSearch)
          Expanded(
            flex: isDesktop ? 2 : 3,
            child: _buildSearchBar(
              context,
              searchController,
              searchFocusNode,
              isMobile,
            ),
          ),
        
        // Filter and presets buttons
        if (showSearch && !isMobile) ...[
          const SizedBox(width: 8),
          const StorageFilterWidget(showAsDropdown: true),
          const SizedBox(width: 4),
          const FilterPresetsWidget(showAsDropdown: true),
        ],
        
        if (showSearch && showActions && !isMobile)
          const SizedBox(width: 16),
        
        // Action buttons
        if (showActions && selectedBucketId != null)
          _buildActionButtons(
            context,
            onUpload,
            onCreateFolder,
            onViewModeChanged,
            viewMode,
            isMobile,
            isTablet,
          ),
      ],
    );
  }

  Widget _buildBreadcrumbs(
    BuildContext context,
    List<Map<String, String>> breadcrumbs,
    StorageBucket? selectedBucket,
    BucketMethods bucketMethods,
    bool isMobile,
  ) {
    if (breadcrumbs.isEmpty) {
      return const Text(
        'Select a bucket to view files',
        style: TextStyle(
          fontSize: 16,
          color: AppColors.textMuted,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Home icon
          IconButton(
            onPressed: selectedBucket != null
                ? () => bucketMethods.navigateToRoot(selectedBucket.id)
                : null,
            icon: const Icon(
              Icons.home,
              size: 18,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Go to bucket root',
            splashRadius: 16,
          ),
          
          // Breadcrumb items
          for (int i = 0; i < breadcrumbs.length; i++) ...[
            if (i > 0)
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: AppColors.textMuted,
              ),
            _buildBreadcrumbItem(
              context,
              breadcrumbs[i],
              i == breadcrumbs.length - 1, // isLast
              bucketMethods,
              isMobile,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreadcrumbItem(
    BuildContext context,
    Map<String, String> breadcrumb,
    bool isLast,
    BucketMethods bucketMethods,
    bool isMobile,
  ) {
    final name = breadcrumb['name'] ?? '';
    final path = breadcrumb['path'] ?? '';
    final isBucket = breadcrumb['isBucket'] == 'true';
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLast ? null : () {
          if (isBucket) {
            bucketMethods.navigateToRoot(name);
          } else {
            bucketMethods.navigateToPath(name, path);
          }
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isBucket) ...[
                const Icon(
                  Icons.folder,
                  size: 16,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                isMobile && name.length > 15 
                    ? '${name.substring(0, 12)}...'
                    : name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isLast ? FontWeight.w600 : FontWeight.w500,
                  color: isLast ? AppColors.textPrimary : AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
    bool isMobile,
  ) {
    return StorageSearchWidget(
      showSuggestions: true,
      showGlobalSearch: false,
      onSearchResults: onSearch != null ? (results) {
        // This will be handled by the search providers
      } : null,
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    VoidCallback? onUpload,
    VoidCallback? onCreateFolder,
    Function(StorageConstants.ViewMode)? onViewModeChanged,
    StorageConstants.ViewMode viewMode,
    bool isMobile,
    bool isTablet,
  ) {
    if (isMobile) {
      return PopupMenuButton<String>(
        icon: const Icon(
          Icons.more_vert,
          color: AppColors.textSecondary,
        ),
        tooltip: 'More actions',
        itemBuilder: (context) => [
          if (onUpload != null)
            const PopupMenuItem(
              value: 'upload',
              child: Row(
                children: [
                  Icon(Icons.upload, size: 18, color: AppColors.textSecondary),
                  SizedBox(width: 12),
                  Text('Upload Files'),
                ],
              ),
            ),
          if (onCreateFolder != null)
            const PopupMenuItem(
              value: 'folder',
              child: Row(
                children: [
                  Icon(Icons.create_new_folder, size: 18, color: AppColors.textSecondary),
                  SizedBox(width: 12),
                  Text('New Folder'),
                ],
              ),
            ),
          if (onViewModeChanged != null)
            PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(
                    viewMode == ViewMode.grid 
                        ? Icons.view_list 
                        : Icons.grid_view,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Text(viewMode == ViewMode.grid 
                      ? 'List View' 
                      : 'Grid View'),
                ],
              ),
            ),
        ],
        onSelected: (value) {
          switch (value) {
            case 'upload':
              onUpload?.call();
              break;
            case 'folder':
              onCreateFolder?.call();
              break;
            case 'view':
              onViewModeChanged?.call(
                viewMode == ViewMode.grid
                    ? ViewMode.list
                    : ViewMode.grid,
              );
              break;
          }
        },
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Upload button
        if (onUpload != null) ...[
          ElevatedButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.upload, size: 16),
            label: Text(isTablet ? 'Upload' : 'Upload Files'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 12 : 16,
                vertical: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        
        // Create folder button
        if (onCreateFolder != null) ...[
          OutlinedButton.icon(
            onPressed: onCreateFolder,
            icon: const Icon(Icons.create_new_folder, size: 16),
            label: Text(isTablet ? 'Folder' : 'New Folder'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              side: const BorderSide(color: AppColors.primaryBlue),
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 12 : 16,
                vertical: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        
        // View mode toggle
        if (onViewModeChanged != null)
          _buildViewModeToggle(context, viewMode, onViewModeChanged),
      ],
    );
  }

  Widget _buildViewModeToggle(
    BuildContext context,
    ViewMode viewMode,
    Function(ViewMode) onViewModeChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewModeButton(
            context,
            Icons.grid_view,
            'Grid View',
            viewMode == ViewMode.grid,
            () => onViewModeChanged(ViewMode.grid),
            isFirst: true,
          ),
          _buildViewModeButton(
            context,
            Icons.view_list,
            'List View',
            viewMode == ViewMode.list,
            () => onViewModeChanged(ViewMode.list),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeButton(
    BuildContext context,
    IconData icon,
    String tooltip,
    bool isSelected,
    VoidCallback onPressed,
    {bool isFirst = false, bool isLast = false}
  ) {
    return Material(
      color: isSelected ? AppColors.primaryBlue : Colors.transparent,
      borderRadius: BorderRadius.horizontal(
        left: isFirst ? const Radius.circular(5) : Radius.zero,
        right: isLast ? const Radius.circular(5) : Radius.zero,
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.horizontal(
          left: isFirst ? const Radius.circular(5) : Radius.zero,
          right: isLast ? const Radius.circular(5) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}