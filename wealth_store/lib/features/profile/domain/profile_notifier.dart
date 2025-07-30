import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealth_app/features/profile/domain/profile_state.dart';


class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState());

  Future<void> updateProfile({String? fullName, String? phoneNumber}) async {
    debugPrint('updateProfile called with $fullName, $phoneNumber');
    return Future.value();
  }
  
  Future<void> uploadAvatar(File imageFile) async {
    debugPrint('uploadAvatar called');
    return Future.value();
  }
  
  Future<void> createAddress({
    required String name,
    required String street,
    required String city,
    required String state,
    required String zipCode,
    required String country,
    bool isDefault = false,
    String? phoneNumber,
    String? additionalInfo,
  }) async {
    debugPrint('createAddress called');
    return Future.value();
  }
  
  Future<void> updateAddress({
    required int id,
    String? name,
    String? street,
    String? city,
    String? stateRegion,
    String? zipCode,
    String? country,
    bool? isDefault,
    String? phoneNumber,
    String? additionalInfo,
  }) async {
    debugPrint('updateAddress called');
    return Future.value();
  }
  
  Future<void> deleteAddress(int id) async {
    debugPrint('deleteAddress called');
    return Future.value();
  }
  
  Future<void> setDefaultAddress(int id) async {
    debugPrint('setDefaultAddress called');
    return Future.value();
  }
  
  Future<void> updateThemePreference(String theme) async {
    debugPrint('updateThemePreference called with $theme');
    return Future.value();
  }
  
  Future<void> updateLanguagePreference(String language) async {
    debugPrint('updateLanguagePreference called with $language');
    return Future.value();
  }
  
  void refreshProfile() {
    debugPrint('refreshProfile called');
  }
}

final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
}); 