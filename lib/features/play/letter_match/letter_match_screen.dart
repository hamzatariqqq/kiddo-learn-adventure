import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class LetterMatchScreen extends StatefulWidget {
  const LetterMatchScreen({super.key});

  @override
  State<LetterMatchScreen> createState() => _LetterMatchScreenState();
}

class _LetterMatchScreenState extends State<LetterMatchScreen> {
  String? selectedLetter;
  bool? isCorrect;

  void checkAnswer(String letter) {
    setState(() {
      selectedLetter = letter;
      isCorrect = letter == 'A';
    });
  }

  Color buttonColor(String letter) {
    if (selectedLetter != letter) {
      return AppColors.white;
    }

    return isCorrect == true ? AppColors.green : AppColors.coral;
  }

  Color textColor(String letter) {
    if (selectedLetter == letter) {
      return AppColors.white;
    }

    return AppColors.textPrimary;
  }

  Widget letterButton(String letter) {
    return SizedBox(
      width: 78,
      height: 70,
      child: ElevatedButton(
        onPressed: () {
          checkAnswer(letter);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor(letter),
          foregroundColor: textColor(letter),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.orange, width: 2),
          ),
        ),
        child: Text(
          letter,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Letter Match')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Match the Letter',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tap the letter shown below.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 36),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(
                child: Text(
                  'A',
                  style: TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                    color: AppColors.orange,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                letterButton('A'),
                letterButton('B'),
                letterButton('C'),
              ],
            ),
            const SizedBox(height: 24),
            if (isCorrect == true)
              const Text(
                'Great job! You found A! ⭐',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.green,
                ),
              ),
            if (isCorrect == false)
              const Text(
                'Try again!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.coral,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
