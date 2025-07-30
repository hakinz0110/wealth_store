import 'package:flutter/material.dart';
import '../models/storage_models.dart';
import '../interfaces/storage_interfaces.dart';
import '../../../shared/utils/logger.dart';

/// Service for searching and filtering storage files
class StorageSearchService {
  final IStorageRepository _repository;

  StorageSearchService({
    required IStorageRepository repository,
  }) : _repository = repository;

  /// Search files with filters
  Future<List<StorageFile>> searchFiles(StorageFilters filters) async {
    try {
      Logger.info('Searching files with filters: ${filters.toString()}');
      
      List<StorageFile> allFiles = [];
      
      if (filters.bucketId != null) {
        // Search in specific bucket
        allFiles = await _repository.getFiles(filters.bucketId!);
      } else {
        // Search across all buckets
        final buckets = await _repository.getBuckets();
        for (final bucket in buckets) {
          try {
            final bucketFiles = await _repository.getFiles(bucket.id);
            allFiles.addAll(bucketFiles);
          } catch (e) {
            Logger.warning('Failed to get files from bucket ${bucket.id}: $e');
            // Continue with other buckets
          }
        }
      }
      
      // Apply filters
      final filteredFiles = _applyFilters(allFiles, filters);
      
      Logger.info('Search completed with ${filteredFiles.length} results');
      return filteredFiles;
    } catch (e, stackTrace) {
      Logger.error('Failed to search files', e, stackTrace);
      rethrow;
    }
  }

  /// Search files across all buckets, grouped by bucket
  Future<Map<String, List<StorageFile>>> searchFilesAcrossBuckets(StorageFilters filters) async {
    try {
      Logger.info('Searching files across all buckets');
      
      final results = <String, List<StorageFile>>{};
      final buckets = await _repository.getBuckets();
      
      for (final bucket in buckets) {
        try {
          final bucketFiles = await _repository.getFiles(bucket.id);
          final filteredFiles = _applyFilters(bucketFiles, filters);
          
          if (filteredFiles.isNotEmpty) {
            results[bucket.id] = filteredFiles;
          }
        } catch (e) {
          Logger.warning('Failed to search in bucket ${bucket.id}: $e');
          // Continue with other buckets
        }
      }
      
      Logger.info('Global search completed with results from ${results.keys.length} buckets');
      return results;
    } catch (e, stackTrace) {
      Logger.error('Failed to search files across buckets', e, stackTrace);
      rethrow;
    }
  }

  /// Search files in a specific bucket and path
  Future<List<StorageFile>> searchFilesInPath(
    String bucketId,
    String path,
    StorageFilters filters,
  ) async {
    try {
      Logger.info('Searching files in bucket: $bucketId, path: $path');
      
      final allFiles = await _repository.getFiles(bucketId, path: path);
      final filteredFiles = _applyFilters(allFiles, filters);
      
      Logger.info('Path search completed with ${filteredFiles.length} results');
      return filteredFiles;
    } catch (e, stackTrace) {
      Logger.error('Failed to search files in path', e, stackTrace);
      rethrow;
    }
  }

  /// Apply filters to a list of files
  List<StorageFile> _applyFilters(List<StorageFile> files, StorageFilters filters) {
    var filteredFiles = files;

    // Apply search query filter
    if (filters.searchQuery?.isNotEmpty == true) {
      filteredFiles = _applySearchQuery(filteredFiles, filters.searchQuery!);
    }

    // Apply file type filter
    if (filters.fileType != null) {
      filteredFiles = _applyFileTypeFilter(filteredFiles, filters.fileType!);
    }

    // Apply date range filters
    if (filters.uploadedAfter != null) {
      filteredFiles = filteredFiles.where((file) {
        return file.createdAt.isAfter(filters.uploadedAfter!) ||
               file.createdAt.isAtSameMomentAs(filters.uploadedAfter!);
      }).toList();
    }

    if (filters.uploadedBefore != null) {
      filteredFiles = filteredFiles.where((file) {
        return file.createdAt.isBefore(filters.uploadedBefore!) ||
               file.createdAt.isAtSameMomentAs(filters.uploadedBefore!);
      }).toList();
    }

    // Apply size range filters
    if (filters.minSize != null) {
      filteredFiles = filteredFiles.where((file) {
        return file.size >= filters.minSize!;
      }).toList();
    }

    if (filters.maxSize != null) {
      filteredFiles = filteredFiles.where((file) {
        return file.size <= filters.maxSize!;
      }).toList();
    }

    return filteredFiles;
  }

  /// Apply search query to files (filename-based search)
  List<StorageFile> _applySearchQuery(List<StorageFile> files, String query) {
    final lowercaseQuery = query.toLowerCase();
    
    return files.where((file) {
      // Search in filename
      final fileName = file.name.toLowerCase();
      if (fileName.contains(lowercaseQuery)) {
        return true;
      }
      
      // Search in file path
      final filePath = file.path.toLowerCase();
      if (filePath.contains(lowercaseQuery)) {
        return true;
      }
      
      // Search in file extension
      final fileExtension = file.extension.toLowerCase();
      if (fileExtension.contains(lowercaseQuery)) {
        return true;
      }
      
      // Search in MIME type
      if (file.mimeType != null) {
        final mimeType = file.mimeType!.toLowerCase();
        if (mimeType.contains(lowercaseQuery)) {
          return true;
        }
      }
      
      return false;
    }).toList();
  }

