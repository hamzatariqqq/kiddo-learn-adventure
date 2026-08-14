import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/data/number_data.dart';
import '../../../core/services/tts_service.dart';
import '../number_quiz/number_quiz_screen.dart';

class CountingLessonScreen extends StatefulWidget {
  const CountingLessonScreen({super.key});

  @override
  State<CountingLessonScreen> createState() =>
      _CountingLessonScreenState();
}

class _CountingLessonScreenState
    extends State<CountingLessonScreen> {
  final numbers = NumberData.items;
  final AudioPlayer _audioPlayer = AudioPlayer();

  int currentIndex = 0;
  bool isSpeaking = false;

  static const Map<String, String> _audioFiles = {
    '1': '1_one.mp3',
    '2': '2_two.mp3',
    '3': '3_three.mp3',
    '4': '4_four.mp3',
    '5': '5_five.mp3',
    '6': '6_six.mp3',
    '7': '7_seven.mp3',
    '8': '8_eight.mp3',
    '9': '9_nine.mp3',
    '10': '10_ten.mp3',
  };

  Future<void> _speakCurrentNumber() async {
    if (isSpeaking) return;

    final item = numbers[currentIndex];
    final number = item['number']!;
    final fileName = _audioFiles[number];

    setState(() {
      isSpeaking = true;
    });

    try {
      await TtsService.instance.stop();
      await _audioPlayer.stop();

      if (fileName == null) {
        throw Exception(
          'No audio file found for number $number',
        );
      }

      await _audioPlayer.play(
        AssetSource(
          'audio/numbers/$fileName',
        ),
      );

      await _audioPlayer.onPlayerComplete.first;
    } catch (error) {
      debugPrint(
        'Number natural audio error: $error',
      );

      // Old TTS remains as emergency fallback.
      await TtsService.instance.speak(
        'Number ${item['number']}. ${item['word']}',
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
    final isLast =
        currentIndex == numbers.length - 1;

    TtsService.instance.stop();
    _audioPlayer.stop();

    if (isLast) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const NumberQuizScreen(),
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
    final item = numbers[currentIndex];

    final isLast =
        currentIndex == numbers.length - 1;

    final progress =
        (currentIndex + 1) / numbers.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Learn Numbers'),
      ),
      body: SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.all(AppSpacing.large),
          child: Column(
            children: [
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Number ${currentIndex + 1}',
                    style: AppTextStyles.bodySmall,
                  ),
                  Text(
                    '${currentIndex + 1} / ${numbers.length}',
                    style: AppTextStyles.bodySmall,
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
                  const AlwaysStoppedAnimation<
                      Color>(
                    AppColors.orange,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Expanded(
                child: GestureDetector(
                  onTap: _speakCurrentNumber,
                  child: Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(30),
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
                      MainAxisAlignment.center,
                      children: [
                        Text(
                          item['number']!,
                          key: ValueKey(
                            '${item['number']}-number',
                          ),
                          style: AppTextStyles
                              .headingLarge
                              .copyWith(
                            fontSize: 90,
                            color: AppColors.orange,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        )
                            .animate(
                          key: ValueKey(
                            '${item['number']}-number-animation',
                          ),
                        )
                            .fade(
                          duration: 300.ms,
                        )
                            .scale(
                          begin:
                          const Offset(
                            0.75,
                            0.75,
                          ),
                          duration: 500.ms,
                          curve: Curves.elasticOut,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          item['word']!,
                          key: ValueKey(
                            '${item['number']}-word',
                          ),
                          style: AppTextStyles
                              .headingMedium
                              .copyWith(
                            color:
                            AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 24),

                        Expanded(
                          child: Center(
                            child:
                            SingleChildScrollView(
                              child: Text(
                                item['objects']!,
                                key: ValueKey(
                                  '${item['number']}-objects',
                                ),
                                textAlign:
                                TextAlign.center,
                                style:
                                const TextStyle(
                                  fontSize: 42,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        ElevatedButton.icon(
                          onPressed: isSpeaking
                              ? null
                              : _speakCurrentNumber,
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

                        const SizedBox(height: 10),

                        Text(
                          'Tap the card or Listen to hear the number.',
                          style: AppTextStyles
                              .bodySmall
                              .copyWith(
                            color: AppColors
                                .textSecondary,
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
                      currentIndex == 0
                          ? null
                          : _goToPrevious,
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                      ),
                      label:
                      const Text('Previous'),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _goToNext,
                      icon: Icon(
                        isLast
                            ? Icons.quiz_rounded
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