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

  // Natural voice files inside:
  // assets/audio/colors/
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
      // Stop old robotic TTS if it is running.
      await TtsService.instance.stop();

      // Stop previous MP3.
      await _audioPlayer.stop();

      if (fileName == null) {
        throw Exception(
          'No natural audio file found for $colorName',
        );
      }

      // Play natural MP3.
      await _audioPlayer.play(
        AssetSource(
          'audio/colors/$fileName',
        ),
      );

      // Keep button disabled until audio finishes.
      await _audioPlayer.onPlayerComplete.first;
    } catch (error) {
      debugPrint(
        'Color natural audio error: $error',
      );

      // TTS is only a fallback if an MP3 cannot be loaded.
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
    final isLast =
        currentIndex == colors.length - 1;

    TtsService.instance.stop();
    _audioPlayer.stop();

    if (isLast) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const ColorsQuizScreen(),
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
    final item = colors[currentIndex];

    final progress =
        (currentIndex + 1) / colors.length;

    final isLast =
        currentIndex == colors.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Learn Colors',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(
            AppSpacing.large,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
                children: [
                  Text(
                    'Color ${currentIndex + 1}',
                    style:
                    AppTextStyles.bodySmall,
                  ),
                  Text(
                    '${currentIndex + 1} / ${colors.length}',
                    style:
                    AppTextStyles.bodySmall,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              ClipRRect(
                borderRadius:
                BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor:
                  Colors.grey.shade300,
                  valueColor:
                  AlwaysStoppedAnimation<
                      Color>(
                    item['color'] as Color,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: GestureDetector(
                  onTap: isSpeaking
                      ? null
                      : _speakCurrentColor,
                  child: Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.all(
                      24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(
                        30,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(
                            alpha: 0.08,
                          ),
                          blurRadius: 18,
                          offset:
                          const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                      children: [
                        Container(
                          width: 160,
                          height: 160,
                          decoration:
                          BoxDecoration(
                            color: item['color']
                            as Color,
                            shape:
                            BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (item[
                                'color']
                                as Color)
                                    .withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 25,
                              ),
                            ],
                          ),
                        )
                            .animate(
                          key: ValueKey(
                            '${item['name']}-color',
                          ),
                        )
                            .scale(
                          begin:
                          const Offset(
                            .75,
                            .75,
                          ),
                          duration: 500.ms,
                          curve: Curves
                              .elasticOut,
                        ),

                        const SizedBox(
                          height: 25,
                        ),

                        Text(
                          item['emoji']
                          as String,
                          key: ValueKey(
                            '${item['name']}-emoji',
                          ),
                          style:
                          const TextStyle(
                            fontSize: 60,
                          ),
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        Text(
                          item['name']
                          as String,
                          key: ValueKey(
                            '${item['name']}-name',
                          ),
                          style: AppTextStyles
                              .headingLarge
                              .copyWith(
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        Text(
                          'This is the ${item['name']} color',
                          style: AppTextStyles
                              .headingMedium
                              .copyWith(
                            color: AppColors
                                .textPrimary,
                          ),
                          textAlign:
                          TextAlign.center,
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        ElevatedButton.icon(
                          onPressed: isSpeaking
                              ? null
                              : _speakCurrentColor,
                          icon: Icon(
                            isSpeaking
                                ? Icons
                                .graphic_eq_rounded
                                : Icons
                                .volume_up_rounded,
                          ),
                          label: Text(
                            isSpeaking
                                ? 'Speaking...'
                                : 'Listen',
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        Text(
                          'Tap anywhere to hear the color.',
                          style: AppTextStyles
                              .bodySmall,
                          textAlign:
                          TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child:
                    OutlinedButton.icon(
                      onPressed:
                      currentIndex == 0
                          ? null
                          : _previous,
                      icon: const Icon(
                        Icons
                            .arrow_back_rounded,
                      ),
                      label: const Text(
                        'Previous',
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child:
                    ElevatedButton.icon(
                      onPressed: _next,
                      icon: Icon(
                        isLast
                            ? Icons
                            .quiz_rounded
                            : Icons
                            .arrow_forward_rounded,
                      ),
                      label: Text(
                        isLast
                            ? 'Start Quiz'
                            : 'Next',
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