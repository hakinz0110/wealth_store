import 'validation_utils.dart';
import 'sanitization_utils.dart';
import '../exceptions/app_exceptions.dart';
import 'validation_interface.dart';

/// Entity-specific validation rules for all CRUD operations in the admin app
class EntityValidation implements ValidationInterface {
  /// Singleton instance
  static final EntityValidation _instance = EntityValidation._internal();
  
  /// Factory constructor
  factory EntityValidation() => _instance;
  
  /// Internal constructor
  EntityValidation._internal();
  
  @override
  ValidationException? validateForm(Map<String, dynamic> formData, Map<String, dynamic> rules) {
    return ValidationUtils.validateForm(formData, rules);
  }
  
  @override
  String? validateField(String field, dynamic value, Map<String, dynamic> rules) {
    final fieldRules = rules[field];
    if (fieldRules == null) return null;
    
    // Required check
    if (fieldRules['required'] == true && (value == null || value.toString().trim().isEmpty)) {
      return '${fieldRules['label'] ?? field} is required';
    }
    
    // Skip other validations if value is null or empty
    if (value == null || (value is String && value.trim().isEmpty)) {
      return null;
    }
    
    // Validate minimum length
    if (fieldRules['minLength'] != null && value.toString().length < fieldRules['minLength']) {
      return '${fieldRules['label'] ?? field} must be at least ${fieldRules['minLength']} characters';
    }
    
    // Validate maximum length
    if (fieldRules['maxLength'] != null && value.toString().length > fieldRules['maxLength']) {
      return '${fieldRules['label'] ?? field} must be no more than ${fieldRules['maxLength']} characters';
    }
    
    // Validate pattern
    if (fieldRules['pattern'] != null) {
      final pattern = RegExp(fieldRules['pattern']);
      if (!pattern.hasMatch(value.toString())) {
        return fieldRules['patternError'] ?? 'Invalid ${fieldRules['label'] ?? field} format';
      }
    }
    
    // Validate numeric
    if (fieldRules['isNumeric'] == true) {
      final numValue = double.tryParse(value.toString());
      if (numValue == null) {
        return '${fieldRules['label'] ?? field} must be a number';
      }
    }
    
    // Validate integer
    if (fieldRules['isInteger'] == true) {
      final intValue = int.tryParse(value.toString());
      if (intValue == null) {
        return '${fieldRules['label'] ?? field} must be a whole number';
      }
    }
    
    // Validate minimum value
    if (fieldRules['min'] != null) {
      final numValue = double.tryParse(value.toString());
      if (numValue != null && numValue < fieldRules['min']) {
        return '${fieldRules['label'] ?? field} must be at least ${fieldRules['min']}';
      }
    }
    
    // Validate maximum value
    if (fieldRules['max'] != null) {
      final numValue = double.tryParse(value.toString());
      if (numValue != null && numValue > fieldRules['max']) {
        return '${fieldRules['label'] ?? field} must be no more than ${fieldRules['max']}';
      }
    }
    
    // Custom validation
    if (fieldRules['validate'] != null && fieldRules['validate'] is Function) {
      return fieldRules['validate'](value);
    }
    
    return null;
  }
  
  @override
  String sanitizeInput(String input) {
    return SanitizationUtils.sanitizeInput(input);
  }
  
  @override
  Map<String, dynamic> sanitizeFormData(Map<String, dynamic> formData) {
    return SanitizationUtils.sanitizeFormData(formData);
  }
  
