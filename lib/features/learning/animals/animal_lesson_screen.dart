import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/data/animal_data.dart';
import '../../../core/services/tts_service.dart';
import '../animal_quiz/animal_quiz_screen.dart';

class AnimalLessonScreen extends StatefulWidget {
  const AnimalLessonScreen({super.key});

  @override
  State<AnimalLessonScreen> createState() => _AnimalLessonScreenState();
}

class _AnimalLessonScreenState extends State<AnimalLessonScreen> {
  final animals = AnimalData.items;
  final AudioPlayer _audioPlayer = AudioPlayer();

  int currentIndex = 0;
  bool isSpeaking = false;

  static const Map<String, String> _audioFiles = {
    'Bear': 'bear.mp3',
    'Cat': 'cat.mp3',
    'Chicken': 'chicken.mp3',
    'Cow': 'cow.mp3',
    'Dog': 'dog.mp3',
    'Duck': 'duck.mp3',
    'Elephant': 'elephant.mp3',
    'Fox': 'fox.mp3',
    'Frog': 'frog.mp3',
    'Goat': 'goat.mp3',
    'Horse': 'horse.mp3',
    'Lion': 'lion.mp3',
    'Monkey': 'monkey.mp3',
    'Panda': 'panda.mp3',
    'Pig': 'pig.mp3',
    'Rabbit': 'rabbit.mp3',
    'Sheep': 'sheep.mp3',
    'Tiger': 'tiger.mp3',
    'Turtle': 'turtle.mp3',
    'Zebra': 'zebra.mp3',
  };

  Future<void> _speakCurrentAnimal() async {
    if (isSpeaking) return;

    final animal = animals[currentIndex];
    final animalName = animal['name']!;
    final fileName = _audioFiles[animalName];

    setState(() {
      isSpeaking = true;
    });

    try {
      await TtsService.instance.stop();
      await _audioPlayer.stop();

      if (fileName == null) {
        throw Exception(
          'No natural audio found for $animalName',
        );
      }

      await _audioPlayer.play(
        AssetSource(
          'audio/animals/$fileName',
        ),
      );

      await _audioPlayer.onPlayerComplete.first;
    } catch (error) {
      debugPrint(
        'Animal natural audio error: $error',
      );

      // Fallback to TTS if MP3 is missing or broken.
      await TtsService.instance.speak(
        'This is a $animalName',
      );
    }

    if (!mounted) return;

    setState(() {
      isSpeaking = false;
    });
  }

  void _goToPrevious() {
    if (currentIndex == 0) return;

    TtsService.instance.stop();
    _audioPlayer.stop();

    setState(() {
      currentIndex--;
      isSpeaking = false;
    });
  }

  void _goToNext() {
    final isLast = currentIndex == animals.length - 1;

    TtsService.instance.stop();
    _audioPlayer.stop();

    if (isLast) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AnimalQuizScreen(),
        ),
      );
      return;
    }

    setState(() {
      currentIndex++;
      isSpeaking = false;
    });
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animal = animals[currentIndex];
    final isLast = currentIndex == animals.length - 1;
    final progress = (currentIndex + 1) / animals.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Learn Animals'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Animal ${currentIndex + 1}',
                    style: AppTextStyles.bodySmall,
                  ),
                  Text(
                    '${currentIndex + 1} / ${animals.length}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.green,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Expanded(
                child: GestureDetector(
                  onTap: _speakCurrentAnimal,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          animal['emoji']!,
                          key: ValueKey(
                            '${animal['name']}-emoji',
                          ),
                          style: const TextStyle(
                            fontSize: 110,
                          ),
                        )
                            .animate(
                          key: ValueKey(
                            '${animal['name']}-emoji-animation',
                          ),
                        )
                            .fade(duration: 300.ms)
                            .scale(
                          begin: const Offset(0.72, 0.72),
                          duration: 520.ms,
                          curve: Curves.elasticOut,
                        ),

                        const SizedBox(height: 24),

                        Text(
                          animal['name']!,
                          key: ValueKey(
                            '${animal['name']}-name',
                          ),
                          style: AppTextStyles.headingLarge.copyWith(
                            color: AppColors.green,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        )
                            .animate(
                          key: ValueKey(
                            '${animal['name']}-name-animation',
                          ),
                        )
                            .fade(duration: 300.ms)
                            .slideY(begin: 0.2),

                        const SizedBox(height: 16),

                        Text(
                          'This is a ${animal['name']}',
                          style: AppTextStyles.headingMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),

                        ElevatedButton.icon(
                          onPressed:
                          isSpeaking ? null : _speakCurrentAnimal,
                          icon: Icon(
                            isSpeaking
                                ? Icons.graphic_eq_rounded
                                : Icons.volume_up_rounded,
                          ),
                          label: Text(
                            isSpeaking
                                ? 'Speaking...'
                                : 'Listen',
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'Tap the card or Listen to hear the animal name.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                      currentIndex == 0 ? null : _goToPrevious,
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                      ),
                      label: const Text('Previous'),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _goToNext,
                      icon: Icon(
                        isLast
                            ? Icons.quiz_rounded
                            : Icons.arrow_forward_rounded,
                      ),
                      label: Text(
                        isLast ? 'Start Quiz' : 'Next',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}