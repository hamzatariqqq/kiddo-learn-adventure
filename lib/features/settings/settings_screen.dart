import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/providers/progress_provider.dart';
import '../../core/widgets/kiddo_card.dart';
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
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: AppTextStyles.headingLarge),

            const SizedBox(height: AppSpacing.large),

            KiddoCard(
              child: ListTile(
                leading: const Icon(Icons.family_restroom_rounded),
                title: const Text('Parent Dashboard'),
                subtitle: const Text('View child progress'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ParentDashboardScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.medium),

            KiddoCard(
              child: ListTile(
                leading: const Icon(
                  Icons.restart_alt_rounded,
                  color: AppColors.coral,
                ),
                title: const Text('Reset Progress'),
                subtitle: const Text('Clear stars and completed lessons'),
                onTap: () {
                  ref.read(progressProvider.notifier).resetProgress();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Progress reset successfully'),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.medium),

            KiddoCard(
              child: ListTile(
                leading: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.coral,
                ),
                title: const Text('Logout'),
                subtitle: const Text('Sign out from your account'),
                onTap: () async {
                  await AuthService().logout();
                  ref.invalidate(authStateProvider);
                  ref.invalidate(currentUserProvider);

                  ref.read(progressProvider.notifier).resetProgress();

                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.medium),

            KiddoCard(
              child: ListTile(
                leading: const Icon(Icons.info_rounded),
                title: const Text('About App'),
                subtitle: const Text('Kiddo Learn Adventure v1.0.0'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
