import 'package:flutter/material.dart';
import '../../../models/user_models.dart';

class UserStatusBadge extends StatelessWidget {
  final UserStatus status;
  final bool isSmall;

  const UserStatusBadge({
    super.key,
    required this.status,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: _getTextColor(),
          fontSize: isSmall ? 10 : 12,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case UserStatus.active:
        return const Color(0xFFD1FAE5); // Light green
      case UserStatus.inactive:
        return const Color(0xFFF3F4F6); // Light gray
      case UserStatus.suspended:
        return const Color(0xFFFEF3C7); // Light yellow
      case UserStatus.banned:
        return const Color(0xFFFEE2E2); // Light red
    }
  }

  Color _getTextColor() {
    switch (status) {
      case UserStatus.active:
        return const Color(0xFF059669); // Green
      case UserStatus.inactive:
        return const Color(0xFF6B7280); // Gray
      case UserStatus.suspended:
        return const Color(0xFFD97706); // Orange
      case UserStatus.banned:
        return const Color(0xFFDC2626); // Red
    }
  }
}

class UserRoleBadge extends StatelessWidget {
  final UserRole role;
  final bool isSmall;

  const UserRoleBadge({
    super.key,
    required this.role,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role.displayName,
        style: TextStyle(
          color: _getTextColor(),
          fontSize: isSmall ? 10 : 12,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (role) {
      case UserRole.customer:
        return const Color(0xFFF3F4F6); // Light gray
      case UserRole.admin:
        return const Color(0xFFDBEAFE); // Light blue
      case UserRole.moderator:
        return const Color(0xFFFEF3C7); // Light yellow
    }
  }

  Color _getTextColor() {
    switch (role) {
      case UserRole.customer:
        return const Color(0xFF6B7280); // Gray
      case UserRole.admin:
        return const Color(0xFF2563EB); // Blue
      case UserRole.moderator:
        return const Color(0xFFD97706); // Orange
    }
  }
}