import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/admin_layout.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../models/product_models.dart';
import '../providers/product_providers.dart';
import '../widgets/product_form.dart';

class AddProductScreen extends ConsumerWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdminLayout(
      title: 'Add Product',
      currentRoute: '/products/add',
      breadcrumbs: ['Dashboard', 'Products', 'Add Product'],
      child: ProductForm(
        onCancel: () => context.go('/products'),
        onSubmit: (formData) => _handleSubmit(context, ref, formData),
      ),
    );
  }

  Future<void> _handleSubmit(
    BuildContext context,
    WidgetRef ref,
    ProductFormData formData,
  ) async {
    try {
      await ref.read(productCrudProvider).createProduct(formData);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Refresh products list and navigate back
        ref.invalidate(productsProvider);
        context.go('/products');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create product: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}