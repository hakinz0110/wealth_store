import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/utils/product_validation.dart';
import '../../../models/product_models.dart';
import '../providers/product_providers.dart';
import '../../categories/widgets/category_dropdown.dart';
import 'product_image_upload.dart';

class ProductForm extends HookConsumerWidget {
  final Product? product; // null for add, Product for edit
  final VoidCallback? onCancel;
  final Function(ProductFormData)? onSubmit;

  const ProductForm({
    super.key,
    this.product,
    this.onCancel,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isLoading = useState(false);
    
    // Form controllers
    final nameController = useTextEditingController(text: product?.name ?? '');
    final descriptionController = useTextEditingController(text: product?.description ?? '');
    final priceController = useTextEditingController(text: product?.price.toString() ?? '');
    final stockController = useTextEditingController(text: product?.stock.toString() ?? '');
    
    // Form state
    final selectedCategoryId = useState<String?>(product?.categoryId);
    final selectedBrandId = useState<String?>(product?.brandId);
    final isActive = useState(product?.isActive ?? true);
    final imageUrls = useState<List<String>>(List.from(product?.imageUrls ?? []));
    final specifications = useState<Map<String, dynamic>>(Map.from(product?.specifications ?? {}));
    
    // Load categories and brands
    final categoriesAsync = ref.watch(categoriesProvider);
    final brandsAsync = ref.watch(brandsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    product == null ? 'Add New Product' : 'Edit Product',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (onCancel != null)
                    TextButton(
                      onPressed: isLoading.value ? null : onCancel,
                      child: const Text('Cancel'),
                    ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Form fields
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information Section
                      _buildSectionHeader('Basic Information'),
                      const SizedBox(height: 16),
                      
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left column
                          Expanded(
                            child: Column(
                              children: [
                                // Product Name
                                TextFormField(
                                  controller: nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Product Name *',
                                    hintText: 'Enter product name',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: ProductValidation.validateProductName,
                                  enabled: !isLoading.value,
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Price and Stock
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: priceController,
                                        decoration: const InputDecoration(
                                          labelText: 'Price *',
                                          hintText: '0.00',
                                          prefixText: '\$ ',
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                        ],
                                        validator: ProductValidation.validateProductPrice,
                                        enabled: !isLoading.value,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: TextFormField(
                                        controller: stockController,
                                        decoration: const InputDecoration(
                                          labelText: 'Stock Quantity *',
                                          hintText: '0',
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                        validator: ProductValidation.validateProductStock,
                                        enabled: !isLoading.value,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Category and Brand
                                Row(
                                  children: [
                                    Expanded(
                                      child: CategoryDropdown(
                                        value: selectedCategoryId.value,
                                        onChanged: (value) {
                                          if (!isLoading.value) {
                                            selectedCategoryId.value = value;
                                          }
                                        },
                                        isRequired: true,
                                        isEnabled: !isLoading.value,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: brandsAsync.when(
                                        data: (brands) => DropdownButtonFormField<String>(
                                          value: selectedBrandId.value,
                                          decoration: const InputDecoration(
                                            labelText: 'Brand',
                                            border: OutlineInputBorder(),
                                          ),
                                          items: [
                                            const DropdownMenuItem<String>(
                                              value: null,
                                              child: Text('Select Brand (Optional)'),
                                            ),
                                            ...brands.map((brand) => DropdownMenuItem<String>(
                                              value: brand.id,
                                              child: Text(brand.name),
                                            )),
                                          ],
                                          onChanged: isLoading.value ? null : (value) {
                                            selectedBrandId.value = value;
                                          },
                                        ),
                                        loading: () => const LinearProgressIndicator(),
                                        error: (_, __) => const Text('Error loading brands'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(width: 24),
                          
                          // Right column - Product Status
                          SizedBox(
                            width: 200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Product Status',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SwitchListTile(
                                  title: const Text('Active'),
                                  subtitle: Text(
                                    isActive.value ? 'Product is visible to customers' : 'Product is hidden from customers',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  value: isActive.value,
                                  onChanged: isLoading.value ? null : (value) {
                                    isActive.value = value;
                                  },
                                  activeColor: AppColors.success,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Description Section
                      _buildSectionHeader('Product Description'),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          hintText: 'Enter detailed product description',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                        validator: ProductValidation.validateProductDescription,
                        enabled: !isLoading.value,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Images Section
                      _buildSectionHeader('Product Images'),
                      const SizedBox(height: 16),
                      
                      ProductImageUpload(
                        imageUrls: imageUrls.value,
                        onImagesChanged: (urls) => imageUrls.value = urls,
                        enabled: !isLoading.value,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Specifications Section
                      _buildSectionHeader('Specifications (Optional)'),
                      const SizedBox(height: 16),
                      
                      _buildSpecificationsSection(specifications, isLoading.value),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onCancel != null)
                    TextButton(
                      onPressed: isLoading.value ? null : onCancel,
                      child: const Text('Cancel'),
                    ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: isLoading.value ? null : () => _handleSubmit(
                      context,
                      ref,
                      formKey,
                      nameController,
                      descriptionController,
                      priceController,
                      stockController,
                      selectedCategoryId.value,
                      selectedBrandId.value,
                      isActive.value,
                      imageUrls.value,
                      specifications.value,
                      isLoading,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(product == null ? 'Add Product' : 'Update Product'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }



  Widget _buildSpecificationsSection(ValueNotifier<Map<String, dynamic>> specifications, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add specification button
        OutlinedButton.icon(
          onPressed: isLoading ? null : () => _showAddSpecificationDialog(specifications),
          icon: const Icon(Icons.add),
          label: const Text('Add Specification'),
        ),
        
        const SizedBox(height: 16),
        
        // Specifications list
        if (specifications.value.isNotEmpty) ...[
          ...specifications.value.entries.map((entry) {
            return Card(
              child: ListTile(
                title: Text(entry.key),
                subtitle: Text(entry.value.toString()),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  onPressed: isLoading ? null : () {
                    final newSpecs = Map<String, dynamic>.from(specifications.value);
                    newSpecs.remove(entry.key);
                    specifications.value = newSpecs;
                  },
                ),
              ),
            );
          }),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderLight, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'No specifications added',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }



  void _showAddSpecificationDialog(ValueNotifier<Map<String, dynamic>> specifications) {
    // This would typically show a dialog to add specifications
    // For now, we'll add a placeholder
    final newSpecs = Map<String, dynamic>.from(specifications.value);
    newSpecs['Specification ${newSpecs.length + 1}'] = 'Value ${newSpecs.length + 1}';
    specifications.value = newSpecs;
  }

  void _handleSubmit(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    TextEditingController nameController,
    TextEditingController descriptionController,
    TextEditingController priceController,
    TextEditingController stockController,
    String? categoryId,
    String? brandId,
    bool isActive,
    List<String> imageUrls,
    Map<String, dynamic> specifications,
    ValueNotifier<bool> isLoading,
  ) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Image validation is now optional since images can be added later
    // if (imageUrls.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Please add at least one product image'),
    //       backgroundColor: AppColors.error,
    //     ),
    //   );
    //   return;
    // }

    final formData = ProductFormData(
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      price: double.parse(priceController.text),
      stock: int.parse(stockController.text),
      categoryId: categoryId,
      brandId: brandId,
      imageUrls: imageUrls,
      specifications: specifications,
      isActive: isActive,
    );

    if (onSubmit != null) {
      onSubmit!(formData);
    }
  }
}