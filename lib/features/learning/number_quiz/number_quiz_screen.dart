import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/providers/progress_provider.dart';
import '../../../core/data/number_data.dart';

class NumberQuizScreen extends ConsumerStatefulWidget {
  const NumberQuizScreen({super.key});

  @override
  ConsumerState<NumberQuizScreen> createState() => _NumberQuizScreenState();
}

class _NumberQuizScreenState extends ConsumerState<NumberQuizScreen> {
  final numberItems = NumberData.items;

  int currentQuestion = 0;
  int score = 0;

  List<String> get currentOptions {
    final correctNumber = numberItems[currentQuestion]['number']!;
    final allNumbers = numberItems.map((item) => item['number']!).toList();

    allNumbers.remove(correctNumber);
    allNumbers.shuffle();

    final options = [
      correctNumber,
      allNumbers[0],
      allNumbers[1],
      allNumbers[2],
    ];

    options.shuffle();
    return options;
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = numberItems[currentQuestion];
    final options = currentOptions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Number Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How many apples?',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                currentItem['objects']!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 42),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Question ${currentQuestion + 1} of ${numberItems.length}',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (currentQuestion + 1) / numberItems.length,
              minHeight: 10,
              borderRadius: BorderRadius.circular(20),
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation(AppColors.orange),
            ),
            const SizedBox(height: 16),
            Text(
              'Score: $score',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: options.map((number) {
                  return _numberButton(number);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberButton(String number) {
    return InkWell(
      onTap: () {
        final bool isCorrect =
            number == numberItems[currentQuestion]['number'];

        if (isCorrect) {
          score++;
          ref.read(progressProvider.notifier).addStars(5);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCorrect ? 'Correct! 🎉  +5 Stars ⭐' : 'Try Again 😊',
            ),
            backgroundColor: isCorrect ? AppColors.green : AppColors.coral,
            behavior: SnackBarBehavior.floating,
          ),
        );

        setState(() {
          if (currentQuestion < numberItems.length - 1) {
            currentQuestion++;
          } else {
            ref.read(progressProvider.notifier).completeLesson();

            Future.delayed(
              const Duration(milliseconds: 400),
                  () {
                _showQuizCompleteDialog();
              },
            );
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.orange.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            number,
            style: AppTextStyles.headingLarge.copyWith(
              color: AppColors.orange,
              fontSize: 48,
            ),
          ),
        ),
      ),
    );
  }

  void _showQuizCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text('🎉 Quiz Complete'),
          content: Text(
            'Your score is $score / ${numberItems.length}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                setState(() {
                  currentQuestion = 0;
                  score = 0;
                });
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }
}