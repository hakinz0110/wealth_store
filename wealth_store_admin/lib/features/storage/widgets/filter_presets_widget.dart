import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../models/filter_preset.dart';
import '../models/storage_models.dart';
import '../providers/search_providers.dart';
import '../services/filter_presets_service.dart';
import '../../../shared/constants/app_colors.dart';

// Filter presets service provider
final filterPresetsServiceProvider = Provider<FilterPresetsService>((ref) {
  return FilterPresetsService();
});

// Filter presets provider
final filterPresetsProvider = FutureProvider<List<FilterPreset>>((ref) async {
  final service = ref.read(filterPresetsServiceProvider);
  return service.getAllPresets();
});

/// Widget for managing filter presets
class FilterPresetsWidget extends HookConsumerWidget {
  final bool showAsDropdown;
  final VoidCallback? onPresetApplied;

  const FilterPresetsWidget({
    super.key,
    this.showAsDropdown = true,
    this.onPresetApplied,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchMethods = ref.read(searchMethodsProvider);
    final currentFilters = ref.watch(searchFiltersProvider);
    final presetsAsync = ref.watch(filterPresetsProvider);
    
    if (showAsDropdown) {
      return _buildDropdownPresets(context, ref, searchMethods, currentFilters, presetsAsync);
    } else {
      return _buildExpandedPresets(context, ref, searchMethods, currentFilters, presetsAsync);
    }
  }

  Widget _buildDropdownPresets(
    BuildContext context,
    WidgetRef ref,
    SearchMethods searchMethods,
    StorageFilters currentFilters,
    AsyncValue<List<FilterPreset>> presetsAsync,
  ) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.bookmark,
        color: AppColors.textSecondary,
      ),
      tooltip: 'Filter presets',
      itemBuilder: (context) {
        return presetsAsync.when(
          data: (presets) {
            final items = <PopupMenuEntry<String>>[];
            
            // Default presets section
            final defaultPresets = presets.where((p) => p.isDefault).toList();
            if (defaultPresets.isNotEmpty) {
              items.add(const PopupMenuItem(
                enabled: false,
                child: Text(
                  'Quick Filters',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ));
              
              for (final preset in defaultPresets) {
                items.add(PopupMenuItem(
                  value: preset.id,
                  child: Row(
                    children: [
                      Icon(
                        _getPresetIcon(preset),
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              preset.name,
                              style: const TextStyle(fontSize: 14),
                            ),
                            if (preset.description != null)
                              Text(
                                preset.description!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (preset.matchesFilters(currentFilters))
                        const Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.primaryBlue,
                        ),
                    ],
                  ),
                ));
              }
            }
            
            // Custom presets section
            final customPresets = presets.where((p) => !p.isDefault).toList();
            if (customPresets.isNotEmpty) {
              if (items.isNotEmpty) {
                items.add(const PopupMenuDivider());
              }
              
              items.add(const PopupMenuItem(
                enabled: false,
                child: Text(
                  'Saved Filters',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ));
              
              for (final preset in customPresets) {
                items.add(PopupMenuItem(
                  value: preset.id,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.bookmark,
                        size: 16,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              preset.name,
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              preset.filterSummary,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (preset.matchesFilters(currentFilters))
                        const Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.primaryBlue,
                        ),
                    ],
                  ),
                ));
              }
            }
            
            // Management options
            if (items.isNotEmpty) {
              items.add(const PopupMenuDivider());
            }
            
            items.addAll([
              const PopupMenuItem(
                value: 'save_current',
                child: Row(
                  children: [
                    Icon(Icons.save, size: 16, color: AppColors.primaryBlue),
                    SizedBox(width: 8),
                    Text('Save Current Filters'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'manage',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 16, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text('Manage Presets'),
                  ],
                ),
              ),
            ]);
            
            return items;
          },
          loading: () => [
            const PopupMenuItem(
              enabled: false,
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Loading presets...'),
                ],
              ),
            ),
          ],
          error: (_, __) => [
            const PopupMenuItem(
              enabled: false,
              child: Row(
                children: [
                  Icon(Icons.error, size: 16, color: AppColors.errorRed),
                  SizedBox(width: 8),
                  Text('Failed to load presets'),
                ],
              ),
            ),
          ],
        );
      },
      onSelected: (value) async {
        switch (value) {
          case 'save_current':
            await _showSavePresetDialog(context, ref, currentFilters);
            break;
          case 'manage':
            await _showManagePresetsDialog(context, ref);
            break;
          default:
            await _applyPreset(ref, value, searchMethods);
            break;
        }
      },
    );
  }

  Widget _buildExpandedPresets(
    BuildContext context,
    WidgetRef ref,
    SearchMethods searchMethods,
    StorageFilters currentFilters,
    AsyncValue<List<FilterPreset>> presetsAsync,
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
                  Icons.bookmark,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Filter Presets',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showSavePresetDialog(context, ref, currentFilters),
                  icon: const Icon(Icons.add, size: 20),
                  tooltip: 'Save current filters',
                ),
                IconButton(
                  onPressed: () => _showManagePresetsDialog(context, ref),
                  icon: const Icon(Icons.settings, size: 20),
                  tooltip: 'Manage presets',
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Presets list
            presetsAsync.when(
              data: (presets) {
                if (presets.isEmpty) {
                  return const Center(
                    child: Text(
                      'No filter presets available',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  );
                }
                
                return Column(
                  children: presets.map((preset) {
                    final isActive = preset.matchesFilters(currentFilters);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isActive 
                          ? AppColors.primaryBlue.withOpacity(0.1)
                          : null,
                      child: ListTile(
                        leading: Icon(
                          _getPresetIcon(preset),
                          color: isActive 
                              ? AppColors.primaryBlue 
                              : AppColors.textSecondary,
                        ),
                        title: Text(
                          preset.name,
                          style: TextStyle(
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                            color: isActive 
                                ? AppColors.primaryBlue 
                                : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          preset.description ?? preset.filterSummary,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isActive)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primaryBlue,
                                size: 20,
                              ),
                            if (!preset.isDefault) ...[
                              IconButton(
                                onPressed: () => _showEditPresetDialog(context, ref, preset),
                                icon: const Icon(Icons.edit, size: 16),
                                tooltip: 'Edit preset',
                              ),
                              IconButton(
                                onPressed: () => _deletePreset(context, ref, preset),
                                icon: const Icon(Icons.delete, size: 16, color: AppColors.errorRed),
                                tooltip: 'Delete preset',
                              ),
                            ],
                          ],
                        ),
                        onTap: isActive ? null : () => _applyPreset(ref, preset.id, searchMethods),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Center(
                child: Text(
                  'Failed to load presets: $error',
                  style: const TextStyle(color: AppColors.errorRed),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPresetIcon(FilterPreset preset) {
    if (preset.filters.fileType != null) {
      switch (preset.filters.fileType!) {
        case StorageFileType.image:
          return Icons.image;
        case StorageFileType.video:
          return Icons.video_file;
        case StorageFileType.document:
          return Icons.description;
        case StorageFileType.folder:
          return Icons.folder;
        case StorageFileType.other:
          return Icons.insert_drive_file;
      }
    }
    
    if (preset.filters.uploadedAfter != null) {
      return Icons.schedule;
    }
    
    if (preset.filters.minSize != null || preset.filters.maxSize != null) {
      return Icons.storage;
    }
    
    return Icons.filter_list;
  }

  Future<void> _applyPreset(WidgetRef ref, String presetId, SearchMethods searchMethods) async {
    try {
      final service = ref.read(filterPresetsServiceProvider);
      final preset = await service.getPreset(presetId);
      
      if (preset != null) {
        searchMethods.updateFilters(preset.filters);
        await service.saveLastUsedPreset(presetId);
        onPresetApplied?.call();
      }
    } catch (e) {
      // Handle error silently or show snackbar
    }
  }

  Future<void> _showSavePresetDialog(BuildContext context, WidgetRef ref, StorageFilters filters) async {
    if (!filters.hasActiveFilters) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active filters to save'),
          backgroundColor: AppColors.warningOrange,
        ),
      );
      return;
    }
    
    await showDialog(
      context: context,
      builder: (context) => _SavePresetDialog(filters: filters),
    );
    
    // Refresh presets list
    ref.invalidate(filterPresetsProvider);
  }

  Future<void> _showEditPresetDialog(BuildContext context, WidgetRef ref, FilterPreset preset) async {
    await showDialog(
      context: context,
      builder: (context) => _EditPresetDialog(preset: preset),
    );
    
    // Refresh presets list
    ref.invalidate(filterPresetsProvider);
  }

  Future<void> _showManagePresetsDialog(BuildContext context, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (context) => const _ManagePresetsDialog(),
    );
    
    // Refresh presets list
    ref.invalidate(filterPresetsProvider);
  }

  Future<void> _deletePreset(BuildContext context, WidgetRef ref, FilterPreset preset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Preset'),
        content: Text('Are you sure you want to delete "${preset.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final service = ref.read(filterPresetsServiceProvider);
        await service.deletePreset(preset.id);
        ref.invalidate(filterPresetsProvider);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted preset "${preset.name}"'),
              backgroundColor: AppColors.successGreen,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete preset: $e'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    }
  }
}

/// Dialog for saving a new preset
class _SavePresetDialog extends HookConsumerWidget {
  final StorageFilters filters;

  const _SavePresetDialog({required this.filters});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final isLoading = useState<bool>(false);

    return AlertDialog(
      title: const Text('Save Filter Preset'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Preset Name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Filters:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getFilterSummary(filters),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading.value ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading.value ? null : () async {
            final name = nameController.text.trim();
            if (name.isEmpty) return;
            
            isLoading.value = true;
            
            try {
              final service = ref.read(filterPresetsServiceProvider);
              
              // Check if name already exists
              final nameExists = await service.presetNameExists(name);
              if (nameExists) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('A preset with this name already exists'),
                      backgroundColor: AppColors.warningOrange,
                    ),
                  );
                }
                return;
              }
              
              await service.savePreset(
                name: name,
                description: descriptionController.text.trim().isEmpty 
                    ? null 
                    : descriptionController.text.trim(),
                filters: filters,
              );
              
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Saved preset "$name"'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to save preset: $e'),
                    backgroundColor: AppColors.errorRed,
                  ),
                );
              }
            } finally {
              isLoading.value = false;
            }
          },
          child: isLoading.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  String _getFilterSummary(StorageFilters filters) {
    final parts = <String>[];
    
    if (filters.searchQuery?.isNotEmpty == true) {
      parts.add('Search: "${filters.searchQuery}"');
    }
    
    if (filters.fileType != null) {
      parts.add('Type: ${filters.fileType!.displayName}');
    }
    
    if (filters.uploadedAfter != null || filters.uploadedBefore != null) {
      parts.add('Date filtered');
    }
    
    if (filters.minSize != null || filters.maxSize != null) {
      parts.add('Size filtered');
    }
    
    return parts.isEmpty ? 'No filters' : parts.join(', ');
  }
}

