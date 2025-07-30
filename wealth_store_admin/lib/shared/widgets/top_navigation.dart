import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../constants/app_colors.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../services/auth_service.dart';

class TopNavigation extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<String> breadcrumbs;

  const TopNavigation({
    super.key,
    required this.title,
    this.breadcrumbs = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final authMethods = ref.read(authMethodsProvider);

    return AppBar(
      backgroundColor: AppColors.cardBackground,
      elevation: 1,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Breadcrumbs
          if (breadcrumbs.isNotEmpty) ...[
            for (int i = 0; i < breadcrumbs.length; i++) ...[
              Text(
                breadcrumbs[i],
                style: TextStyle(
                  fontSize: 14,
                  color: i == breadcrumbs.length - 1 
                      ? AppColors.textPrimary 
                      : AppColors.textSecondary,
                  fontWeight: i == breadcrumbs.length - 1 
                      ? FontWeight.w600 
                      : FontWeight.w400,
                ),
              ),
              if (i < breadcrumbs.length - 1) ...[
                const SizedBox(width: 8),
                const Text(
                  '/',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ] else ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ],
      ),
      actions: [
        // Global search
        Container(
          width: 300,
          height: 36,
          margin: const EdgeInsets.symmetric(vertical: 14),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search anything...',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
              prefixIcon: const Icon(
                Icons.search,
                size: 20,
                color: AppColors.textMuted,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primaryBlue),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              filled: true,
              fillColor: AppColors.backgroundLight,
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Notifications
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppColors.textSecondary,
          ),
          onPressed: () {
            // TODO: Implement notifications
          },
          tooltip: 'Notifications',
        ),
        
        const SizedBox(width: 8),
        
        // User profile section
        if (currentUser != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryBlue,
                  child: Text(
                    (currentUser?.email?.isNotEmpty ?? false)
                        ? currentUser!.email![0].toUpperCase()
                        : 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (currentUser?.email?.length ?? 0) > 20 
                          ? '${currentUser!.email!.substring(0, 20)}...'
                          : currentUser?.email ?? 'Admin',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    FutureBuilder<String?>(
                      future: AuthService.getCurrentAdminDetails().then((details) => details?['role'] as String?),
                      builder: (context, snapshot) {
                        return Text(
                          (snapshot.data ?? 'ADMIN').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  offset: const Offset(0, 40),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.person_outline, size: 18),
                          SizedBox(width: 12),
                          Text('Profile'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(Icons.settings_outlined, size: 18),
                          SizedBox(width: 12),
                          Text('Settings'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 18, color: AppColors.error),
                          SizedBox(width: 12),
                          Text('Sign Out', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    switch (value) {
                      case 'profile':
                        // TODO: Navigate to profile
                        break;
                      case 'settings':
                        // TODO: Navigate to settings
                        break;
                      case 'logout':
                        await authMethods.signOut();
                        break;
                    }
                  },
                ),
              ],
            ),
          ),
        ],
        
        const SizedBox(width: 16),
      ],
    );
  }
}