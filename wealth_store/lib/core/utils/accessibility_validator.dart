import 'package:flutter/material.dart';
import 'package:wealth_app/core/utils/accessibility_utils.dart';

/// Comprehensive accessibility validation utility for WCAG 2.1 AA compliance
class AccessibilityValidator {
  AccessibilityValidator._();

  /// Validate color contrast compliance for the entire theme
  static AccessibilityValidationResult validateThemeAccessibility(ThemeData theme) {
    final results = <String, ValidationResult>{};
    final issues = <AccessibilityIssue>[];

    // Validate primary color combinations
    final primaryOnSurface = AccessibilityUtils.calculateContrastRatio(
      theme.colorScheme.primary,
      theme.colorScheme.surface,
    );
    results['primary_on_surface'] = ValidationResult(
      isValid: primaryOnSurface >= 4.5,
      contrastRatio: primaryOnSurface,
      requirement: 4.5,
    );
    if (primaryOnSurface < 4.5) {
      issues.add(AccessibilityIssue(
        type: AccessibilityIssueType.colorContrast,
        severity: AccessibilityIssueSeverity.high,
        description: 'Primary color on surface background does not meet WCAG AA contrast requirements',
        suggestion: 'Adjust primary color or surface color to achieve minimum 4.5:1 contrast ratio',
        currentValue: primaryOnSurface.toStringAsFixed(2),
        requiredValue: '4.5',
      ));
    }

    // Validate secondary color combinations
    final secondaryOnSurface = AccessibilityUtils.calculateContrastRatio(
      theme.colorScheme.secondary,
      theme.colorScheme.surface,
    );
    results['secondary_on_surface'] = ValidationResult(
      isValid: secondaryOnSurface >= 4.5,
      contrastRatio: secondaryOnSurface,
      requirement: 4.5,
    );
    if (secondaryOnSurface < 4.5) {
      issues.add(AccessibilityIssue(
        type: AccessibilityIssueType.colorContrast,
        severity: AccessibilityIssueSeverity.medium,
        description: 'Secondary color on surface background does not meet WCAG AA contrast requirements',
        suggestion: 'Adjust secondary color or surface color to achieve minimum 4.5:1 contrast ratio',
        currentValue: secondaryOnSurface.toStringAsFixed(2),
        requiredValue: '4.5',
      ));
    }

    // Validate error color combinations
    final errorOnSurface = AccessibilityUtils.calculateContrastRatio(
      theme.colorScheme.error,
      theme.colorScheme.surface,
    );
    results['error_on_surface'] = ValidationResult(
      isValid: errorOnSurface >= 4.5,
      contrastRatio: errorOnSurface,
      requirement: 4.5,
    );
    if (errorOnSurface < 4.5) {
      issues.add(AccessibilityIssue(
        type: AccessibilityIssueType.colorContrast,
        severity: AccessibilityIssueSeverity.high,
        description: 'Error color on surface background does not meet WCAG AA contrast requirements',
        suggestion: 'Adjust error color or surface color to achieve minimum 4.5:1 contrast ratio',
        currentValue: errorOnSurface.toStringAsFixed(2),
        requiredValue: '4.5',
      ));
    }

    // Validate text on primary combinations
    final onPrimaryPrimary = AccessibilityUtils.calculateContrastRatio(
      theme.colorScheme.onPrimary,
      theme.colorScheme.primary,
    );
    results['on_primary_primary'] = ValidationResult(
      isValid: onPrimaryPrimary >= 4.5,
      contrastRatio: onPrimaryPrimary,
      requirement: 4.5,
    );
    if (onPrimaryPrimary < 4.5) {
      issues.add(AccessibilityIssue(
        type: AccessibilityIssueType.colorContrast,
        severity: AccessibilityIssueSeverity.high,
        description: 'Text on primary color does not meet WCAG AA contrast requirements',
        suggestion: 'Adjust onPrimary color to achieve minimum 4.5:1 contrast ratio with primary color',
        currentValue: onPrimaryPrimary.toStringAsFixed(2),
        requiredValue: '4.5',
      ));
    }

    return AccessibilityValidationResult(
      isValid: issues.isEmpty,
      results: results,
      issues: issues,
      summary: _generateValidationSummary(results, issues),
    );
  }

