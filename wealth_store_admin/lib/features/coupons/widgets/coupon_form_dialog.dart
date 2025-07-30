import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../models/coupon_models.dart';
import '../../../services/coupon_service.dart';
import '../providers/coupon_providers.dart';

class CouponFormDialog extends HookConsumerWidget {
  final Coupon? coupon;
  final CouponFormData? initialData;

  const CouponFormDialog({
    super.key,
    this.coupon,
    this.initialData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isEditing = coupon != null;
    final data = initialData ?? (coupon != null ? CouponFormData.fromCoupon(coupon!) : CouponFormData.empty());
    
    // Form controllers
    final codeController = useTextEditingController(text: data.code);
    final nameController = useTextEditingController(text: data.name);
    final descriptionController = useTextEditingController(text: data.description ?? '');
    final discountValueController = useTextEditingController(text: data.discountValue.toString());
    final minimumOrderController = useTextEditingController(text: data.minimumOrderAmount?.toString() ?? '');
    final maximumDiscountController = useTextEditingController(text: data.maximumDiscountAmount?.toString() ?? '');
    final usageLimitController = useTextEditingController(text: data.usageLimit?.toString() ?? '');
    
    // Form state
    final discountType = useState<DiscountType>(data.discountType);
    final startDate = useState<DateTime?>(data.startDate);
    final endDate = useState<DateTime?>(data.endDate);
    final isFirstTimeUserOnly = useState<bool>(data.isFirstTimeUserOnly);
    final isLoading = useState(false);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 600,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  isEditing ? 'Edit Coupon' : 'Add Coupon',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Form content
            Expanded(
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information
                      _buildSectionTitle('Basic Information'),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          // Coupon Code
                          Expanded(
                            child: TextFormField(
                              controller: codeController,
                              decoration: const InputDecoration(
                                labelText: 'Coupon Code *',
                                border: OutlineInputBorder(),
                                hintText: 'e.g., SAVE20',
                              ),
                              validator: CouponService.validateCouponCode,
                              enabled: !isLoading.value,
                              textCapitalization: TextCapitalization.characters,
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Coupon Name
                          Expanded(
                            child: TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Coupon Name *',
                                border: OutlineInputBorder(),
                                hintText: 'e.g., Summer Sale',
                              ),
                              validator: CouponService.validateCouponName,
                              enabled: !isLoading.value,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Description
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          hintText: 'Brief description of the coupon',
                        ),
                        validator: CouponService.validateCouponDescription,
                        maxLines: 2,
                        enabled: !isLoading.value,
                      ),
                      const SizedBox(height: 24),
                      
                      // Discount Settings
                      _buildSectionTitle('Discount Settings'),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          // Discount Type
                          Expanded(
                            child: DropdownButtonFormField<DiscountType>(
                              value: discountType.value,
                              onChanged: isLoading.value ? null : (value) {
                                if (value != null) {
                                  discountType.value = value;
                                }
                              },
                              decoration: const InputDecoration(
                                labelText: 'Discount Type *',
                                border: OutlineInputBorder(),
                              ),
                              items: DiscountType.values.map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.displayName),
                              )).toList(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Discount Value
                          Expanded(
                            child: TextFormField(
                              controller: discountValueController,
                              decoration: InputDecoration(
                                labelText: 'Discount Value *',
                                border: const OutlineInputBorder(),
                                suffixText: discountType.value == DiscountType.percentage ? '%' : '\$',
                              ),
                              validator: (value) => CouponService.validateDiscountValue(value, discountType.value),
                              keyboardType: TextInputType.number,
                              enabled: !isLoading.value,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          // Minimum Order Amount
                          Expanded(
                            child: TextFormField(
                              controller: minimumOrderController,
                              decoration: const InputDecoration(
                                labelText: 'Minimum Order Amount',
                                border: OutlineInputBorder(),
                                prefixText: '\$',
                                hintText: 'Optional',
                              ),
                              validator: CouponService.validateMinimumOrderAmount,
                              keyboardType: TextInputType.number,
                              enabled: !isLoading.value,
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Maximum Discount Amount (for percentage)
                          if (discountType.value == DiscountType.percentage)
                            Expanded(
                              child: TextFormField(
                                controller: maximumDiscountController,
                                decoration: const InputDecoration(
                                  labelText: 'Maximum Discount',
                                  border: OutlineInputBorder(),
                                  prefixText: '\$',
                                  hintText: 'Optional',
                                ),
                                validator: CouponService.validateMaximumDiscountAmount,
                                keyboardType: TextInputType.number,
                                enabled: !isLoading.value,
                              ),
                            )
                          else
                            const Expanded(child: SizedBox()),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Usage Settings
                      _buildSectionTitle('Usage Settings'),
                      const SizedBox(height: 12),
                      
                      // Usage Limit
                      TextFormField(
                        controller: usageLimitController,
                        decoration: const InputDecoration(
                          labelText: 'Usage Limit',
                          border: OutlineInputBorder(),
                          hintText: 'Leave empty for unlimited',
                        ),
                        validator: CouponService.validateUsageLimit,
                        keyboardType: TextInputType.number,
                        enabled: !isLoading.value,
                      ),
                      const SizedBox(height: 16),
                      
                      // First Time User Only
                      CheckboxListTile(
                        title: const Text('First-time users only'),
                        subtitle: const Text('This coupon can only be used by new customers'),
                        value: isFirstTimeUserOnly.value,
                        onChanged: isLoading.value ? null : (value) {
                          isFirstTimeUserOnly.value = value ?? false;
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 24),
                      
                      // Validity Period
                      _buildSectionTitle('Validity Period'),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          // Start Date
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isLoading.value ? null : () => _selectDate(context, startDate, 'Start Date'),
                              child: Text(
                                startDate.value != null
                                    ? 'Start: ${startDate.value!.day}/${startDate.value!.month}/${startDate.value!.year}'
                                    : 'Start Date (Optional)',
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // End Date
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isLoading.value ? null : () => _selectDate(context, endDate, 'End Date'),
                              child: Text(
                                endDate.value != null
                                    ? 'End: ${endDate.value!.day}/${endDate.value!.month}/${endDate.value!.year}'
                                    : 'End Date (Optional)',
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Date validation warning
                      if (startDate.value != null && endDate.value != null && startDate.value!.isAfter(endDate.value!)) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning, color: AppColors.error, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'End date must be after start date',
                                style: TextStyle(color: AppColors.error, fontSize: 12),
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
            
            // Actions
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: isLoading.value ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: isLoading.value
                      ? null
                      : () => _handleSubmit(
                            context,
                            ref,
                            formKey,
                            codeController,
                            nameController,
                            descriptionController,
                            discountValueController,
                            minimumOrderController,
                            maximumDiscountController,
                            usageLimitController,
                            discountType.value,
                            startDate.value,
                            endDate.value,
                            isFirstTimeUserOnly.value,
                            isLoading,
                            isEditing,
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: isLoading.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          isEditing ? 'Update Coupon' : 'Create Coupon',
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  void _selectDate(BuildContext context, ValueNotifier<DateTime?> dateNotifier, String label) async {
    final date = await showDatePicker(
      context: context,
      initialDate: dateNotifier.value ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      helpText: label,
    );
    
    if (date != null) {
      dateNotifier.value = date;
    }
  }

  Future<void> _handleSubmit(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    TextEditingController codeController,
    TextEditingController nameController,
    TextEditingController descriptionController,
    TextEditingController discountValueController,
    TextEditingController minimumOrderController,
    TextEditingController maximumDiscountController,
    TextEditingController usageLimitController,
    DiscountType discountType,
    DateTime? startDate,
    DateTime? endDate,
    bool isFirstTimeUserOnly,
    ValueNotifier<bool> isLoading,
    bool isEditing,
  ) async {
    if (!formKey.currentState!.validate()) return;

    // Additional date validation
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date must be after start date'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    isLoading.value = true;

    try {
      final formData = CouponFormData(
        code: codeController.text.trim().toUpperCase(),
        name: nameController.text.trim(),
        description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
        discountType: discountType,
        discountValue: double.parse(discountValueController.text),
        minimumOrderAmount: minimumOrderController.text.trim().isEmpty 
            ? null 
            : double.parse(minimumOrderController.text),
        maximumDiscountAmount: maximumDiscountController.text.trim().isEmpty 
            ? null 
            : double.parse(maximumDiscountController.text),
        usageLimit: usageLimitController.text.trim().isEmpty 
            ? null 
            : int.parse(usageLimitController.text),
        startDate: startDate,
        endDate: endDate,
        isFirstTimeUserOnly: isFirstTimeUserOnly,
      );

      final crudOperations = ref.read(couponCrudProvider);

      if (isEditing) {
        await crudOperations.updateCoupon(coupon!.id, formData);
      } else {
        await crudOperations.createCoupon(formData);
      }

      // Refresh coupons list
      ref.invalidate(paginatedCouponsProvider);
      ref.invalidate(activeCouponsProvider);
      ref.invalidate(couponStatisticsProvider);

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Coupon updated successfully' : 'Coupon created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}