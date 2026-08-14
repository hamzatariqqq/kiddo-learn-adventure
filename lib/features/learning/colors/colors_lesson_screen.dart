import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/data/color_data.dart';
import '../../../core/services/tts_service.dart';
import 'colors_quiz_screen.dart';

class ColorsLessonScreen extends StatefulWidget {
  const ColorsLessonScreen({super.key});

  @override
  State<ColorsLessonScreen> createState() => _ColorsLessonScreenState();
}

class _ColorsLessonScreenState extends State<ColorsLessonScreen> {
  final colors = ColorData.items;
  final AudioPlayer _audioPlayer = AudioPlayer();

  int currentIndex = 0;
  bool isSpeaking = false;

  static const Map<String, String> _audioFiles = {
    'Red': 'red.mp3',
    'Blue': 'blue.mp3',
    'Green': 'green.mp3',
    'Yellow': 'yellow.mp3',
    'Orange': 'orange.mp3',
    'Purple': 'purple.mp3',
    'Pink': 'pink.mp3',
    'Brown': 'brown.mp3',
    'Black': 'black.mp3',
    'White': 'white.mp3',
  };

  Future<void> _speakCurrentColor() async {
    if (isSpeaking) return;

    final item = colors[currentIndex];
    final colorName = item['name'] as String;
    final fileName = _audioFiles[colorName];

    setState(() {
      isSpeaking = true;
    });

    try {
      await TtsService.instance.stop();
      await _audioPlayer.stop();

      if (fileName == null) {
        throw Exception(
          'No natural audio file found for $colorName',
        );
      }

      await _audioPlayer.play(
        AssetSource('audio/colors/$fileName'),
      );

      await _audioPlayer.onPlayerComplete.first;
    } catch (error) {
      debugPrint(
        'Color natural audio error: $error',
      );

      await TtsService.instance.speak(
        'This is the $colorName color',
      );
    }

    if (!mounted) return;

    setState(() {
      isSpeaking = false;
    });
  }

  void _previous() {
    if (currentIndex == 0) return;

    TtsService.instance.stop();
    _audioPlayer.stop();

    setState(() {
      currentIndex--;
      isSpeaking = false;
    });
  }

  void _next() {
    final isLast = currentIndex == colors.length - 1;

    TtsService.instance.stop();
    _audioPlayer.stop();

    if (isLast) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ColorsQuizScreen(),
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
    final item = colors[currentIndex];
    final colorName = item['name'] as String;
    final currentColor = item['color'] as Color;
    final emoji = item['emoji'] as String;

    final isLast = currentIndex == colors.length - 1;

    // White needs a darker accent so UI remains visible.
    final accentColor = colorName == 'White'
        ? AppColors.darkBlue
        : currentColor;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Color Adventure',
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
              _buildProgressDots(accentColor),

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
                          color: accentColor,
                          opacity: 0.10,
                        ),
                      ),

                      Positioned(
                        bottom: 70,
                        left: -35,
                        child: _bubble(
                          size: 100,
                          color: AppColors.primaryBlue,
                          opacity: 0.08,
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
                                color: accentColor.withValues(
                                  alpha: 0.10,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'COLOR ${currentIndex + 1}',
                                style: TextStyle(
                                  color: accentColor,
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
                                        width: 175,
                                        height: 175,
                                        decoration: BoxDecoration(
                                          color: currentColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: colorName == 'White'
                                                ? Colors.grey.shade300
                                                : Colors.white,
                                            width: 5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: accentColor.withValues(
                                                alpha: 0.25,
                                              ),
                                              blurRadius: 28,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            emoji,
                                            key: ValueKey(
                                              '$colorName-emoji',
                                            ),
                                            style: const TextStyle(
                                              fontSize: 70,
                                            ),
                                          ),
                                        ),
                                      )
                                          .animate(
                                        key: ValueKey(
                                          '$colorName-color-animation',
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

                                      const SizedBox(height: 24),

                                      Text(
                                        colorName,
                                        key: ValueKey(
                                          '$colorName-name',
                                        ),
                                        style: AppTextStyles.headingLarge
                                            .copyWith(
                                          color: accentColor,
                                          fontWeight: FontWeight.w900,
                                        ),
                                        textAlign: TextAlign.center,
                                      )
                                          .animate(
                                        key: ValueKey(
                                          '$colorName-name-animation',
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
                                          color: accentColor.withValues(
                                            alpha: 0.08,
                                          ),
                                          borderRadius:
                                          BorderRadius.circular(24),
                                        ),
                                        child: Text(
                                          'This is the $colorName color',
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

                                      _buildListenButton(
                                        accentColor,
                                      ),

                                      const SizedBox(height: 12),

                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isSpeaking
                                                ? Icons.music_note_rounded
                                                : Icons.touch_app_rounded,
                                            color: accentColor,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            isSpeaking
                                                ? 'Listen carefully!'
                                                : 'Tap to hear the color',
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
                      currentIndex == 0 ? null : _previous,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        side: BorderSide(
                          color: currentIndex == 0
                              ? Colors.grey.shade300
                              : accentColor,
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
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          elevation: 5,
                          shadowColor: accentColor.withValues(
                            alpha: 0.35,
                          ),
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

  Widget _buildListenButton(Color accentColor) {
    return GestureDetector(
      onTap: isSpeaking ? null : _speakCurrentColor,
      child: Container(
        width: 94,
        height: 94,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor,
              AppColors.darkBlue,
            ],
          ),
          border: Border.all(
            color: Colors.white,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(
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

  Widget _buildProgressDots(Color accentColor) {
    return SizedBox(
      height: 22,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,

        //sp
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
                  ? accentColor
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