  /// Validate touch target sizes for a widget
  static List<AccessibilityIssue> validateTouchTargets(Widget widget) {
    final issues = <AccessibilityIssue>[];
    
    // This would need to be implemented with widget testing framework
    // For now, we provide guidelines
    
    return issues;
  }

  /// Validate semantic labels and hints
  static List<AccessibilityIssue> validateSemanticLabels(Map<String, String?> labels) {
    final issues = <AccessibilityIssue>[];

    labels.forEach((key, label) {
      if (label == null || label.isEmpty) {
        issues.add(AccessibilityIssue(
          type: AccessibilityIssueType.missingSemanticLabel,
          severity: AccessibilityIssueSeverity.high,
          description: 'Missing semantic label for $key',
          suggestion: 'Add descriptive semantic label for screen reader users',
          currentValue: 'null or empty',
          requiredValue: 'Descriptive label',
        ));
      } else if (label.length < 3) {
        issues.add(AccessibilityIssue(
          type: AccessibilityIssueType.inadequateSemanticLabel,
          severity: AccessibilityIssueSeverity.medium,
          description: 'Semantic label for $key is too short',
          suggestion: 'Provide more descriptive semantic label (minimum 3 characters)',
          currentValue: label,
          requiredValue: 'Descriptive label (3+ characters)',
        ));
      }
    });

    return issues;
  }

  /// Validate focus management
  static List<AccessibilityIssue> validateFocusManagement(List<FocusNode> focusNodes) {
    final issues = <AccessibilityIssue>[];

    for (int i = 0; i < focusNodes.length; i++) {
      final node = focusNodes[i];
      
      if (node.debugLabel == null || node.debugLabel!.isEmpty) {
        issues.add(AccessibilityIssue(
          type: AccessibilityIssueType.missingFocusLabel,
          severity: AccessibilityIssueSeverity.medium,
          description: 'Focus node at index $i missing debug label',
          suggestion: 'Add debug label to focus node for better debugging and accessibility testing',
          currentValue: 'null or empty',
          requiredValue: 'Descriptive debug label',
        ));
      }
    }

    return issues;
  }

  /// Generate accessibility report
  static AccessibilityReport generateAccessibilityReport(ThemeData theme) {
    final themeValidation = validateThemeAccessibility(theme);
    final allIssues = <AccessibilityIssue>[];
    
    allIssues.addAll(themeValidation.issues);

    // Count issues by severity
    final criticalIssues = allIssues.where((i) => i.severity == AccessibilityIssueSeverity.critical).length;
    final highIssues = allIssues.where((i) => i.severity == AccessibilityIssueSeverity.high).length;
    final mediumIssues = allIssues.where((i) => i.severity == AccessibilityIssueSeverity.medium).length;
    final lowIssues = allIssues.where((i) => i.severity == AccessibilityIssueSeverity.low).length;

    return AccessibilityReport(
      isCompliant: allIssues.isEmpty,
      totalIssues: allIssues.length,
      criticalIssues: criticalIssues,
      highIssues: highIssues,
      mediumIssues: mediumIssues,
      lowIssues: lowIssues,
      issues: allIssues,
      themeValidation: themeValidation,
      recommendations: _generateRecommendations(allIssues),
      complianceScore: _calculateComplianceScore(allIssues),
    );
  }

  static String _generateValidationSummary(
    Map<String, ValidationResult> results,
    List<AccessibilityIssue> issues,
  ) {
    final totalTests = results.length;
    final passedTests = results.values.where((r) => r.isValid).length;
    final failedTests = totalTests - passedTests;

    return 'Accessibility Validation Summary:\n'
        'Total Tests: $totalTests\n'
        'Passed: $passedTests\n'
        'Failed: $failedTests\n'
        'Issues Found: ${issues.length}';
  }

