import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import '../models/storage_models.dart';
import '../utils/storage_utils.dart';
import '../constants/storage_constants.dart';
import '../../../shared/utils/logger.dart';

/// Comprehensive file utilities for storage operations
class FileUtilities {
  /// Generate file hash for duplicate detection
  static String generateFileHash(Uint8List fileBytes) {
    try {
      final digest = sha256.convert(fileBytes);
      return digest.toString();
    } catch (e) {
      Logger.error('Failed to generate file hash', e);
      return '';
    }
  }

  /// Generate unique filename with timestamp
  static String generateUniqueFileName(String originalName) {
    try {
      final extension = StorageUtils.getFileExtension(originalName);
      final nameWithoutExt = path.basenameWithoutExtension(originalName);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      return extension.isEmpty 
          ? '${nameWithoutExt}_$timestamp'
          : '${nameWithoutExt}_$timestamp.$extension';
    } catch (e) {
      Logger.error('Failed to generate unique filename for $originalName', e);
      return 'file_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Validate file integrity using checksum
  static bool validateFileIntegrity(Uint8List fileBytes, String expectedHash) {
    try {
      final actualHash = generateFileHash(fileBytes);
      return actualHash == expectedHash;
    } catch (e) {
      Logger.error('Failed to validate file integrity', e);
      return false;
    }
  }

  /// Extract metadata from file bytes
  static Map<String, dynamic> extractFileMetadata(
    String fileName,
    Uint8List fileBytes,
  ) {
    try {
      final metadata = <String, dynamic>{
        'fileName': fileName,
        'fileSize': fileBytes.length,
        'formattedSize': StorageUtils.formatFileSize(fileBytes.length),
        'mimeType': StorageUtils.getMimeType(fileName),
        'fileType': StorageUtils.getFileType(fileName).name,
        'extension': StorageUtils.getFileExtension(fileName),
        'hash': generateFileHash(fileBytes),
        'extractedAt': DateTime.now().toIso8601String(),
      };

      // Add file-type specific metadata
      final fileType = StorageUtils.getFileType(fileName);
      switch (fileType) {
        case StorageFileType.image:
          metadata.addAll(_extractImageMetadata(fileBytes));
          break;
        case StorageFileType.document:
          metadata.addAll(_extractDocumentMetadata(fileName, fileBytes));
          break;
        default:
          break;
      }

      return metadata;
    } catch (e) {
      Logger.error('Failed to extract metadata for $fileName', e);
      return {
        'fileName': fileName,
        'fileSize': fileBytes.length,
        'error': 'Failed to extract metadata',
      };
    }
  }

  /// Extract image-specific metadata
  static Map<String, dynamic> _extractImageMetadata(Uint8List imageBytes) {
    final metadata = <String, dynamic>{};
    
    try {
      // Basic image validation
      if (imageBytes.length < 10) {
        metadata['error'] = 'Invalid image data';
        return metadata;
      }

      // Check image format by magic numbers
      final signature = imageBytes.take(8).toList();
      
      if (signature.length >= 2 && signature[0] == 0xFF && signature[1] == 0xD8) {
        metadata['format'] = 'JPEG';
        metadata['quality'] = 'Unknown'; // Would need JPEG parsing
      } else if (signature.length >= 8 && 
                 signature[0] == 0x89 && signature[1] == 0x50 && 
                 signature[2] == 0x4E && signature[3] == 0x47) {
        metadata['format'] = 'PNG';
        metadata['hasTransparency'] = true; // PNG supports transparency
      } else if (signature.length >= 6 && 
                 signature[0] == 0x47 && signature[1] == 0x49 && signature[2] == 0x46) {
        metadata['format'] = 'GIF';
        metadata['animated'] = 'Unknown'; // Would need GIF parsing
      } else {
        metadata['format'] = 'Unknown';
      }

      // Note: For full image metadata extraction (dimensions, EXIF, etc.),
      // you would need a proper image processing library like image package
      metadata['note'] = 'Full image analysis requires additional dependencies';
      
    } catch (e) {
      Logger.warning('Failed to extract image metadata', e);
      metadata['error'] = 'Image metadata extraction failed';
    }
    
    return metadata;
  }

  /// Extract document-specific metadata
  static Map<String, dynamic> _extractDocumentMetadata(
    String fileName,
    Uint8List documentBytes,
  ) {
    final metadata = <String, dynamic>{};
    
    try {
      final extension = StorageUtils.getFileExtension(fileName).toLowerCase();
      
      switch (extension) {
        case 'pdf':
          metadata.addAll(_extractPdfMetadata(documentBytes));
          break;
        case 'txt':
          metadata.addAll(_extractTextMetadata(documentBytes));
          break;
        default:
          metadata['documentType'] = extension.toUpperCase();
          break;
      }
    } catch (e) {
      Logger.warning('Failed to extract document metadata for $fileName', e);
      metadata['error'] = 'Document metadata extraction failed';
    }
    
    return metadata;
  }

  /// Extract PDF metadata (basic)
  static Map<String, dynamic> _extractPdfMetadata(Uint8List pdfBytes) {
    final metadata = <String, dynamic>{'documentType': 'PDF'};
    
    try {
      // Check PDF signature
      if (pdfBytes.length >= 4 && 
          pdfBytes[0] == 0x25 && pdfBytes[1] == 0x50 && 
          pdfBytes[2] == 0x44 && pdfBytes[3] == 0x46) {
        metadata['validPdf'] = true;
        
        // Try to extract PDF version
        final headerString = String.fromCharCodes(pdfBytes.take(20));
        final versionMatch = RegExp(r'%PDF-(\d+\.\d+)').firstMatch(headerString);
        if (versionMatch != null) {
          metadata['pdfVersion'] = versionMatch.group(1);
        }
      } else {
        metadata['validPdf'] = false;
        metadata['error'] = 'Invalid PDF signature';
      }
    } catch (e) {
      Logger.warning('Failed to extract PDF metadata', e);
      metadata['error'] = 'PDF analysis failed';
    }
    
    return metadata;
  }

  /// Extract text file metadata
  static Map<String, dynamic> _extractTextMetadata(Uint8List textBytes) {
    final metadata = <String, dynamic>{'documentType': 'Text'};
    
    try {
      final textContent = utf8.decode(textBytes, allowMalformed: true);
      
      metadata['characterCount'] = textContent.length;
      metadata['lineCount'] = textContent.split('\n').length;
      metadata['wordCount'] = textContent.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
      
      // Detect encoding
      try {
        utf8.decode(textBytes);
        metadata['encoding'] = 'UTF-8';
      } catch (e) {
        metadata['encoding'] = 'Unknown/Binary';
      }
      
    } catch (e) {
      Logger.warning('Failed to extract text metadata', e);
      metadata['error'] = 'Text analysis failed';
    }
    
    return metadata;
  }

  /// Generate thumbnail placeholder data
  static Uint8List generateThumbnailPlaceholder(StorageFileType fileType) {
    try {
      // This would generate a simple placeholder image
      // For now, return empty bytes (would need image generation library)
      return Uint8List(0);
    } catch (e) {
      Logger.error('Failed to generate thumbnail placeholder', e);
      return Uint8List(0);
    }
  }

  /// Compress file if needed
  static Future<Uint8List> compressFileIfNeeded(
    String fileName,
    Uint8List fileBytes, {
    int? maxSize,
  }) async {
    try {
      final currentSize = fileBytes.length;
      final targetSize = maxSize ?? StorageUtils.getMaxFileSize(fileName);
      
      if (currentSize <= targetSize) {
        return fileBytes; // No compression needed
      }
      
      final fileType = StorageUtils.getFileType(fileName);
      
      switch (fileType) {
        case StorageFileType.image:
          return await _compressImage(fileBytes, targetSize);
        case StorageFileType.document:
          return await _compressDocument(fileBytes, targetSize);
        default:
          Logger.warning('Compression not supported for file type: ${fileType.name}');
          return fileBytes;
      }
    } catch (e) {
      Logger.error('Failed to compress file $fileName', e);
      return fileBytes;
    }
  }

  /// Compress image (placeholder implementation)
  static Future<Uint8List> _compressImage(Uint8List imageBytes, int targetSize) async {
    try {
      // This would use an image compression library
      // For now, return original bytes
      Logger.info('Image compression would be implemented here');
      return imageBytes;
    } catch (e) {
      Logger.error('Failed to compress image', e);
      return imageBytes;
    }
  }

  /// Compress document (placeholder implementation)
  static Future<Uint8List> _compressDocument(Uint8List documentBytes, int targetSize) async {
    try {
      // This would use document compression techniques
      // For now, return original bytes
      Logger.info('Document compression would be implemented here');
      return documentBytes;
    } catch (e) {
      Logger.error('Failed to compress document', e);
      return documentBytes;
    }
  }

  /// Batch validate files
  static Map<String, List<String>> batchValidateFiles(
    Map<String, Uint8List> files, {
    String? bucketId,
  }) {
    final results = <String, List<String>>{};
    
    try {
      for (final entry in files.entries) {
        final fileName = entry.key;
        final fileBytes = entry.value;
        
        final errors = <String>[];
        
        // Validate file name
        if (!StorageUtils.isValidFileName(fileName)) {
          errors.add('Invalid file name');
        }
        
        // Validate file size
        if (!StorageUtils.isFileSizeValid(fileName, fileBytes.length)) {
          final maxSize = StorageUtils.getMaxFileSize(fileName);
          errors.add('File size exceeds limit of ${StorageUtils.formatFileSize(maxSize)}');
        }
        
        // Validate file content
        if (!_validateFileContent(fileName, fileBytes)) {
          errors.add('File content does not match extension');
        }
        
        results[fileName] = errors;
      }
    } catch (e) {
      Logger.error('Failed to batch validate files', e);
    }
    
    return results;
  }

  /// Validate file content matches extension
  static bool _validateFileContent(String fileName, Uint8List fileBytes) {
    try {
      if (fileBytes.isEmpty) return false;
      
      final extension = StorageUtils.getFileExtension(fileName).toLowerCase();
      final signature = fileBytes.take(8).toList();
      
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          return signature.length >= 2 && signature[0] == 0xFF && signature[1] == 0xD8;
        
        case 'png':
          return signature.length >= 8 && 
                 signature[0] == 0x89 && signature[1] == 0x50 && 
                 signature[2] == 0x4E && signature[3] == 0x47;
        
        case 'gif':
          return signature.length >= 6 && 
                 signature[0] == 0x47 && signature[1] == 0x49 && signature[2] == 0x46;
        
        case 'pdf':
          return signature.length >= 4 && 
                 signature[0] == 0x25 && signature[1] == 0x50 && 
                 signature[2] == 0x44 && signature[3] == 0x46;
        
        case 'zip':
          return signature.length >= 4 && 
                 signature[0] == 0x50 && signature[1] == 0x4B;
        
        default:
          // For other file types, assume valid
          return true;
      }
    } catch (e) {
      Logger.warning('Failed to validate file content for $fileName', e);
      return false;
    }
  }

  /// Generate file preview data
  static Map<String, dynamic> generateFilePreview(
    String fileName,
    Uint8List fileBytes,
  ) {
    try {
      final fileType = StorageUtils.getFileType(fileName);
      final preview = <String, dynamic>{
        'fileName': fileName,
        'fileType': fileType.name,
        'size': fileBytes.length,
        'formattedSize': StorageUtils.formatFileSize(fileBytes.length),
      };
      
      switch (fileType) {
        case StorageFileType.image:
          preview['previewType'] = 'image';
          preview['canPreview'] = true;
          break;
        
        case StorageFileType.document:
          preview['previewType'] = 'document';
          preview['canPreview'] = StorageUtils.getFileExtension(fileName) == 'txt';
          if (preview['canPreview']) {
            try {
              final content = utf8.decode(fileBytes.take(500).toList(), allowMalformed: true);
              preview['textPreview'] = content;
            } catch (e) {
              preview['canPreview'] = false;
            }
          }
          break;
        
        default:
          preview['previewType'] = 'generic';
          preview['canPreview'] = false;
          break;
      }
      
      return preview;
    } catch (e) {
      Logger.error('Failed to generate file preview for $fileName', e);
      return {
        'fileName': fileName,
        'error': 'Preview generation failed',
        'canPreview': false,
      };
    }
  }

  /// Clean up temporary files
  static Future<void> cleanupTempFiles(List<String> tempFilePaths) async {
    try {
      int cleanedCount = 0;
      
      for (final filePath in tempFilePaths) {
        try {
          final file = File(filePath);
          if (await file.exists()) {
            await file.delete();
            cleanedCount++;
          }
        } catch (e) {
          Logger.warning('Failed to delete temp file: $filePath', e);
        }
      }
      
      Logger.info('Cleaned up $cleanedCount temporary files');
    } catch (e) {
      Logger.error('Failed to cleanup temporary files', e);
    }
  }

  /// Convert file size to different units
  static Map<String, double> convertFileSize(int bytes) {
    return {
      'bytes': bytes.toDouble(),
      'kb': bytes / 1024,
      'mb': bytes / (1024 * 1024),
      'gb': bytes / (1024 * 1024 * 1024),
    };
  }

  /// Get file age in different units
  static Map<String, int> getFileAge(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    return {
      'seconds': difference.inSeconds,
      'minutes': difference.inMinutes,
      'hours': difference.inHours,
      'days': difference.inDays,
    };
  }

  /// Check if file is recently modified
  static bool isRecentlyModified(DateTime modifiedAt, {Duration threshold = const Duration(hours: 24)}) {
    final now = DateTime.now();
    final difference = now.difference(modifiedAt);
    return difference <= threshold;
  }

  /// Generate file operation summary
  static Map<String, dynamic> generateOperationSummary(
    String operation,
    List<String> fileNames,
    List<bool> results,
  ) {
    try {
      final successful = results.where((r) => r).length;
      final failed = results.length - successful;
      
      return {
        'operation': operation,
        'totalFiles': fileNames.length,
        'successful': successful,
        'failed': failed,
        'successRate': fileNames.isNotEmpty ? (successful / fileNames.length * 100) : 0,
        'timestamp': DateTime.now().toIso8601String(),
        'files': fileNames.asMap().entries.map((entry) => {
          'fileName': entry.value,
          'success': results[entry.key],
        }).toList(),
      };
    } catch (e) {
      Logger.error('Failed to generate operation summary', e);
      return {
        'operation': operation,
        'error': 'Summary generation failed',
      };
    }
  }
}