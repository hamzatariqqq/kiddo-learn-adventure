import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class AlphabetLessonScreen extends StatefulWidget {
  const AlphabetLessonScreen({super.key});

  @override
  State<AlphabetLessonScreen> createState() => _AlphabetLessonScreenState();
}

class _AlphabetLessonScreenState extends State<AlphabetLessonScreen> {
  int currentQuestion = 0;
  String? selectedLetter;
  bool? isCorrect;

  final List<String> letters = ['A', 'B'];
  final List<String> words = ['Apple', 'Ball'];

  String get correctLetter => letters[currentQuestion];

  String get currentWord => words[currentQuestion];

  void checkAnswer(String letter) {
    setState(() {
      selectedLetter = letter;
      isCorrect = letter == correctLetter;
    });
  }

  void nextQuestion() {
    setState(() {
      currentQuestion++;
      selectedLetter = null;
      isCorrect = null;
    });
  }

  Color getButtonColor(String letter) {
    if (selectedLetter != letter) {
      return AppColors.white;
    }

    return isCorrect == true ? AppColors.green : AppColors.coral;
  }

  Color getTextColor(String letter) {
    if (selectedLetter == letter) {
      return AppColors.white;
    }

    return AppColors.textPrimary;
  }

  Widget letterButton(String letter) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () {
            checkAnswer(letter);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: getButtonColor(letter),
            foregroundColor: getTextColor(letter),
            minimumSize: const Size(0, 58),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(
                color: AppColors.orange,
                width: 2,
              ),
            ),
          ),
          child: Text(
            letter,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastQuestion = currentQuestion == letters.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Alphabet Fun'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (currentQuestion + 1) / letters.length,
              minHeight: 10,
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
              color: AppColors.orange,
              backgroundColor: AppColors.white,
            ),
            const SizedBox(height: 32),
            const Text(
              'Learn the Letter',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap the letter $correctLetter',
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 36),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 38),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  Text(
                    correctLetter,
                    style: const TextStyle(
                      fontSize: 110,
                      fontWeight: FontWeight.bold,
                      color: AppColors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$correctLetter for $currentWord',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            Row(
              children: [
                letterButton('A'),
                letterButton('B'),
                letterButton('C'),
              ],
            ),
            const SizedBox(height: 24),
            if (isCorrect == false)
              const Text(
                'Try again!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.coral,
                ),
              ),
            if (isCorrect == true) ...[
              Text(
                'Great job! $correctLetter is correct! ⭐',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (isLastQuestion) {
                    Navigator.of(context).pop();
                  } else {
                    nextQuestion();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: AppColors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isLastQuestion ? 'Lesson Complete' : 'Next Letter',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}