  /// Product validation rules for admin operations
  static Map<String, dynamic> get productRules => {
    'name': {
      'required': true,
      'label': 'Product Name',
      'minLength': 3,
      'maxLength': 100,
      'validate': (String value) {
        // Admin-specific validation - stricter rules
        if (value.toLowerCase().contains('test') && !_isDevelopmentMode()) {
          return 'Test products are not allowed in production';
        }
        return null;
      }
    },
    'description': {
      'required': true, // Required for admin
      'label': 'Description',
      'minLength': 10,
      'maxLength': 2000,
    },
    'price': {
      'required': true,
      'label': 'Price',
      'isNumeric': true,
      'min': 0.01,
      'max': 999999.99,
    },
    'categoryId': {
      'required': true,
      'label': 'Category',
      'pattern': r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      'patternError': 'Invalid category ID format',
    },
    'stockQuantity': {
      'required': true, // Required for admin
      'label': 'Stock Quantity',
      'isInteger': true,
      'min': 0,
      'max': 999999,
    },
    'sku': {
      'required': false,
      'label': 'SKU',
      'minLength': 3,
      'maxLength': 50,
      'pattern': r'^[A-Z0-9-_]+$',
      'patternError': 'SKU can only contain uppercase letters, numbers, hyphens, and underscores',
    },
    'weight': {
      'required': false,
      'label': 'Weight',
      'isNumeric': true,
      'min': 0,
      'max': 999999,
    },
    'dimensions': {
      'required': false,
      'label': 'Dimensions',
      'validate': (dynamic value) {
        if (value == null) return null;
        
        if (value is! Map) {
          return 'Dimensions must be a valid object with length, width, and height';
        }
        
        final dims = value as Map<String, dynamic>;
        final requiredFields = ['length', 'width', 'height'];
        
        for (final field in requiredFields) {
          if (dims[field] != null) {
            final numValue = double.tryParse(dims[field].toString());
            if (numValue == null || numValue < 0) {
              return 'Invalid $field dimension';
            }
          }
        }
        
        return null;
      }
    },
  };

  /// Category validation rules for admin operations
  static Map<String, dynamic> get categoryRules => {
    'name': {
      'required': true,
      'label': 'Category Name',
      'minLength': 2,
      'maxLength': 50,
      'validate': (String value) {
        // Check for reserved names
        final reserved = ['uncategorized', 'all', 'none', 'default'];
        if (reserved.contains(value.toLowerCase())) {
          return 'Category name "$value" is reserved';
        }
        return null;
      }
    },
    'description': {
      'required': true, // Required for admin
      'label': 'Description',
      'minLength': 10,
      'maxLength': 1000,
    },
    'imageUrl': {
      'required': false,
      'label': 'Image URL',
      'isUrl': true,
    },
    'slug': {
      'required': false,
      'label': 'URL Slug',
      'isSlug': true,
      'minLength': 2,
      'maxLength': 50,
    },
    'parentId': {
      'required': false,
      'label': 'Parent Category',
      'pattern': r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      'patternError': 'Invalid parent category ID format',
    },
    'sortOrder': {
      'required': false,
      'label': 'Sort Order',
      'isInteger': true,
      'min': 0,
      'max': 999,
    },
  };

  /// Order validation rules for admin operations
  static Map<String, dynamic> get orderRules => {
    'userId': {
      'required': true,
      'label': 'User ID',
      'pattern': r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      'patternError': 'Invalid user ID format',
    },
    'totalAmount': {
      'required': true,
      'label': 'Total Amount',
      'isNumeric': true,
      'min': 0.01,
      'max': 999999.99,
    },
    'status': {
      'required': true,
      'label': 'Status',
      'validate': (String value) {
        final validStatuses = ['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded'];
        if (!validStatuses.contains(value.toLowerCase())) {
          return 'Invalid order status';
        }
        return null;
      }
    },
    'shippingAddress': {
      'required': true,
      'label': 'Shipping Address',
      'validate': (dynamic value) {
        if (value is! Map) {
          return 'Shipping address must be a valid address object';
        }
        
        final address = value as Map<String, dynamic>;
        final requiredFields = ['street', 'city', 'state', 'zipCode', 'country'];
        
        for (final field in requiredFields) {
          if (address[field] == null || address[field].toString().trim().isEmpty) {
            return 'Shipping address is missing required field: $field';
          }
        }
        
        // Validate zip code format
        final zipCode = address['zipCode'].toString();
        if (!RegExp(r'^\d{5}(-\d{4})?$').hasMatch(zipCode)) {
          return 'Invalid zip code format';
        }
        
        return null;
      }
    },
    'orderItems': {
      'required': true,
      'label': 'Order Items',
      'validate': (dynamic value) {
        if (value is! List || (value as List).isEmpty) {
          return 'Order must contain at least one item';
        }
        
        final items = value as List;
        for (int i = 0; i < items.length; i++) {
          final item = items[i];
          if (item is! Map) {
            return 'Order item ${i + 1} is invalid';
          }
          
          final itemMap = item as Map<String, dynamic>;
          final requiredFields = ['productId', 'quantity', 'price'];
          
          for (final field in requiredFields) {
            if (itemMap[field] == null) {
              return 'Order item ${i + 1} is missing required field: $field';
            }
          }
          
          // Validate quantity
          final quantity = int.tryParse(itemMap['quantity'].toString());
          if (quantity == null || quantity < 1) {
            return 'Order item ${i + 1} has invalid quantity';
          }
          
          // Validate price
          final price = double.tryParse(itemMap['price'].toString());
          if (price == null || price < 0) {
            return 'Order item ${i + 1} has invalid price';
          }
        }
        
        return null;
      }
    },
    'notes': {
      'required': false,
      'label': 'Admin Notes',
      'maxLength': 1000,
    },
    'trackingNumber': {
      'required': false,
      'label': 'Tracking Number',
      'minLength': 5,
      'maxLength': 50,
    },
  };

