import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/data/animal_data.dart';
import '../../../core/providers/progress_provider.dart';

class AnimalQuizScreen extends ConsumerStatefulWidget {
  const AnimalQuizScreen({super.key});

  @override
  ConsumerState<AnimalQuizScreen> createState() => _AnimalQuizScreenState();
}

class _AnimalQuizScreenState extends ConsumerState<AnimalQuizScreen> {
  final animals = AnimalData.items;

  int currentQuestion = 0;
  int score = 0;

  List<String> get currentOptions {
    final correctAnimal = animals[currentQuestion]['name']!;
    final allAnimals = animals.map((item) => item['name']!).toList();

    allAnimals.remove(correctAnimal);
    allAnimals.shuffle();

    final options = [
      correctAnimal,
      allAnimals[0],
      allAnimals[1],
      allAnimals[2],
    ];

    options.shuffle();
    return options;
  }

  @override
  Widget build(BuildContext context) {
    final currentAnimal = animals[currentQuestion];
    final options = currentOptions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Animal Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Which animal is this?',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                currentAnimal['emoji']!,
                style: const TextStyle(fontSize: 90),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Question ${currentQuestion + 1} of ${animals.length}',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (currentQuestion + 1) / animals.length,
              minHeight: 10,
              borderRadius: BorderRadius.circular(20),
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation(AppColors.green),
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
                children: options.map((animal) {
                  return _animalButton(animal);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _animalButton(String animal) {
    return InkWell(
      onTap: () {
        final bool isCorrect = animal == animals[currentQuestion]['name'];

        if (isCorrect) {
          score++;
          ref.read(progressProvider.notifier).addStars(5);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCorrect ? 'Correct! 🎉 +5 Stars ⭐' : 'Try Again 😊',
            ),
            backgroundColor: isCorrect ? AppColors.green : AppColors.coral,
            behavior: SnackBarBehavior.floating,
          ),
        );

        setState(() {
          if (currentQuestion < animals.length - 1) {
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
          color: AppColors.green.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            animal,
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
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
            'Your score is $score / ${animals.length}',
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