import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealth_app/core/services/supabase_service.dart';
import 'package:wealth_app/core/utils/app_exceptions.dart';
import 'package:wealth_app/shared/models/customer.dart';

part 'profile_repository.g.dart';

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  Future<Customer> getProfile(String userId) async {
    try {
      final response = await _client
          .from('customers')
          .select()
          .eq('id', userId)
          .single();
      
      return Customer.fromJson(response);
    } catch (e) {
      throw DataException('Failed to load profile: $e');
    }
  }

  Future<Customer> updateProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (fullName != null) updateData['full_name'] = fullName;
      if (phoneNumber != null) updateData['phone_number'] = phoneNumber;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      if (preferences != null) updateData['preferences'] = preferences;
      
      final response = await _client
          .from('customers')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();
      
      return Customer.fromJson(response);
    } catch (e) {
      throw DataException('Failed to update profile: $e');
    }
  }

  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final fileExtension = path.extension(imageFile.path);
      final fileName = 'avatar_$userId$fileExtension';
      
      await _client
          .storage
          .from('user-avatars')
          .upload(fileName, imageFile);
      
      // Get the public URL
      final imageUrlResponse = _client
          .storage
          .from('user-avatars')
          .getPublicUrl(fileName);
      
      // Update the user profile with the new avatar URL
      await updateProfile(
        userId: userId,
        avatarUrl: imageUrlResponse,
      );
      
      return imageUrlResponse;
    } catch (e) {
      throw DataException('Failed to upload avatar: $e');
    }
  }

  Future<String> uploadAvatarBytes({
    required String userId,
    required Uint8List bytes,
    required String fileExtension,
  }) async {
    try {
      final fileName = 'avatar_$userId$fileExtension';
      
      await _client
          .storage
          .from('user-avatars')
          .uploadBinary(fileName, bytes);
      
      // Get the public URL
      final imageUrlResponse = _client
          .storage
          .from('user-avatars')
          .getPublicUrl(fileName);
      
      // Update the user profile with the new avatar URL
      await updateProfile(
        userId: userId,
        avatarUrl: imageUrlResponse,
      );
      
      return imageUrlResponse;
    } catch (e) {
      throw DataException('Failed to upload avatar: $e');
    }
  }

  Future<void> updateUserPreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  }) async {
    try {
      // First get current preferences
      final customer = await getProfile(userId);
      final currentPreferences = customer.preferences ?? {};
      
      // Merge with new preferences
      final updatedPreferences = {
        ...currentPreferences,
        ...preferences,
      };
      
      // Update profile with merged preferences
      await updateProfile(
        userId: userId,
        preferences: updatedPreferences,
      );
    } catch (e) {
      throw DataException('Failed to update preferences: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserPreferences(String userId) async {
    try {
      final customer = await getProfile(userId);
      return customer.preferences;
    } catch (e) {
      throw DataException('Failed to get preferences: $e');
    }
  }
}

@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  return ProfileRepository(ref.watch(supabaseProvider));
} 