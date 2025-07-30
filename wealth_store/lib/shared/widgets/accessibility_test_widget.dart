import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wealth_app/core/utils/accessibility_utils.dart';
import 'package:wealth_app/core/utils/accessibility_validator.dart';
import 'package:wealth_app/core/theme/app_theme.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_text_styles.dart';

/// Widget for testing and validating accessibility compliance
class AccessibilityTestWidget extends StatefulWidget {
  final Widget child;
  final bool enableValidation;
  final bool showOverlay;

  const AccessibilityTestWidget({
    super.key,
    required this.child,
    this.enableValidation = false,
    this.showOverlay = false,
  });

  @override
  State<AccessibilityTestWidget> createState() => _AccessibilityTestWidgetState();
}

class _AccessibilityTestWidgetState extends State<AccessibilityTestWidget> {
  AccessibilityReport? _report;
  bool _showReport = false;

  @override
  void initState() {
    super.initState();
    if (widget.enableValidation) {
      _generateReport();
    }
  }

  void _generateReport() {
    setState(() {
      _report = AppTheme.generateAccessibilityReport();
    });
  }

  void _toggleReport() {
    setState(() {
      _showReport = !_showReport;
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        
        // Accessibility overlay
        if (widget.showOverlay && widget.enableValidation)
          _buildAccessibilityOverlay(),
        
        // Accessibility report panel
        if (_showReport && _report != null)
          _buildReportPanel(),
      ],
    );
  }

  Widget _buildAccessibilityOverlay() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      right: 10,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Accessibility score indicator
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getScoreColor(_report?.complianceScore ?? 0),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${(_report?.complianceScore ?? 0).round()}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Toggle report button
              GestureDetector(
                onTap: _toggleReport,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'A11Y',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportPanel() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Material(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Accessibility Report',
                      style: AppTextStyles.headlineSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _toggleReport,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Score and summary
                _buildScoreSummary(),
                
                const SizedBox(height: 16),
                
                // Issues breakdown
                if (_report!.totalIssues > 0) ...[
                  Text(
                    'Issues Found',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildIssuesBreakdown(),
                  const SizedBox(height: 16),
                ],
                
                // Recommendations
                Text(
                  'Recommendations',
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildRecommendations(),
                
                const SizedBox(height: 16),
                
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _generateReport,
                      child: const Text('Refresh'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _toggleReport,
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getScoreColor(_report!.complianceScore).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getScoreColor(_report!.complianceScore),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getScoreColor(_report!.complianceScore),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${_report!.complianceScore.round()}',
                style: AppTextStyles.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getScoreLabel(_report!.complianceScore),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: _getScoreColor(_report!.complianceScore),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_report!.totalIssues} issues found',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssuesBreakdown() {
    return Column(
      children: [
        if (_report!.criticalIssues > 0)
          _buildIssueRow('Critical', _report!.criticalIssues, Colors.red),
        if (_report!.highIssues > 0)
          _buildIssueRow('High', _report!.highIssues, Colors.orange),
        if (_report!.mediumIssues > 0)
          _buildIssueRow('Medium', _report!.mediumIssues, Colors.yellow[700]!),
        if (_report!.lowIssues > 0)
          _buildIssueRow('Low', _report!.lowIssues, Colors.blue),
      ],
    );
  }

  Widget _buildIssueRow(String severity, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$severity: $count',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _report!.recommendations.map((recommendation) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(double score) {
    if (score >= 90) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 50) return 'Fair';
    return 'Needs Improvement';
  }
}

/// Mixin for widgets to easily add accessibility testing
mixin AccessibilityTestMixin<T extends StatefulWidget> on State<T> {
  
  /// Test color contrast for the current theme
  void testColorContrast() {
    final theme = Theme.of(context);
    final validation = AccessibilityValidator.validateThemeAccessibility(theme);
    
    if (!validation.isValid) {
      debugPrint('Accessibility Issues Found:');
      for (final issue in validation.issues) {
        debugPrint('- ${issue.description}');
        debugPrint('  Suggestion: ${issue.suggestion}');
      }
    } else {
      debugPrint('All color combinations meet WCAG 2.1 AA standards');
    }
  }
  
  /// Announce message to screen readers
  void announceToScreenReader(String message) {
    AccessibilityUtils.announceToScreenReader(context, message);
  }
  
  /// Provide haptic feedback for accessibility
  void provideAccessibilityFeedback(AccessibilityFeedbackType type) {
    AccessibilityUtils.provideAccessibilityFeedback(type: type);
  }
  
  /// Create semantic label for screen readers
  String createSemanticLabel({
    required String primaryText,
    String? secondaryText,
    String? statusText,
    String? actionHint,
  }) {
    return AccessibilityUtils.createSemanticLabel(
      primaryText: primaryText,
      secondaryText: secondaryText,
      statusText: statusText,
      actionHint: actionHint,
    );
  }
}