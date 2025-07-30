import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wealth_app/core/services/supabase_service.dart';
import 'package:wealth_app/core/utils/app_exceptions.dart';
import 'package:wealth_app/shared/models/promotion.dart';

part 'feed_repository.g.dart';

class FeedRepository {
  final SupabaseClient _client;

  FeedRepository(this._client);

  Future<List<Promotion>> getPromotions() async {
    try {
      final now = DateTime.now();
      
      final response = await _client
          .from('promotions')
          .select()
          .lte('start_date', now.toIso8601String())
          .gte('end_date', now.toIso8601String())
          .eq('is_active', true)
          .order('created_at', ascending: false);
      
      return response.map((json) => Promotion.fromJson(json)).toList();
    } catch (e) {
      throw DataException('Failed to load promotions: $e');
    }
  }

  Future<Promotion> getPromotion(int id) async {
    try {
      final response = await _client
          .from('promotions')
          .select()
          .eq('id', id)
          .single();
      
      return Promotion.fromJson(response);
    } catch (e) {
      throw DataException('Failed to load promotion: $e');
    }
  }

  Future<List<Promotion>> getPromotionsByCategory(int categoryId) async {
    try {
      final now = DateTime.now();
      
      final response = await _client
          .from('promotions')
          .select()
          .eq('category_id', categoryId)
          .lte('start_date', now.toIso8601String())
          .gte('end_date', now.toIso8601String())
          .eq('is_active', true)
          .order('created_at', ascending: false);
      
      return response.map((json) => Promotion.fromJson(json)).toList();
    } catch (e) {
      throw DataException('Failed to load category promotions: $e');
    }
  }

  Future<List<Promotion>> getPromotionsByProduct(int productId) async {
    try {
      final now = DateTime.now();
      
      final response = await _client
          .from('promotions')
          .select()
          .eq('product_id', productId)
          .lte('start_date', now.toIso8601String())
          .gte('end_date', now.toIso8601String())
          .eq('is_active', true)
          .order('created_at', ascending: false);
      
      return response.map((json) => Promotion.fromJson(json)).toList();
    } catch (e) {
      throw DataException('Failed to load product promotions: $e');
    }
  }
}

@riverpod
FeedRepository feedRepository(FeedRepositoryRef ref) {
  return FeedRepository(ref.watch(supabaseProvider));
} 