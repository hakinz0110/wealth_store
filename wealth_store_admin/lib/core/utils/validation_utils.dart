import '../exceptions/app_exceptions.dart';

/// Utility class for input validation and sanitization in the admin app
class ValidationUtils {
  /// Email validation regex pattern
  static final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  /// Password validation regex pattern (min 8 chars, at least 1 letter, 1 number, and 1 special char)
  static final RegExp _strongPasswordPattern = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$',
  );
  
  /// URL validation regex pattern
  static final RegExp _urlPattern = RegExp(
    r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );
  
  /// Slug validation regex pattern (for URL-friendly strings)
  static final RegExp _slugPattern = RegExp(
    r'^[a-z0-9]+(?:-[a-z0-9]+)*$',
  );
  
  /// Hex color validation regex pattern
  static final RegExp _hexColorPattern = RegExp(
    r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$',
  );
  
  /// Validates an email address
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    
    if (!_emailPattern.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  /// Validates a strong password (for admin users)
  static String? validateStrongPassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    if (!_strongPasswordPattern.hasMatch(password)) {
      return 'Password must contain at least one letter, one number, and one special character';
    }
    
    return null;
  }
  
  /// Validates a product name
  static String? validateProductName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Product name is required';
    }
    
    if (name.length < 3) {
      return 'Product name must be at least 3 characters long';
    }
    
    if (name.length > 100) {
      return 'Product name must be less than 100 characters long';
    }
    
    return null;
  }
  
  /// Validates a product price
  static String? validatePrice(String? price) {
    if (price == null || price.isEmpty) {
      return 'Price is required';
    }
    
    final numValue = double.tryParse(price);
    if (numValue == null) {
      return 'Price must be a valid number';
    }
    
    if (numValue < 0) {
      return 'Price cannot be negative';
    }
    
    return null;
  }
  
  /// Validates a product stock quantity
  static String? validateStockQuantity(String? quantity) {
    if (quantity == null || quantity.isEmpty) {
      return null; // Stock might be optional
    }
    
    final numValue = int.tryParse(quantity);
    if (numValue == null) {
      return 'Stock quantity must be a whole number';
    }
    
    if (numValue < 0) {
      return 'Stock quantity cannot be negative';
    }
    
    return null;
  }
  
  /// Validates a category name
  static String? validateCategoryName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Category name is required';
    }
    
    if (name.length < 2) {
      return 'Category name must be at least 2 characters long';
    }
    
    if (name.length > 50) {
      return 'Category name must be less than 50 characters long';
    }
    
    return null;
  }
  
  /// Validates a URL
  static String? validateUrl(String? url) {
    if (url == null || url.isEmpty) {
      return null; // URL might be optional
    }
    
    if (!_urlPattern.hasMatch(url)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }
  
  /// Validates a slug (URL-friendly string)
  static String? validateSlug(String? slug) {
    if (slug == null || slug.isEmpty) {
      return 'Slug is required';
    }
    
    if (!_slugPattern.hasMatch(slug)) {
      return 'Slug must contain only lowercase letters, numbers, and hyphens';
    }
    
    return null;
  }
  
  /// Validates a hex color code
  static String? validateHexColor(String? color) {
    if (color == null || color.isEmpty) {
      return null; // Color might be optional
    }
    
    if (!_hexColorPattern.hasMatch(color)) {
      return 'Please enter a valid hex color code (e.g., #FF5733)';
    }
    
    return null;
  }
  
  /// Validates a coupon code
  static String? validateCouponCode(String? code) {
    if (code == null || code.isEmpty) {
      return 'Coupon code is required';
    }
    
    if (code.length < 3 || code.length > 20) {
      return 'Coupon code must be between 3 and 20 characters';
    }
    
    if (!RegExp(r'^[A-Z0-9_-]+$').hasMatch(code)) {
      return 'Coupon code can only contain uppercase letters, numbers, underscores, and hyphens';
    }
    
    return null;
  }
  
  /// Validates a discount value
  static String? validateDiscountValue(String? value, String discountType) {
    if (value == null || value.isEmpty) {
      return 'Discount value is required';
    }
    
    final numValue = double.tryParse(value);
    if (numValue == null) {
      return 'Discount value must be a valid number';
    }
    
    if (numValue <= 0) {
      return 'Discount value must be greater than zero';
    }
    
    if (discountType == 'percentage' && numValue > 100) {
      return 'Percentage discount cannot exceed 100%';
    }
    
    return null;
  }
  
  /// Validates a required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    return null;
  }
  
  /// Validates a numeric field
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return null; // Field might be optional
    }
    
    if (double.tryParse(value) == null) {
      return '$fieldName must be a number';
    }
    
    return null;
  }
  
  /// Validates an integer field
  static String? validateInteger(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return null; // Field might be optional
    }
    
    if (int.tryParse(value) == null) {
      return '$fieldName must be a whole number';
    }
    
    return null;
  }
  
  /// Validates a minimum value
  static String? validateMin(String? value, double min, String fieldName) {
    if (value == null || value.isEmpty) {
      return null; // Field might be optional
    }
    
    final numValue = double.tryParse(value);
    if (numValue == null) {
      return '$fieldName must be a number';
    }
    
    if (numValue < min) {
      return '$fieldName must be at least $min';
    }
    
    return null;
  }
  
  /// Validates a maximum value
  static String? validateMax(String? value, double max, String fieldName) {
    if (value == null || value.isEmpty) {
      return null; // Field might be optional
    }
    
    final numValue = double.tryParse(value);
    if (numValue == null) {
      return '$fieldName must be a number';
    }
    
    if (numValue > max) {
      return '$fieldName must be no more than $max';
    }
    
    return null;
  }
  
  /// Validates a field length
  static String? validateLength(String? value, int minLength, int maxLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return null; // Field might be optional
    }
    
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    
    if (value.length > maxLength) {
      return '$fieldName must be no more than $maxLength characters';
    }
    
    return null;
  }
  
  /// Validates a date in the future
  static String? validateFutureDate(String? dateStr, String fieldName) {
    if (dateStr == null || dateStr.isEmpty) {
      return null; // Date might be optional
    }
    
    final date = DateTime.tryParse(dateStr);
    if (date == null) {
      return 'Invalid date format';
    }
    
    if (date.isBefore(DateTime.now())) {
      return '$fieldName must be in the future';
    }
    
    return null;
  }
  
  /// Validates a form with multiple fields
  static ValidationException? validateForm(Map<String, dynamic> formData, Map<String, dynamic> rules) {
    final errors = <String, List<String>>{};
    
    rules.forEach((field, fieldRules) {
      final value = formData[field]?.toString();
      final fieldErrors = <String>[];
      
      // Required check
      if (fieldRules['required'] == true && (value == null || value.trim().isEmpty)) {
        fieldErrors.add('${fieldRules['label'] ?? field} is required');
      }
      
      // Skip other validations if value is null or empty
      if (value != null && value.trim().isNotEmpty) {
        // Validate minimum length
        if (fieldRules['minLength'] != null && value.length < fieldRules['minLength']) {
          fieldErrors.add('${fieldRules['label'] ?? field} must be at least ${fieldRules['minLength']} characters');
        }
        
        // Validate maximum length
        if (fieldRules['maxLength'] != null && value.length > fieldRules['maxLength']) {
          fieldErrors.add('${fieldRules['label'] ?? field} must be no more than ${fieldRules['maxLength']} characters');
        }
        
        // Validate pattern
        if (fieldRules['pattern'] != null) {
          final pattern = RegExp(fieldRules['pattern']);
          if (!pattern.hasMatch(value)) {
            fieldErrors.add(fieldRules['patternError'] ?? 'Invalid ${fieldRules['label'] ?? field} format');
          }
        }
        
        // Validate email
        if (fieldRules['isEmail'] == true && !_emailPattern.hasMatch(value)) {
          fieldErrors.add('Please enter a valid email address');
        }
        
        // Validate strong password
        if (fieldRules['isStrongPassword'] == true && !_strongPasswordPattern.hasMatch(value)) {
          fieldErrors.add('Password must contain at least one letter, one number, and one special character');
        }
        
        // Validate URL
        if (fieldRules['isUrl'] == true && !_urlPattern.hasMatch(value)) {
          fieldErrors.add('Please enter a valid URL');
        }
        
        // Validate slug
        if (fieldRules['isSlug'] == true && !_slugPattern.hasMatch(value)) {
          fieldErrors.add('${fieldRules['label'] ?? field} must contain only lowercase letters, numbers, and hyphens');
        }
        
        // Validate numeric
        if (fieldRules['isNumeric'] == true && double.tryParse(value) == null) {
          fieldErrors.add('${fieldRules['label'] ?? field} must be a number');
        }
        
        // Validate integer
        if (fieldRules['isInteger'] == true && int.tryParse(value) == null) {
          fieldErrors.add('${fieldRules['label'] ?? field} must be a whole number');
        }
        
        // Validate minimum value
        if (fieldRules['min'] != null) {
          final numValue = double.tryParse(value);
          if (numValue != null && numValue < fieldRules['min']) {
            fieldErrors.add('${fieldRules['label'] ?? field} must be at least ${fieldRules['min']}');
          }
        }
        
        // Validate maximum value
        if (fieldRules['max'] != null) {
          final numValue = double.tryParse(value);
          if (numValue != null && numValue > fieldRules['max']) {
            fieldErrors.add('${fieldRules['label'] ?? field} must be no more than ${fieldRules['max']}');
          }
        }
        
        // Validate future date
        if (fieldRules['isFutureDate'] == true) {
          final date = DateTime.tryParse(value);
          if (date != null && date.isBefore(DateTime.now())) {
            fieldErrors.add('${fieldRules['label'] ?? field} must be in the future');
          }
        }
        
        // Custom validation
        if (fieldRules['validate'] != null && fieldRules['validate'] is Function) {
          final customError = fieldRules['validate'](value);
          if (customError != null && customError.isNotEmpty) {
            fieldErrors.add(customError);
          }
        }
      }
      
      if (fieldErrors.isNotEmpty) {
        errors[field] = fieldErrors;
      }
    });
    
    if (errors.isNotEmpty) {
      return ValidationException(
        'Please correct the errors in the form',
        code: 'FORM_VALIDATION_ERROR',
        fieldErrors: errors,
      );
    }
    
    return null;
  }
  
  /// Sanitizes user input to prevent XSS and injection attacks
  static String sanitizeInput(String input) {
    // Replace potentially dangerous HTML characters
    return input
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#x27;')
      .replaceAll('/', '&#x2F;');
  }
  
  /// Sanitizes a map of form data
  static Map<String, dynamic> sanitizeFormData(Map<String, dynamic> formData) {
    final sanitized = <String, dynamic>{};
    
    formData.forEach((key, value) {
      if (value is String) {
        sanitized[key] = sanitizeInput(value);
      } else if (value is Map) {
        sanitized[key] = sanitizeFormData(Map<String, dynamic>.from(value));
      } else if (value is List) {
        sanitized[key] = value.map((item) {
          if (item is String) {
            return sanitizeInput(item);
          } else if (item is Map) {
            return sanitizeFormData(Map<String, dynamic>.from(item));
          }
          return item;
        }).toList();
      } else {
        sanitized[key] = value;
      }
    });
    
    return sanitized;
  }
  
  /// Sanitizes HTML content for rich text fields
  static String sanitizeHtml(String html) {
    // This is a basic implementation - in production, use a proper HTML sanitizer library
    
    // Remove script tags and their content
    html = html.replaceAll(RegExp(r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>'), '');
    
    // Remove iframe tags
    html = html.replaceAll(RegExp(r'<iframe\b[^<]*(?:(?!<\/iframe>)<[^<]*)*<\/iframe>'), '');
    
    // Remove on* attributes (onclick, onload, etc.)
    html = html.replaceAll(RegExp(r' on\w+="[^"]*"'), '');
    
    // Remove javascript: URLs
    html = html.replaceAll(RegExp(r'javascript:', caseSensitive: false), 'invalid:');
    
    return html;
  }
} 
 /// Validates search query
  static String? validateSearchQuery(String? query) {
    if (query == null || query.isEmpty) {
      return 'Search query cannot be empty';
    }
    
    if (query.length < 2) {
      return 'Search query must be at least 2 characters long';
    }
    
    if (query.length > 100) {
      return 'Search query cannot exceed 100 characters';
    }
    
    // Check for potentially dangerous patterns
    final dangerousPatterns = ['<script', 'javascript:', 'data:', 'vbscript:'];
    final lowerQuery = query.toLowerCase();
    
    for (final pattern in dangerousPatterns) {
      if (lowerQuery.contains(pattern)) {
        return 'Search query contains invalid characters';
      }
    }
    
    return null;
  }
}