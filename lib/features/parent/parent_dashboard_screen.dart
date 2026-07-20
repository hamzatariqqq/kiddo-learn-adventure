import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/models/badge_data.dart';
import '../../core/providers/progress_provider.dart';
import '../../core/widgets/kiddo_card.dart';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);

    final unlockedBadges = BadgeData.badges
        .where((badge) => progress.completedLessons >= badge.requiredLessons)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Parent Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Child Progress', style: AppTextStyles.headingLarge),

            const SizedBox(height: AppSpacing.large),

            KiddoCard(
              backgroundColor: AppColors.softBlueBackground,
              child: _DashboardRow(
                icon: Icons.star_rounded,
                title: 'Total Stars',
                value: progress.stars.toString(),
                color: AppColors.primaryBlue,
              ),
            ),

            const SizedBox(height: AppSpacing.medium),

            KiddoCard(
              backgroundColor: AppColors.softGreenBackground,
              child: _DashboardRow(
                icon: Icons.menu_book_rounded,
                title: 'Lessons Completed',
                value: progress.completedLessons.toString(),
                color: AppColors.green,
              ),
            ),

            const SizedBox(height: AppSpacing.medium),

            KiddoCard(
              backgroundColor: AppColors.softYellowBackground,
              child: _DashboardRow(
                icon: Icons.workspace_premium_rounded,
                title: 'Badges Unlocked',
                value: '$unlockedBadges / ${BadgeData.badges.length}',
                color: AppColors.orange,
              ),
            ),

            const SizedBox(height: AppSpacing.large),

            Text('Learning Summary', style: AppTextStyles.headingMedium),

            const SizedBox(height: AppSpacing.medium),

            KiddoCard(
              child: Text(
                progress.completedLessons == 0
                    ? 'No lessons completed yet. Let your child finish a quiz to start tracking progress.'
                    : 'Great progress! Your child has completed ${progress.completedLessons} lessons and earned ${progress.stars} stars.',
                style: AppTextStyles.body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _DashboardRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.18),
          child: Icon(icon, color: color),
        ),

        const SizedBox(width: 16),

        Expanded(child: Text(title, style: AppTextStyles.title)),

        Text(value, style: AppTextStyles.headingMedium.copyWith(color: color)),
      ],
    );
  }
}
