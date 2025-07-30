import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/filter_preset.dart';
import '../models/storage_models.dart';
import '../../../shared/utils/logger.dart';

/// Service for managing filter presets
class FilterPresetsService {
  static const String _presetsKey = 'storage_filter_presets';
  static const String _lastUsedPresetKey = 'storage_last_used_preset';

  /// Get all filter presets (default + custom)
  Future<List<FilterPreset>> getAllPresets() async {
    try {
      final customPresets = await getCustomPresets();
      final defaultPresets = DefaultFilterPresets.getDefaults();
      
      // Combine default and custom presets
      final allPresets = <FilterPreset>[...defaultPresets, ...customPresets];
      
      // Sort by creation date (newest first)
      allPresets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      Logger.info('Loaded ${allPresets.length} filter presets (${defaultPresets.length} default, ${customPresets.length} custom)');
      return allPresets;
    } catch (e, stackTrace) {
      Logger.error('Failed to get all presets', e, stackTrace);
      return DefaultFilterPresets.getDefaults();
    }
  }

  /// Get only custom (user-created) presets
  Future<List<FilterPreset>> getCustomPresets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final presetsJson = prefs.getString(_presetsKey);
      
      if (presetsJson == null) {
        return [];
      }
      
      final presetsList = jsonDecode(presetsJson) as List<dynamic>;
      final presets = presetsList
          .map((json) => FilterPreset.fromJson(json as Map<String, dynamic>))
          .toList();
      
