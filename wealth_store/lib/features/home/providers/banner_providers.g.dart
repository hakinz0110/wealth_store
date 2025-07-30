// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bannerServiceHash() => r'80222b2f6f1adc913acbc62bf97e09e1844895c2';

/// See also [bannerService].
@ProviderFor(bannerService)
final bannerServiceProvider = AutoDisposeProvider<BannerService>.internal(
  bannerService,
  name: r'bannerServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bannerServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BannerServiceRef = AutoDisposeProviderRef<BannerService>;
String _$activeBannersHash() => r'16efb4134621b1f141b7fdb690ae62f2500c532a';

/// Provider for active banners to display in the carousel
///
/// Copied from [activeBanners].
@ProviderFor(activeBanners)
final activeBannersProvider = AutoDisposeFutureProvider<List<Banner>>.internal(
  activeBanners,
  name: r'activeBannersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeBannersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveBannersRef = AutoDisposeFutureProviderRef<List<Banner>>;
String _$bannerStreamHash() => r'4bd3af9e27b3a10d09861578f1141ad9823ce3e7';

/// Stream provider for real-time banner updates
///
/// Copied from [bannerStream].
@ProviderFor(bannerStream)
final bannerStreamProvider = AutoDisposeStreamProvider<List<Banner>>.internal(
  bannerStream,
  name: r'bannerStreamProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$bannerStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BannerStreamRef = AutoDisposeStreamProviderRef<List<Banner>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
