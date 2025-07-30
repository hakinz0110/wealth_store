import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/features/profile/domain/profile_notifier.dart';
import 'package:wealth_app/shared/models/address.dart';
import 'package:wealth_app/shared/widgets/base_screen.dart';
import 'package:wealth_app/shared/widgets/custom_button.dart';

class AddressListScreen extends ConsumerWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileNotifierProvider);
    final addresses = profileState.addresses;
    final isLoading = profileState.isLoading || profileState.isUpdating;

    return BaseScreen(
      title: 'My Addresses',
      showBackButton: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/profile/addresses/add'),
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : addresses.isEmpty
              ? _buildEmptyState(context)
              : _buildAddressList(context, ref, addresses),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'No Addresses Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'Add a shipping address to make checkout easier',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.large),
          CustomButton(
            text: 'Add New Address',
            onPressed: () => context.push('/profile/addresses/add'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList(BuildContext context, WidgetRef ref, List<Address> addresses) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(profileNotifierProvider.notifier).refreshProfile();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.medium),
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final address = addresses[index];
          return _buildAddressCard(context, ref, address);
        },
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, WidgetRef ref, Address address) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  address.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Default',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              '${address.street}, ${address.city}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${address.state}, ${address.zipCode}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              address.country,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (address.phoneNumber != null) ...[
              const SizedBox(height: AppSpacing.small),
              Text(
                'Phone: ${address.phoneNumber}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: AppSpacing.medium),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Edit button
                TextButton.icon(
                  onPressed: () => context.push('/profile/addresses/edit/${address.id}'),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: AppSpacing.small),
                // Delete button
                TextButton.icon(
                  onPressed: () => _showDeleteConfirmation(context, ref, address),
                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                // Set as default button
                if (!address.isDefault)
                  TextButton.icon(
                    onPressed: () => _setAsDefault(ref, address.id),
                    icon: const Icon(Icons.check_circle, size: 16),
                    label: const Text('Set as Default'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Address address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: Text('Are you sure you want to delete ${address.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(profileNotifierProvider.notifier).deleteAddress(address.id);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _setAsDefault(WidgetRef ref, int addressId) {
    ref.read(profileNotifierProvider.notifier).setDefaultAddress(addressId);
  }
} 