  /// Banner validation rules for admin operations
  static Map<String, dynamic> get bannerRules => {
    'title': {
      'required': true,
      'label': 'Banner Title',
      'minLength': 3,
      'maxLength': 100,
    },
    'description': {
      'required': false,
      'label': 'Description',
      'maxLength': 500,
    },
    'imageUrl': {
      'required': true,
      'label': 'Image URL',
      'isUrl': true,
    },
    'linkUrl': {
      'required': false,
      'label': 'Link URL',
      'isUrl': true,
    },
    'displayOrder': {
      'required': false,
      'label': 'Display Order',
      'isInteger': true,
      'min': 0,
      'max': 999,
    },
    'startDate': {
      'required': false,
      'label': 'Start Date',
      'validate': (String? value) {
        if (value == null || value.isEmpty) return null;
        
        final date = DateTime.tryParse(value);
        if (date == null) {
          return 'Invalid start date format';
        }
        
        return null;
      }
    },
    'endDate': {
      'required': false,
      'label': 'End Date',
      'validate': (String? value, Map<String, dynamic> formData) {
        if (value == null || value.isEmpty) return null;
        
        final endDate = DateTime.tryParse(value);
        if (endDate == null) {
          return 'Invalid end date format';
        }
        
        final startDateStr = formData['startDate']?.toString();
        if (startDateStr != null && startDateStr.isNotEmpty) {
          final startDate = DateTime.tryParse(startDateStr);
          if (startDate != null && endDate.isBefore(startDate)) {
            return 'End date must be after start date';
          }
        }
        
        return null;
      }
    },
    'targetAudience': {
      'required': false,
      'label': 'Target Audience',
      'validate': (String? value) {
        if (value == null || value.isEmpty) return null;
        
        final validAudiences = ['all', 'new_customers', 'returning_customers', 'vip_customers'];
        if (!validAudiences.contains(value.toLowerCase())) {
          return 'Invalid target audience';
        }
        
        return null;
      }
    },
  };

  /// Coupon validation rules for admin operations
  static Map<String, dynamic> get couponRules => {
    'code': {
      'required': true,
      'label': 'Coupon Code',
      'minLength': 3,
      'maxLength': 20,
      'pattern': r'^[A-Z0-9_-]+$',
      'patternError': 'Coupon code can only contain uppercase letters, numbers, underscores, and hyphens',
    },
    'description': {
      'required': true, // Required for admin
      'label': 'Description',
      'minLength': 10,
      'maxLength': 500,
    },
    'discountType': {
      'required': true,
      'label': 'Discount Type',
      'validate': (String value) {
        final validTypes = ['percentage', 'fixed', 'buy_one_get_one', 'free_shipping'];
        if (!validTypes.contains(value.toLowerCase())) {
          return 'Invalid discount type';
        }
        return null;
      }
    },
    'discountValue': {
      'required': true,
      'label': 'Discount Value',
      'isNumeric': true,
      'min': 0.01,
      'validate': (String value, Map<String, dynamic> formData) {
        final numValue = double.tryParse(value);
        if (numValue == null) return 'Discount value must be a number';
        
        final discountType = formData['discountType']?.toString().toLowerCase();
        if (discountType == 'percentage' && numValue > 100) {
          return 'Percentage discount cannot exceed 100%';
        }
        
        if (discountType == 'free_shipping' && numValue != 0) {
          return 'Free shipping discount value should be 0';
        }
        
        return null;
      }
    },
    'minOrderAmount': {
      'required': false,
      'label': 'Minimum Order Amount',
      'isNumeric': true,
      'min': 0,
    },
    'maxUses': {
      'required': false,
      'label': 'Maximum Uses',
      'isInteger': true,
      'min': 1,
    },
    'maxUsesPerUser': {
      'required': false,
      'label': 'Maximum Uses Per User',
      'isInteger': true,
      'min': 1,
    },
    'expiresAt': {
      'required': false,
      'label': 'Expiration Date',
      'isFutureDate': true,
    },
    'applicableCategories': {
      'required': false,
      'label': 'Applicable Categories',
      'validate': (dynamic value) {
        if (value == null) return null;
        
        if (value is! List) {
          return 'Applicable categories must be a list';
        }
        
        final categories = value as List;
        for (final categoryId in categories) {
          if (!RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(categoryId.toString())) {
            return 'Invalid category ID format in applicable categories';
          }
        }
        
        return null;
      }
    },
  };

