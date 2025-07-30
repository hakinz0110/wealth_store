import '../../models/product_models.dart';

class ProductValidation {
  static List<ProductValidationError> validateProductForm(ProductFormData data) {
    final errors = <ProductValidationError>[];

    // Name validation
    if (data.name.trim().isEmpty) {
      errors.add(const ProductValidationError(
        field: 'name',
        message: 'Product name is required',
      ));
    } else if (data.name.trim().length < 2) {
      errors.add(const ProductValidationError(
        field: 'name',
        message: 'Product name must be at least 2 characters long',
      ));
    } else if (data.name.trim().length > 100) {
      errors.add(const ProductValidationError(
        field: 'name',
        message: 'Product name must be less than 100 characters',
      ));
    }

    // Description validation
    if (data.description.trim().isEmpty) {
      errors.add(const ProductValidationError(
        field: 'description',
        message: 'Product description is required',
      ));
    } else if (data.description.trim().length < 10) {
      errors.add(const ProductValidationError(
        field: 'description',
        message: 'Product description must be at least 10 characters long',
      ));
    } else if (data.description.trim().length > 1000) {
      errors.add(const ProductValidationError(
        field: 'description',
        message: 'Product description must be less than 1000 characters',
      ));
    }

    // Price validation
    if (data.price <= 0) {
      errors.add(const ProductValidationError(
        field: 'price',
        message: 'Product price must be greater than 0',
      ));
    } else if (data.price > 999999.99) {
      errors.add(const ProductValidationError(
        field: 'price',
        message: 'Product price must be less than \$999,999.99',
      ));
    }

    // Stock validation
    if (data.stock < 0) {
      errors.add(const ProductValidationError(
        field: 'stock',
        message: 'Stock quantity cannot be negative',
      ));
    } else if (data.stock > 999999) {
      errors.add(const ProductValidationError(
        field: 'stock',
        message: 'Stock quantity must be less than 999,999',
      ));
    }

    // Category validation
    if (data.categoryId.trim().isEmpty) {
      errors.add(const ProductValidationError(
        field: 'categoryId',
        message: 'Product category is required',
      ));
    }

    // Image validation
    if (data.imageUrls.isEmpty) {
      errors.add(const ProductValidationError(
        field: 'imageUrls',
        message: 'At least one product image is required',
      ));
    } else if (data.imageUrls.length > 10) {
      errors.add(const ProductValidationError(
        field: 'imageUrls',
        message: 'Maximum 10 images allowed per product',
      ));
    }

    // Validate image URLs
    for (int i = 0; i < data.imageUrls.length; i++) {
      final url = data.imageUrls[i];
      if (!_isValidImageUrl(url)) {
        errors.add(ProductValidationError(
          field: 'imageUrls',
          message: 'Invalid image URL at position ${i + 1}',
        ));
      }
    }

    return errors;
  }

  static bool _isValidImageUrl(String url) {
    if (url.trim().isEmpty) return false;
    
    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return false;
      }
      
      // Check if URL ends with common image extensions
      final path = uri.path.toLowerCase();
      return path.endsWith('.jpg') ||
          path.endsWith('.jpeg') ||
          path.endsWith('.png') ||
          path.endsWith('.webp') ||
          path.endsWith('.gif');
    } catch (e) {
      return false;
    }
  }

  static String? validateProductName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Product name is required';
    }
    if (value.trim().length < 2) {
      return 'Product name must be at least 2 characters long';
    }
    if (value.trim().length > 100) {
      return 'Product name must be less than 100 characters';
    }
    return null;
  }

  static String? validateProductDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Product description is required';
    }
    if (value.trim().length < 10) {
      return 'Product description must be at least 10 characters long';
    }
    if (value.trim().length > 1000) {
      return 'Product description must be less than 1000 characters';
    }
    return null;
  }

  static String? validateProductPrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Product price is required';
    }
    
    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid price';
    }
    
    if (price <= 0) {
      return 'Product price must be greater than 0';
    }
    
    if (price > 999999.99) {
      return 'Product price must be less than \$999,999.99';
    }
    
    return null;
  }

  static String? validateProductStock(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Stock quantity is required';
    }
    
    final stock = int.tryParse(value);
    if (stock == null) {
      return 'Please enter a valid stock quantity';
    }
    
    if (stock < 0) {
      return 'Stock quantity cannot be negative';
    }
    
    if (stock > 999999) {
      return 'Stock quantity must be less than 999,999';
    }
    
    return null;
  }

  static String? validateCategory(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Product category is required';
    }
    return null;
  }

  static bool isValidProduct(ProductFormData data) {
    return validateProductForm(data).isEmpty;
  }

  static Map<String, String> getValidationErrors(ProductFormData data) {
    final errors = validateProductForm(data);
    final errorMap = <String, String>{};
    
    for (final error in errors) {
      if (!errorMap.containsKey(error.field)) {
        errorMap[error.field] = error.message;
      }
    }
    
    return errorMap;
  }
}