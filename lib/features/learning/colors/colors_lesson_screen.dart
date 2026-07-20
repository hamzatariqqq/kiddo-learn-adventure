import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/data/color_data.dart';
import 'colors_quiz_screen.dart';

class ColorsLessonScreen extends StatelessWidget {
  const ColorsLessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = ColorData.items;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Learn Colors')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Learn Colors', style: AppTextStyles.headingLarge),
              const SizedBox(height: AppSpacing.small),
              const Text(
                'Tap and learn different colors.',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: AppSpacing.large),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: colors.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final colorItem = colors[index];

                  return Container(
                    decoration: BoxDecoration(
                      color: (colorItem['color'] as Color).withValues(
                        alpha: 0.18,
                      ),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          colorItem['emoji'] as String,
                          style: const TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          colorItem['name'] as String,
                          style: AppTextStyles.title,
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.large),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ColorsQuizScreen(),
                      ),
                    );
                  },
                  child: const Text('Start Color Quiz'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
