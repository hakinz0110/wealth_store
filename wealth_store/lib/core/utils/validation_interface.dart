import '../exceptions/app_exceptions.dart';

/// Interface for validation rules and methods
/// This provides a common structure for validation across both apps
abstract class ValidationInterface {
  /// Validates a form with multiple fields
  ValidationException? validateForm(Map<String, dynamic> formData, Map<String, dynamic> rules);
  
  /// Validates a single field
  String? validateField(String field, dynamic value, Map<String, dynamic> rules);
  
  /// Sanitizes a map of form data
  Map<String, dynamic> sanitizeData(Map<String, dynamic> data);
}