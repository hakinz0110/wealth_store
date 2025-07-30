import '../exceptions/app_exceptions.dart';

/// Utility class for input validation and sanitization
class ValidationUtils {
  /// Email validation regex pattern
  static final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  /// Password validation regex pattern (min 8 chars, at least 1 letter and 1 number)
  static final RegExp _passwordPattern = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$',
  );
  
  /// Phone number validation regex pattern
  static final RegExp _phonePattern = RegExp(
    r'^\+?[0-9]{10,15}$',
  );
  
  /// URL validation regex pattern
  static final RegExp _urlPattern = RegExp(
    r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );
  
  /// Zip/Postal code validation regex pattern
  static final RegExp _zipPattern = RegExp(
    r'^\d{5}(-\d{4})?$',
  );
  
  /// Credit card number validation regex pattern
  static final RegExp _creditCardPattern = RegExp(
    r'^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|3[47][0-9]{13}|6(?:011|5[0-9]{2})[0-9]{12})$',
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
  
  /// Validates a password
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    if (!_passwordPattern.hasMatch(password)) {
      return 'Password must contain at least one letter and one number';
    }
    
    return null;
  }
  
  /// Validates a name field
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }
    
    if (name.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    
    if (name.length > 50) {
      return 'Name must be less than 50 characters long';
    }
    
    return null;
  }
  
  /// Validates a phone number
  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return null; // Phone might be optional
    }
    
    if (!_phonePattern.hasMatch(phone)) {
      return 'Please enter a valid phone number';
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
  
  /// Validates a zip/postal code
  static String? validateZip(String? zip) {
    if (zip == null || zip.isEmpty) {
      return null; // Zip might be optional
    }
    
    if (!_zipPattern.hasMatch(zip)) {
      return 'Please enter a valid zip code';
    }
    
    return null;
  }
  
  /// Validates a credit card number
  static String? validateCreditCard(String? cardNumber) {
    if (cardNumber == null || cardNumber.isEmpty) {
      return 'Credit card number is required';
    }
    
    // Remove spaces and dashes
    final cleanNumber = cardNumber.replaceAll(RegExp(r'[\s-]'), '');
    
    if (!_creditCardPattern.hasMatch(cleanNumber)) {
      return 'Please enter a valid credit card number';
    }
    
    // Luhn algorithm check
    if (!_isValidLuhn(cleanNumber)) {
      return 'Invalid credit card number';
    }
    
    return null;
  }
  
  /// Validates a credit card expiration date
  static String? validateCardExpiry(String? expiry) {
    if (expiry == null || expiry.isEmpty) {
      return 'Expiration date is required';
    }
    
    // Check format (MM/YY)
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiry)) {
      return 'Please use MM/YY format';
    }
    
    final parts = expiry.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    
    if (month == null || year == null) {
      return 'Invalid expiration date';
    }
    
    if (month < 1 || month > 12) {
      return 'Invalid month';
    }
    
    // Convert 2-digit year to 4-digit year
    final currentYear = DateTime.now().year % 100;
    final fullYear = 2000 + year;
    final currentMonth = DateTime.now().month;
    
    // Check if card is expired
    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return 'Card has expired';
    }
    
    return null;
  }
  
  /// Validates a CVV code
  static String? validateCVV(String? cvv) {
    if (cvv == null || cvv.isEmpty) {
      return 'CVV is required';
    }
    
    if (!RegExp(r'^\d{3,4}$').hasMatch(cvv)) {
      return 'CVV must be 3 or 4 digits';
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
  
  /// Validates a form with multiple fields
  static ValidationException? validateForm(Map<String, dynamic> formData, Map<String, dynamic> rules) {
    final errors = <String, String>{};
    
    rules.forEach((field, fieldRules) {
      final value = formData[field]?.toString();
      String? error;
      
      // Required check
      if (fieldRules['required'] == true) {
        error = validateRequired(value, fieldRules['label'] ?? field);
        if (error != null) {
          errors[field] = error;
          return; // Skip other validations if required field is empty
        }
      }
      
      // Skip other validations if value is null or empty
      if (value == null || value.isEmpty) {
        return;
      }
      
      // Email check
      if (fieldRules['isEmail'] == true) {
        error = validateEmail(value);
        if (error != null) {
          errors[field] = error;
          return;
        }
      }
      
      // Password check
      if (fieldRules['isPassword'] == true) {
        error = validatePassword(value);
        if (error != null) {
          errors[field] = error;
          return;
        }
      }
      
      // Numeric check
      if (fieldRules['isNumeric'] == true) {
        error = validateNumeric(value, fieldRules['label'] ?? field);
        if (error != null) {
          errors[field] = error;
          return;
        }
      }
      
      // Integer check
      if (fieldRules['isInteger'] == true) {
        error = validateInteger(value, fieldRules['label'] ?? field);
        if (error != null) {
          errors[field] = error;
          return;
        }
      }
      
      // Min value check
      if (fieldRules['min'] != null) {
        error = validateMin(value, fieldRules['min'], fieldRules['label'] ?? field);
        if (error != null) {
          errors[field] = error;
          return;
        }
      }
      
      // Max value check
      if (fieldRules['max'] != null) {
        error = validateMax(value, fieldRules['max'], fieldRules['label'] ?? field);
        if (error != null) {
          errors[field] = error;
          return;
        }
      }
      
      // Length check
      if (fieldRules['minLength'] != null || fieldRules['maxLength'] != null) {
        error = validateLength(
          value, 
          fieldRules['minLength'] ?? 0, 
          fieldRules['maxLength'] ?? 1000000, 
          fieldRules['label'] ?? field,
        );
        if (error != null) {
          errors[field] = error;
          return;
        }
      }
      
      // Pattern check
      if (fieldRules['pattern'] != null) {
        final pattern = RegExp(fieldRules['pattern']);
        if (!pattern.hasMatch(value)) {
          errors[field] = fieldRules['patternError'] ?? 'Invalid ${fieldRules['label'] ?? field} format';
          return;
        }
      }
      
      // Custom validation
      if (fieldRules['validate'] != null && fieldRules['validate'] is Function) {
        error = fieldRules['validate'](value);
        if (error != null) {
          errors[field] = error;
          return;
        }
      }
    });
    
    if (errors.isNotEmpty) {
      return ValidationException.multipleFields(errors);
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
      } else {
        sanitized[key] = value;
      }
    });
    
    return sanitized;
  }
  
  /// Implements the Luhn algorithm for credit card validation
  static bool _isValidLuhn(String number) {
    int sum = 0;
    bool alternate = false;
    
    for (int i = number.length - 1; i >= 0; i--) {
      int digit = int.parse(number[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    return sum % 10 == 0;
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
  
  /// Validates a product description
  static String? validateProductDescription(String? description) {
    if (description == null || description.isEmpty) {
      return null; // Description might be optional
    }
    
    if (description.length > 2000) {
      return 'Description must be less than 2000 characters long';
    }
    
    return null;
  }
  
  /// Validates a price value
  static String? validatePrice(String? price) {
    if (price == null || price.isEmpty) {
      return 'Price is required';
    }
    
    final numValue = double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), ''));
    if (numValue == null) {
      return 'Price must be a valid number';
    }
    
    if (numValue <= 0) {
      return 'Price must be greater than zero';
    }
    
    if (numValue > 999999.99) {
      return 'Price is too high';
    }
    
    return null;
  }
  
  /// Validates a stock quantity
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
    
    if (numValue > 999999) {
      return 'Stock quantity is too high';
    }
    
    return null;
  }
  
  /// Validates a URL slug
  static String? validateSlug(String? slug) {
    if (slug == null || slug.isEmpty) {
      return 'Slug is required';
    }
    
    if (!RegExp(r'^[a-z0-9\-]+$').hasMatch(slug)) {
      return 'Slug can only contain lowercase letters, numbers, and hyphens';
    }
    
    if (slug.length < 3) {
      return 'Slug must be at least 3 characters long';
    }
    
    if (slug.length > 100) {
      return 'Slug must be less than 100 characters long';
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
  
  /// Validates a banner title
  static String? validateBannerTitle(String? title) {
    if (title == null || title.isEmpty) {
      return 'Banner title is required';
    }
    
    if (title.length < 3) {
      return 'Banner title must be at least 3 characters long';
    }
    
    if (title.length > 100) {
      return 'Banner title must be less than 100 characters long';
    }
    
    return null;
  }
  
  /// Validates a coupon code
  static String? validateCouponCode(String? code) {
    if (code == null || code.isEmpty) {
      return 'Coupon code is required';
    }
    
    if (!RegExp(r'^[A-Z0-9_-]+$').hasMatch(code.toUpperCase())) {
      return 'Coupon code can only contain letters, numbers, underscores, and hyphens';
    }
    
    if (code.length < 3) {
      return 'Coupon code must be at least 3 characters long';
    }
    
    if (code.length > 20) {
      return 'Coupon code must be less than 20 characters long';
    }
    
    return null;
  }
  
  /// Validates a discount type
  static String? validateDiscountType(String? type) {
    if (type == null || type.isEmpty) {
      return 'Discount type is required';
    }
    
    final validTypes = ['percentage', 'fixed'];
    if (!validTypes.contains(type.toLowerCase())) {
      return 'Discount type must be either "percentage" or "fixed"';
    }
    
    return null;
  }
  
  /// Validates a discount value
  static String? validateDiscountValue(String? value, String? discountType) {
    if (value == null || value.isEmpty) {
      return 'Discount value is required';
    }
    
    final numValue = double.tryParse(value);
    if (numValue == null) {
      return 'Discount value must be a number';
    }
    
    if (numValue <= 0) {
      return 'Discount value must be greater than zero';
    }
    
    if (discountType?.toLowerCase() == 'percentage' && numValue > 100) {
      return 'Percentage discount cannot exceed 100%';
    }
    
    return null;
  }
  
  /// Validates an order status
  static String? validateOrderStatus(String? status) {
    if (status == null || status.isEmpty) {
      return 'Order status is required';
    }
    
    final validStatuses = ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'];
    if (!validStatuses.contains(status.toLowerCase())) {
      return 'Invalid order status';
    }
    
    return null;
  }
  
  /// Validates a user role
  static String? validateUserRole(String? role) {
    if (role == null || role.isEmpty) {
      return 'User role is required';
    }
    
    final validRoles = ['admin', 'manager', 'customer'];
    if (!validRoles.contains(role.toLowerCase())) {
      return 'Invalid user role';
    }
    
    return null;
  }
  
  /// Validates a UUID
  static String? validateUuid(String? uuid) {
    if (uuid == null || uuid.isEmpty) {
      return 'ID is required';
    }
    
    if (!RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(uuid)) {
      return 'Invalid ID format';
    }
    
    return null;
  }
}