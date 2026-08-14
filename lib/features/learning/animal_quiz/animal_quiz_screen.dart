import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/data/animal_data.dart';
import '../services/lesson_service.dart';

class AnimalQuizScreen extends StatefulWidget {
  const AnimalQuizScreen({super.key});

  @override
  State<AnimalQuizScreen> createState() => _AnimalQuizScreenState();
}

class _AnimalQuizScreenState extends State<AnimalQuizScreen> {
  final animals = AnimalData.items;
  final LessonService _lessonService = LessonService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  late final ConfettiController _confettiController;

  int currentQuestion = 0;
  int score = 0;

  bool _answering = false;
  late List<String> _options;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    _generateOptions();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _generateOptions() {
    final correctAnimal = animals[currentQuestion]['name']!;

    final wrongAnimals = animals
        .map((item) => item['name']!)
        .where((animal) => animal != correctAnimal)
        .toList()
      ..shuffle();

    _options = [
      correctAnimal,
      ...wrongAnimals.take(3),
    ]..shuffle();
  }

  Future<void> _playFeedbackAudio(String fileName) async {
    try {
      await _audioPlayer.stop();

      await _audioPlayer.play(
        AssetSource(
          'audio/feedback/$fileName',
        ),
      );

      await _audioPlayer.onPlayerComplete.first;
    } catch (error) {
      debugPrint(
        'Animal quiz feedback audio error: $error',
      );
    }
  }

  Future<void> _handleAnswer(String selectedAnimal) async {
    if (_answering) return;

    final correctAnimal = animals[currentQuestion]['name']!;
    final isCorrect = selectedAnimal == correctAnimal;

    // WRONG ANSWER
    if (!isCorrect) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Try again 😊'),
            backgroundColor: AppColors.coral,
            behavior: SnackBarBehavior.floating,
          ),
        );

      await _playFeedbackAudio(
        'try_again.mp3',
      );

      return;
    }

    // CORRECT ANSWER
    setState(() {
      _answering = true;
      score++;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Correct! 🎉'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(milliseconds: 500),
        ),
      );

    await _playFeedbackAudio(
      'correct.mp3',
    );

    if (!mounted) return;

    // NEXT QUESTION
    if (currentQuestion < animals.length - 1) {
      setState(() {
        currentQuestion++;
        _answering = false;
        _generateOptions();
      });

      return;
    }

    // QUIZ COPLETE  ....../////////////revice
    final receivedRewards =
    await _lessonService.completeLesson(
      lessonId: 'animals',
    );

    if (!mounted) return;

    _confettiController.play();

    // NATURAL COMPLETION VOICE
    await _playFeedbackAudio(
      'lesson_complete.mp3',
    );

    if (!mounted) return;

    await _showQuizCompleteDialog(
      receivedRewards: receivedRewards,
    );

    if (mounted) {
      setState(() {
        _answering = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentAnimal = animals[currentQuestion];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Animal Quiz'),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(
                AppSpacing.large,
              ),
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
                      style: const TextStyle(
                        fontSize: 90,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${currentQuestion + 1} '
                            'of ${animals.length}',
                        style: AppTextStyles.bodySmall,
                      ),
                      Text(
                        'Score: $score',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value:
                      (currentQuestion + 1) / animals.length,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade300,
                      valueColor:
                      const AlwaysStoppedAnimation<Color>(
                        AppColors.green,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: _options.map((animal) {
                        return _animalButton(animal);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality:
            BlastDirectionality.explosive,
            emissionFrequency: 0.05,
            numberOfParticles: 25,
            gravity: 0.2,
          ),
        ],
      ),
    );
  }

  Widget _animalButton(String animal) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: _answering
          ? null
          : () => _handleAnswer(animal),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _answering ? 0.65 : 1,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.green.withValues(
              alpha: 0.15,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.green.withValues(
                alpha: 0.3,
              ),
              width: 2,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                animal,
                style: AppTextStyles.title.copyWith(
                  color: AppColors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showQuizCompleteDialog({
    required bool receivedRewards,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: const Column(
            children: [
              Text(
                '🎉',
                style: TextStyle(fontSize: 55),
              ),
              SizedBox(height: 8),
              Text(
                'Animals Complete!',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your score is $score / ${animals.length}',
                textAlign: TextAlign.center,
                style: AppTextStyles.title,
              ),

              const SizedBox(height: 18),

              if (receivedRewards) ...[
                const Text('⭐ +10 Stars'),
                const SizedBox(height: 6),

                const Text('🪙 +50 Coins'),
                const SizedBox(height: 6),

                const Text('⚡ +100 XP'),
                const SizedBox(height: 12),

                const Text(
                  '🏅 Animal Explorer badge unlocked!',
                  textAlign: TextAlign.center,
                ),
              ] else
                const Text(
                  'You already received rewards for this lesson.',
                  textAlign: TextAlign.center,
                ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                _audioPlayer.stop();

                setState(() {
                  currentQuestion = 0;
                  score = 0;
                  _answering = false;
                  _generateOptions();
                });
              },
              child: const Text(
                'Play Again',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                _audioPlayer.stop();

                Navigator.pop(context);
              },
              child: const Text(
                'Continue',
              ),
            ),
          ],
        );
      },
    );
  }
}