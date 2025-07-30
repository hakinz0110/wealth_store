import '../../../services/supabase_service.dart';
import '../../../shared/utils/logger.dart';

/// Debug utility to test storage connection and list buckets
class StorageDebugger {
  /// Test the storage connection and list all available buckets
  static Future<Map<String, dynamic>> debugStorageConnection() async {
    final result = <String, dynamic>{
      'success': false,
      'buckets': <Map<String, dynamic>>[],
      'errors': <String>[],
      'totalFiles': 0,
      'authInfo': <String, dynamic>{},
    };

    try {
      Logger.info('Starting storage connection debug...');
      
      // Check authentication first
      final client = SupabaseService.client;
      final user = client.auth.currentUser;
      
      result['authInfo'] = {
        'isAuthenticated': user != null,
        'userId': user?.id,
        'email': user?.email,
        'role': user?.userMetadata?['role'],
        'appMetadata': user?.appMetadata,
        'userMetadata': user?.userMetadata,
      };
      
      Logger.info('Auth info: ${result['authInfo']}');
      
      // Test basic connection
      final storage = SupabaseService.storage;
      Logger.info('Storage client initialized');
      
      // List all buckets
      Logger.info('Attempting to list buckets...');
      try {
        final buckets = await storage.listBuckets();
        Logger.info('Successfully listed ${buckets.length} buckets');
        
        if (buckets.isEmpty) {
          result['errors'].add('No buckets returned from Supabase. This could mean:');
          result['errors'].add('1. No storage buckets exist in your Supabase project');
          result['errors'].add('2. Row Level Security (RLS) policies are blocking access');
          result['errors'].add('3. The authenticated user lacks storage permissions');
          result['errors'].add('4. Storage service is not properly configured');
        }
      
        for (final bucket in buckets) {
          final bucketInfo = <String, dynamic>{
            'id': bucket.id,
            'name': bucket.name,
            'public': bucket.public,
            'createdAt': bucket.createdAt,
            'updatedAt': bucket.updatedAt,
            'files': <Map<String, dynamic>>[],
            'fileCount': 0,
            'error': null,
          };
        
          try {
            // Try to list files in each bucket
            Logger.info('Listing files in bucket: ${bucket.id}');
            final files = await storage.from(bucket.id).list();
            bucketInfo['fileCount'] = files.length;
            Logger.info('Found ${files.length} files in bucket ${bucket.id}');
            
            for (final file in files) {
              final fileInfo = <String, dynamic>{
                'name': file.name,
                'id': file.id,
                'size': file.metadata?['size'],
                'mimeType': file.metadata?['mimetype'],
                'lastModified': file.metadata?['lastModified'],
                'isFolder': file.metadata?['mimetype'] == null,
              };
              
              // Try to get public URL for files (not folders)
              if (file.metadata?['mimetype'] != null) {
                try {
                  fileInfo['publicUrl'] = storage.from(bucket.id).getPublicUrl(file.name);
                } catch (e) {
                  fileInfo['urlError'] = e.toString();
                }
              }
              
              bucketInfo['files'].add(fileInfo);
            }
            
            result['totalFiles'] = (result['totalFiles'] as int) + files.length;
            Logger.info('Successfully processed bucket ${bucket.id}: ${files.length} files');
            
          } catch (e) {
            bucketInfo['error'] = e.toString();
            result['errors'].add('Error accessing bucket ${bucket.id}: $e');
            Logger.error('Error accessing bucket ${bucket.id}', e);
          }
          
          result['buckets'].add(bucketInfo);
        }
      } catch (e) {
        result['errors'].add('Failed to list buckets: $e');
        Logger.error('Failed to list buckets', e);
      }
      
      result['success'] = true;
      Logger.info('Storage debug completed successfully');
      
    } catch (e, stackTrace) {
      result['errors'].add('Failed to connect to storage: $e');
      Logger.error('Storage debug failed', e, stackTrace);
    }
    
    return result;
  }

  /// Test specific bucket access
  static Future<Map<String, dynamic>> debugBucketAccess(String bucketId) async {
    final result = <String, dynamic>{
      'success': false,
      'bucketId': bucketId,
      'files': <Map<String, dynamic>>[],
      'error': null,
    };

    try {
      Logger.info('Testing access to bucket: $bucketId');
      
      final storage = SupabaseService.storage;
      final files = await storage.from(bucketId).list();
      
      for (final file in files) {
        final fileInfo = <String, dynamic>{
          'name': file.name,
          'id': file.id,
          'size': file.metadata?['size'],
          'mimeType': file.metadata?['mimetype'],
          'lastModified': file.metadata?['lastModified'],
          'isFolder': file.metadata?['mimetype'] == null,
        };
        
        // Try to get public URL for files (not folders)
        if (file.metadata?['mimetype'] != null) {
          try {
            fileInfo['publicUrl'] = storage.from(bucketId).getPublicUrl(file.name);
          } catch (e) {
            fileInfo['urlError'] = e.toString();
          }
        }
        
        result['files'].add(fileInfo);
      }
      
      result['success'] = true;
      Logger.info('Successfully accessed bucket $bucketId: ${files.length} files');
      
    } catch (e, stackTrace) {
      result['error'] = e.toString();
      Logger.error('Failed to access bucket $bucketId', e, stackTrace);
    }
    
    return result;
  }

  /// Print debug results in a readable format
  static void printDebugResults(Map<String, dynamic> results) {
    print('\n=== STORAGE DEBUG RESULTS ===');
    print('Success: ${results['success']}');
    print('Total Files: ${results['totalFiles']}');
    print('Total Buckets: ${results['buckets'].length}');
    
    // Print auth info
    if (results['authInfo'] != null) {
      print('\nAuthentication Info:');
      final authInfo = results['authInfo'] as Map<String, dynamic>;
      print('  Authenticated: ${authInfo['isAuthenticated']}');
      print('  User ID: ${authInfo['userId']}');
      print('  Email: ${authInfo['email']}');
      print('  Role: ${authInfo['role']}');
      print('  App Metadata: ${authInfo['appMetadata']}');
      print('  User Metadata: ${authInfo['userMetadata']}');
    }
    
    if (results['errors'].isNotEmpty) {
      print('\nErrors:');
      for (final error in results['errors']) {
        print('  - $error');
      }
    }
    
    print('\nBuckets:');
    if (results['buckets'].isEmpty) {
      print('  No buckets found! This might indicate:');
      print('  1. No storage buckets exist in Supabase');
      print('  2. Authentication/permission issues');
      print('  3. Incorrect Supabase configuration');
    } else {
      for (final bucket in results['buckets']) {
        print('  ${bucket['id']} (${bucket['name']})');
        print('    Public: ${bucket['public']}');
        print('    Files: ${bucket['fileCount']}');
        
        if (bucket['error'] != null) {
          print('    Error: ${bucket['error']}');
        } else if (bucket['files'].isNotEmpty) {
          print('    Sample files:');
          final files = bucket['files'] as List;
          for (int i = 0; i < files.length && i < 5; i++) {
            final file = files[i];
            print('      - ${file['name']} (${file['size']} bytes)');
          }
          if (files.length > 5) {
            print('      ... and ${files.length - 5} more files');
          }
        }
        print('');
      }
    }
    print('=== END DEBUG RESULTS ===\n');
  }
}