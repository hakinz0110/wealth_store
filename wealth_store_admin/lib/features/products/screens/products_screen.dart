import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/admin_layout.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../models/product_models.dart';
import '../../../services/product_service.dart';
import '../../../services/category_service.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Product> _products = [];
  List<Category> _categories = [];
  List<Brand> _brands = [];
  bool _isLoading = true;
  String? _error;
  ProductFilters _filters = const ProductFilters();
  Set<String> _selectedProducts = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _productService.getProducts(filters: _filters),
        _categoryService.getCategories(),
        _productService.getBrands(),
      ]);

      setState(() {
        _products = results[0] as List<Product>;
        _categories = results[1] as List<Category>;
        _brands = results[2] as List<Brand>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _updateFilters(ProductFilters newFilters) {
    setState(() {
      _filters = newFilters;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Products',
      currentRoute: '/products',
      breadcrumbs: const ['Dashboard', 'Products'],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          _buildHeader(),
          
          const SizedBox(height: 24),
          
          // Filters section
          _buildFilters(),
          
          const SizedBox(height: 24),
          
          // Products table
          Expanded(
            child: _buildProductsTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Add Product button
        ElevatedButton.icon(
          onPressed: () => context.go('/products/add'),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Product'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        
        const Spacer(),
        
        // Search field
        SizedBox(
          width: 300,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primaryBlue),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              _updateFilters(_filters.copyWith(
                searchQuery: value.trim().isEmpty ? null : value.trim(),
              ));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Category filter
            SizedBox(
              width: 150,
              child: DropdownButtonFormField<String>(
                value: _filters.categoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Categories'),
                  ),
                  ..._categories.map((category) => DropdownMenuItem<String>(
                    value: category.id,
                    child: Text(category.name),
                  )),
                ],
                onChanged: (value) {
                  _updateFilters(_filters.copyWith(categoryId: value));
                },
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Brand filter
            SizedBox(
              width: 150,
              child: DropdownButtonFormField<String>(
                value: _filters.brandId,
                decoration: const InputDecoration(
                  labelText: 'Brand',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Brands'),
                  ),
                  ..._brands.map((brand) => DropdownMenuItem<String>(
                    value: brand.id,
                    child: Text(brand.name),
                  )),
                ],
                onChanged: (value) {
                  _updateFilters(_filters.copyWith(brandId: value));
                },
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Low stock filter
            FilterChip(
              label: const Text('Low Stock'),
              selected: _filters.lowStock == true,
              onSelected: (selected) {
                _updateFilters(_filters.copyWith(
                  lowStock: selected ? true : null,
                ));
              },
              selectedColor: AppColors.warning.withOpacity(0.2),
              checkmarkColor: AppColors.warning,
            ),
            
            const SizedBox(width: 16),
            
            // Active filter
            FilterChip(
              label: const Text('Active Only'),
              selected: _filters.isActive == true,
              onSelected: (selected) {
                _updateFilters(_filters.copyWith(
                  isActive: selected ? true : null,
                ));
              },
              selectedColor: AppColors.success.withOpacity(0.2),
              checkmarkColor: AppColors.success,
            ),
            
            const Spacer(),
            
            // Clear filters
            if (_filters.categoryId != null || 
                _filters.brandId != null || 
                _filters.lowStock != null || 
                _filters.isActive != null ||
                _filters.searchQuery != null)
              TextButton(
                onPressed: () {
                  _updateFilters(const ProductFilters());
                  _searchController.clear();
                },
                child: const Text('Clear Filters'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsTable() {
    return Card(
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderLight),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  'Rows per page: 20',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Table content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading products...');
    }

    if (_error != null) {
      return ErrorDisplayWidget(
        error: _error!,
        onRetry: _loadData,
      );
    }

    return _buildDataTable();
  }

  Widget _buildDataTable() {
    if (_products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
            SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 16,
      minWidth: 800,
      columns: const [
        DataColumn2(
          label: Text('Product'),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text('Stock'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('Brand'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text('Price'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('Date'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text('Action'),
          size: ColumnSize.S,
        ),
      ],
      rows: _products.map((product) => _buildDataRow(product)).toList(),
    );
  }

  DataRow _buildDataRow(Product product) {
    return DataRow(
      cells: [
        // Product info with image
        DataCell(
          Row(
            children: [
              // Product image
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: product.imageUrls.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          product.imageUrls.first,
                          fit: BoxFit.cover,
                          width: 40,
                          height: 40,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.broken_image,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.image,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Stock with warning indicator
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                product.stock.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: product.isOutOfStock 
                      ? AppColors.error 
                      : product.isLowStock 
                          ? AppColors.warning 
                          : AppColors.textPrimary,
                ),
              ),
              if (product.isLowStock) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.warning,
                  size: 16,
                  color: product.isOutOfStock ? AppColors.error : AppColors.warning,
                ),
              ],
            ],
          ),
        ),
        
        // Brand
        DataCell(
          Text(
            _brands.firstWhere(
              (brand) => brand.id == product.brandId,
              orElse: () => Brand(
                id: '',
                name: 'Unknown',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            ).name,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        
        // Price
        DataCell(
          Text(
            product.formattedPrice,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        
        // Date
        DataCell(
          Text(
            DateFormat('dd/MM/yyyy').format(product.createdAt),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        
        // Actions
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => context.go('/products/edit/${product.id}'),
                tooltip: 'Edit Product',
                color: AppColors.primaryBlue,
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18),
                onPressed: () => _showDeleteConfirmation(product),
                tooltip: 'Delete Product',
                color: AppColors.error,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await _productService.deleteProduct(product.id);
                await _loadData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete product: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}