/// Utility class for data sanitization to prevent security vulnerabilities
class SanitizationUtils {
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
  
  /// Sanitizes a search query
  static String sanitizeSearchQuery(String query) {
    // Remove SQL injection patterns
    final sanitized = query
      .replaceAll("'", "")
      .replaceAll('"', '')
      .replaceAll(';', '')
      .replaceAll('--', '')
      .replaceAll('/*', '')
      .replaceAll('*/', '')
      .replaceAll('=', '')
      .replaceAll('DROP', '')
      .replaceAll('SELECT', '')
      .replaceAll('INSERT', '')
      .replaceAll('UPDATE', '')
      .replaceAll('DELETE', '')
      .replaceAll('UNION', '');
    
    return sanitized.trim();
  }
  
  /// Sanitizes a URL
  static String sanitizeUrl(String url) {
    // Remove javascript: protocol
    if (url.toLowerCase().startsWith('javascript:')) {
      return '#';
    }
    
    // Remove data: protocol (could be used for XSS)
    if (url.toLowerCase().startsWith('data:')) {
      return '#';
    }
    
    return url;
  }
  
  /// Sanitizes a filename
  static String sanitizeFilename(String filename) {
    // Remove path traversal characters and other problematic characters
    return filename
      .replaceAll('..', '')
      .replaceAll('/', '')
      .replaceAll('\\', '')
      .replaceAll(':', '')
      .replaceAll('*', '')
      .replaceAll('?', '')
      .replaceAll('"', '')
      .replaceAll('<', '')
      .replaceAll('>', '')
      .replaceAll('|', '');
  }
  
