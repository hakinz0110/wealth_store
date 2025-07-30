import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/core/theme/app_theme_provider.dart';
import 'package:wealth_app/features/profile/domain/profile_notifier.dart';
import 'package:wealth_app/shared/widgets/base_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileNotifierProvider);
    final customer = profileState.customer;
    final preferences = customer?.preferences ?? {};
    
    // Default to system if not set in preferences
    final savedTheme = preferences['theme'] as String? ?? 'system';
    final savedLanguage = preferences['language'] as String? ?? 'english';

    return BaseScreen(
      title: 'Settings',
      showBackButton: true,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        children: [
          // Theme section
          _buildSectionHeader(context, 'Theme'),
          _buildThemeOption(
            context,
            title: 'Light Theme',
            icon: Icons.light_mode,
            isSelected: savedTheme == 'light',
            onTap: () {
              ref.read(appThemeProvider.notifier).setThemeMode(ThemeMode.light);
              ref.read(profileNotifierProvider.notifier).updateThemePreference('light');
            },
          ),
          _buildThemeOption(
            context,
            title: 'Dark Theme',
            icon: Icons.dark_mode,
            isSelected: savedTheme == 'dark',
            onTap: () {
              ref.read(appThemeProvider.notifier).setThemeMode(ThemeMode.dark);
              ref.read(profileNotifierProvider.notifier).updateThemePreference('dark');
            },
          ),
          _buildThemeOption(
            context,
            title: 'System Default',
            icon: Icons.settings_suggest,
            isSelected: savedTheme == 'system',
            onTap: () {
              ref.read(appThemeProvider.notifier).setThemeMode(ThemeMode.system);
              ref.read(profileNotifierProvider.notifier).updateThemePreference('system');
            },
          ),
          
          const SizedBox(height: AppSpacing.large),
          
          // Language section
          _buildSectionHeader(context, 'Language'),
          _buildLanguageOption(
            context,
            title: 'English',
            isSelected: savedLanguage == 'english',
            onTap: () {
              ref.read(profileNotifierProvider.notifier).updateLanguagePreference('english');
            },
          ),
          _buildLanguageOption(
            context,
            title: 'Spanish',
            isSelected: savedLanguage == 'spanish',
            onTap: () {
              ref.read(profileNotifierProvider.notifier).updateLanguagePreference('spanish');
            },
          ),
          _buildLanguageOption(
            context,
            title: 'French',
            isSelected: savedLanguage == 'french',
            onTap: () {
              ref.read(profileNotifierProvider.notifier).updateLanguagePreference('french');
            },
          ),
          
          const SizedBox(height: AppSpacing.large),
          
          // App information
          _buildSectionHeader(context, 'About'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: () {
              // Navigate to privacy policy
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            onTap: () {
              // Navigate to terms of service
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.small,
        horizontal: AppSpacing.small,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: isSelected
          ? const Icon(
              Icons.check_circle,
              color: Colors.green,
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: isSelected
          ? const Icon(
              Icons.check_circle,
              color: Colors.green,
            )
          : null,
      onTap: onTap,
    );
  }
} 