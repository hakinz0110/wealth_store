import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  
  // Auth Token
  static Future<void> storeToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
  
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  static Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
  
  // User ID
  static Future<void> storeUserId(String userId) async {
    await _storage.write(key: 'user_id', value: userId);
  }
  
  static Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }
  
  // Clear all stored data
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
} 