/// Dialog for editing an existing preset
class _EditPresetDialog extends HookConsumerWidget {
  final FilterPreset preset;

  const _EditPresetDialog({required this.preset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController(text: preset.name);
    final descriptionController = useTextEditingController(text: preset.description ?? '');
    final isLoading = useState<bool>(false);

    return AlertDialog(
      title: const Text('Edit Filter Preset'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Preset Name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading.value ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading.value ? null : () async {
            final name = nameController.text.trim();
            if (name.isEmpty) return;
            
            isLoading.value = true;
            
            try {
              final service = ref.read(filterPresetsServiceProvider);
              
              // Check if name already exists (excluding current preset)
              final nameExists = await service.presetNameExists(name, excludeId: preset.id);
              if (nameExists) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('A preset with this name already exists'),
                      backgroundColor: AppColors.warningOrange,
                    ),
                  );
                }
                return;
              }
              
              final updatedPreset = preset.copyWith(
                name: name,
                description: descriptionController.text.trim().isEmpty 
                    ? null 
                    : descriptionController.text.trim(),
              );
              
              await service.updatePreset(updatedPreset);
              
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Updated preset "$name"'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update preset: $e'),
                    backgroundColor: AppColors.errorRed,
                  ),
                );
              }
            } finally {
              isLoading.value = false;
            }
          },
          child: isLoading.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update'),
        ),
      ],
    );
  }
}

