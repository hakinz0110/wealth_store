import 'package:flutter/services.dart';

/// Haptic feedback utility for providing appropriate tactile feedback
/// Based on Material Design guidelines and iOS Human Interface Guidelines
class HapticFeedbackUtils {
  
  /// Light impact feedback for subtle interactions
  /// Use for: Button taps, toggle switches, selection changes
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }
  
  /// Medium impact feedback for standard interactions
  /// Use for: Successful actions, confirmations, important button presses
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }
  
  /// Heavy impact feedback for significant interactions
  /// Use for: Errors, warnings, critical actions, destructive operations
  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }
  
  /// Selection click feedback for navigation and selection
  /// Use for: Tab navigation, list item selection, menu navigation
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }
  
  /// Vibrate for notifications and alerts
  /// Use for: Incoming messages, system notifications, alerts
  static void vibrate() {
    HapticFeedback.vibrate();
  }
  
  // Contextual haptic feedback methods
  
  /// Feedback for successful operations
  static void success() {
    mediumImpact();
  }
  
  /// Feedback for error states
  static void error() {
    heavyImpact();
  }
  
  /// Feedback for warning states
  static void warning() {
    mediumImpact();
  }
  
  /// Feedback for button presses
  static void buttonPress() {
    lightImpact();
  }
  
  /// Feedback for toggle actions (switches, checkboxes)
  static void toggle() {
    lightImpact();
  }
  
  /// Feedback for navigation actions
  static void navigation() {
    selectionClick();
  }
  
  /// Feedback for drag and drop operations
  static void dragStart() {
    lightImpact();
  }
  
  /// Feedback for successful drop operations
  static void dropSuccess() {
    mediumImpact();
  }
  
  /// Feedback for failed drop operations
  static void dropFailed() {
    heavyImpact();
  }
  
  /// Feedback for swipe actions
  static void swipe() {
    lightImpact();
  }
  
  /// Feedback for pull-to-refresh actions
  static void pullToRefresh() {
    lightImpact();
  }
  
  /// Feedback for refresh completion
  static void refreshComplete() {
    mediumImpact();
  }
  
  /// Feedback for adding items (e.g., add to cart)
  static void addItem() {
    mediumImpact();
  }
  
  /// Feedback for removing items
  static void removeItem() {
    lightImpact();
  }
  
  /// Feedback for quantity changes
  static void quantityChange() {
    lightImpact();
  }
  
  /// Feedback for like/favorite actions
  static void favorite() {
    mediumImpact();
  }
  
  /// Feedback for share actions
  static void share() {
    lightImpact();
  }
  
  /// Feedback for search actions
  static void search() {
    selectionClick();
  }
  
  /// Feedback for filter applications
  static void filter() {
    lightImpact();
  }
  
  /// Feedback for sort actions
  static void sort() {
    lightImpact();
  }
  
  /// Feedback for form validation errors
  static void validationError() {
    heavyImpact();
  }
  
  /// Feedback for form submission success
  static void formSubmitSuccess() {
    mediumImpact();
  }
  
  /// Feedback for payment actions
  static void payment() {
    mediumImpact();
  }
  
  /// Feedback for checkout completion
  static void checkoutComplete() {
    mediumImpact();
  }
  
  /// Feedback for authentication success
  static void authSuccess() {
    mediumImpact();
  }
  
  /// Feedback for authentication failure
  static void authFailure() {
    heavyImpact();
  }
  
  /// Feedback for biometric authentication
  static void biometric() {
    lightImpact();
  }
  
  /// Feedback for camera capture
  static void cameraCapture() {
    mediumImpact();
  }
  
  /// Feedback for voice recording start
  static void voiceRecordStart() {
    lightImpact();
  }
  
  /// Feedback for voice recording stop
  static void voiceRecordStop() {
    mediumImpact();
  }
  
  /// Feedback for notification interactions
  static void notification() {
    vibrate();
  }
  
  /// Feedback for achievement unlocks
  static void achievement() {
    mediumImpact();
  }
  
  /// Feedback for level completion or progress milestones
  static void milestone() {
    mediumImpact();
  }
  
  /// Feedback for connection established
  static void connectionEstablished() {
    lightImpact();
  }
  
  /// Feedback for connection lost
  static void connectionLost() {
    heavyImpact();
  }
  
  /// Feedback for data sync completion
  static void syncComplete() {
    lightImpact();
  }
  
  /// Feedback for backup completion
  static void backupComplete() {
    mediumImpact();
  }
  
  /// Feedback for app update available
  static void updateAvailable() {
    lightImpact();
  }
  
  /// Feedback for app update completion
  static void updateComplete() {
    mediumImpact();
  }
  
  // Accessibility-specific haptic feedback methods
  
  /// Feedback for focus changes in accessibility mode
  static void focusChange() {
    selectionClick();
  }
  
  /// Feedback for screen reader announcements
  static void announcement() {
    lightImpact();
  }
  
  /// Feedback for accessibility actions (double tap, swipe gestures)
  static void accessibilityAction() {
    mediumImpact();
  }
  
  /// Feedback for form validation in accessibility context
  static void accessibilityFormValidation({required bool isValid}) {
    if (isValid) {
      lightImpact();
    } else {
      heavyImpact();
    }
  }
  
  /// Feedback for page navigation in accessibility mode
  static void accessibilityPageNavigation() {
    mediumImpact();
  }
  
  /// Feedback for modal or dialog actions in accessibility context
  static void accessibilityModalAction() {
    mediumImpact();
  }
  
  /// Feedback for loading state completion in accessibility mode
  static void accessibilityLoadingComplete() {
    lightImpact();
  }
  
  /// Feedback for touch target activation (minimum 44dp compliance)
  static void touchTargetActivation() {
    lightImpact();
  }
  
  /// Feedback for semantic action completion
  static void semanticActionComplete() {
    mediumImpact();
  }

  /// Contextual feedback based on interaction type
  static void contextualFeedback(HapticFeedbackType type) {
    switch (type) {
      case HapticFeedbackType.success:
        success();
        break;
      case HapticFeedbackType.error:
        error();
        break;
      case HapticFeedbackType.warning:
        warning();
        break;
      case HapticFeedbackType.buttonPress:
        buttonPress();
        break;
      case HapticFeedbackType.toggle:
        toggle();
        break;
      case HapticFeedbackType.navigation:
        navigation();
        break;
      case HapticFeedbackType.addItem:
        addItem();
        break;
      case HapticFeedbackType.removeItem:
        removeItem();
        break;
      case HapticFeedbackType.favorite:
        favorite();
        break;
      case HapticFeedbackType.share:
        share();
        break;
      case HapticFeedbackType.payment:
        payment();
        break;
      case HapticFeedbackType.notification:
        notification();
        break;
      case HapticFeedbackType.focusChange:
        focusChange();
        break;
      case HapticFeedbackType.accessibilityAction:
        accessibilityAction();
        break;
      case HapticFeedbackType.touchTargetActivation:
        touchTargetActivation();
        break;
    }
  }
}

/// Enum for different types of haptic feedback contexts
enum HapticFeedbackType {
  success,
  error,
  warning,
  buttonPress,
  toggle,
  navigation,
  addItem,
  removeItem,
  favorite,
  share,
  payment,
  notification,
  focusChange,
  accessibilityAction,
  touchTargetActivation,
}