  /// Sanitizes a phone number (removes non-digit characters)
  static String sanitizePhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }
  
  /// Sanitizes a credit card number (removes spaces and dashes)
  static String sanitizeCreditCardNumber(String cardNumber) {
    return cardNumber.replaceAll(RegExp(r'[\s-]'), '');
  }
  
  /// Sanitizes a zip/postal code
  static String sanitizeZipCode(String zip) {
    return zip.replaceAll(RegExp(r'[^\d-]'), '');
  }
  
  /// Sanitizes an email address
  static String sanitizeEmail(String email) {
    return email.trim().toLowerCase();
  }
  
  /// Sanitizes HTML content (basic implementation)
  static String sanitizeHtml(String html) {
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
  
  /// Sanitizes SQL query parameters
  static String sanitizeSqlParam(String param) {
    // Replace single quotes with two single quotes (SQL escape)
    return param.replaceAll("'", "''");
  }
  
  /// Normalizes whitespace in text
  static String normalizeWhitespace(String text) {
    // Replace multiple whitespace characters with a single space
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
  
  /// Truncates text to a maximum length
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    
    return '${text.substring(0, maxLength)}...';
  }
  
  /// Sanitizes a product name
  static String sanitizeProductName(String name) {
    // Remove any HTML tags and normalize whitespace
    final sanitized = sanitizeInput(name);
    return normalizeWhitespace(sanitized);
  }
  
  /// Sanitizes a product description
  static String sanitizeProductDescription(String description) {
    // Allow some basic HTML formatting but remove potentially dangerous elements
    return sanitizeHtml(description);
  }
  
  /// Sanitizes a price value
  static dynamic sanitizePrice(dynamic price) {
    if (price is String) {
      // Remove currency symbols and other non-numeric characters except decimal point
      final sanitized = price.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(sanitized) ?? 0.0;
    } else if (price is num) {
      return price;
    }
    return 0.0;
  }
  
  /// Sanitizes a slug (URL-friendly string)
  static String sanitizeSlug(String text) {
    // Convert to lowercase
    String slug = text.toLowerCase();
    
    // Replace spaces with hyphens
    slug = slug.replaceAll(RegExp(r'\s+'), '-');
    
    // Remove special characters
    slug = slug.replaceAll(RegExp(r'[^a-z0-9\-]'), '');
    
    // Replace multiple hyphens with a single hyphen
    slug = slug.replaceAll(RegExp(r'-+'), '-');
    
    // Remove leading and trailing hyphens
    slug = slug.replaceAll(RegExp(r'^-|-$'), '');
    
    return slug;
  }
  
  /// Sanitizes a category name
  static String sanitizeCategoryName(String name) {
    return sanitizeProductName(name);
  }
  
  /// Sanitizes a username
  static String sanitizeUsername(String username) {
    // Remove spaces and special characters
    return username.replaceAll(RegExp(r'[^\w\.]'), '').toLowerCase();
  }
  
  /// Sanitizes a JSON string
  static String sanitizeJsonString(String jsonStr) {
    // Remove control characters that could break JSON parsing
    return jsonStr.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
  }
  
  /// Sanitizes a UUID string
  static String sanitizeUuid(String uuid) {
    // Ensure it only contains valid UUID characters
    final sanitized = uuid.replaceAll(RegExp(r'[^a-fA-F0-9\-]'), '');
    return sanitized;
  }
  
  /// Sanitizes a boolean value from various input types
  static bool sanitizeBoolean(dynamic value) {
    if (value is bool) {
      return value;
    } else if (value is String) {
      final lowered = value.toLowerCase();
      return lowered == 'true' || lowered == 'yes' || lowered == '1';
    } else if (value is num) {
      return value != 0;
    }
    return false;
  }
  
  /// Sanitizes an integer value
  static int sanitizeInteger(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is double) {
      return value.toInt();
    } else if (value is String) {
      return int.tryParse(value.replaceAll(RegExp(r'[^\d-]'), '')) ?? 0;
    }
    return 0;
  }
  
  /// Sanitizes a date string to ensure it's in ISO format
  static String sanitizeDateString(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return date.toIso8601String();
    } catch (_) {
      // Return current date if parsing fails
      return DateTime.now().toIso8601String();
    }
  }
  
  /// Sanitizes a banner title
  static String sanitizeBannerTitle(String title) {
    return sanitizeProductName(title);
  }
  
  /// Sanitizes a coupon code
  static String sanitizeCouponCode(String code) {
    // Convert to uppercase and remove spaces
    return code.toUpperCase().replaceAll(RegExp(r'\s'), '');
  }
  
  /// Sanitizes an order status
  static String sanitizeOrderStatus(String status) {
    // Ensure it's one of the valid statuses
    final validStatuses = ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'];
    final lowered = status.toLowerCase();
    
    if (validStatuses.contains(lowered)) {
      return lowered;
    }
    
    // Default to pending if invalid
    return 'pending';
  }
  
  /// Sanitizes a user role
  static String sanitizeUserRole(String role) {
    // Ensure it's one of the valid roles
    final validRoles = ['admin', 'manager', 'customer'];
    final lowered = role.toLowerCase();
    
    if (validRoles.contains(lowered)) {
      return lowered;
    }
    
    // Default to customer if invalid
    return 'customer';
  }
  
  /// Sanitizes a shipping address object
  static Map<String, dynamic> sanitizeShippingAddress(Map<String, dynamic> address) {
    final sanitized = <String, dynamic>{};
    
    // Sanitize each field
    if (address.containsKey('street')) {
      sanitized['street'] = sanitizeInput(address['street'].toString());
    }
    
    if (address.containsKey('city')) {
      sanitized['city'] = sanitizeInput(address['city'].toString());
    }
    
    if (address.containsKey('state')) {
      sanitized['state'] = sanitizeInput(address['state'].toString());
    }
    
    if (address.containsKey('zipCode')) {
      sanitized['zipCode'] = sanitizeZipCode(address['zipCode'].toString());
    }
    
    if (address.containsKey('country')) {
      sanitized['country'] = sanitizeInput(address['country'].toString());
    }
    
    return sanitized;
  }
  
  /// Sanitizes a file path for storage operations
  static String sanitizeStoragePath(String path) {
    // Remove any path traversal attempts
    String sanitized = path.replaceAll('..', '');
    
    // Ensure path starts with a slash if not empty
    if (sanitized.isNotEmpty && !sanitized.startsWith('/')) {
      sanitized = '/$sanitized';
    }
    
    // Remove multiple slashes
    sanitized = sanitized.replaceAll(RegExp(r'\/+'), '/');
    
    return sanitized;
  }
  
  /// Sanitizes a file MIME type
  static String sanitizeMimeType(String mimeType) {
    // Ensure it's a valid MIME type format
    if (RegExp(r'^[a-zA-Z0-9\-\.]+\/[a-zA-Z0-9\-\.]+$').hasMatch(mimeType)) {
      return mimeType.toLowerCase();
    }
    
    // Default to binary if invalid
    return 'application/octet-stream';
  }
}