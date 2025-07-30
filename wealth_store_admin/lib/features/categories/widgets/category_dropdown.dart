import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../models/product_models.dart';
import '../providers/category_providers.dart';

class CategoryDropdown extends ConsumerWidget {
  final String? value;
  final Function(String?) onChanged;
  final String? labelText;
  final String? hintText;
  final bool isRequired;
  final bool isEnabled;

  const CategoryDropdown({
    super.key,
    this.value,
    required this.onChanged,
    this.labelText,
    this.hintText,
    this.isRequired = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoriesProvider);

    return FormField<String>(
      initialValue: value,
      validator: isRequired
          ? (value) => value == null || value.isEmpty
              ? 'Please select a category'
              : null
          : null,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (labelText != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  isRequired ? '$labelText *' : labelText!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: state.hasError ? Colors.red : Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  hint: Text(hintText ?? 'Select a category'),
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(
                    color: isEnabled ? Colors.black : Colors.grey,
                    fontSize: 16,
                  ),
                  onChanged: isEnabled ? onChanged : null,
                  items: [
                    if (categoriesState.isLoading)
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Loading...'),
                      )
                    else if (categoriesState.error != null)
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Error loading categories'),
                      )
                    else if (categoriesState.categories.isEmpty)
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('No categories available'),
                      )
                    else
                      ...categoriesState.categories.map<DropdownMenuItem<String>>(
                        (Category category) {
                          return DropdownMenuItem<String>(
                            value: category.id,
                            child: Row(
                              children: [
                                if (category.imageUrl != null)
                                  Container(
                                    width: 24,
                                    height: 24,
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
                                    width: 24,
                                    height: 24,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(
                                      Icons.category,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    category.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 12),
                child: Text(
                  state.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}