/// Dialog for managing presets (import/export/clear)
class _ManagePresetsDialog extends HookConsumerWidget {
  const _ManagePresetsDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Manage Filter Presets'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.file_download, color: AppColors.primaryBlue),
            title: const Text('Export Presets'),
            subtitle: const Text('Export custom presets to file'),
            onTap: () {
              Navigator.of(context).pop();
              _exportPresets(context, ref);
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_upload, color: AppColors.primaryBlue),
            title: const Text('Import Presets'),
            subtitle: const Text('Import presets from file'),
            onTap: () {
              Navigator.of(context).pop();
              _importPresets(context, ref);
            },
          ),
          ListTile(
            leading: const Icon(Icons.clear_all, color: AppColors.errorRed),
            title: const Text('Clear All Custom Presets'),
            subtitle: const Text('Remove all custom presets'),
            onTap: () {
              Navigator.of(context).pop();
              _clearAllPresets(context, ref);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Future<void> _exportPresets(BuildContext context, WidgetRef ref) async {
    try {
      final service = ref.read(filterPresetsServiceProvider);
      final jsonString = await service.exportPresets();
      
      // In a real app, you would use file_picker or similar to save the file
      // For now, we'll just show the JSON in a dialog
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Export Data'),
            content: SingleChildScrollView(
              child: SelectableText(jsonString),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export presets: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _importPresets(BuildContext context, WidgetRef ref) async {
    // In a real app, you would use file_picker to select a file
    // For now, we'll show a text input dialog
    final controller = TextEditingController();
    
    final jsonString = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Presets'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Paste JSON data here',
            border: OutlineInputBorder(),
          ),
          maxLines: 10,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    
    if (jsonString?.isNotEmpty == true) {
      try {
        final service = ref.read(filterPresetsServiceProvider);
        final importedPresets = await service.importPresets(jsonString!);
        ref.invalidate(filterPresetsProvider);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Imported ${importedPresets.length} presets'),
              backgroundColor: AppColors.successGreen,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to import presets: $e'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _clearAllPresets(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Custom Presets'),
        content: const Text(
          'Are you sure you want to delete all custom filter presets? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final service = ref.read(filterPresetsServiceProvider);
        await service.clearAllCustomPresets();
        ref.invalidate(filterPresetsProvider);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cleared all custom presets'),
              backgroundColor: AppColors.successGreen,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to clear presets: $e'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    }
  }
}