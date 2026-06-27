import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../alphabet_quiz/alphabet_quiz_screen.dart';
import '../../../core/data/alphabet_data.dart';

class AlphabetLearningScreen extends StatefulWidget {
  const AlphabetLearningScreen({super.key});

  @override
  State<AlphabetLearningScreen> createState() => _AlphabetLearningScreenState();
}

class _AlphabetLearningScreenState extends State<AlphabetLearningScreen> {
  final alphabetItems = AlphabetData.items;

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final item = alphabetItems[currentIndex];
    final bool isLast = currentIndex == alphabetItems.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Learn Alphabets'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          children: [
            const SizedBox(height: 20),

            Text(
              item['emoji']!,
              style: const TextStyle(fontSize: 90),
            ),

            const SizedBox(height: 20),

            Text(
              item['letter']!,
              style: AppTextStyles.headingLarge.copyWith(
                fontSize: 80,
                color: AppColors.primaryBlue,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              '${item['letter']} for ${item['word']}',
              style: AppTextStyles.headingMedium,
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AlphabetQuizScreen(),
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