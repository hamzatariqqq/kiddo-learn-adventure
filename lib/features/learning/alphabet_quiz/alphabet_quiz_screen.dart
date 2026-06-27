import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/data/alphabet_data.dart';
import '../../../core/providers/progress_provider.dart';

class AlphabetQuizScreen extends ConsumerStatefulWidget {
  const AlphabetQuizScreen({super.key});

  @override
  ConsumerState<AlphabetQuizScreen> createState() =>
      _AlphabetQuizScreenState();
}

class _AlphabetQuizScreenState extends ConsumerState<AlphabetQuizScreen> {
  final alphabetItems = AlphabetData.items;

  int currentQuestion = 0;
  int score = 0;

  List<String> get currentOptions {
    final correctLetter = alphabetItems[currentQuestion]['letter']!;
    final allLetters =
    alphabetItems.map((item) => item['letter']!).toList();

    allLetters.remove(correctLetter);
    allLetters.shuffle();

    final options = [
      correctLetter,
      allLetters[0],
      allLetters[1],
      allLetters[2],
    ];

    options.shuffle();
    return options;
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = alphabetItems[currentQuestion];
    final options = currentOptions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Alphabet Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${currentItem['letter']} for ${currentItem['word']} ${currentItem['emoji']}',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Question ${currentQuestion + 1} of ${alphabetItems.length}',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (currentQuestion + 1) / alphabetItems.length,
              minHeight: 10,
              borderRadius: BorderRadius.circular(20),
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation(
                AppColors.primaryBlue,
              ),
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
                children: options.map((letter) {
                  return _letterButton(letter);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _letterButton(String letter) {
    return InkWell(
      onTap: () {
        final bool isCorrect =
            letter == alphabetItems[currentQuestion]['letter'];

        if (isCorrect) {
          score++;
          ref.read(progressProvider.notifier).addStars(5);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCorrect ? 'Correct! 🎉 +5 Stars ⭐' : 'Try Again 😊',
            ),
            backgroundColor:
            isCorrect ? AppColors.green : AppColors.coral,
          ),
        );

        setState(() {
          if (currentQuestion < alphabetItems.length - 1) {
            currentQuestion++;
          } else {
            ref.read(progressProvider.notifier).completeLesson();
            Future.delayed(
              const Duration(milliseconds: 400),
              _showQuizCompleteDialog,
            );
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            letter,
            style: AppTextStyles.headingLarge.copyWith(
              color: AppColors.primaryBlue,
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
      builder: (_) => AlertDialog(
        title: const Text('🎉 Quiz Complete'),
        content: Text(
          'Your score is $score / ${alphabetItems.length}',
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
      ),
    );
  }
}