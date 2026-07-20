import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/widgets/category_card.dart';

import '../learning/alphabet/alphabet_learning_screen.dart';
import '../learning/animal_quiz/animal_quiz_screen.dart';
import '../learning/colors/colors_lesson_screen.dart';
import '../learning/number_quiz/number_quiz_screen.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Learn')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose a Subject', style: AppTextStyles.headingLarge),

              const SizedBox(height: AppSpacing.small),

              const Text(
                'Pick a learning adventure and start practicing.',
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AlphabetLearningScreen(),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NumberQuizScreen(),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ColorsLessonScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
