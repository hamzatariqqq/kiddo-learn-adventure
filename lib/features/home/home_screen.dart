import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/providers/progress_provider.dart';
import '../../core/widgets/achievement_card.dart';
import '../../core/widgets/category_card.dart';
import '../../core/widgets/home_header.dart';
import '../../core/widgets/progress_summary_card.dart';
import '../learning/alphabet/alphabet_learning_screen.dart';
import '../learning/colors/colors_lesson_screen.dart';
import '../learning/number_quiz/number_quiz_screen.dart';
import '../learning/animal_quiz/animal_quiz_screen.dart';
import '../parent/parent_dashboard_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(
                childName: 'Explorer',
                stars: progress.stars,
              ),

              const SizedBox(height: AppSpacing.large),

              ProgressSummaryCard(
                completedLessons: progress.completedLessons,
                totalLessons: 8,
                streakDays: 5,
              ),
              const SizedBox(height: AppSpacing.medium),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ParentDashboardScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.family_restroom_rounded),
                  label: const Text('Parent Dashboard'),
                ),
              ),
              const SizedBox(height: AppSpacing.medium),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings_rounded),
                  label: const Text('Settings'),
                ),
              ),

              const SizedBox(height: AppSpacing.large),

              const Text(
                'Learning Adventures',
                style: AppTextStyles.headingMedium,
              ),

              const SizedBox(height: AppSpacing.small),

              const Text(
                'Choose a subject and start learning.',
                style: AppTextStyles.bodySmall,
              ),

              const SizedBox(height: AppSpacing.large),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
                children: [
                  CategoryCard(
                    title: 'Alphabets',
                    lessonCount: '24 Lessons',
                    icon: Icons.abc_rounded,
                    color: AppColors.primaryBlue,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                          const AlphabetLearningScreen(),
                        ),
                      );
                    },
                  ),
                  CategoryCard(
                    title: 'Numbers',
                    lessonCount: '20 Lessons',
                    icon: Icons.numbers_rounded,
                    color: AppColors.orange,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NumberQuizScreen(),
                        ),
                      );
                    },
                  ),
                  CategoryCard(
                    title: 'Animals',
                    lessonCount: '15 Lessons',
                    icon: Icons.pets_rounded,
                    color: AppColors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AnimalQuizScreen(),
                        ),
                      );
                    },
                  ),
                  CategoryCard(
                    title: 'Colors',
                    lessonCount: '10 Lessons',
                    icon: Icons.palette_rounded,
                    color: AppColors.purple,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                          const ColorsLessonScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.large),

              const Text(
                'Achievements',
                style: AppTextStyles.headingMedium,
              ),

              const SizedBox(height: AppSpacing.medium),

              AchievementCard(
                title: progress.completedLessons >= 1
                    ? 'Beginner Learner'
                    : 'Keep Learning',
                subtitle: progress.completedLessons >= 1
                    ? 'You completed your first lesson!'
                    : 'Complete 1 lesson to unlock a badge',
                icon: progress.completedLessons >= 1
                    ? Icons.workspace_premium_rounded
                    : Icons.lock_rounded,
                color: progress.completedLessons >= 1
                    ? AppColors.orange
                    : AppColors.textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}