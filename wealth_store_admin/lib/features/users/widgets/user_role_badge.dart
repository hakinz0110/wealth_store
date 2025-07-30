import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../models/user_models.dart';

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
        color: _getRoleColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role.displayName,
        style: TextStyle(
          fontSize: isSmall ? 10 : 12,
          fontWeight: FontWeight.w500,
          color: _getRoleColor(),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color _getRoleColor() {
    switch (role) {
      case UserRole.admin:
        return AppColors.primary;
      case UserRole.moderator:
        return AppColors.warning;
      case UserRole.customer:
        return AppColors.textPrimary;
    }
  }
}