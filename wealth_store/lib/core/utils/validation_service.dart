import 'dart:async';
import 'package:flutter/material.dart';
import 'validation_interface.dart';
import 'entity_validation.dart';
import 'validation_utils.dart';
import 'sanitization_utils.dart';
import '../exceptions/app_exceptions.dart';

/// Service for handling both client-side and server-side validation
class ValidationService {
  /// The validation interface implementation to use
  final ValidationInterface _validator;
  
  /// Constructor
  ValidationService({ValidationInterface? validator}) : _validator = validator ?? EntityValidation();
  
  /// Validates a form with client-side validation
  ValidationException? validateClientSide(Map<String, dynamic> formData, Map<String, dynamic> rules) {
    return _validator.validateForm(formData, rules);
  }
  
  /// Validates a single field with client-side validation
  String? validateFieldClientSide(String field, dynamic value, Map<String, dynamic> rules) {
    return _validator.validateField(field, value, rules);
  }
  
  /// Sanitizes form data
  Map<String, dynamic> sanitizeData(Map<String, dynamic> formData) {
    return _validator.sanitizeFormData(formData);
  }
  
  /// Validates and sanitizes form data for a specific entity type
  Future<Map<String, dynamic>> validateAndSanitize(
    String entityType,
    Map<String, dynamic> formData,
    {bool isUpdate = false}
  ) async {
    // Get the appropriate validation rules based on entity type
    final rules = _getRulesForEntityType(entityType);
    
    // Validate the form data
    final validationException = validateClientSide(formData, rules);
    if (validationException != null) {
      throw validationException;
    }
    
    // Sanitize the form data
    final sanitizedData = sanitizeData(formData);
    
    // Add timestamps
    if (isUpdate) {
      sanitizedData['updated_at'] = DateTime.now().toIso8601String();
    } else {
      sanitizedData['created_at'] = DateTime.now().toIso8601String();
      if (!sanitizedData.containsKey('updated_at')) {
        sanitizedData['updated_at'] = DateTime.now().toIso8601String();
      }
    }
    
    // Perform entity-specific sanitization
    return _performEntitySpecificSanitization(entityType, sanitizedData);
  }
  
  /// Gets validation rules for a specific entity type
  Map<String, dynamic> _getRulesForEntityType(String entityType) {
    switch (entityType.toLowerCase()) {
      case 'product':
        return EntityValidation.productRules;
      case 'category':
        return EntityValidation.categoryRules;
      case 'order':
        return EntityValidation.orderRules;
      case 'banner':
        return EntityValidation.bannerRules;
      case 'coupon':
        return EntityValidation.couponRules;
      case 'user':
        return EntityValidation.userRules;
      case 'file':
        return EntityValidation.fileUploadRules;
      default:
        throw ValidationException(
          'Unknown entity type: $entityType',
          code: 'UNKNOWN_ENTITY_TYPE',
        );
    }
  }
  
