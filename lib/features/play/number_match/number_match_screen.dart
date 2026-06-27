import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class NumberMatchScreen extends StatefulWidget {
  const NumberMatchScreen({super.key});

  @override
  State<NumberMatchScreen> createState() => _NumberMatchScreenState();
}

class _NumberMatchScreenState extends State<NumberMatchScreen> {
  int? selectedNumber;
  bool? isCorrect;

  void checkAnswer(int number) {
    setState(() {
      selectedNumber = number;
      isCorrect = number == 3;
    });
  }

  Color buttonColor(int number) {
    if (selectedNumber != number) {
      return AppColors.white;
    }

    return isCorrect == true ? AppColors.green : AppColors.coral;
  }

  Color textColor(int number) {
    if (selectedNumber == number) {
      return AppColors.white;
    }

    return AppColors.textPrimary;
  }

  Widget numberButton(int number) {
    return SizedBox(
      width: 70,
      height: 70,
      child: ElevatedButton(
        onPressed: () {
          checkAnswer(number);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor(number),
          foregroundColor: textColor(number),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(
              color: AppColors.primaryBlue,
              width: 2,
            ),
          ),
        ),
        child: Text(
          '$number',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Number Match'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Match the Number',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tap the number that matches the dots.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 36),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Wrap(
                alignment: WrapAlignment.center,
                spacing: 18,
                runSpacing: 18,
                children: [
                  _Dot(),
                  _Dot(),
                  _Dot(),
                ],
              ),
            ),
            const SizedBox(height: 36),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                numberButton(1),
                numberButton(2),
                numberButton(3),
                numberButton(4),
              ],
            ),
            const SizedBox(height: 24),
            if (isCorrect == true)
              const Text(
                'Great job! There are 3 dots! ⭐',
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

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        shape: BoxShape.circle,
      ),
    );
  }
}