  /// User management validation rules for admin operations
  static Map<String, dynamic> get userRules => {
    'email': {
      'required': true,
      'label': 'Email',
      'isEmail': true,
    },
    'fullName': {
      'required': true,
      'label': 'Full Name',
      'minLength': 2,
      'maxLength': 100,
    },
    'username': {
      'required': false,
      'label': 'Username',
      'minLength': 3,
      'maxLength': 30,
      'pattern': r'^[a-zA-Z0-9_]+$',
      'patternError': 'Username can only contain letters, numbers, and underscores',
    },
    'role': {
      'required': true,
      'label': 'Role',
      'validate': (String value) {
        final validRoles = ['admin', 'manager', 'customer', 'moderator'];
        if (!validRoles.contains(value.toLowerCase())) {
          return 'Invalid user role';
        }
        return null;
      }
    },
    'permissions': {
      'required': false,
      'label': 'Permissions',
      'validate': (dynamic value) {
        if (value == null) return null;
        
        if (value is! List) {
          return 'Permissions must be a list';
        }
        
        final permissions = value as List;
        final validPermissions = [
          'manage_products',
          'manage_categories',
          'manage_orders',
          'manage_users',
          'manage_banners',
          'manage_coupons',
          'view_analytics',
          'manage_settings',
        ];
        
        for (final permission in permissions) {
          if (!validPermissions.contains(permission.toString())) {
            return 'Invalid permission: $permission';
          }
        }
        
        return null;
      }
    },
  };

  /// File upload validation rules for admin operations
  static Map<String, dynamic> get fileUploadRules => {
    'filename': {
      'required': true,
      'label': 'Filename',
      'minLength': 1,
      'maxLength': 255,
      'validate': (String value) {
        // Check for dangerous file extensions
        final dangerousExtensions = ['.exe', '.bat', '.cmd', '.scr', '.pif', '.com', '.js', '.php', '.asp'];
        final extension = value.toLowerCase().substring(value.lastIndexOf('.'));
        
        if (dangerousExtensions.contains(extension)) {
          return 'File type not allowed for security reasons';
        }
        
        return null;
      }
    },
    'fileSize': {
      'required': true,
      'label': 'File Size',
      'isInteger': true,
      'min': 1,
      'max': 52428800, // 50MB in bytes for admin
    },
    'mimeType': {
      'required': true,
      'label': 'File Type',
      'validate': (String value) {
        final allowedTypes = [
          'image/jpeg',
          'image/png',
          'image/gif',
          'image/webp',
          'image/svg+xml',
          'application/pdf',
          'text/plain',
          'text/csv',
          'application/json',
          'application/xml',
        ];
        
        if (!allowedTypes.contains(value.toLowerCase())) {
          return 'File type not supported';
        }
        
        return null;
      }
    },
    'bucket': {
      'required': true,
      'label': 'Storage Bucket',
      'validate': (String value) {
        final validBuckets = ['products', 'categories', 'banners', 'documents', 'temp'];
        if (!validBuckets.contains(value.toLowerCase())) {
          return 'Invalid storage bucket';
        }
        return null;
      }
    },
  };