  /// Performs entity-specific sanitization
  Future<Map<String, dynamic>> _performEntitySpecificSanitization(
    String entityType,
    Map<String, dynamic> data
  ) async {
    final sanitized = Map<String, dynamic>.from(data);
    
    switch (entityType.toLowerCase()) {
      case 'product':
        if (sanitized.containsKey('name')) {
          sanitized['name'] = SanitizationUtils.sanitizeProductName(sanitized['name'] as String);
        }
        if (sanitized.containsKey('description')) {
          sanitized['description'] = SanitizationUtils.sanitizeProductDescription(
            sanitized['description'] as String? ?? ''
          );
        }
        if (sanitized.containsKey('price')) {
          sanitized['price'] = SanitizationUtils.sanitizePrice(sanitized['price']);
        }
        if (sanitized.containsKey('stockQuantity')) {
          sanitized['stock_quantity'] = SanitizationUtils.sanitizeInteger(sanitized['stockQuantity']);
          sanitized.remove('stockQuantity');
        }
        break;
        
      case 'category':
        if (sanitized.containsKey('name')) {
          sanitized['name'] = SanitizationUtils.sanitizeCategoryName(sanitized['name'] as String);
        }
        if (sanitized.containsKey('description')) {
          sanitized['description'] = SanitizationUtils.sanitizeProductDescription(
            sanitized['description'] as String? ?? ''
          );
        }
        if (sanitized.containsKey('imageUrl')) {
          sanitized['image_url'] = SanitizationUtils.sanitizeUrl(
            sanitized['imageUrl'] as String? ?? ''
          );
          sanitized.remove('imageUrl');
        }
        break;
        
      case 'order':
        if (sanitized.containsKey('userId')) {
          sanitized['user_id'] = SanitizationUtils.sanitizeUuid(sanitized['userId'] as String);
          sanitized.remove('userId');
        }
        if (sanitized.containsKey('totalAmount')) {
          sanitized['total_amount'] = SanitizationUtils.sanitizePrice(sanitized['totalAmount']);
          sanitized.remove('totalAmount');
        }
        if (sanitized.containsKey('status')) {
          sanitized['status'] = SanitizationUtils.sanitizeOrderStatus(sanitized['status'] as String);
        }
        if (sanitized.containsKey('shippingAddress')) {
          sanitized['shipping_address'] = SanitizationUtils.sanitizeShippingAddress(
            Map<String, dynamic>.from(sanitized['shippingAddress'] as Map)
          );
          sanitized.remove('shippingAddress');
        }
        break;
        
      case 'banner':
        if (sanitized.containsKey('title')) {
          sanitized['title'] = SanitizationUtils.sanitizeBannerTitle(sanitized['title'] as String);
        }
        if (sanitized.containsKey('description')) {
          sanitized['description'] = SanitizationUtils.sanitizeProductDescription(
            sanitized['description'] as String? ?? ''
          );
        }
        if (sanitized.containsKey('imageUrl')) {
          sanitized['image_url'] = SanitizationUtils.sanitizeUrl(sanitized['imageUrl'] as String);
          sanitized.remove('imageUrl');
        }
        if (sanitized.containsKey('linkUrl')) {
          sanitized['link_url'] = SanitizationUtils.sanitizeUrl(
            sanitized['linkUrl'] as String? ?? ''
          );
          sanitized.remove('linkUrl');
        }
        if (sanitized.containsKey('displayOrder')) {
          sanitized['display_order'] = SanitizationUtils.sanitizeInteger(sanitized['displayOrder']);
          sanitized.remove('displayOrder');
        }
        break;
        
      case 'coupon':
        if (sanitized.containsKey('code')) {
          sanitized['code'] = SanitizationUtils.sanitizeCouponCode(sanitized['code'] as String);
        }
        if (sanitized.containsKey('description')) {
          sanitized['description'] = SanitizationUtils.sanitizeProductDescription(
            sanitized['description'] as String? ?? ''
          );
        }
        if (sanitized.containsKey('discountType')) {
          sanitized['discount_type'] = sanitized['discountType'] as String;
          sanitized.remove('discountType');
        }
        if (sanitized.containsKey('discountValue')) {
          sanitized['discount_value'] = SanitizationUtils.sanitizePrice(sanitized['discountValue']);
          sanitized.remove('discountValue');
        }
        if (sanitized.containsKey('minOrderAmount')) {
          sanitized['min_order_amount'] = SanitizationUtils.sanitizePrice(sanitized['minOrderAmount']);
          sanitized.remove('minOrderAmount');
        }
        if (sanitized.containsKey('maxUses')) {
          sanitized['max_uses'] = SanitizationUtils.sanitizeInteger(sanitized['maxUses']);
          sanitized.remove('maxUses');
        }
        if (sanitized.containsKey('expiresAt')) {
          sanitized['expires_at'] = SanitizationUtils.sanitizeDateString(sanitized['expiresAt'] as String);
          sanitized.remove('expiresAt');
        }
        break;
        
      case 'user':
        if (sanitized.containsKey('email')) {
          sanitized['email'] = SanitizationUtils.sanitizeEmail(sanitized['email'] as String);
        }
        if (sanitized.containsKey('fullName')) {
          sanitized['full_name'] = SanitizationUtils.sanitizeInput(sanitized['fullName'] as String);
          sanitized.remove('fullName');
        }
        if (sanitized.containsKey('username')) {
          sanitized['username'] = SanitizationUtils.sanitizeUsername(sanitized['username'] as String);
        }
        if (sanitized.containsKey('role')) {
          sanitized['role'] = SanitizationUtils.sanitizeUserRole(sanitized['role'] as String);
        }
        break;
        
      case 'file':
        if (sanitized.containsKey('filename')) {
          sanitized['filename'] = SanitizationUtils.sanitizeFilename(sanitized['filename'] as String);
        }
        if (sanitized.containsKey('path')) {
          sanitized['path'] = SanitizationUtils.sanitizeStoragePath(sanitized['path'] as String);
        }
        if (sanitized.containsKey('mimeType')) {
          sanitized['mimeType'] = SanitizationUtils.sanitizeMimeType(sanitized['mimeType'] as String);
        }
        break;
    }
    
    return sanitized;
  }
  
  /// Handles form submission with validation and error handling
  static Future<T> handleFormSubmission<T>({
    required BuildContext context,
    required Future<T> Function() onSubmit,
    required void Function(ValidationException) onValidationError,
    void Function(AppException)? onOtherError,
    void Function()? onSuccess,
  }) async {
    try {
      final result = await onSubmit();
      
      if (onSuccess != null) {
        onSuccess();
      }
      
      return result;
    } on ValidationException catch (e) {
      onValidationError(e);
      rethrow;
    } catch (e, stackTrace) {
      final appError = AppException(
        'An error occurred: ${e.toString()}',
        code: 'FORM_SUBMISSION_ERROR',
        originalError: e,
        stackTrace: stackTrace,
      );
      
      if (onOtherError != null) {
        onOtherError(appError);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appError.message)),
        );
      }
      
      rethrow;
    }
  }
}