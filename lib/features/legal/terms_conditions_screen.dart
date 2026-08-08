import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const String lastUpdated = 'August 6, 2026';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.orange.withValues(alpha: 0.40),
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.description_rounded,
                      color: AppColors.orange,
                      size: 54,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Terms & Conditions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Rules for using Kiddo Learn Adventure.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const _TermsSection(
                title: '1. Acceptance of Terms',
                text:
                'By downloading, accessing or using Kiddo Learn '
                    'Adventure, the parent or guardian agrees to these terms.',
              ),

              const _TermsSection(
                title: '2. Educational Purpose',
                text:
                'The app provides educational lessons, quizzes and games. '
                    'It is intended as a learning aid and does not replace '
                    'school teaching or professional educational advice.',
              ),

              const _TermsSection(
                title: '3. Parent or Guardian Responsibility',
                text:
                'A parent or guardian should supervise the child’s use of '
                    'the app, manage the account and review any purchases or '
                    'account-related actions.',
              ),

              const _TermsSection(
                title: '4. Account Responsibility',
                text:
                'Users are responsible for keeping account credentials '
                    'private and providing accurate account information.',
              ),

              const _TermsSection(
                title: '5. Acceptable Use',
                text:
                'The app must not be misused, copied, modified, attacked, '
                    'reverse engineered or used for unlawful activities.',
              ),

              const _TermsSection(
                title: '6. Rewards and Progress',
                text:
                'Stars, coins, XP, badges and other rewards are virtual '
                    'items used only inside the app. They have no cash value.',
              ),

              const _TermsSection(
                title: '7. Premium Features',
                text:
                'If premium features are added, prices and benefits will '
                    'be displayed before purchase. Purchases will be handled '
                    'through the applicable app store billing system.',
              ),

              const _TermsSection(
                title: '8. Account Deletion',
                text:
                'Users may delete their account through Settings. '
                    'Deleting an account permanently removes associated '
                    'progress and cannot be undone.',
              ),

              const _TermsSection(
                title: '9. Availability',
                text:
                'We may update, change, suspend or remove app features '
                    'when required for maintenance, safety or improvement.',
              ),

              const _TermsSection(
                title: '10. Limitation of Liability',
                text:
                'The app is provided on an as-available basis. We are not '
                    'responsible for losses caused by device problems, '
                    'internet failure, service interruptions or misuse.',
              ),

              const _TermsSection(
                title: '11. Changes to These Terms',
                text:
                'These terms may be updated when the app or applicable '
                    'requirements change. Continued use after an update means '
                    'the revised terms are accepted.',
              ),

              const _TermsSection(
                title: '12. Contact',
                text:
                'For support or questions, contact: '
                    'mehamzatariqq@gmail.com',
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
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

class _TermsSection extends StatelessWidget {
  const _TermsSection({
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