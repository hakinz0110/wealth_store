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
    return normalizeWhitespace(
      name.replaceAll(RegExp(r'<[^>]*>'), '')
    );
  }
  
  /// Sanitizes a product description (allows some HTML)
  static String sanitizeProductDescription(String description) {
    // Allow basic formatting tags but remove potentially dangerous ones
    return sanitizeHtml(description);
  }
  
  /// Sanitizes a category name
  static String sanitizeCategoryName(String name) {
    // Remove any HTML tags and normalize whitespace
    return normalizeWhitespace(
      name.replaceAll(RegExp(r'<[^>]*>'), '')
    );
  }
  
  /// Sanitizes a slug (URL-friendly string)
  static String sanitizeSlug(String text) {
    // Convert to lowercase
    String slug = text.toLowerCase();
    
    // Replace spaces with hyphens
    slug = slug.replaceAll(' ', '-');
    
    // Remove special characters
    slug = slug.replaceAll(RegExp(r'[^a-z0-9-]'), '');
    
    // Replace multiple hyphens with a single hyphen
    slug = slug.replaceAll(RegExp(r'-+'), '-');
    
    // Remove leading and trailing hyphens
    slug = slug.replaceAll(RegExp(r'^-|-$'), '');
    
    return slug;
  }
  
  /// Sanitizes a price value
  static double sanitizePrice(dynamic price) {
    if (price is double) {
      return price;
    }
    
    if (price is int) {
      return price.toDouble();
    }
    
    if (price is String) {
      // Remove currency symbols and other non-numeric characters except decimal point
      final cleanPrice = price.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleanPrice) ?? 0.0;
    }
    
    return 0.0;
  }
  
  /// Sanitizes a discount value
  static double sanitizeDiscountValue(dynamic value, String discountType) {
    final sanitizedValue = sanitizePrice(value);
    
    // For percentage discounts, cap at 100%
    if (discountType == 'percentage') {
      return sanitizedValue > 100 ? 100 : sanitizedValue;
    }
    
    return sanitizedValue;
  }
  
  /// Sanitizes a coupon code
  static String sanitizeCouponCode(String code) {
    // Convert to uppercase
    String sanitized = code.toUpperCase();
    
    // Remove spaces
    sanitized = sanitized.replaceAll(' ', '');
    
    // Remove special characters except underscores and hyphens
    sanitized = sanitized.replaceAll(RegExp(r'[^A-Z0-9_-]'), '');
    
    return sanitized;
  }
}