import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wealth_app/core/services/banner_service.dart';
import 'package:wealth_app/shared/models/banner.dart';

part 'banner_providers.g.dart';

@riverpod
BannerService bannerService(BannerServiceRef ref) {
  return ref.watch(bannerServiceProvider);
}

/// Provider for active banners to display in the carousel
@riverpod
Future<List<Banner>> activeBanners(ActiveBannersRef ref) async {
  final service = ref.watch(bannerServiceProvider);
  return service.getActiveBanners(limit: 10);
}

/// Stream provider for real-time banner updates
@riverpod
Stream<List<Banner>> bannerStream(BannerStreamRef ref) {
  final service = ref.watch(bannerServiceProvider);
  return service.watchActiveBanners();
}