      Logger.info('Loaded ${presets.length} custom filter presets');
      return presets;
    } catch (e, stackTrace) {
      Logger.error('Failed to get custom presets', e, stackTrace);
      return [];
    }
  }

  /// Save a new custom preset
  Future<FilterPreset> savePreset({
    required String name,
    String? description,
    required StorageFilters filters,
  }) async {
    try {
      final now = DateTime.now();
      final preset = FilterPreset(
        id: 'custom_${now.millisecondsSinceEpoch}',
        name: name,
        description: description,
        filters: filters,
        createdAt: now,
        updatedAt: now,
      );
      
      final customPresets = await getCustomPresets();
      customPresets.add(preset);
      
      await _saveCustomPresets(customPresets);
      
      Logger.info('Saved filter preset: ${preset.name}');
      return preset;
    } catch (e, stackTrace) {
      Logger.error('Failed to save preset', e, stackTrace);
      rethrow;
    }
  }

  /// Update an existing custom preset
  Future<FilterPreset> updatePreset(FilterPreset preset) async {
    try {
      if (DefaultFilterPresets.isDefault(preset.id)) {
        throw ArgumentError('Cannot update default preset');
      }
      
      final customPresets = await getCustomPresets();
      final index = customPresets.indexWhere((p) => p.id == preset.id);
      
      if (index == -1) {
        throw ArgumentError('Preset not found: ${preset.id}');
      }
      
      final updatedPreset = preset.copyWith(updatedAt: DateTime.now());
      customPresets[index] = updatedPreset;
      
      await _saveCustomPresets(customPresets);
      
      Logger.info('Updated filter preset: ${updatedPreset.name}');
      return updatedPreset;
    } catch (e, stackTrace) {
      Logger.error('Failed to update preset', e, stackTrace);
      rethrow;
    }
  }

  /// Delete a custom preset
  Future<void> deletePreset(String presetId) async {
    try {
      if (DefaultFilterPresets.isDefault(presetId)) {
        throw ArgumentError('Cannot delete default preset');
      }
      
      final customPresets = await getCustomPresets();
      customPresets.removeWhere((preset) => preset.id == presetId);
      
      await _saveCustomPresets(customPresets);
      
      // Clear last used preset if it was deleted
      final lastUsedId = await getLastUsedPresetId();
      if (lastUsedId == presetId) {
        await clearLastUsedPreset();
      }
      
      Logger.info('Deleted filter preset: $presetId');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete preset', e, stackTrace);
      rethrow;
    }
  }

  /// Get a specific preset by ID
  Future<FilterPreset?> getPreset(String presetId) async {
    try {
      final allPresets = await getAllPresets();
      return allPresets.firstWhere(
        (preset) => preset.id == presetId,
        orElse: () => throw StateError('Preset not found: $presetId'),
      );
    } catch (e) {
      Logger.warning('Preset not found: $presetId');
      return null;
    }
  }

  /// Check if a preset name already exists
  Future<bool> presetNameExists(String name, {String? excludeId}) async {
    try {
      final allPresets = await getAllPresets();
      return allPresets.any((preset) => 
          preset.name.toLowerCase() == name.toLowerCase() && 
          preset.id != excludeId);
    } catch (e) {
      Logger.error('Failed to check preset name existence', e);
      return false;
    }
  }

  /// Find presets that match current filters
  Future<List<FilterPreset>> findMatchingPresets(StorageFilters filters) async {
    try {
      final allPresets = await getAllPresets();
      return allPresets.where((preset) => preset.matchesFilters(filters)).toList();
    } catch (e) {
      Logger.error('Failed to find matching presets', e);
      return [];
    }
  }

  /// Save the last used preset ID
  Future<void> saveLastUsedPreset(String presetId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastUsedPresetKey, presetId);
      Logger.info('Saved last used preset: $presetId');
    } catch (e) {
      Logger.error('Failed to save last used preset', e);
    }
  }

  /// Get the last used preset ID
  Future<String?> getLastUsedPresetId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastUsedPresetKey);
    } catch (e) {
      Logger.error('Failed to get last used preset', e);
      return null;
    }
  }

  /// Clear the last used preset
  Future<void> clearLastUsedPreset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastUsedPresetKey);
      Logger.info('Cleared last used preset');
    } catch (e) {
      Logger.error('Failed to clear last used preset', e);
    }
  }

  /// Export presets to JSON string
  Future<String> exportPresets() async {
    try {
      final customPresets = await getCustomPresets();
      final exportData = {
        'version': '1.0',
        'exportedAt': DateTime.now().toIso8601String(),
        'presets': customPresets.map((preset) => preset.toJson()).toList(),
      };
      
      final jsonString = jsonEncode(exportData);
      Logger.info('Exported ${customPresets.length} filter presets');
      return jsonString;
    } catch (e, stackTrace) {
      Logger.error('Failed to export presets', e, stackTrace);
      rethrow;
    }
  }

  /// Import presets from JSON string
  Future<List<FilterPreset>> importPresets(String jsonString, {bool overwrite = false}) async {
    try {
      final importData = jsonDecode(jsonString) as Map<String, dynamic>;
      final presetsData = importData['presets'] as List<dynamic>;
      
      final importedPresets = presetsData
          .map((json) => FilterPreset.fromJson(json as Map<String, dynamic>))
          .toList();
      
      final customPresets = await getCustomPresets();
      final newPresets = <FilterPreset>[];
      
      for (final importedPreset in importedPresets) {
        // Check if preset already exists
        final existingIndex = customPresets.indexWhere((p) => p.id == importedPreset.id);
        
        if (existingIndex != -1) {
          if (overwrite) {
            customPresets[existingIndex] = importedPreset;
            newPresets.add(importedPreset);
          }
        } else {
          // Generate new ID if name conflicts
          var preset = importedPreset;
          var counter = 1;
          
          while (await presetNameExists(preset.name, excludeId: preset.id)) {
            preset = preset.copyWith(name: '${importedPreset.name} ($counter)');
            counter++;
          }
          
          customPresets.add(preset);
          newPresets.add(preset);
        }
      }
      
      await _saveCustomPresets(customPresets);
      
      Logger.info('Imported ${newPresets.length} filter presets');
      return newPresets;
    } catch (e, stackTrace) {
      Logger.error('Failed to import presets', e, stackTrace);
      rethrow;
    }
  }

  /// Clear all custom presets
  Future<void> clearAllCustomPresets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_presetsKey);
      await clearLastUsedPreset();
      
      Logger.info('Cleared all custom filter presets');
    } catch (e, stackTrace) {
      Logger.error('Failed to clear all custom presets', e, stackTrace);
      rethrow;
    }
  }

  /// Get preset usage statistics
  Future<Map<String, dynamic>> getUsageStatistics() async {
    try {
      final allPresets = await getAllPresets();
      final customPresets = await getCustomPresets();
      final lastUsedId = await getLastUsedPresetId();
      
      return {
        'totalPresets': allPresets.length,
        'customPresets': customPresets.length,
        'defaultPresets': DefaultFilterPresets.getDefaults().length,
        'lastUsedPreset': lastUsedId,
        'oldestCustomPreset': customPresets.isEmpty 
            ? null 
            : customPresets.map((p) => p.createdAt).reduce((a, b) => a.isBefore(b) ? a : b),
        'newestCustomPreset': customPresets.isEmpty 
            ? null 
            : customPresets.map((p) => p.createdAt).reduce((a, b) => a.isAfter(b) ? a : b),
      };
    } catch (e) {
      Logger.error('Failed to get usage statistics', e);
      return {};
    }
  }

  /// Save custom presets to storage
  Future<void> _saveCustomPresets(List<FilterPreset> presets) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final presetsJson = jsonEncode(presets.map((preset) => preset.toJson()).toList());
      await prefs.setString(_presetsKey, presetsJson);
    } catch (e, stackTrace) {
      Logger.error('Failed to save custom presets', e, stackTrace);
      rethrow;
    }
  }
}