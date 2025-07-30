import 'dart:html' as html;
import '../models/storage_models.dart';
import '../utils/storage_utils.dart';
import '../../../shared/utils/logger.dart';

/// URL management utilities for storage files
class StorageUrlManager {
  static const String _supabaseStoragePrefix = '/storage/v1/object/public/';
  
  /// Generate public URL for a file
  static String generatePublicUrl(
    String baseUrl,
    String bucketId,
    String filePath,
  ) {
    try {
      // Ensure base URL doesn't end with slash
      final cleanBaseUrl = baseUrl.endsWith('/') 
          ? baseUrl.substring(0, baseUrl.length - 1) 
          : baseUrl;
      
      // Ensure file path doesn't start with slash
      final cleanFilePath = filePath.startsWith('/') 
          ? filePath.substring(1) 
          : filePath;
      
      return '$cleanBaseUrl$_supabaseStoragePrefix$bucketId/$cleanFilePath';
    } catch (e) {
      Logger.error('Failed to generate public URL for $bucketId/$filePath', e);
      return '';
    }
  }

  /// Parse Supabase storage URL to extract components
  static Map<String, String?> parseStorageUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      // Supabase storage URL format: /storage/v1/object/public/{bucket}/{path}
      if (pathSegments.length >= 5 && 
          pathSegments[0] == 'storage' && 
          pathSegments[1] == 'v1' && 
          pathSegments[2] == 'object' && 
          pathSegments[3] == 'public') {
        
        final bucketId = pathSegments[4];
        final filePath = pathSegments.skip(5).join('/');
        final fileName = pathSegments.last;
        
        return {
          'baseUrl': '${uri.scheme}://${uri.host}${uri.port != 80 && uri.port != 443 ? ':${uri.port}' : ''}',
          'bucketId': bucketId,
          'filePath': filePath,
          'fileName': fileName,
        };
      }
      
