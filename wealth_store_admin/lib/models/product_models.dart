class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String categoryId;
  final String? brandId;
  final List<String> imageUrls;
  final Map<String, dynamic> specifications;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.categoryId,
    this.brandId,
    required this.imageUrls,
    required this.specifications,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      categoryId: json['category_id']?.toString() ?? '',
      brandId: json['brand_id']?.toString(),
      imageUrls: (json['image_urls'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      specifications: json['specifications'] as Map<String, dynamic>? ?? {},
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category_id': categoryId,
      'brand_id': brandId,
      'image_urls': imageUrls,
      'specifications': specifications,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? categoryId,
    String? brandId,
    List<String>? imageUrls,
    Map<String, dynamic>? specifications,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
      imageUrls: imageUrls ?? this.imageUrls,
      specifications: specifications ?? this.specifications,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getters
  String? get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;
  bool get isLowStock => stock <= 10;
  bool get isOutOfStock => stock <= 0;
  String get primaryImageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
}

class ProductFormData {
  final String name;
  final String description;
  final double price;
  final int stock;
  final String categoryId;
  final String? brandId;
  final List<String> imageUrls;
  final Map<String, dynamic> specifications;
  final bool isActive;

  const ProductFormData({
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.categoryId,
    this.brandId,
    required this.imageUrls,
    required this.specifications,
    this.isActive = true,
  });

  factory ProductFormData.empty() {
    return const ProductFormData(
      name: '',
      description: '',
      price: 0.0,
      stock: 0,
      categoryId: '',
      imageUrls: [],
      specifications: {},
    );
  }

  factory ProductFormData.fromProduct(Product product) {
    return ProductFormData(
      name: product.name,
      description: product.description,
      price: product.price,
      stock: product.stock,
      categoryId: product.categoryId,
      brandId: product.brandId,
      imageUrls: product.imageUrls,
      specifications: product.specifications,
      isActive: product.isActive,
    );
  }

  ProductFormData copyWith({
    String? name,
    String? description,
    double? price,
    int? stock,
    String? categoryId,
    String? brandId,
    List<String>? imageUrls,
    Map<String, dynamic>? specifications,
    bool? isActive,
  }) {
    return ProductFormData(
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
      imageUrls: imageUrls ?? this.imageUrls,
      specifications: specifications ?? this.specifications,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category_id': categoryId,
      'brand_id': brandId,
      'image_urls': imageUrls,
      'specifications': specifications,
      'is_active': isActive,
    };
  }
}

class Category {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int productCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.productCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(),
      productCount: (json['product_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'product_count': productCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Brand {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final int productCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Brand({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.productCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      logoUrl: json['logo_url']?.toString(),
      productCount: (json['product_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo_url': logoUrl,
      'product_count': productCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// Validation errors
class ProductValidationError {
  final String field;
  final String message;

  const ProductValidationError({
    required this.field,
    required this.message,
  });
}

// Product filters and sorting
enum ProductSortBy {
  name,
  price,
  stock,
  createdAt,
  updatedAt,
}

enum SortOrder {
  ascending,
  descending,
}

class ProductFilters {
  final String? categoryId;
  final String? brandId;
  final double? minPrice;
  final double? maxPrice;
  final bool? isActive;
  final bool? lowStock;
  final String? searchQuery;
  final ProductSortBy sortBy;
  final SortOrder sortOrder;

  const ProductFilters({
    this.categoryId,
    this.brandId,
    this.minPrice,
    this.maxPrice,
    this.isActive,
    this.lowStock,
    this.searchQuery,
    this.sortBy = ProductSortBy.createdAt,
    this.sortOrder = SortOrder.descending,
  });

  ProductFilters copyWith({
    String? categoryId,
    String? brandId,
    double? minPrice,
    double? maxPrice,
    bool? isActive,
    bool? lowStock,
    String? searchQuery,
    ProductSortBy? sortBy,
    SortOrder? sortOrder,
  }) {
    return ProductFilters(
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      isActive: isActive ?? this.isActive,
      lowStock: lowStock ?? this.lowStock,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'brand_id': brandId,
      'min_price': minPrice,
      'max_price': maxPrice,
      'is_active': isActive,
      'low_stock': lowStock,
      'search_query': searchQuery,
      'sort_by': sortBy.name,
      'sort_order': sortOrder.name,
    };
  }
}