  /// Apply file type filter
  List<StorageFile> _applyFileTypeFilter(List<StorageFile> files, StorageFileType fileType) {
    return files.where((file) => file.fileType == fileType).toList();
  }

  /// Get search suggestions based on existing files
  Future<List<String>> getSearchSuggestions(String query, {String? bucketId}) async {
    try {
      if (query.length < 2) return [];
      
      Logger.info('Getting search suggestions for query: "$query"');
      
      List<StorageFile> allFiles = [];
      
      if (bucketId != null) {
        allFiles = await _repository.getFiles(bucketId);
      } else {
        final buckets = await _repository.getBuckets();
        for (final bucket in buckets) {
          try {
            final bucketFiles = await _repository.getFiles(bucket.id);
            allFiles.addAll(bucketFiles);
          } catch (e) {
            Logger.warning('Failed to get files from bucket ${bucket.id} for suggestions: $e');
          }
        }
      }
      
      final suggestions = <String>{};
      final lowercaseQuery = query.toLowerCase();
      
      for (final file in allFiles) {
        final fileName = file.name.toLowerCase();
        
        // Add filename suggestions
        if (fileName.contains(lowercaseQuery)) {
          suggestions.add(file.name);
        }
        
        // Add extension suggestions
        if (file.extension.isNotEmpty && file.extension.toLowerCase().contains(lowercaseQuery)) {
          suggestions.add('.${file.extension}');
        }
        
        // Add MIME type suggestions
        if (file.mimeType != null && file.mimeType!.toLowerCase().contains(lowercaseQuery)) {
          final mimeTypeParts = file.mimeType!.split('/');
          if (mimeTypeParts.isNotEmpty) {
            suggestions.add(mimeTypeParts.first);
          }
        }
      }
      
      final sortedSuggestions = suggestions.toList()
        ..sort((a, b) {
          // Prioritize exact matches
          final aStartsWith = a.toLowerCase().startsWith(lowercaseQuery);
          final bStartsWith = b.toLowerCase().startsWith(lowercaseQuery);
          
          if (aStartsWith && !bStartsWith) return -1;
          if (!aStartsWith && bStartsWith) return 1;
          
          // Then sort alphabetically
          return a.compareTo(b);
        });
      
      // Limit to 10 suggestions
      final limitedSuggestions = sortedSuggestions.take(10).toList();
      
      Logger.info('Generated ${limitedSuggestions.length} search suggestions');
      return limitedSuggestions;
    } catch (e, stackTrace) {
      Logger.error('Failed to get search suggestions', e, stackTrace);
      return [];
    }
  }

  /// Highlight search terms in text
  List<TextSpan> highlightSearchTerms(String text, String query) {
    if (query.isEmpty) {
      return [TextSpan(text: text)];
    }
    
    final spans = <TextSpan>[];
    final lowercaseText = text.toLowerCase();
    final lowercaseQuery = query.toLowerCase();
    
    int currentIndex = 0;
    
    while (currentIndex < text.length) {
      final matchIndex = lowercaseText.indexOf(lowercaseQuery, currentIndex);
      
      if (matchIndex == -1) {
        // No more matches, add remaining text
        if (currentIndex < text.length) {
          spans.add(TextSpan(text: text.substring(currentIndex)));
        }
        break;
      }
      
      // Add text before match
      if (matchIndex > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, matchIndex)));
      }
      
      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(matchIndex, matchIndex + query.length),
        style: const TextStyle(
          backgroundColor: Colors.yellow,
          fontWeight: FontWeight.bold,
        ),
      ));
      
      currentIndex = matchIndex + query.length;
    }
    
    return spans;
  }

  /// Get file count by type for current search results
  Future<Map<StorageFileType, int>> getFileTypeBreakdown(StorageFilters filters) async {
    try {
      final files = await searchFiles(filters);
      final breakdown = <StorageFileType, int>{};
      
      for (final file in files) {
        breakdown[file.fileType] = (breakdown[file.fileType] ?? 0) + 1;
      }
      
      return breakdown;
    } catch (e, stackTrace) {
      Logger.error('Failed to get file type breakdown', e, stackTrace);
      return {};
    }
  }

  /// Get size statistics for current search results
  Future<Map<String, dynamic>> getSizeStatistics(StorageFilters filters) async {
    try {
      final files = await searchFiles(filters);
      
      if (files.isEmpty) {
        return {
          'totalSize': 0,
          'averageSize': 0,
          'minSize': 0,
          'maxSize': 0,
          'fileCount': 0,
        };
      }
      
      final sizes = files.map((f) => f.size).toList()..sort();
      final totalSize = sizes.fold<int>(0, (sum, size) => sum + size);
      
      return {
        'totalSize': totalSize,
        'averageSize': (totalSize / files.length).round(),
        'minSize': sizes.first,
        'maxSize': sizes.last,
        'fileCount': files.length,
      };
    } catch (e, stackTrace) {
      Logger.error('Failed to get size statistics', e, stackTrace);
      return {};
    }
  }
}