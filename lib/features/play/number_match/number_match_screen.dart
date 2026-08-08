import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/services/tts_service.dart';

class NumberMatchScreen extends StatefulWidget {
  const NumberMatchScreen({super.key});

  @override
  State<NumberMatchScreen> createState() => _NumberMatchScreenState();
}

class _NumberMatchScreenState extends State<NumberMatchScreen> {
  final Random _random = Random();

  final List<int> numbers = List.generate(10, (index) => index + 1);

  int currentIndex = 0;
  int score = 0;

  int? selectedNumber;
  bool? isCorrect;
  bool isAnswering = false;

  late List<int> options;

  int get currentNumber => numbers[currentIndex];

  @override
  void initState() {
    super.initState();
    _generateOptions();
  }

  void _generateOptions() {
    final wrongNumbers = numbers
        .where((number) => number != currentNumber)
        .toList()
      ..shuffle(_random);

    options = [
      currentNumber,
      ...wrongNumbers.take(3),
    ]..shuffle(_random);
  }

  Future<void> _checkAnswer(int number) async {
    if (isAnswering) return;

    final answerIsCorrect = number == currentNumber;

    setState(() {
      selectedNumber = number;
      isCorrect = answerIsCorrect;
      isAnswering = true;

      if (answerIsCorrect) {
        score++;
      }
    });

    if (answerIsCorrect) {
      await TtsService.instance.speak(
        'Correct! There are $currentNumber dots',
      );

      await Future<void>.delayed(
        const Duration(milliseconds: 600),
      );

      if (!mounted) return;

      if (currentIndex < numbers.length - 1) {
        setState(() {
          currentIndex++;
          selectedNumber = null;
          isCorrect = null;
          isAnswering = false;
          _generateOptions();
        });
      } else {
        _showCompleteDialog();
      }
    } else {
      await TtsService.instance.speak('Try again');

      await Future<void>.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      setState(() {
        selectedNumber = null;
        isCorrect = null;
        isAnswering = false;
      });
    }
  }

  Color _buttonBackground(int number) {
    if (selectedNumber != number) {
      return Colors.white;
    }

    return isCorrect == true
        ? AppColors.green
        : AppColors.coral;
  }

  Color _numberColor(int number) {
    if (selectedNumber == number) {
      return Colors.white;
    }

    return AppColors.orange;
  }

  Widget _numberButton(int number) {
    return SizedBox(
      width: 70,
      height: 70,
      child: ElevatedButton(
        onPressed: isAnswering
            ? null
            : () => _checkAnswer(number),
        style: ElevatedButton.styleFrom(
          backgroundColor: _buttonBackground(number),
          disabledBackgroundColor: _buttonBackground(number),
          foregroundColor: _numberColor(number),
          disabledForegroundColor: _numberColor(number),
          elevation: 3,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(
              color: AppColors.orange,
              width: 2,
            ),
          ),
        ),
        child: Text(
          '$number',
          style: TextStyle(
            color: _numberColor(number),
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _restartGame() {
    Navigator.pop(context);

    setState(() {
      currentIndex = 0;
      score = 0;
      selectedNumber = null;
      isCorrect = null;
      isAnswering = false;
      _generateOptions();
    });
  }

  void _showCompleteDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          title: const Text(
            '🎉 Number Match Complete!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Your score is $score / ${numbers.length}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: _restartGame,
              child: const Text('Play Again'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.orange,
              ),
              child: const Text('Finish'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (currentIndex + 1) / numbers.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Number Match'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Number ${currentIndex + 1}',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    'Score: $score',
                    style: const TextStyle(
                      color: AppColors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 9,
                  backgroundColor:
                  Colors.white.withValues(alpha: 0.20),
                  valueColor: const AlwaysStoppedAnimation(
                    AppColors.orange,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Match the Number',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Tap the number that matches the dots.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 30),

              GestureDetector(
                onTap: () {
                  TtsService.instance.speak(
                    'There are $currentNumber dots',
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 16,
                    children: List.generate(
                      currentNumber,
                          (_) => const _Dot(),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 34),

              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: options
                    .map(_numberButton)
                    .toList(),
              ),

              const SizedBox(height: 28),

              if (isCorrect == true)
                Text(
                  '🎉 Great job! There are $currentNumber dots!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.green,
                  ),
                ),

              if (isCorrect == false)
                const Text(
                  'Try again!',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.coral,
                  ),
                ),
            ],
          ),
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
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        shape: BoxShape.circle,
      ),
    );
  }
}