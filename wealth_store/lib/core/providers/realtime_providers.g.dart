// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realtime_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allProductsHash() => r'ec57dcee608b88539ff7860863affa67568ba812';

/// Stream provider for all products with real-time updates
///
/// Copied from [allProducts].
@ProviderFor(allProducts)
final allProductsProvider = AutoDisposeStreamProvider<List<Product>>.internal(
  allProducts,
  name: r'allProductsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allProductsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllProductsRef = AutoDisposeStreamProviderRef<List<Product>>;
String _$featuredProductsHash() => r'bc880bde950bc223391a63231b3b0d21d158dbb6';

/// Stream provider for featured products with real-time updates
///
/// Copied from [featuredProducts].
@ProviderFor(featuredProducts)
final featuredProductsProvider =
    AutoDisposeStreamProvider<List<Product>>.internal(
  featuredProducts,
  name: r'featuredProductsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$featuredProductsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FeaturedProductsRef = AutoDisposeStreamProviderRef<List<Product>>;
String _$productsByCategoryHash() =>
    r'4f892bf1e6b9827af617ffa0c43d4cf110b0e15d';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Stream provider for products by category with real-time updates
///
/// Copied from [productsByCategory].
@ProviderFor(productsByCategory)
const productsByCategoryProvider = ProductsByCategoryFamily();

/// Stream provider for products by category with real-time updates
///
/// Copied from [productsByCategory].
class ProductsByCategoryFamily extends Family<AsyncValue<List<Product>>> {
  /// Stream provider for products by category with real-time updates
  ///
  /// Copied from [productsByCategory].
  const ProductsByCategoryFamily();

  /// Stream provider for products by category with real-time updates
  ///
  /// Copied from [productsByCategory].
  ProductsByCategoryProvider call(
    int categoryId,
  ) {
    return ProductsByCategoryProvider(
      categoryId,
    );
  }

  @override
  ProductsByCategoryProvider getProviderOverride(
    covariant ProductsByCategoryProvider provider,
  ) {
    return call(
      provider.categoryId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'productsByCategoryProvider';
}

/// Stream provider for products by category with real-time updates
///
/// Copied from [productsByCategory].
class ProductsByCategoryProvider
    extends AutoDisposeStreamProvider<List<Product>> {
  /// Stream provider for products by category with real-time updates
  ///
  /// Copied from [productsByCategory].
  ProductsByCategoryProvider(
    int categoryId,
  ) : this._internal(
          (ref) => productsByCategory(
            ref as ProductsByCategoryRef,
            categoryId,
          ),
          from: productsByCategoryProvider,
          name: r'productsByCategoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productsByCategoryHash,
          dependencies: ProductsByCategoryFamily._dependencies,
          allTransitiveDependencies:
              ProductsByCategoryFamily._allTransitiveDependencies,
          categoryId: categoryId,
        );

  ProductsByCategoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final int categoryId;

  @override
  Override overrideWith(
    Stream<List<Product>> Function(ProductsByCategoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProductsByCategoryProvider._internal(
        (ref) => create(ref as ProductsByCategoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Product>> createElement() {
    return _ProductsByCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductsByCategoryProvider &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProductsByCategoryRef on AutoDisposeStreamProviderRef<List<Product>> {
  /// The parameter `categoryId` of this provider.
  int get categoryId;
}

class _ProductsByCategoryProviderElement
    extends AutoDisposeStreamProviderElement<List<Product>>
    with ProductsByCategoryRef {
  _ProductsByCategoryProviderElement(super.provider);

  @override
  int get categoryId => (origin as ProductsByCategoryProvider).categoryId;
}

String _$searchProductsHash() => r'05fb9be23ec9cdc3778862a2ab4d03f8a4813082';

/// Stream provider for product search with real-time updates
///
/// Copied from [searchProducts].
@ProviderFor(searchProducts)
const searchProductsProvider = SearchProductsFamily();

/// Stream provider for product search with real-time updates
///
/// Copied from [searchProducts].
class SearchProductsFamily extends Family<AsyncValue<List<Product>>> {
  /// Stream provider for product search with real-time updates
  ///
  /// Copied from [searchProducts].
  const SearchProductsFamily();

  /// Stream provider for product search with real-time updates
  ///
  /// Copied from [searchProducts].
  SearchProductsProvider call(
    String query,
  ) {
    return SearchProductsProvider(
      query,
    );
  }

  @override
  SearchProductsProvider getProviderOverride(
    covariant SearchProductsProvider provider,
  ) {
    return call(
      provider.query,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchProductsProvider';
}

/// Stream provider for product search with real-time updates
///
/// Copied from [searchProducts].
class SearchProductsProvider extends AutoDisposeStreamProvider<List<Product>> {
  /// Stream provider for product search with real-time updates
  ///
  /// Copied from [searchProducts].
  SearchProductsProvider(
    String query,
  ) : this._internal(
          (ref) => searchProducts(
            ref as SearchProductsRef,
            query,
          ),
          from: searchProductsProvider,
          name: r'searchProductsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$searchProductsHash,
          dependencies: SearchProductsFamily._dependencies,
          allTransitiveDependencies:
              SearchProductsFamily._allTransitiveDependencies,
          query: query,
        );

  SearchProductsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    Stream<List<Product>> Function(SearchProductsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchProductsProvider._internal(
        (ref) => create(ref as SearchProductsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Product>> createElement() {
    return _SearchProductsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchProductsProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchProductsRef on AutoDisposeStreamProviderRef<List<Product>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchProductsProviderElement
    extends AutoDisposeStreamProviderElement<List<Product>>
    with SearchProductsRef {
  _SearchProductsProviderElement(super.provider);

  @override
  String get query => (origin as SearchProductsProvider).query;
}

String _$filteredProductsHash() => r'087d8167a1bc1847e4ec3de7f17b9c193ac69ee6';

/// Stream provider for products with complex filtering
///
/// Copied from [filteredProducts].
@ProviderFor(filteredProducts)
const filteredProductsProvider = FilteredProductsFamily();

/// Stream provider for products with complex filtering
///
/// Copied from [filteredProducts].
class FilteredProductsFamily extends Family<AsyncValue<List<Product>>> {
  /// Stream provider for products with complex filtering
  ///
  /// Copied from [filteredProducts].
  const FilteredProductsFamily();

  /// Stream provider for products with complex filtering
  ///
  /// Copied from [filteredProducts].
  FilteredProductsProvider call({
    int? categoryId,
    bool? isFeatured,
    String? searchQuery,
  }) {
    return FilteredProductsProvider(
      categoryId: categoryId,
      isFeatured: isFeatured,
      searchQuery: searchQuery,
    );
  }

  @override
  FilteredProductsProvider getProviderOverride(
    covariant FilteredProductsProvider provider,
  ) {
    return call(
      categoryId: provider.categoryId,
      isFeatured: provider.isFeatured,
      searchQuery: provider.searchQuery,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'filteredProductsProvider';
}

/// Stream provider for products with complex filtering
///
/// Copied from [filteredProducts].
class FilteredProductsProvider
    extends AutoDisposeStreamProvider<List<Product>> {
  /// Stream provider for products with complex filtering
  ///
  /// Copied from [filteredProducts].
  FilteredProductsProvider({
    int? categoryId,
    bool? isFeatured,
    String? searchQuery,
  }) : this._internal(
          (ref) => filteredProducts(
            ref as FilteredProductsRef,
            categoryId: categoryId,
            isFeatured: isFeatured,
            searchQuery: searchQuery,
          ),
          from: filteredProductsProvider,
          name: r'filteredProductsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$filteredProductsHash,
          dependencies: FilteredProductsFamily._dependencies,
          allTransitiveDependencies:
              FilteredProductsFamily._allTransitiveDependencies,
          categoryId: categoryId,
          isFeatured: isFeatured,
          searchQuery: searchQuery,
        );

  FilteredProductsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
    required this.isFeatured,
    required this.searchQuery,
  }) : super.internal();

  final int? categoryId;
  final bool? isFeatured;
  final String? searchQuery;

  @override
  Override overrideWith(
    Stream<List<Product>> Function(FilteredProductsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FilteredProductsProvider._internal(
        (ref) => create(ref as FilteredProductsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
        isFeatured: isFeatured,
        searchQuery: searchQuery,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Product>> createElement() {
    return _FilteredProductsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredProductsProvider &&
        other.categoryId == categoryId &&
        other.isFeatured == isFeatured &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);
    hash = _SystemHash.combine(hash, isFeatured.hashCode);
    hash = _SystemHash.combine(hash, searchQuery.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FilteredProductsRef on AutoDisposeStreamProviderRef<List<Product>> {
  /// The parameter `categoryId` of this provider.
  int? get categoryId;

  /// The parameter `isFeatured` of this provider.
  bool? get isFeatured;

  /// The parameter `searchQuery` of this provider.
  String? get searchQuery;
}

class _FilteredProductsProviderElement
    extends AutoDisposeStreamProviderElement<List<Product>>
    with FilteredProductsRef {
  _FilteredProductsProviderElement(super.provider);

  @override
  int? get categoryId => (origin as FilteredProductsProvider).categoryId;
  @override
  bool? get isFeatured => (origin as FilteredProductsProvider).isFeatured;
  @override
  String? get searchQuery => (origin as FilteredProductsProvider).searchQuery;
}

String _$allCategoriesHash() => r'3375da34a950e78ea917b6a49415530bc5bd8574';

/// Stream provider for all categories with real-time updates
///
/// Copied from [allCategories].
@ProviderFor(allCategories)
final allCategoriesProvider =
    AutoDisposeStreamProvider<List<Category>>.internal(
  allCategories,
  name: r'allCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllCategoriesRef = AutoDisposeStreamProviderRef<List<Category>>;
String _$activeCategoriesHash() => r'8574afe8857dc8d69fd2142c7e2f3b939faf9110';

/// Stream provider for active categories with real-time updates
///
/// Copied from [activeCategories].
@ProviderFor(activeCategories)
final activeCategoriesProvider =
    AutoDisposeStreamProvider<List<Category>>.internal(
  activeCategories,
  name: r'activeCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveCategoriesRef = AutoDisposeStreamProviderRef<List<Category>>;
String _$allOrdersHash() => r'f4710d3b700a8bafc976dd38fd37e0d8ca2ace79';

/// Stream provider for all orders with real-time updates
///
/// Copied from [allOrders].
@ProviderFor(allOrders)
final allOrdersProvider = AutoDisposeStreamProvider<List<Order>>.internal(
  allOrders,
  name: r'allOrdersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allOrdersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllOrdersRef = AutoDisposeStreamProviderRef<List<Order>>;
String _$ordersByStatusHash() => r'ac2586678a5b3d3087558c9da23f4c8c93949a2f';

/// Stream provider for orders by status with real-time updates
///
/// Copied from [ordersByStatus].
@ProviderFor(ordersByStatus)
const ordersByStatusProvider = OrdersByStatusFamily();

/// Stream provider for orders by status with real-time updates
///
/// Copied from [ordersByStatus].
class OrdersByStatusFamily extends Family<AsyncValue<List<Order>>> {
  /// Stream provider for orders by status with real-time updates
  ///
  /// Copied from [ordersByStatus].
  const OrdersByStatusFamily();

  /// Stream provider for orders by status with real-time updates
  ///
  /// Copied from [ordersByStatus].
  OrdersByStatusProvider call(
    String status,
  ) {
    return OrdersByStatusProvider(
      status,
    );
  }

  @override
  OrdersByStatusProvider getProviderOverride(
    covariant OrdersByStatusProvider provider,
  ) {
    return call(
      provider.status,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'ordersByStatusProvider';
}

/// Stream provider for orders by status with real-time updates
///
/// Copied from [ordersByStatus].
class OrdersByStatusProvider extends AutoDisposeStreamProvider<List<Order>> {
  /// Stream provider for orders by status with real-time updates
  ///
  /// Copied from [ordersByStatus].
  OrdersByStatusProvider(
    String status,
  ) : this._internal(
          (ref) => ordersByStatus(
            ref as OrdersByStatusRef,
            status,
          ),
          from: ordersByStatusProvider,
          name: r'ordersByStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$ordersByStatusHash,
          dependencies: OrdersByStatusFamily._dependencies,
          allTransitiveDependencies:
              OrdersByStatusFamily._allTransitiveDependencies,
          status: status,
        );

  OrdersByStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final String status;

  @override
  Override overrideWith(
    Stream<List<Order>> Function(OrdersByStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OrdersByStatusProvider._internal(
        (ref) => create(ref as OrdersByStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Order>> createElement() {
    return _OrdersByStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrdersByStatusProvider && other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrdersByStatusRef on AutoDisposeStreamProviderRef<List<Order>> {
  /// The parameter `status` of this provider.
  String get status;
}

class _OrdersByStatusProviderElement
    extends AutoDisposeStreamProviderElement<List<Order>>
    with OrdersByStatusRef {
  _OrdersByStatusProviderElement(super.provider);

  @override
  String get status => (origin as OrdersByStatusProvider).status;
}

String _$userOrdersHash() => r'd256b07b01ec913c433a3c51a8b7f7f97fa25469';

/// Stream provider for user orders with real-time updates
///
/// Copied from [userOrders].
@ProviderFor(userOrders)
const userOrdersProvider = UserOrdersFamily();

/// Stream provider for user orders with real-time updates
///
/// Copied from [userOrders].
class UserOrdersFamily extends Family<AsyncValue<List<Order>>> {
  /// Stream provider for user orders with real-time updates
  ///
  /// Copied from [userOrders].
  const UserOrdersFamily();

  /// Stream provider for user orders with real-time updates
  ///
  /// Copied from [userOrders].
  UserOrdersProvider call(
    String userId,
  ) {
    return UserOrdersProvider(
      userId,
    );
  }

  @override
  UserOrdersProvider getProviderOverride(
    covariant UserOrdersProvider provider,
  ) {
    return call(
      provider.userId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userOrdersProvider';
}

/// Stream provider for user orders with real-time updates
///
/// Copied from [userOrders].
class UserOrdersProvider extends AutoDisposeStreamProvider<List<Order>> {
  /// Stream provider for user orders with real-time updates
  ///
  /// Copied from [userOrders].
  UserOrdersProvider(
    String userId,
  ) : this._internal(
          (ref) => userOrders(
            ref as UserOrdersRef,
            userId,
          ),
          from: userOrdersProvider,
          name: r'userOrdersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userOrdersHash,
          dependencies: UserOrdersFamily._dependencies,
          allTransitiveDependencies:
              UserOrdersFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserOrdersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    Stream<List<Order>> Function(UserOrdersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserOrdersProvider._internal(
        (ref) => create(ref as UserOrdersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Order>> createElement() {
    return _UserOrdersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserOrdersProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserOrdersRef on AutoDisposeStreamProviderRef<List<Order>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserOrdersProviderElement
    extends AutoDisposeStreamProviderElement<List<Order>> with UserOrdersRef {
  _UserOrdersProviderElement(super.provider);

  @override
  String get userId => (origin as UserOrdersProvider).userId;
}

String _$pendingOrdersHash() => r'85e0dd92b69244c8aa08b982bde4ad9877aa8d98';

/// Stream provider for pending orders with real-time updates
///
/// Copied from [pendingOrders].
@ProviderFor(pendingOrders)
final pendingOrdersProvider = AutoDisposeStreamProvider<List<Order>>.internal(
  pendingOrders,
  name: r'pendingOrdersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingOrdersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingOrdersRef = AutoDisposeStreamProviderRef<List<Order>>;
String _$completedOrdersHash() => r'cd00ce4c9dce6a719aea8e5073f4528eeb91a77b';

/// Stream provider for completed orders with real-time updates
///
/// Copied from [completedOrders].
@ProviderFor(completedOrders)
final completedOrdersProvider = AutoDisposeStreamProvider<List<Order>>.internal(
  completedOrders,
  name: r'completedOrdersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$completedOrdersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CompletedOrdersRef = AutoDisposeStreamProviderRef<List<Order>>;
String _$allBannersHash() => r'0dc446f18c1463d7b81dd070b370aee419e8bc5f';

/// Stream provider for all banners with real-time updates
///
/// Copied from [allBanners].
@ProviderFor(allBanners)
final allBannersProvider = AutoDisposeStreamProvider<List<Banner>>.internal(
  allBanners,
  name: r'allBannersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allBannersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllBannersRef = AutoDisposeStreamProviderRef<List<Banner>>;
String _$activeBannersHash() => r'8ccf796495589cc79ce6d37873a9caffca195c6e';

/// Stream provider for active banners with real-time updates
///
/// Copied from [activeBanners].
@ProviderFor(activeBanners)
final activeBannersProvider = AutoDisposeStreamProvider<List<Banner>>.internal(
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
typedef ActiveBannersRef = AutoDisposeStreamProviderRef<List<Banner>>;
String _$allCouponsHash() => r'5964c3c1af8b00d1405756c34f17c5b1f42ecc77';

/// Stream provider for all coupons with real-time updates
///
/// Copied from [allCoupons].
@ProviderFor(allCoupons)
final allCouponsProvider = AutoDisposeStreamProvider<List<Coupon>>.internal(
  allCoupons,
  name: r'allCouponsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allCouponsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllCouponsRef = AutoDisposeStreamProviderRef<List<Coupon>>;
String _$activeCouponsHash() => r'8bec5da6656d82dcc8a69206746a554049262168';

/// Stream provider for active coupons with real-time updates
///
/// Copied from [activeCoupons].
@ProviderFor(activeCoupons)
final activeCouponsProvider = AutoDisposeStreamProvider<List<Coupon>>.internal(
  activeCoupons,
  name: r'activeCouponsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeCouponsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveCouponsRef = AutoDisposeStreamProviderRef<List<Coupon>>;
String _$realtimeConnectionStatusHash() =>
    r'f95d01b2bea2208e61c489d5b1a144d39d833715';

/// Stream provider for real-time connection status
///
/// Copied from [realtimeConnectionStatus].
@ProviderFor(realtimeConnectionStatus)
final realtimeConnectionStatusProvider =
    AutoDisposeStreamProvider<RealtimeConnectionState>.internal(
  realtimeConnectionStatus,
  name: r'realtimeConnectionStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$realtimeConnectionStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RealtimeConnectionStatusRef
    = AutoDisposeStreamProviderRef<RealtimeConnectionState>;
String _$isRealtimeConnectedHash() =>
    r'1227f9a46c74a1b0d49a3f03d60e6a940d9d4de4';

/// Provider for current connection status
///
/// Copied from [isRealtimeConnected].
@ProviderFor(isRealtimeConnected)
final isRealtimeConnectedProvider = AutoDisposeProvider<bool>.internal(
  isRealtimeConnected,
  name: r'isRealtimeConnectedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isRealtimeConnectedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsRealtimeConnectedRef = AutoDisposeProviderRef<bool>;
String _$realtimeMethodsHash() => r'0822a351406a84e733bd7bd3f575af9ae83a4adf';

/// Provider for real-time service methods
///
/// Copied from [realtimeMethods].
@ProviderFor(realtimeMethods)
final realtimeMethodsProvider = AutoDisposeProvider<RealtimeMethods>.internal(
  realtimeMethods,
  name: r'realtimeMethodsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$realtimeMethodsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RealtimeMethodsRef = AutoDisposeProviderRef<RealtimeMethods>;
String _$realtimeConnectionNotifierHash() =>
    r'287f19c94263446584807757ff657711dcedfa4e';

/// Provider for managing real-time connection state
///
/// Copied from [RealtimeConnectionNotifier].
@ProviderFor(RealtimeConnectionNotifier)
final realtimeConnectionNotifierProvider = AutoDisposeNotifierProvider<
    RealtimeConnectionNotifier, RealtimeConnectionState>.internal(
  RealtimeConnectionNotifier.new,
  name: r'realtimeConnectionNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$realtimeConnectionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RealtimeConnectionNotifier
    = AutoDisposeNotifier<RealtimeConnectionState>;
String _$realtimeErrorNotifierHash() =>
    r'4fdc5ae58fee0efdf0669f9a48600bf834da3920';

/// Provider for tracking real-time errors
///
/// Copied from [RealtimeErrorNotifier].
@ProviderFor(RealtimeErrorNotifier)
final realtimeErrorNotifierProvider =
    AutoDisposeNotifierProvider<RealtimeErrorNotifier, String?>.internal(
  RealtimeErrorNotifier.new,
  name: r'realtimeErrorNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$realtimeErrorNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RealtimeErrorNotifier = AutoDisposeNotifier<String?>;
String _$realtimeLoadingNotifierHash() =>
    r'89649e8f6cdf7715d0b12f28a35501aff47d78de';

/// Provider for tracking loading states
///
/// Copied from [RealtimeLoadingNotifier].
@ProviderFor(RealtimeLoadingNotifier)
final realtimeLoadingNotifierProvider =
    AutoDisposeNotifierProvider<RealtimeLoadingNotifier, bool>.internal(
  RealtimeLoadingNotifier.new,
  name: r'realtimeLoadingNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$realtimeLoadingNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RealtimeLoadingNotifier = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
