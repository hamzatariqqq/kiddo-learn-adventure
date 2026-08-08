import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String lastUpdated = 'August 6, 2026';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _LegalHeader(
                icon: Icons.privacy_tip_rounded,
                title: 'Privacy Policy',
                subtitle:
                'How Kiddo Learn Adventure handles information.',
              ),

              const SizedBox(height: 24),

              const _LegalSection(
                title: '1. Introduction',
                text:
                'Kiddo Learn Adventure is a children’s educational app '
                    'designed to help children learn alphabets, numbers, '
                    'colors and animals through lessons, quizzes and games.',
              ),

              const _LegalSection(
                title: '2. Information We Collect',
                text:
                'We may collect the account name, email address, '
                    'lesson progress, stars, coins, XP, levels, streaks, '
                    'badges, achievements and completed lesson information.',
              ),

              const _LegalSection(
                title: '3. Why We Collect Information',
                text:
                'The information is used to create and secure accounts, '
                    'save learning progress, show achievements, restore '
                    'progress after login and improve the learning experience.',
              ),

              const _LegalSection(
                title: '4. Firebase Services',
                text:
                'The app uses Firebase Authentication for account login '
                    'and Cloud Firestore for storing account and learning '
                    'progress information. Firebase is provided by Google.',
              ),

              const _LegalSection(
                title: '5. Children’s Privacy',
                text:
                'The app is designed for children and parents. Parents '
                    'should create and manage the account. Children should '
                    'not enter unnecessary personal information. Parent-only '
                    'features are protected through a parental gate.',
              ),

              const _LegalSection(
                title: '6. Advertising',
                text:
                'The current version may not show advertising. If ads are '
                    'added later, child-appropriate and non-personalized ads '
                    'will be used according to applicable Google Play '
                    'Families requirements.',
              ),

              const _LegalSection(
                title: '7. Data Sharing',
                text:
                'We do not sell personal information. Information may be '
                    'processed by service providers required to operate the '
                    'app, including Firebase services.',
              ),

              const _LegalSection(
                title: '8. Data Security',
                text:
                'We use authentication and database security rules to '
                    'protect account information. However, no online service '
                    'can guarantee absolute security.',
              ),

              const _LegalSection(
                title: '9. Account and Data Deletion',
                text:
                'Users can permanently delete their account and associated '
                    'Firestore data from Settings → Delete Account. Account '
                    'deletion cannot be undone.',
              ),

              const _LegalSection(
                title: '10. Policy Changes',
                text:
                'This policy may be updated when app features, services '
                    'or legal requirements change. The latest version will '
                    'display its updated date.',
              ),

              const _LegalSection(
                title: '11. Contact Us',
                text:
                'For privacy questions or account deletion support, '
                    'contact: mehamzatariqq@gmail.com',
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: const Text(
                  'Last updated: $lastUpdated',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegalHeader extends StatelessWidget {
  const _LegalHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.40),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 54,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalSection extends StatelessWidget {
  const _LegalSection({
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF183B56),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF5F7187),
              fontSize: 14,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}