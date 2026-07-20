import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/models/badge_data.dart';
import '../../core/providers/progress_provider.dart';
import '../../core/widgets/badge_card.dart';
import '../../core/widgets/kiddo_card.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Badges')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KiddoCard(
              backgroundColor: AppColors.yellow,
              child: Column(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 60,
                    color: AppColors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${progress.stars} Stars',
                    style: AppTextStyles.headingLarge.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${progress.completedLessons} lessons completed',
                    style: AppTextStyles.body.copyWith(color: AppColors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.large),

            const Text('Your Badges', style: AppTextStyles.headingMedium),

            const SizedBox(height: AppSpacing.medium),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: BadgeData.badges.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final badge = BadgeData.badges[index];
                final isUnlocked =
                    progress.completedLessons >= badge.requiredLessons;

                return BadgeCard(badge: badge, isUnlocked: isUnlocked);
              },
            ),
          ],
        ),
      ),
    );
  }
}
