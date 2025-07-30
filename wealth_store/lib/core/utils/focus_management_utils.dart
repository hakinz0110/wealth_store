import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wealth_app/core/utils/haptic_feedback_utils.dart';

/// Comprehensive focus management utilities for accessibility
class FocusManagementUtils {
  FocusManagementUtils._();

  /// Create a focus node with accessibility-friendly configuration
  static FocusNode createAccessibleFocusNode({
    String? debugLabel,
    bool skipTraversal = false,
    bool canRequestFocus = true,
    VoidCallback? onFocusChange,
  }) {
    final focusNode = FocusNode(
      debugLabel: debugLabel,
      skipTraversal: skipTraversal,
      canRequestFocus: canRequestFocus,
    );

    if (onFocusChange != null) {
      focusNode.addListener(() {
        if (focusNode.hasFocus) {
          HapticFeedbackUtils.contextualFeedback(HapticFeedbackType.focusChange);
          onFocusChange();
        }
      });
    }

    return focusNode;
  }

  /// Create a focus scope with proper accessibility handling
  static Widget createAccessibleFocusScope({
    required Widget child,
    FocusScopeNode? node,
    bool autofocus = false,
    VoidCallback? onFocusChange,
  }) {
    return FocusScope(
      node: node,
      autofocus: autofocus,
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          HapticFeedbackUtils.contextualFeedback(HapticFeedbackType.focusChange);
        }
        onFocusChange?.call();
      },
      child: child,
    );
  }

  /// Manage focus traversal order for a list of widgets
  static List<Widget> createFocusTraversalGroup({
    required List<Widget> children,
    TraversalPolicy? policy,
    String? debugLabel,
  }) {
    return [
      FocusTraversalGroup(
        policy: policy ?? OrderedTraversalPolicy(),
        child: Column(
          children: children.asMap().entries.map((entry) {
            final index = entry.key;
            final child = entry.value;
            
            return FocusTraversalOrder(
              order: NumericFocusOrder(index.toDouble()),
              child: child,
            );
          }).toList(),
        ),
      ),
    ];
  }

  /// Request focus with accessibility feedback
  static void requestFocusWithFeedback(FocusNode focusNode) {
    focusNode.requestFocus();
    HapticFeedbackUtils.contextualFeedback(HapticFeedbackType.focusChange);
  }

  /// Move focus to next focusable element
  static void focusNext(BuildContext context) {
    FocusScope.of(context).nextFocus();
    HapticFeedbackUtils.contextualFeedback(HapticFeedbackType.focusChange);
  }

  /// Move focus to previous focusable element
  static void focusPrevious(BuildContext context) {
    FocusScope.of(context).previousFocus();
    HapticFeedbackUtils.contextualFeedback(HapticFeedbackType.focusChange);
  }

  /// Unfocus current element
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
    HapticFeedbackUtils.contextualFeedback(HapticFeedbackType.focusChange);
  }

  /// Create keyboard shortcuts for accessibility
  static Map<ShortcutActivator, Intent> createAccessibilityShortcuts() {
    return {
      // Tab navigation
      const SingleActivator(LogicalKeyboardKey.tab): const NextFocusIntent(),
      const SingleActivator(LogicalKeyboardKey.tab, shift: true): const PreviousFocusIntent(),
      
      // Arrow key navigation
      const SingleActivator(LogicalKeyboardKey.arrowDown): const NextFocusIntent(),
      const SingleActivator(LogicalKeyboardKey.arrowUp): const PreviousFocusIntent(),
      const SingleActivator(LogicalKeyboardKey.arrowRight): const NextFocusIntent(),
      const SingleActivator(LogicalKeyboardKey.arrowLeft): const PreviousFocusIntent(),
      
      // Escape to unfocus
      const SingleActivator(LogicalKeyboardKey.escape): const DismissIntent(),
      
      // Enter/Space for activation
      const SingleActivator(LogicalKeyboardKey.enter): const ActivateIntent(),
      const SingleActivator(LogicalKeyboardKey.space): const ActivateIntent(),
    };
  }

  /// Create actions for accessibility shortcuts
  static Map<Type, Action<Intent>> createAccessibilityActions(BuildContext context) {
    return {
      NextFocusIntent: CallbackAction<NextFocusIntent>(
        onInvoke: (intent) {
          focusNext(context);
          return null;
        },
      ),
      PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(
        onInvoke: (intent) {
          focusPrevious(context);
          return null;
        },
      ),
      DismissIntent: CallbackAction<DismissIntent>(
        onInvoke: (intent) {
          unfocus(context);
          return null;
        },
      ),
      ActivateIntent: CallbackAction<ActivateIntent>(
        onInvoke: (intent) {
          // This should be handled by individual widgets
          HapticFeedbackUtils.contextualFeedback(HapticFeedbackType.accessibilityAction);
          return null;
        },
      ),
    };
  }

  /// Wrap widget with accessibility keyboard shortcuts
  static Widget wrapWithAccessibilityShortcuts({
    required Widget child,
    required BuildContext context,
    Map<ShortcutActivator, Intent>? additionalShortcuts,
    Map<Type, Action<Intent>>? additionalActions,
  }) {
    final shortcuts = <ShortcutActivator, Intent>{};
    shortcuts.addAll(createAccessibilityShortcuts());
    if (additionalShortcuts != null) {
      shortcuts.addAll(additionalShortcuts);
    }

    final actions = <Type, Action<Intent>>{};
    actions.addAll(createAccessibilityActions(context));
    if (additionalActions != null) {
      actions.addAll(additionalActions);
    }

    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: actions,
        child: child,
      ),
    );
  }

  /// Create focus-aware button with proper accessibility handling
  static Widget createAccessibleButton({
    required Widget child,
    required VoidCallback? onPressed,
    FocusNode? focusNode,
    String? semanticLabel,
    String? tooltip,
    bool autofocus = false,
  }) {
    final effectiveFocusNode = focusNode ?? FocusNode();

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: Focus(
        focusNode: effectiveFocusNode,
        autofocus: autofocus,
        onFocusChange: (hasFocus) {
          if (hasFocus) {
            HapticFeedbackUtils.contextualFeedback(HapticFeedbackType.focusChange);
          }
        },
        child: Builder(
          builder: (context) {
            final isFocused = Focus.of(context).hasFocus;
            
            return GestureDetector(
              onTap: onPressed,
              child: Container(
                decoration: BoxDecoration(
                  border: isFocused
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: tooltip != null
                    ? Tooltip(
                        message: tooltip,
                        child: child,
                      )
                    : child,
              ),
            );
          },
        ),
      ),
    );
  }

  /// Create accessible form field with proper focus management
  static Widget createAccessibleFormField({
    required Widget child,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    String? label,
    String? hint,
    bool required = false,
    String? errorText,
  }) {
    final effectiveFocusNode = focusNode ?? FocusNode();

    return Semantics(
      label: label,
      hint: hint,
      textField: true,
      child: Focus(
        focusNode: effectiveFocusNode,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.tab && !event.isShiftPressed) {
              if (nextFocusNode != null) {
                nextFocusNode.requestFocus();
                return KeyEventResult.handled;
              }
            }
          }
          return KeyEventResult.ignored;
        },
        child: child,
      ),
    );
  }

  /// Validate focus management for a list of focus nodes
  static List<FocusValidationIssue> validateFocusManagement(List<FocusNode> focusNodes) {
    final issues = <FocusValidationIssue>[];

    for (int i = 0; i < focusNodes.length; i++) {
      final node = focusNodes[i];
      
      // Check for debug labels
      if (node.debugLabel == null || node.debugLabel!.isEmpty) {
        issues.add(FocusValidationIssue(
          index: i,
          type: FocusIssueType.missingDebugLabel,
          description: 'Focus node at index $i is missing a debug label',
          suggestion: 'Add a descriptive debug label for better debugging and accessibility testing',
        ));
      }
      
      // Check for proper disposal
      if (node.hasListeners && node.context == null) {
        issues.add(FocusValidationIssue(
          index: i,
          type: FocusIssueType.memoryLeak,
          description: 'Focus node at index $i may have a memory leak',
          suggestion: 'Ensure focus node is properly disposed in the dispose() method',
        ));
      }
    }

    return issues;
  }

  /// Create focus highlight decoration
  static BoxDecoration createFocusHighlight(BuildContext context, {bool hasFocus = false}) {
    if (!hasFocus) return const BoxDecoration();
    
    return BoxDecoration(
      border: Border.all(
        color: Theme.of(context).colorScheme.primary,
        width: 2,
      ),
      borderRadius: BorderRadius.circular(4),
    );
  }
}

/// Focus validation issue
class FocusValidationIssue {
  final int index;
  final FocusIssueType type;
  final String description;
  final String suggestion;

  const FocusValidationIssue({
    required this.index,
    required this.type,
    required this.description,
    required this.suggestion,
  });
}

/// Types of focus management issues
enum FocusIssueType {
  missingDebugLabel,
  memoryLeak,
  improperTraversal,
  missingSemantics,
}

/// Custom traversal policy for accessibility
class AccessibilityTraversalPolicy extends TraversalPolicy {
  @override
  Iterable<FocusNode> sortDescendants(Iterable<FocusNode> descendants, FocusNode currentNode) {
    // Sort by reading order (top to bottom, left to right)
    final list = descendants.toList();
    list.sort((a, b) {
      final aRect = a.rect;
      final bRect = b.rect;
      
      // First sort by vertical position
      final verticalDiff = aRect.top.compareTo(bRect.top);
      if (verticalDiff != 0) return verticalDiff;
      
      // Then sort by horizontal position
      return aRect.left.compareTo(bRect.left);
    });
    
    return list;
  }
}