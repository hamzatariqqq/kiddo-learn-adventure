import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/providers/progress_provider.dart';
import '../../core/widgets/parent_gate_dialog.dart';
import '../auth/providers/user_provider.dart';
import '../auth/screens/login_screen.dart';
import '../auth/services/auth_service.dart';
import '../parent/parent_dashboard_screen.dart';

import '../legal/privacy_policy_screen.dart';
import '../legal/terms_conditions_screen.dart';
import '../premium/premium_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const Color cardBackground = Color(0xFFF4F7FB);
  static const Color cardTitleColor = Color(0xFF183B56);
  static const Color cardSubtitleColor = Color(0xFF6B7A90);

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
      body: SafeArea(
        child: SingleChildScrollView(
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

              // Parent Dashboard
              _SettingsTile(
                icon: Icons.family_restroom_rounded,
                iconColor: AppColors.primaryBlue,
                title: 'Parent Dashboard',
                subtitle: 'View child progress and activity',
                trailingIcon: Icons.arrow_forward_ios_rounded,
                onTap: () async {
                  final allowed = await ParentGateDialog.show(context);

                  if (!context.mounted || !allowed) return;

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ParentDashboardScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.medium),

              // Reset Progress
              _SettingsTile(
                icon: Icons.restart_alt_rounded,
                iconColor: AppColors.orange,
                title: 'Reset Progress',
                subtitle: 'Clear stars and completed lessons',
                trailingIcon: Icons.arrow_forward_ios_rounded,
                onTap: () async {
                  final allowed = await ParentGateDialog.show(context);

                  if (!context.mounted || !allowed) return;

                  _showResetDialog(context, ref);
                },
              ),

              const SizedBox(height: AppSpacing.medium),

              // Logout
              _SettingsTile(
                icon: Icons.logout_rounded,
                iconColor: const Color(0xFF9B6DFF),
                title: 'Logout',
                subtitle: 'Sign out from your account',
                trailingIcon: Icons.arrow_forward_ios_rounded,
                onTap: () {
                  _showLogoutDialog(context, ref);
                },
              ),

              const SizedBox(height: AppSpacing.medium),

              // Delete Account
              _SettingsTile(
                icon: Icons.delete_forever_rounded,
                iconColor: AppColors.coral,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account and data',
                trailingIcon: Icons.arrow_forward_ios_rounded,
                onTap: () async {
                  final allowed = await ParentGateDialog.show(context);

                  if (!context.mounted || !allowed) return;

                  await _openDeleteAccountDialog(context, ref);
                },
              ),

              const SizedBox(height: AppSpacing.medium),

              _SettingsTile(
                icon: Icons.privacy_tip_rounded,
                iconColor: const Color(0xFF28A7FF),
                title: 'Privacy Policy',
                subtitle: 'Read how your data is handled',
                trailingIcon: Icons.arrow_forward_ios_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.medium),

              _SettingsTile(
                icon: Icons.description_rounded,
                iconColor: const Color(0xFF7C6CFF),
                title: 'Terms & Conditions',
                subtitle: 'Read the rules for using the app',
                trailingIcon: Icons.arrow_forward_ios_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TermsConditionsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.medium),

              _SettingsTile(
                icon: Icons.workspace_premium_rounded,
                iconColor: AppColors.gold,
                title: 'Go Premium',
                subtitle: 'Remove ads and unlock premium features',
                trailingIcon: Icons.arrow_forward_ios_rounded,
                onTap: () async {
                  final allowed = await ParentGateDialog.show(context);

                  if (!context.mounted || !allowed) return;

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PremiumScreen(),
                    ),
                  );
                },
              ),

              const _SettingsTile(
                icon: Icons.info_rounded,
                iconColor: AppColors.green,
                title: 'About App',
                subtitle: 'Kiddo Learn Adventure v1.0.0',
              ),
            ],
          ),
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
          backgroundColor: cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Reset Progress?',
            style: TextStyle(
              color: cardTitleColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'This will clear stars and completed lessons. '
                'This action cannot be undone.',
            style: TextStyle(
              color: cardSubtitleColor,
              height: 1.4,
            ),
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
                Navigator.pop(dialogContext);

                ref.read(progressProvider.notifier).resetProgress();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Progress reset successfully.',
                    ),
                    backgroundColor: AppColors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.coral,
                foregroundColor: Colors.white,
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
          backgroundColor: cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Logout?',
            style: TextStyle(
              color: cardTitleColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(
              color: cardSubtitleColor,
            ),
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

                try {
                  await AuthService().logout();

                  ref.invalidate(authStateProvider);
                  ref.invalidate(currentUserProvider);

                  ref.read(progressProvider.notifier).resetProgress();

                  if (!context.mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                        (route) => false,
                  );
                } catch (_) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Unable to logout. Please try again.',
                      ),
                      backgroundColor: AppColors.coral,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.coral,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openDeleteAccountDialog(
      BuildContext context,
      WidgetRef ref,
      ) async {
    final passwordController = TextEditingController();

    final password = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool hidePassword = true;
        String? validationMessage;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text(
                'Delete Account?',
                style: TextStyle(
                  color: cardTitleColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your account, progress, stars, coins, XP and '
                          'achievements will be permanently deleted.',
                      style: TextStyle(
                        color: cardSubtitleColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'This action cannot be undone.',
                      style: TextStyle(
                        color: AppColors.coral,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      obscureText: hidePassword,
                      style: const TextStyle(
                        color: cardTitleColor,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Enter your password',
                        hintText: 'Password',
                        errorText: validationMessage,
                        labelStyle: const TextStyle(
                          color: cardSubtitleColor,
                        ),
                        hintStyle: const TextStyle(
                          color: cardSubtitleColor,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.primaryBlue,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setDialogState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: cardSubtitleColor,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.primaryBlue.withValues(
                              alpha: 0.35,
                            ),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.primaryBlue,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    final enteredPassword =
                    passwordController.text.trim();

                    if (enteredPassword.isEmpty) {
                      setDialogState(() {
                        validationMessage =
                        'Please enter your password.';
                      });
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      enteredPassword,
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.coral,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(
                    Icons.delete_forever_rounded,
                  ),
                  label: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );

    passwordController.dispose();

    if (password == null || password.isEmpty) {
      return;
    }

    if (!context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: cardBackground,
            content: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.coral,
                  ),
                  SizedBox(height: 22),
                  Text(
                    'Deleting your account...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: cardTitleColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please wait and do not close the app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: cardSubtitleColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      await AuthService().deleteAccount(
        password: password,
      );

      ref.read(progressProvider.notifier).resetProgress();

      ref.invalidate(authStateProvider);
      ref.invalidate(currentUserProvider);

      if (!context.mounted) return;

      Navigator.of(
        context,
        rootNavigator: true,
      ).pop();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
            (route) => false,
      );
    } catch (error) {
      if (!context.mounted) return;

      Navigator.of(
        context,
        rootNavigator: true,
      ).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _deleteAccountErrorMessage(error),
          ),
          backgroundColor: AppColors.coral,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  String _deleteAccountErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'wrong-password':
        case 'invalid-credential':
          return 'The password you entered is incorrect.';

        case 'requires-recent-login':
          return 'Please logout, login again and retry.';

        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';

        case 'network-request-failed':
          return 'Please check your internet connection.';

        default:
          return error.message ??
              'The account could not be deleted.';
      }
    }

    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }

    return 'The account could not be deleted. Please try again.';
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailingIcon,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SettingsScreen.cardBackground,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 16,
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
                        color: SettingsScreen.cardTitleColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: SettingsScreen.cardSubtitleColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingIcon != null)
                Icon(
                  trailingIcon,
                  color: AppColors.primaryBlue,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}