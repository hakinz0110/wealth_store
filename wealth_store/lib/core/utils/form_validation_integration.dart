import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../exceptions/app_exceptions.dart';
import '../exceptions/error_handler.dart';
import 'validation_utils.dart';
import 'sanitization_utils.dart';
import 'entity_validation.dart';
import 'validation_service.dart';

/// Integrates form validation with Supabase operations
class FormValidationIntegration {
  /// The validation service instance
  static final ValidationService _validationService = ValidationService();
  /// Validates and sanitizes product data before Supabase operations
  static Future<Map<String, dynamic>> validateAndSanitizeProduct(
    Map<String, dynamic> productData,
    {bool isUpdate = false}
  ) async {
    return _validationService.validateAndSanitize('product', productData, isUpdate: isUpdate);
  }
  
  /// Validates and sanitizes category data before Supabase operations
  static Future<Map<String, dynamic>> validateAndSanitizeCategory(
    Map<String, dynamic> categoryData,
    {bool isUpdate = false}
  ) async {
    return _validationService.validateAndSanitize('category', categoryData, isUpdate: isUpdate);
  }
  
  /// Validates and sanitizes order data before Supabase operations
  static Future<Map<String, dynamic>> validateAndSanitizeOrder(
    Map<String, dynamic> orderData,
    {bool isUpdate = false}
  ) async {
    return _validationService.validateAndSanitize('order', orderData, isUpdate: isUpdate);
  }
  
  /// Validates and sanitizes banner data before Supabase operations
  static Future<Map<String, dynamic>> validateAndSanitizeBanner(
    Map<String, dynamic> bannerData,
    {bool isUpdate = false}
  ) async {
    return _validationService.validateAndSanitize('banner', bannerData, isUpdate: isUpdate);
  }
  
  /// Validates and sanitizes coupon data before Supabase operations
  static Future<Map<String, dynamic>> validateAndSanitizeCoupon(
    Map<String, dynamic> couponData,
    {bool isUpdate = false}
  ) async {
    return _validationService.validateAndSanitize('coupon', couponData, isUpdate: isUpdate);
  }
  
  /// Validates and sanitizes user data before Supabase operations
  static Future<Map<String, dynamic>> validateAndSanitizeUser(
    Map<String, dynamic> userData,
    {bool isUpdate = false}
  ) async {
    return _validationService.validateAndSanitize('user', userData, isUpdate: isUpdate);
  }
  
  /// Validates and sanitizes file upload data before Supabase storage operations
  static Future<Map<String, dynamic>> validateAndSanitizeFileUpload(
    Map<String, dynamic> fileData
  ) async {
    return _validationService.validateAndSanitize('file', fileData);
  }
  
  /// Validates and sanitizes search parameters
  static Map<String, dynamic> validateAndSanitizeSearchParams(Map<String, dynamic> params) {
    final sanitized = <String, dynamic>{};
    
    // Sanitize search query
    if (params.containsKey('query')) {
      final query = params['query'] as String?;
      final error = ValidationUtils.validateSearchQuery(query);
      if (error != null) {
        throw ValidationException(error);
      }
      sanitized['query'] = SanitizationUtils.sanitizeSearchQuery(query ?? '');
    }
    
    // Sanitize pagination parameters
    if (params.containsKey('limit')) {
      sanitized['limit'] = SanitizationUtils.sanitizeInteger(params['limit']);
    }
    
    if (params.containsKey('offset')) {
      sanitized['offset'] = SanitizationUtils.sanitizeInteger(params['offset']);
    }
    
    // Sanitize filter parameters
    if (params.containsKey('filters') && params['filters'] is Map) {
      final filters = <String, dynamic>{};
      final inputFilters = params['filters'] as Map;
      
      inputFilters.forEach((key, value) {
        if (key == 'categoryId') {
          filters[key] = SanitizationUtils.sanitizeUuid(value.toString());
        } else if (key == 'minPrice' || key == 'maxPrice') {
          filters[key] = SanitizationUtils.sanitizePrice(value);
        } else if (key == 'isActive') {
          filters[key] = SanitizationUtils.sanitizeBoolean(value);
        } else {
          filters[key] = SanitizationUtils.sanitizeInput(value.toString());
        }
      });
      
      sanitized['filters'] = filters;
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
    return ValidationService.handleFormSubmission(
      context: context,
      onSubmit: onSubmit,
      onValidationError: onValidationError,
      onOtherError: onOtherError,
      onSuccess: onSuccess,
    );
  }
}