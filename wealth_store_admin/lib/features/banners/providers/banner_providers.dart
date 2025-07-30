import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../models/banner_models.dart';
import '../../../services/banner_service.dart';
import '../../../services/storage_service.dart';

// Banner service provider
final bannerServiceProvider = Provider<BannerService>((ref) {
  return BannerService();
});

// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// Banner filters state provider
final bannerFiltersProvider = StateProvider<BannerFilters>((ref) {
  return const BannerFilters();
});

// Banners list provider
final bannersProvider = FutureProvider<List<Banner>>((ref) async {
  final service = ref.read(bannerServiceProvider);
  final filters = ref.watch(bannerFiltersProvider);
  
  return await service.getBanners(
    isActive: filters.isActive,
    limit: filters.limit,
    offset: filters.offset,
  );
});

// Active banners provider
final activeBannersProvider = FutureProvider<List<Banner>>((ref) async {
  final service = ref.read(bannerServiceProvider);
  return await service.getActiveBanners();
});

// Banner by ID provider
final bannerByIdProvider = FutureProvider.family<Banner?, String>((ref, id) async {
  final service = ref.read(bannerServiceProvider);
  return await service.getBannerById(id);
});

// Banner statistics providers
final totalBannerCountProvider = FutureProvider<int>((ref) async {
  final service = ref.read(bannerServiceProvider);
  return await service.getTotalBannerCount();
});

final activeBannerCountProvider = FutureProvider<int>((ref) async {
  final service = ref.read(bannerServiceProvider);
  return await service.getActiveBannerCount();
});

// Banner CRUD operations provider
final bannerCrudProvider = Provider<BannerCrudOperations>((ref) {
  return BannerCrudOperations(
    ref.read(bannerServiceProvider),
    ref.read(storageServiceProvider),
  );
});

class BannerCrudOperations {
  final BannerService _bannerService;
  final StorageService _storageService;
  
  BannerCrudOperations(this._bannerService, this._storageService);
  
  Future<Banner> createBanner(BannerFormData data) async {
    return await _bannerService.createBanner(data);
  }
  
  Future<Banner> updateBanner(String id, BannerFormData data) async {
    return await _bannerService.updateBanner(id, data);
  }
  
  Future<void> deleteBanner(String id) async {
    return await _bannerService.deleteBanner(id);
  }
  
  Future<Banner> toggleBannerStatus(String id) async {
    return await _bannerService.toggleBannerStatus(id);
  }
  
  Future<String> uploadBannerImage(dynamic file, String bannerTitle) async {
    return await _storageService.uploadBannerImage(file, bannerTitle);
  }
}

class BannerFilters {
  final bool? isActive;
  final int? limit;
  final int? offset;
  final String? searchQuery;

  const BannerFilters({
    this.isActive,
    this.limit,
    this.offset,
    this.searchQuery,
  });

  BannerFilters copyWith({
    bool? isActive,
    int? limit,
    int? offset,
    String? searchQuery,
  }) {
    return BannerFilters(
      isActive: isActive ?? this.isActive,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}