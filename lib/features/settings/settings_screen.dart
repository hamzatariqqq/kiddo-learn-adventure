import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/providers/progress_provider.dart';
import '../parent/parent_dashboard_screen.dart';

import '../auth/services/auth_service.dart';
import '../auth/screens/login_screen.dart';
import '../auth/providers/user_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: AppTextStyles.headingLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Manage your app and account preferences.',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: AppSpacing.large),

            _SettingsTile(
              icon: Icons.family_restroom_rounded,
              iconColor: AppColors.primaryBlue,
              title: 'Parent Dashboard',
              subtitle: 'View child progress and activity',
              trailingIcon: Icons.arrow_forward_ios_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const ParentDashboardScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.medium),

            _SettingsTile(
              icon: Icons.restart_alt_rounded,
              iconColor: AppColors.orange,
              title: 'Reset Progress',
              subtitle: 'Clear stars and completed lessons',
              onTap: () {
                _showResetDialog(context, ref);
              },
            ),

            const SizedBox(height: AppSpacing.medium),

            _SettingsTile(
              icon: Icons.logout_rounded,
              iconColor: AppColors.coral,
              title: 'Logout',
              subtitle: 'Sign out from your account',
              onTap: () {
                _showLogoutDialog(context, ref);
              },
            ),

            const SizedBox(height: AppSpacing.medium),

            const _SettingsTile(
              icon: Icons.info_rounded,
              iconColor: AppColors.green,
              title: 'About App',
              subtitle: 'Kiddo Learn Adventure v1.0.0',
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(
      BuildContext context,
      WidgetRef ref,
      ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Reset Progress?'),
          content: const Text(
            'This will clear stars and completed lessons. '
                'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                ref
                    .read(progressProvider.notifier)
                    .resetProgress();

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Progress reset successfully',
                    ),
                    backgroundColor: AppColors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.coral,
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(
      BuildContext context,
      WidgetRef ref,
      ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Logout?'),
          content: const Text(
            'Are you sure you want to sign out?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await AuthService().logout();

                ref.invalidate(authStateProvider);
                ref.invalidate(currentUserProvider);

                ref
                    .read(progressProvider.notifier)
                    .resetProgress();

                if (!context.mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                      (route) => false,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.coral,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailingIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 27,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.title.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              if (trailingIcon != null)
                Icon(
                  trailingIcon,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}



