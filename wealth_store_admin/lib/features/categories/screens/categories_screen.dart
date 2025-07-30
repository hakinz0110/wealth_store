import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../shared/widgets/admin_layout.dart';
import '../../../models/product_models.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../providers/category_providers.dart';
import '../widgets/add_category_dialog.dart';
import '../widgets/edit_category_dialog.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Initial load is handled by the provider
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddCategoryDialog(),
    );

    if (result == true) {
      // Refresh is handled by the provider after creation
    }
  }

  Future<void> _editCategory(Category category) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditCategoryDialog(category: category),
    );

    if (result == true) {
      // Refresh is handled by the provider after update
    }
  }

  Future<void> _deleteCategory(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(categoriesProvider.notifier).deleteCategory(category.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting category: $e')),
          );
        }
      }
    }
  }

  void _onSearchChanged(String query) {
    ref.read(categorySearchQueryProvider.notifier).state = query;
    ref.read(categoriesProvider.notifier).loadCategories(searchQuery: query);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesProvider);
    final searchQuery = ref.watch(categorySearchQueryProvider);
    
    return AdminLayout(
      title: 'Categories',
      currentRoute: '/categories',
      breadcrumbs: const ['Dashboard', 'Categories'],
      child: Column(
        children: [
          // Header with search and add button
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search categories...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _addCategory,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Category'),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _buildContent(categoriesState, searchQuery),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(CategoriesState state, String searchQuery) {
    if (state.isLoading) {
      return const LoadingWidget(message: 'Loading categories...');
    }

    if (state.error != null) {
      return ErrorDisplayWidget(
        error: state.error!,
        onRetry: () => ref.read(categoriesProvider.notifier).refresh(),
      );
    }

    if (state.categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty ? 'No categories found' : 'No categories match your search',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              searchQuery.isEmpty 
                  ? 'Create your first category to get started'
                  : 'Try a different search term',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            if (searchQuery.isEmpty)
              ElevatedButton.icon(
                onPressed: _addCategory,
                icon: const Icon(Icons.add),
                label: const Text('Add Category'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(categoriesProvider.notifier).refresh(),
      child: Container(
        margin: const EdgeInsets.all(16),
        child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 600,
          columns: const [
            DataColumn2(
              label: Text('Name'),
              size: ColumnSize.L,
            ),
            DataColumn2(
              label: Text('Description'),
              size: ColumnSize.L,
            ),
            DataColumn2(
              label: Text('Products'),
              size: ColumnSize.S,
            ),
            DataColumn2(
              label: Text('Created'),
              size: ColumnSize.M,
            ),
            DataColumn2(
              label: Text('Actions'),
              size: ColumnSize.M,
            ),
          ],
          rows: state.categories.map((category) {
            return DataRow2(
              cells: [
                DataCell(
                  Row(
                    children: [
                      if (category.imageUrl != null)
                        Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            image: DecorationImage(
                              image: NetworkImage(category.imageUrl!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.category,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          category.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    category.description ?? 'No description',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: category.description == null ? Colors.grey : null,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category.productCount.toString(),
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '${category.createdAt.day}/${category.createdAt.month}/${category.createdAt.year}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () => _editCategory(category),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18),
                        onPressed: () => _deleteCategory(category),
                        tooltip: 'Delete',
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}