  /// Validates product data with admin-specific rules
  static ValidationException? validateProduct(Map<String, dynamic> productData) {
    final sanitizedData = SanitizationUtils.sanitizeFormData(productData);
    return ValidationUtils.validateForm(sanitizedData, productRules);
  }

  /// Validates category data with admin-specific rules
  static ValidationException? validateCategory(Map<String, dynamic> categoryData) {
    final sanitizedData = SanitizationUtils.sanitizeFormData(categoryData);
    return ValidationUtils.validateForm(sanitizedData, categoryRules);
  }

  /// Validates order data with admin-specific rules
  static ValidationException? validateOrder(Map<String, dynamic> orderData) {
    final sanitizedData = SanitizationUtils.sanitizeFormData(orderData);
    return ValidationUtils.validateForm(sanitizedData, orderRules);
  }

  /// Validates banner data with admin-specific rules
  static ValidationException? validateBanner(Map<String, dynamic> bannerData) {
    final sanitizedData = SanitizationUtils.sanitizeFormData(bannerData);
    return ValidationUtils.validateForm(sanitizedData, bannerRules);
  }

  /// Validates coupon data with admin-specific rules
  static ValidationException? validateCoupon(Map<String, dynamic> couponData) {
    final sanitizedData = SanitizationUtils.sanitizeFormData(couponData);
    return ValidationUtils.validateForm(sanitizedData, couponRules);
  }

  /// Validates user data with admin-specific rules
  static ValidationException? validateUser(Map<String, dynamic> userData) {
    final sanitizedData = SanitizationUtils.sanitizeFormData(userData);
    return ValidationUtils.validateForm(sanitizedData, userRules);
  }

  /// Validates file upload data with admin-specific rules
  static ValidationException? validateFileUpload(Map<String, dynamic> fileData) {
    return ValidationUtils.validateForm(fileData, fileUploadRules);
  }

  /// Validates bulk operations
  static ValidationException? validateBulkOperation(Map<String, dynamic> operationData) {
    final rules = {
      'operation': {
        'required': true,
        'label': 'Operation',
        'validate': (String value) {
          final validOperations = ['delete', 'activate', 'deactivate', 'update_category', 'update_status'];
          if (!validOperations.contains(value.toLowerCase())) {
            return 'Invalid bulk operation';
          }
          return null;
        }
      },
      'ids': {
        'required': true,
        'label': 'Item IDs',
        'validate': (dynamic value) {
          if (value is! List || (value as List).isEmpty) {
            return 'At least one item must be selected';
          }
          
          final ids = value as List;
          if (ids.length > 100) {
            return 'Cannot process more than 100 items at once';
          }
          
          for (final id in ids) {
            if (!RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(id.toString())) {
              return 'Invalid ID format: $id';
            }
          }
          
          return null;
        }
      },
    };

    return ValidationUtils.validateForm(operationData, rules);
  }

  /// Validates admin settings
  static ValidationException? validateSettings(Map<String, dynamic> settingsData) {
    final rules = {
      'siteName': {
        'required': true,
        'label': 'Site Name',
        'minLength': 2,
        'maxLength': 100,
      },
      'siteDescription': {
        'required': false,
        'label': 'Site Description',
        'maxLength': 500,
      },
      'contactEmail': {
        'required': true,
        'label': 'Contact Email',
        'isEmail': true,
      },
      'currency': {
        'required': true,
        'label': 'Currency',
        'pattern': r'^[A-Z]{3}$',
        'patternError': 'Currency must be a 3-letter code (e.g., USD)',
      },
      'taxRate': {
        'required': false,
        'label': 'Tax Rate',
        'isNumeric': true,
        'min': 0,
        'max': 100,
      },
      'shippingCost': {
        'required': false,
        'label': 'Shipping Cost',
        'isNumeric': true,
        'min': 0,
      },
      'freeShippingThreshold': {
        'required': false,
        'label': 'Free Shipping Threshold',
        'isNumeric': true,
        'min': 0,
      },
    };

    final sanitizedData = SanitizationUtils.sanitizeFormData(settingsData);
    return ValidationUtils.validateForm(sanitizedData, rules);
  }

  /// Helper method to check if we're in development mode
  static bool _isDevelopmentMode() {
    // This would typically check an environment variable or build configuration
    return const bool.fromEnvironment('DEVELOPMENT_MODE', defaultValue: false);
  }
}