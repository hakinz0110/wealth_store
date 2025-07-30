import 'validation_utils.dart';
import 'sanitization_utils.dart';
import '../exceptions/app_exceptions.dart';
import 'validation_interface.dart';

/// Entity-specific validation rules for all CRUD operations
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
    
    return null;
  }
  
  @override
  Map<String, dynamic> sanitizeData(Map<String, dynamic> data) {
    return SanitizationUtils.sanitizeFormData(data);
  }
  
  /// Product validation rules
  static Map<String, dynamic> get productRules => {
    'name': {
      'required': true,
      'label': 'Product Name',
      'minLength': 3,
      'maxLength': 100,
    },
    'description': {
      'required': false,
      'label': 'Description',
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
      'required': false,
      'label': 'Stock Quantity',
      'isInteger': true,
      'min': 0,
      'max': 999999,
    },
    'isActive': {
      'required': false,
      'label': 'Active Status',
    },
  };
  
  /// Category validation rules
  static Map<String, dynamic> get categoryRules => {
    'name': {
      'required': true,
      'label': 'Category Name',
      'minLength': 2,
      'maxLength': 50,
    },
    'description': {
      'required': false,
      'label': 'Description',
      'maxLength': 500,
    },
    'isActive': {
      'required': false,
      'label': 'Active Status',
    },
  };
  
  /// Order validation rules
  static Map<String, dynamic> get orderRules => {
    'customerId': {
      'required': true,
      'label': 'Customer ID',
      'pattern': r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      'patternError': 'Invalid customer ID format',
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
      'label': 'Order Status',
      'pattern': r'^(pending|confirmed|shipped|delivered|cancelled)$',
      'patternError': 'Invalid order status',
    },
    'shippingAddress': {
      'required': true,
      'label': 'Shipping Address',
    },
    'orderItems': {
      'required': true,
      'label': 'Order Items',
    },
  };
  
  /// Banner validation rules
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
    'isActive': {
      'required': false,
      'label': 'Active Status',
    },
    'displayOrder': {
      'required': false,
      'label': 'Display Order',
      'isInteger': true,
      'min': 0,
      'max': 999,
    },
  };
  
  /// Coupon validation rules
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
      'required': false,
      'label': 'Description',
      'maxLength': 500,
    },
    'discountType': {
      'required': true,
      'label': 'Discount Type',
      'pattern': r'^(percentage|fixed)$',
      'patternError': 'Discount type must be either "percentage" or "fixed"',
    },
    'discountValue': {
      'required': true,
      'label': 'Discount Value',
      'isNumeric': true,
      'min': 0.01,
      'max': 999999.99,
    },
    'minOrderAmount': {
      'required': false,
      'label': 'Minimum Order Amount',
      'isNumeric': true,
      'min': 0,
      'max': 999999.99,
    },
    'maxUses': {
      'required': false,
      'label': 'Maximum Uses',
      'isInteger': true,
      'min': 1,
      'max': 999999,
    },
    'expiresAt': {
      'required': false,
      'label': 'Expiration Date',
    },
    'isActive': {
      'required': false,
      'label': 'Active Status',
    },
  };
  
  /// User validation rules
  static Map<String, dynamic> get userRules => {
    'email': {
      'required': true,
      'label': 'Email',
      'isEmail': true,
    },
    'fullName': {
      'required': false,
      'label': 'Full Name',
      'minLength': 2,
      'maxLength': 100,
    },
    'role': {
      'required': true,
      'label': 'User Role',
      'pattern': r'^(admin|manager|customer)$',
      'patternError': 'Invalid user role',
    },
    'isActive': {
      'required': false,
      'label': 'Active Status',
    },
  };
  
  /// Validates product data
  ValidationException? validateProduct(Map<String, dynamic> productData) {
    final sanitizedData = sanitizeData(productData);
    return validateForm(sanitizedData, productRules);
  }
  
  /// Validates category data
  ValidationException? validateCategory(Map<String, dynamic> categoryData) {
    final sanitizedData = sanitizeData(categoryData);
    return validateForm(sanitizedData, categoryRules);
  }
  
  /// Validates order data
  ValidationException? validateOrder(Map<String, dynamic> orderData) {
    final sanitizedData = sanitizeData(orderData);
    return validateForm(sanitizedData, orderRules);
  }
  
  /// Validates banner data
  ValidationException? validateBanner(Map<String, dynamic> bannerData) {
    final sanitizedData = sanitizeData(bannerData);
    return validateForm(sanitizedData, bannerRules);
  }
  
  /// Validates coupon data
  ValidationException? validateCoupon(Map<String, dynamic> couponData) {
    final sanitizedData = sanitizeData(couponData);
    return validateForm(sanitizedData, couponRules);
  }
  
  /// Validates user data
  ValidationException? validateUser(Map<String, dynamic> userData) {
    final sanitizedData = sanitizeData(userData);
    return validateForm(sanitizedData, userRules);
  }
}