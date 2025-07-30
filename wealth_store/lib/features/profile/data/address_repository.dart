import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealth_app/core/services/supabase_service.dart';
import 'package:wealth_app/core/utils/app_exceptions.dart';
import 'package:wealth_app/shared/models/address.dart';

part 'address_repository.g.dart';

class AddressRepository {
  final SupabaseClient _client;

  AddressRepository(this._client);

  Future<List<Address>> getUserAddresses(String userId) async {
    try {
      final response = await _client
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .order('is_default', ascending: false);
      
      return response.map((json) => Address.fromJson(json)).toList();
    } catch (e) {
      throw DataException('Failed to load addresses: $e');
    }
  }

  Future<Address> getAddress(int id) async {
    try {
      final response = await _client
          .from('addresses')
          .select()
          .eq('id', id)
          .single();
      
      return Address.fromJson(response);
    } catch (e) {
      throw DataException('Failed to load address: $e');
    }
  }

  Future<Address> createAddress({
    required String userId,
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
    try {
      // If this is the default address, unset any existing default
      if (isDefault) {
        await _client
            .from('addresses')
            .update({'is_default': false})
            .eq('user_id', userId)
            .eq('is_default', true);
      }
      
      final addressData = {
        'user_id': userId,
        'name': name,
        'street': street,
        'city': city,
        'state': state,
        'zip_code': zipCode,
        'country': country,
        'is_default': isDefault,
        'phone_number': phoneNumber,
        'additional_info': additionalInfo,
      };
      
      final response = await _client
          .from('addresses')
          .insert(addressData)
          .select()
          .single();
      
      return Address.fromJson(response);
    } catch (e) {
      throw DataException('Failed to create address: $e');
    }
  }

  Future<Address> updateAddress({
    required int id,
    required String userId,
    String? name,
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    bool? isDefault,
    String? phoneNumber,
    String? additionalInfo,
  }) async {
    try {
      // If this is being set as default, unset any existing default
      if (isDefault == true) {
        await _client
            .from('addresses')
            .update({'is_default': false})
            .eq('user_id', userId)
            .eq('is_default', true);
      }
      
      final updateData = <String, dynamic>{};
      
      if (name != null) updateData['name'] = name;
      if (street != null) updateData['street'] = street;
      if (city != null) updateData['city'] = city;
      if (state != null) updateData['state'] = state;
      if (zipCode != null) updateData['zip_code'] = zipCode;
      if (country != null) updateData['country'] = country;
      if (isDefault != null) updateData['is_default'] = isDefault;
      if (phoneNumber != null) updateData['phone_number'] = phoneNumber;
      if (additionalInfo != null) updateData['additional_info'] = additionalInfo;
      
      final response = await _client
          .from('addresses')
          .update(updateData)
          .eq('id', id)
          .eq('user_id', userId) // Security: ensure user owns this address
          .select()
          .single();
      
      return Address.fromJson(response);
    } catch (e) {
      throw DataException('Failed to update address: $e');
    }
  }

  Future<void> deleteAddress(int id, String userId) async {
    try {
      await _client
          .from('addresses')
          .delete()
          .eq('id', id)
          .eq('user_id', userId); // Security: ensure user owns this address
    } catch (e) {
      throw DataException('Failed to delete address: $e');
    }
  }

  Future<Address?> getDefaultAddress(String userId) async {
    try {
      final response = await _client
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .eq('is_default', true)
          .maybeSingle();
      
      if (response == null) return null;
      
      return Address.fromJson(response);
    } catch (e) {
      throw DataException('Failed to get default address: $e');
    }
  }

  Future<void> setDefaultAddress(int id, String userId) async {
    try {
      // First, unset any existing default
      await _client
          .from('addresses')
          .update({'is_default': false})
          .eq('user_id', userId)
          .eq('is_default', true);
      
      // Then set the new default
      await _client
          .from('addresses')
          .update({'is_default': true})
          .eq('id', id)
          .eq('user_id', userId);
    } catch (e) {
      throw DataException('Failed to set default address: $e');
    }
  }
}

@riverpod
AddressRepository addressRepository(AddressRepositoryRef ref) {
  return AddressRepository(ref.watch(supabaseProvider));
} 