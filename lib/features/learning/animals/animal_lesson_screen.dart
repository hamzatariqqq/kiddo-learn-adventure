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
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animal = animals[currentIndex];
    final isLast = currentIndex == animals.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Animal Adventure',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.large,
            8,
            AppSpacing.large,
            AppSpacing.large,
          ),
          child: Column(
            children: [
              _buildProgressDots(),

              const SizedBox(height: 18),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -35,
                        right: -35,
                        child: _bubble(
                          size: 125,
                          color: AppColors.green,
                          opacity: 0.12,
                        ),
                      ),
                      Positioned(
                        bottom: 80,
                        left: -35,
                        child: _bubble(
                          size: 100,
                          color: AppColors.primaryBlue,
                          opacity: 0.09,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.green.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'ANIMAL ${currentIndex + 1}',
                                style: const TextStyle(
                                  color: AppColors.green,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Expanded(
                              child: Center(
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 180,
                                        height: 180,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.green.withValues(
                                            alpha: 0.10,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.green
                                                  .withValues(alpha: 0.12),
                                              blurRadius: 22,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            animal['emoji']!,
                                            key: ValueKey(
                                              '${animal['name']}-emoji',
                                            ),
                                            style: const TextStyle(
                                              fontSize: 100,
                                            ),
                                          )
                                              .animate(
                                            key: ValueKey(
                                              '${animal['name']}-emoji-animation',
                                            ),
                                          )
                                              .fade(duration: 250.ms)
                                              .scale(
                                            begin: const Offset(
                                              0.65,
                                              0.65,
                                            ),
                                            end: const Offset(1, 1),
                                            duration: 550.ms,
                                            curve: Curves.elasticOut,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 22),

                                      Text(
                                        animal['name']!,
                                        key: ValueKey(
                                          '${animal['name']}-name',
                                        ),
                                        style: AppTextStyles.headingLarge
                                            .copyWith(
                                          color: AppColors.green,
                                          fontWeight: FontWeight.w900,
                                        ),
                                        textAlign: TextAlign.center,
                                      )
                                          .animate(
                                        key: ValueKey(
                                          '${animal['name']}-name-animation',
                                        ),
                                      )
                                          .fade(duration: 250.ms)
                                          .slideY(begin: 0.15),

                                      const SizedBox(height: 12),

                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryBlue
                                              .withValues(alpha: 0.08),
                                          borderRadius:
                                          BorderRadius.circular(24),
                                        ),
                                        child: Text(
                                          'This is a ${animal['name']}',
                                          style: AppTextStyles.headingMedium
                                              .copyWith(
                                            color:
                                            AppColors.textPrimary,
                                            fontWeight:
                                            FontWeight.w700,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),

                                      const SizedBox(height: 30),

                                      _buildListenButton(),

                                      const SizedBox(height: 12),

                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isSpeaking
                                                ? Icons.music_note_rounded
                                                : Icons.touch_app_rounded,
                                            color: AppColors.green,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            isSpeaking
                                                ? 'Listen carefully!'
                                                : 'Tap to hear the animal',
                                            style: const TextStyle(
                                              color:
                                              AppColors.textSecondary,
                                              fontSize: 13,
                                              fontWeight:
                                              FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  SizedBox(
                    width: 58,
                    height: 58,
                    child: OutlinedButton(
                      onPressed:
                      currentIndex == 0 ? null : _goToPrevious,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        side: BorderSide(
                          color: currentIndex == 0
                              ? Colors.grey.shade300
                              : AppColors.green,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 28,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: SizedBox(
                      height: 58,
                      child: ElevatedButton(
                        onPressed: _goToNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: Colors.white,
                          elevation: 5,
                          shadowColor:
                          AppColors.green.withValues(alpha: 0.35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Text(
                              isLast ? 'START QUIZ' : 'NEXT',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.7,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isLast
                                  ? Icons.quiz_rounded
                                  : Icons.arrow_forward_rounded,
                            ),
                          ],
                        ),
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

  Widget _buildListenButton() {
    return GestureDetector(
      onTap: isSpeaking ? null : _speakCurrentAnimal,
      child: Container(
        width: 94,
        height: 94,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.green,
              AppColors.darkBlue,
            ],
          ),
          border: Border.all(
            color: Colors.white,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.green.withValues(
                alpha: isSpeaking ? 0.50 : 0.28,
              ),
              blurRadius: isSpeaking ? 32 : 18,
              spreadRadius: isSpeaking ? 6 : 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSpeaking
                  ? Icons.graphic_eq_rounded
                  : Icons.volume_up_rounded,
              color: Colors.white,
              size: 39,
            ),
            const SizedBox(height: 2),
            Text(
              isSpeaking ? 'PLAYING' : 'LISTEN',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      )
          .animate(
        target: isSpeaking ? 1 : 0,
        onPlay: (controller) {
          if (isSpeaking) {
            controller.repeat(reverse: true);
          }
        },
      )
          .scale(
        begin: const Offset(1, 1),
        end: const Offset(1.07, 1.07),
        duration: 500.ms,
      ),
    );
  }

  Widget _buildProgressDots() {
    return SizedBox(
      height: 22,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: animals.length,
        separatorBuilder: (context, index) =>
        const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final completed = index <= currentIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: index == currentIndex ? 25 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: completed
                  ? AppColors.green
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }

  Widget _bubble({
    required double size,
    required Color color,
    required double opacity,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    );
  }
}