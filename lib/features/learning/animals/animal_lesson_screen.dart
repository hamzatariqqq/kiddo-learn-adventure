import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/data/animal_data.dart';
import '../animal_quiz/animal_quiz_screen.dart';

class AnimalLessonScreen extends StatefulWidget {
  const AnimalLessonScreen({super.key});

  @override
  State<AnimalLessonScreen> createState() => _AnimalLessonScreenState();
}

class _AnimalLessonScreenState extends State<AnimalLessonScreen> {
  final animals = AnimalData.items;
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final animal = animals[currentIndex];
    final isLast = currentIndex == animals.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Learn Animals')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          children: [
            Text(
              'Animal ${currentIndex + 1} of ${animals.length}',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (currentIndex + 1) / animals.length,
              minHeight: 10,
              borderRadius: BorderRadius.circular(20),
              backgroundColor: AppColors.white,
              valueColor: const AlwaysStoppedAnimation(AppColors.green),
            ),
            const SizedBox(height: 40),
            Text(animal['emoji']!, style: const TextStyle(fontSize: 100)),
            const SizedBox(height: 24),
            Text(
              animal['name']!,
              style: AppTextStyles.headingLarge.copyWith(
                color: AppColors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
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
                            builder: (_) => const AnimalQuizScreen(),
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