      return {
        'error': 'Invalid Supabase storage URL format',
      };
    } catch (e) {
      Logger.error('Failed to parse storage URL: $url', e);
      return {
        'error': 'URL parsing failed: ${e.toString()}',
      };
    }
  }

  /// Generate signed URL with expiration
  static Future<String> generateSignedUrl(
    String bucketId,
    String filePath, {
    Duration expiration = const Duration(hours: 1),
    String? baseUrl,
  }) async {
    try {
      // For now, generate a public URL with expiration parameters
      // In a real implementation, this would use Supabase's signed URL API
      final publicUrl = generatePublicUrl(
        baseUrl ?? '', 
        bucketId, 
        filePath,
      );
      
      final expirationTimestamp = DateTime.now()
          .add(expiration)
          .millisecondsSinceEpoch;
      
      final signedUrl = generateCustomUrl(publicUrl, {
        'expires': expirationTimestamp.toString(),
        'signature': _generateUrlSignature(publicUrl, expirationTimestamp),
      });
      
      Logger.info('Generated signed URL for $bucketId/$filePath (expires in ${expiration.inHours}h)');
      return signedUrl;
    } catch (e) {
      Logger.error('Failed to generate signed URL for $bucketId/$filePath', e);
      return '';
    }
  }

  /// Generate URL signature (simplified implementation)
  static String _generateUrlSignature(String url, int expiration) {
    // In a real implementation, this would use proper cryptographic signing
    // For now, generate a simple hash-like signature
    final combined = '$url$expiration';
    return combined.hashCode.abs().toRadixString(16).padLeft(8, '0');
  }

  /// Copy URL to clipboard
  static Future<bool> copyUrlToClipboard(String url) async {
    try {
      await html.window.navigator.clipboard?.writeText(url);
      Logger.info('URL copied to clipboard: $url');
      return true;
    } catch (e) {
      Logger.error('Failed to copy URL to clipboard', e);
      
      // Fallback method for older browsers
      try {
        final textArea = html.TextAreaElement();
        textArea.value = url;
        html.document.body?.append(textArea);
        textArea.select();
        html.document.execCommand('copy');
        textArea.remove();
        Logger.info('URL copied to clipboard using fallback method');
        return true;
      } catch (fallbackError) {
        Logger.error('Fallback clipboard copy also failed', fallbackError);
        return false;
      }
    }
  }

  /// Generate download URL with proper headers
  static String generateDownloadUrl(
    String publicUrl,
    String fileName, {
    bool forceDownload = true,
  }) {
    try {
      final uri = Uri.parse(publicUrl);
      final queryParams = Map<String, String>.from(uri.queryParameters);
      
      if (forceDownload) {
        queryParams['download'] = fileName;
      }
      
      final newUri = uri.replace(queryParameters: queryParams);
      return newUri.toString();
    } catch (e) {
      Logger.error('Failed to generate download URL for $fileName', e);
      return publicUrl;
    }
  }

  /// Generate thumbnail URL (if supported by storage provider)
  static String? generateThumbnailUrl(
    String originalUrl, {
    int width = 200,
    int height = 200,
    String quality = 'auto',
  }) {
    try {
      // Check if the file is an image
      final fileName = StorageUtils.extractFileNameFromUrl(originalUrl);
      if (!StorageUtils.isImageFile(fileName)) {
        return null;
      }
      
      // For Supabase, thumbnail generation would depend on their image transformation service
      // For now, return the original URL for images
      Logger.debug('Thumbnail URL generation would be implemented here');
      return originalUrl;
    } catch (e) {
      Logger.error('Failed to generate thumbnail URL', e);
      return null;
    }
  }

  /// Check if a signed URL has expired
  static bool isUrlExpired(String url) {
    try {
      final uri = Uri.parse(url);
      final expiresParam = uri.queryParameters['expires'];
      
      if (expiresParam == null) {
        // No expiration parameter means it's a permanent URL
        return false;
      }
      
      final expirationTimestamp = int.tryParse(expiresParam);
      if (expirationTimestamp == null) {
        Logger.warning('Invalid expiration timestamp in URL: $url');
        return true; // Treat invalid expiration as expired
      }
      
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(expirationTimestamp);
      final isExpired = DateTime.now().isAfter(expirationDate);
      
      if (isExpired) {
        Logger.info('URL has expired: $url');
      }
      
      return isExpired;
    } catch (e) {
      Logger.error('Failed to check URL expiration: $url', e);
      return true; // Treat errors as expired for safety
    }
  }

  /// Get URL expiration date
  static DateTime? getUrlExpirationDate(String url) {
    try {
      final uri = Uri.parse(url);
      final expiresParam = uri.queryParameters['expires'];
      
      if (expiresParam == null) {
        return null; // No expiration
      }
      
      final expirationTimestamp = int.tryParse(expiresParam);
      if (expirationTimestamp == null) {
        return null;
      }
      
      return DateTime.fromMillisecondsSinceEpoch(expirationTimestamp);
    } catch (e) {
      Logger.error('Failed to get URL expiration date: $url', e);
      return null;
    }
  }

  /// Validate URL accessibility
  static Future<bool> validateUrlAccessibility(String url) async {
    try {
      // Check if URL is expired first
      if (isUrlExpired(url)) {
        Logger.info('URL is expired: $url');
        return false;
      }
      
      // This would make a HEAD request to check if the URL is accessible
      // For now, return true for valid URLs
      final uri = Uri.tryParse(url);
      return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      Logger.error('Failed to validate URL accessibility: $url', e);
      return false;
    }
  }

  /// Generate secure shareable URL with options
  static Future<Map<String, dynamic>> generateSecureShareableUrl(
    StorageFile file, {
    Duration? expiration,
    bool includeMetadata = true,
    bool requireAuthentication = false,
    List<String>? allowedDomains,
    int? maxDownloads,
    String? baseUrl,
  }) async {
    try {
      String shareUrl;
      
      if (expiration != null || requireAuthentication || maxDownloads != null) {
        // Generate signed URL for secure sharing
        shareUrl = await generateSignedUrl(
          file.bucketId,
          file.path,
          expiration: expiration ?? const Duration(hours: 24),
          baseUrl: baseUrl,
        );
        
        // Add additional security parameters
        final securityParams = <String, String>{};
        
        if (requireAuthentication) {
          securityParams['auth'] = 'required';
        }
        
        if (allowedDomains != null && allowedDomains.isNotEmpty) {
          securityParams['domains'] = allowedDomains.join(',');
        }
        
        if (maxDownloads != null) {
          securityParams['max_downloads'] = maxDownloads.toString();
        }
        
        if (securityParams.isNotEmpty) {
          shareUrl = generateCustomUrl(shareUrl, securityParams);
        }
      } else {
        // Use public URL for non-secure sharing
        shareUrl = file.publicUrl ?? '';
      }
      
      final shareData = <String, dynamic>{
        'url': shareUrl,
        'fileName': file.name,
        'fileSize': file.formattedSize,
        'fileType': file.fileType.displayName,
        'generatedAt': DateTime.now().toIso8601String(),
        'isSecure': expiration != null || requireAuthentication || maxDownloads != null,
      };
      
      if (expiration != null) {
        shareData['expiresAt'] = DateTime.now().add(expiration).toIso8601String();
        shareData['expiresIn'] = expiration.inHours > 0 
            ? '${expiration.inHours} hours'
            : '${expiration.inMinutes} minutes';
      }
      
      if (requireAuthentication) {
        shareData['requiresAuth'] = true;
      }
      
      if (maxDownloads != null) {
        shareData['maxDownloads'] = maxDownloads;
      }
      
      if (allowedDomains != null && allowedDomains.isNotEmpty) {
        shareData['allowedDomains'] = allowedDomains;
      }
      
      if (includeMetadata) {
        shareData['metadata'] = {
          'bucketId': file.bucketId,
          'path': file.path,
          'mimeType': file.mimeType,
          'createdAt': file.createdAt.toIso8601String(),
          'updatedAt': file.updatedAt.toIso8601String(),
        };
      }
      
      Logger.info('Generated secure shareable URL for ${file.name}');
      return shareData;
    } catch (e) {
      Logger.error('Failed to generate secure shareable URL for ${file.name}', e);
      return {
        'error': 'Failed to generate secure shareable URL',
        'fileName': file.name,
      };
    }
  }

  /// Generate shareable URL with metadata (legacy method)
  static Map<String, dynamic> generateShareableUrl(
    StorageFile file, {
    Duration? expiration,
    bool includeMetadata = true,
  }) {
    try {
      final shareData = <String, dynamic>{
        'url': file.publicUrl ?? '',
        'fileName': file.name,
        'fileSize': file.formattedSize,
        'fileType': file.fileType.displayName,
        'generatedAt': DateTime.now().toIso8601String(),
      };
      
      if (expiration != null) {
        shareData['expiresAt'] = DateTime.now().add(expiration).toIso8601String();
      }
      
      if (includeMetadata) {
        shareData['metadata'] = {
          'bucketId': file.bucketId,
          'path': file.path,
          'mimeType': file.mimeType,
          'createdAt': file.createdAt.toIso8601String(),
          'updatedAt': file.updatedAt.toIso8601String(),
        };
      }
      
      return shareData;
    } catch (e) {
      Logger.error('Failed to generate shareable URL for ${file.name}', e);
      return {
        'error': 'Failed to generate shareable URL',
        'fileName': file.name,
      };
    }
  }

  /// Generate QR code data for URL (placeholder)
  static String generateQrCodeData(String url) {
    try {
      // This would generate QR code data for the URL
      // For now, return the URL itself
      Logger.info('QR code generation would be implemented here');
      return url;
    } catch (e) {
      Logger.error('Failed to generate QR code data for URL', e);
      return '';
    }
  }

  /// Batch generate URLs for multiple files
  static Map<String, String> batchGenerateUrls(
    String baseUrl,
    String bucketId,
    List<String> filePaths,
  ) {
    final urls = <String, String>{};
    
    try {
      for (final filePath in filePaths) {
        final url = generatePublicUrl(baseUrl, bucketId, filePath);
        urls[filePath] = url;
      }
      
      Logger.info('Generated ${urls.length} URLs for batch operation');
    } catch (e) {
      Logger.error('Failed to batch generate URLs', e);
    }
    
    return urls;
  }

  /// Extract file information from URL
  static Map<String, dynamic> extractFileInfoFromUrl(String url) {
    try {
      final parsedUrl = parseStorageUrl(url);
      
      if (parsedUrl.containsKey('error')) {
        return parsedUrl;
      }
      
      final fileName = parsedUrl['fileName'] ?? '';
      final fileType = StorageUtils.getFileType(fileName);
      
      return {
        'bucketId': parsedUrl['bucketId'],
        'filePath': parsedUrl['filePath'],
        'fileName': fileName,
        'fileType': fileType.name,
        'extension': StorageUtils.getFileExtension(fileName),
        'mimeType': StorageUtils.getMimeType(fileName),
        'isImage': StorageUtils.isImageFile(fileName),
        'isVideo': StorageUtils.isVideoFile(fileName),
        'isDocument': StorageUtils.isDocumentFile(fileName),
      };
    } catch (e) {
      Logger.error('Failed to extract file info from URL: $url', e);
      return {
        'error': 'File info extraction failed',
      };
    }
  }

  /// Generate URL with custom parameters
  static String generateCustomUrl(
    String baseUrl,
    Map<String, String> parameters,
  ) {
    try {
      final uri = Uri.parse(baseUrl);
      final newUri = uri.replace(queryParameters: {
        ...uri.queryParameters,
        ...parameters,
      });
      
      return newUri.toString();
    } catch (e) {
      Logger.error('Failed to generate custom URL', e);
      return baseUrl;
    }
  }

  /// Check if URL is a storage URL
  static bool isStorageUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.path.contains(_supabaseStoragePrefix);
    } catch (e) {
      Logger.error('Failed to check if URL is storage URL', e);
      return false;
    }
  }

  /// Generate CDN URL (if CDN is configured)
  static String generateCdnUrl(String originalUrl, {String? cdnDomain}) {
    try {
      if (cdnDomain == null) return originalUrl;
      
      final uri = Uri.parse(originalUrl);
      final newUri = uri.replace(host: cdnDomain);
      
      Logger.debug('Generated CDN URL: ${newUri.toString()}');
      return newUri.toString();
    } catch (e) {
      Logger.error('Failed to generate CDN URL', e);
      return originalUrl;
    }
  }

  /// Generate URL with cache busting parameter
  static String generateCacheBustedUrl(String originalUrl) {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return generateCustomUrl(originalUrl, {'v': timestamp.toString()});
    } catch (e) {
      Logger.error('Failed to generate cache busted URL', e);
      return originalUrl;
    }
  }

  /// Validate URL format
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.tryParse(url);
      return uri != null && 
             uri.hasScheme && 
             (uri.scheme == 'http' || uri.scheme == 'https') &&
             uri.hasAuthority;
    } catch (e) {
      Logger.error('Failed to validate URL format: $url', e);
      return false;
    }
  }

  /// Get URL domain
  static String? getUrlDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      Logger.error('Failed to get URL domain: $url', e);
      return null;
    }
  }

  /// Generate URL analytics data
  static Map<String, dynamic> generateUrlAnalytics(String url) {
    try {
      final uri = Uri.parse(url);
      final fileInfo = extractFileInfoFromUrl(url);
      
      return {
        'url': url,
        'domain': uri.host,
        'scheme': uri.scheme,
        'path': uri.path,
        'queryParameters': uri.queryParameters,
        'fileInfo': fileInfo,
        'isSecure': uri.scheme == 'https',
        'analyzedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      Logger.error('Failed to generate URL analytics', e);
      return {
        'error': 'URL analytics generation failed',
        'url': url,
      };
    }
  }
}