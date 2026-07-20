import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../number_quiz/number_quiz_screen.dart';
import '../../../core/data/number_data.dart';

class CountingLessonScreen extends StatefulWidget {
  const CountingLessonScreen({super.key});

  @override
  State<CountingLessonScreen> createState() => _CountingLessonScreenState();
}

class _CountingLessonScreenState extends State<CountingLessonScreen> {
  final numbers = NumberData.items;

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final item = numbers[currentIndex];
    final isLast = currentIndex == numbers.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Learn Numbers')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          children: [
            Text(
              'Number ${currentIndex + 1} of ${numbers.length}',
              style: AppTextStyles.bodySmall,
            ),

            const SizedBox(height: 12),

            LinearProgressIndicator(
              value: (currentIndex + 1) / numbers.length,
              minHeight: 10,
              borderRadius: BorderRadius.circular(20),
              backgroundColor: AppColors.white,
              valueColor: const AlwaysStoppedAnimation(AppColors.orange),
            ),

            const SizedBox(height: 32),

            Text(
              item['number']!,
              style: AppTextStyles.headingLarge.copyWith(
                fontSize: 90,
                color: AppColors.orange,
              ),
            ),

            const SizedBox(height: 8),

            Text(item['word']!, style: AppTextStyles.headingMedium),

            const SizedBox(height: 24),

            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Text(
                    item['objects']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 42),
                  ),
                ),
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: currentIndex == 0
                        ? null
                        : () {
                            setState(() {
                              currentIndex--;
                            });
                          },
                    child: const Text('Previous'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (isLast) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NumberQuizScreen(),
                          ),
                        );
                      } else {
                        setState(() {
                          currentIndex++;
                        });
                      }
                    },
                    child: Text(isLast ? 'Start Quiz' : 'Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
