class ProductVariation {
  final String color; // e.g., "green", "black", "red"
  final String size; // e.g., "EU 30", "EU 32"
  final double price;
  final bool inStock;

  ProductVariation({
    required this.color,
    required this.size,
    required this.price,
    required this.inStock,
  });

  factory ProductVariation.fromJson(Map<String, dynamic> json) {
    return ProductVariation(
      color: json['color'] ?? '',
      size: json['size'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      inStock: json['inStock'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'color': color, 'size': size, 'price': price, 'inStock': inStock};
  }
}

class ProductModel {
  final String id;
  final String name;
  final String category;
  final List<String> subcategories;
  final double price;
  final String imageUrl;
  final String description;
  final double rating;
  final bool isFavorite;
  final String? brand;
  final String? color;
  final String? size;
  final String type; // 'single' or 'variation'
  final List<ProductVariation>? variations;
  final double discountPercentage;
  final bool isFeatured;
  final bool isNew;
  final bool isPopular;
  final bool isDeal;
  final bool isVisible;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    this.subcategories = const [],
    required this.price,
    required this.imageUrl,
    this.description = '',
    this.rating = 0.0,
    this.isFavorite = false,
    this.brand,
    this.color,
    this.size,
    this.type = 'single',
    this.variations,
    this.discountPercentage = 0.0,
    this.isFeatured = true,
    this.isNew = false,
    this.isPopular = false,
    this.isDeal = false,
    this.isVisible = true,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      subcategories: json['subcategories'] != null
          ? List<String>.from(json['subcategories'])
          : [],
      price: (json['price'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      isFavorite: json['isFavorite'] ?? false,
      brand: json['brand'],
      color: json['color'],
      size: json['size'],
      type: json['type'] ?? 'single',
      variations: json['variations'] != null
          ? (json['variations'] as List)
                .map((v) => ProductVariation.fromJson(v))
                .toList()
          : null,
      discountPercentage: (json['discountPercentage'] ?? 0.0).toDouble(),
      isFeatured: json['isFeatured'] ?? true,
      isNew: json['isNew'] ?? false,
      isPopular: json['isPopular'] ?? false,
      isDeal: json['isDeal'] ?? false,
      isVisible: json['isVisible'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'subcategories': subcategories,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
      'rating': rating,
      'isFavorite': isFavorite,
      'brand': brand,
      'color': color,
      'size': size,
      'type': type,
      'variations': variations?.map((v) => v.toJson()).toList(),
      'discountPercentage': discountPercentage,
      'isFeatured': isFeatured,
      'isNew': isNew,
      'isPopular': isPopular,
      'isDeal': isDeal,
      'isVisible': isVisible,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? category,
    List<String>? subcategories,
    double? price,
    String? imageUrl,
    String? description,
    double? rating,
    bool? isFavorite,
    String? brand,
    String? color,
    String? size,
    String? type,
    List<ProductVariation>? variations,
    double? discountPercentage,
    bool? isFeatured,
    bool? isNew,
    bool? isPopular,
    bool? isDeal,
    bool? isVisible,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      subcategories: subcategories ?? this.subcategories,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
      brand: brand ?? this.brand,
      color: color ?? this.color,
      size: size ?? this.size,
      type: type ?? this.type,
      variations: variations ?? this.variations,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      isFeatured: isFeatured ?? this.isFeatured,
      isNew: isNew ?? this.isNew,
      isPopular: isPopular ?? this.isPopular,
      isDeal: isDeal ?? this.isDeal,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}
