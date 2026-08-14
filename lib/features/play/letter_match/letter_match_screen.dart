import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/data/alphabet_data.dart';

class LetterMatchScreen extends StatefulWidget {
  const LetterMatchScreen({super.key});

  @override
  State<LetterMatchScreen> createState() => _LetterMatchScreenState();
}

class _LetterMatchScreenState extends State<LetterMatchScreen> {
  final List<Map<String, String>> alphabetItems = AlphabetData.items;
  final Random _random = Random();

  final AudioPlayer _audioPlayer = AudioPlayer();

  int currentIndex = 0;
  int score = 0;

  String? selectedLetter;
  bool? isCorrect;
  bool isAnswering = false;

  late List<String> options;

  @override
  void initState() {
    super.initState();
    _generateOptions();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playMatchSound('match_start.mp3');
    });
  }

  String get currentLetter =>
      alphabetItems[currentIndex]['letter']!;

  String get currentWord =>
      alphabetItems[currentIndex]['word']!;

  void _generateOptions() {
    final correctLetter = currentLetter;

    final wrongLetters = alphabetItems
        .map((item) => item['letter']!)
        .where((letter) => letter != correctLetter)
        .toList()
      ..shuffle(_random);

    options = [
      correctLetter,
      ...wrongLetters.take(2),
    ]..shuffle(_random);
  }

  Future<void> _playMatchSound(String fileName) async {
    try {
      await _audioPlayer.stop();

      await _audioPlayer.play(
        AssetSource('audio/match/$fileName'),
      );
    } catch (e) {
      debugPrint('Match audio error: $e');
    }
  }

  Future<void> _checkAnswer(String letter) async {
    if (isAnswering) return;

    final answerIsCorrect = letter == currentLetter;

    setState(() {
      selectedLetter = letter;
      isCorrect = answerIsCorrect;
      isAnswering = true;

      if (answerIsCorrect) {
        score++;
      }
    });

    if (answerIsCorrect) {
      await _playMatchSound('match_correct.mp3');

      await Future<void>.delayed(
        const Duration(milliseconds: 900),
      );

      if (!mounted) return;

      if (currentIndex < alphabetItems.length - 1) {
        setState(() {
          currentIndex++;
          selectedLetter = null;
          isCorrect = null;
          isAnswering = false;

          _generateOptions();
        });
      } else {
        await _playMatchSound('match_complete.mp3');

        await Future<void>.delayed(
          const Duration(milliseconds: 900),
        );

        if (!mounted) return;

        _showCompleteDialog();
      }
    } else {
      await _playMatchSound('match_wrong.mp3');

      await Future<void>.delayed(
        const Duration(milliseconds: 900),
      );

      if (!mounted) return;

      setState(() {
        selectedLetter = null;
        isCorrect = null;
        isAnswering = false;
      });
    }
  }

  Color _buttonBackground(String letter) {
    if (selectedLetter != letter) {
      return Colors.white;
    }

    return isCorrect == true
        ? AppColors.green
        : AppColors.coral;
  }

  Color _letterColor(String letter) {
    if (selectedLetter == letter) {
      return Colors.white;
    }

    return AppColors.orange;
  }

  Widget _letterButton(String letter) {
    return SizedBox(
      width: 78,
      height: 66,
      child: ElevatedButton(
        onPressed:
        isAnswering ? null : () => _checkAnswer(letter),
        style: ElevatedButton.styleFrom(
          backgroundColor: _buttonBackground(letter),
          disabledBackgroundColor: _buttonBackground(letter),
          foregroundColor: _letterColor(letter),
          disabledForegroundColor: _letterColor(letter),
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
          letter,
          style: TextStyle(
            color: _letterColor(letter),
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
      selectedLetter = null;
      isCorrect = null;
      isAnswering = false;

      _generateOptions();
    });

    _playMatchSound('match_start.mp3');
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
            '🎉 Letter Match Complete!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Your score is $score / ${alphabetItems.length}',
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
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        (currentIndex + 1) / alphabetItems.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Letter Match'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Letter ${currentIndex + 1}',
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
                  valueColor:
                  const AlwaysStoppedAnimation<Color>(
                    AppColors.orange,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Match the Letter',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Tap the correct letter shown below.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                height: 210,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    currentLetter,
                    key: ValueKey(currentLetter),
                    style: const TextStyle(
                      color: AppColors.orange,
                      fontSize: 100,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Wrap(
                alignment: WrapAlignment.center,
                spacing: 14,
                runSpacing: 14,
                children: options
                    .map(_letterButton)
                    .toList(),
              ),

              const SizedBox(height: 28),

              if (isCorrect == true)
                const Text(
                  '🎉 Great Job!',
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              if (isCorrect == false)
                const Text(
                  'Try Again!',
                  style: TextStyle(
                    color: AppColors.coral,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}