  static List<String> _generateRecommendations(List<AccessibilityIssue> issues) {
    final recommendations = <String>[];

    if (issues.any((i) => i.type == AccessibilityIssueType.colorContrast)) {
      recommendations.add('Review and adjust color combinations to meet WCAG 2.1 AA contrast requirements (4.5:1 for normal text, 3:1 for large text)');
    }

    if (issues.any((i) => i.type == AccessibilityIssueType.missingSemanticLabel)) {
      recommendations.add('Add semantic labels to all interactive elements for screen reader accessibility');
    }

    if (issues.any((i) => i.type == AccessibilityIssueType.touchTargetSize)) {
      recommendations.add('Ensure all touch targets meet minimum 44dp size requirement');
    }

    if (issues.any((i) => i.type == AccessibilityIssueType.missingFocusLabel)) {
      recommendations.add('Add debug labels to focus nodes for better accessibility testing and debugging');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Great job! No major accessibility issues found. Continue following accessibility best practices.');
    }

    return recommendations;
  }

  static double _calculateComplianceScore(List<AccessibilityIssue> issues) {
    if (issues.isEmpty) return 100.0;

    // Weight issues by severity
    double totalWeight = 0.0;
    for (final issue in issues) {
      switch (issue.severity) {
        case AccessibilityIssueSeverity.critical:
          totalWeight += 10.0;
          break;
        case AccessibilityIssueSeverity.high:
          totalWeight += 5.0;
          break;
        case AccessibilityIssueSeverity.medium:
          totalWeight += 2.0;
          break;
        case AccessibilityIssueSeverity.low:
          totalWeight += 1.0;
          break;
      }
    }

    // Calculate score (max deduction is 100 points)
    final deduction = (totalWeight * 2).clamp(0.0, 100.0);
    return (100.0 - deduction).clamp(0.0, 100.0);
  }
}

/// Accessibility validation result
class AccessibilityValidationResult {
  final bool isValid;
  final Map<String, ValidationResult> results;
  final List<AccessibilityIssue> issues;
  final String summary;

  const AccessibilityValidationResult({
    required this.isValid,
    required this.results,
    required this.issues,
    required this.summary,
  });
}

/// Individual validation result
class ValidationResult {
  final bool isValid;
  final double contrastRatio;
  final double requirement;

  const ValidationResult({
    required this.isValid,
    required this.contrastRatio,
    required this.requirement,
  });
}

/// Accessibility issue
class AccessibilityIssue {
  final AccessibilityIssueType type;
  final AccessibilityIssueSeverity severity;
  final String description;
  final String suggestion;
  final String currentValue;
  final String requiredValue;

  const AccessibilityIssue({
    required this.type,
    required this.severity,
    required this.description,
    required this.suggestion,
    required this.currentValue,
    required this.requiredValue,
  });
}

/// Comprehensive accessibility report
class AccessibilityReport {
  final bool isCompliant;
  final int totalIssues;
  final int criticalIssues;
  final int highIssues;
  final int mediumIssues;
  final int lowIssues;
  final List<AccessibilityIssue> issues;
  final AccessibilityValidationResult themeValidation;
  final List<String> recommendations;
  final double complianceScore;

  const AccessibilityReport({
    required this.isCompliant,
    required this.totalIssues,
    required this.criticalIssues,
    required this.highIssues,
    required this.mediumIssues,
    required this.lowIssues,
    required this.issues,
    required this.themeValidation,
    required this.recommendations,
    required this.complianceScore,
  });
}

/// Types of accessibility issues
enum AccessibilityIssueType {
  colorContrast,
  touchTargetSize,
  missingSemanticLabel,
  inadequateSemanticLabel,
  missingFocusLabel,
  focusManagement,
  keyboardNavigation,
}

/// Severity levels for accessibility issues
enum AccessibilityIssueSeverity {
  critical,
  high,
  medium,
  low,
}