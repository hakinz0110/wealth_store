import 'storage_models.dart';

/// Represents a saved filter preset
class FilterPreset {
  final String id;
  final String name;
  final String? description;
  final StorageFilters filters;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDefault;

  const FilterPreset({
    required this.id,
    required this.name,
    this.description,
    required this.filters,
    required this.createdAt,
    required this.updatedAt,
    this.isDefault = false,
  });

  FilterPreset copyWith({
    String? id,
    String? name,
    String? description,
    StorageFilters? filters,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDefault,
  }) {
    return FilterPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      filters: filters ?? this.filters,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'filters': _filtersToJson(filters),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDefault': isDefault,
    };
  }

  /// Create from JSON
  factory FilterPreset.fromJson(Map<String, dynamic> json) {
    return FilterPreset(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      filters: _filtersFromJson(json['filters'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  /// Convert filters to JSON
  static Map<String, dynamic> _filtersToJson(StorageFilters filters) {
    return {
      'searchQuery': filters.searchQuery,
      'fileType': filters.fileType?.name,
      'uploadedAfter': filters.uploadedAfter?.toIso8601String(),
      'uploadedBefore': filters.uploadedBefore?.toIso8601String(),
      'minSize': filters.minSize,
      'maxSize': filters.maxSize,
      'bucketId': filters.bucketId,
    };
  }

  /// Create filters from JSON
  static StorageFilters _filtersFromJson(Map<String, dynamic> json) {
    return StorageFilters(
      searchQuery: json['searchQuery'] as String?,
      fileType: json['fileType'] != null
          ? StorageFileType.values.firstWhere(
              (type) => type.name == json['fileType'],
              orElse: () => StorageFileType.other,
            )
          : null,
      uploadedAfter: json['uploadedAfter'] != null
          ? DateTime.parse(json['uploadedAfter'] as String)
          : null,
      uploadedBefore: json['uploadedBefore'] != null
          ? DateTime.parse(json['uploadedBefore'] as String)
          : null,
      minSize: json['minSize'] as int?,
      maxSize: json['maxSize'] as int?,
      bucketId: json['bucketId'] as String?,
    );
  }

  /// Get a summary of the filters
  String get filterSummary {
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
    
    if (filters.bucketId != null) {
      parts.add('Bucket: ${filters.bucketId}');
    }
    
    return parts.isEmpty ? 'No filters' : parts.join(', ');
  }

  /// Check if this preset matches current filters
  bool matchesFilters(StorageFilters currentFilters) {
    return filters.searchQuery == currentFilters.searchQuery &&
           filters.fileType == currentFilters.fileType &&
           filters.uploadedAfter == currentFilters.uploadedAfter &&
           filters.uploadedBefore == currentFilters.uploadedBefore &&
           filters.minSize == currentFilters.minSize &&
           filters.maxSize == currentFilters.maxSize &&
           filters.bucketId == currentFilters.bucketId;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterPreset &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'FilterPreset(id: $id, name: $name, filters: $filterSummary)';
}

/// Default filter presets
class DefaultFilterPresets {
  static const String _idPrefix = 'default_';

  /// Get all default presets
  static List<FilterPreset> getDefaults() {
    final now = DateTime.now();
    
    return [
      // Images only
      FilterPreset(
        id: '${_idPrefix}images',
        name: 'Images Only',
        description: 'Show only image files',
        filters: const StorageFilters(fileType: StorageFileType.image),
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      
      // Videos only
      FilterPreset(
        id: '${_idPrefix}videos',
        name: 'Videos Only',
        description: 'Show only video files',
        filters: const StorageFilters(fileType: StorageFileType.video),
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      
      // Documents only
      FilterPreset(
        id: '${_idPrefix}documents',
        name: 'Documents Only',
        description: 'Show only document files',
        filters: const StorageFilters(fileType: StorageFileType.document),
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      
      // Recent files (last 7 days)
      FilterPreset(
        id: '${_idPrefix}recent',
        name: 'Recent Files',
        description: 'Files uploaded in the last 7 days',
        filters: StorageFilters(
          uploadedAfter: now.subtract(const Duration(days: 7)),
        ),
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      
      // Large files (> 10MB)
      FilterPreset(
        id: '${_idPrefix}large',
        name: 'Large Files',
        description: 'Files larger than 10MB',
        filters: const StorageFilters(
          minSize: 10 * 1024 * 1024, // 10MB in bytes
        ),
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
      
      // Small files (< 1MB)
      FilterPreset(
        id: '${_idPrefix}small',
        name: 'Small Files',
        description: 'Files smaller than 1MB',
        filters: const StorageFilters(
          maxSize: 1024 * 1024, // 1MB in bytes
        ),
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      ),
    ];
  }

  /// Check if a preset ID is a default preset
  static bool isDefault(String id) {
    return id.startsWith(_idPrefix);
  }
}