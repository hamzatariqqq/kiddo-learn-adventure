import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
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
          builder: (_) => const NumberQuizScreen(),
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
        title: const Text(
          '123 Adventure',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(
            AppSpacing.large,
          ),
          child: Column(
            children: [
              // ==================================
              // PROGRESS
              // ==================================

              Row(
                children: [
                  const Text(
                    '⭐',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                      BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor:
                        AppColors.surface,
                        valueColor:
                        const AlwaysStoppedAnimation<
                            Color>(
                          AppColors.orange,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.orange
                          .withValues(alpha: 0.14),
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${currentIndex + 1}/${numbers.length}',
                      style: const TextStyle(
                        color: AppColors.orange,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==================================
              // MAIN NUMBER CARD
              // ==================================

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(34),
                    border: Border.all(
                      color: AppColors.orange
                          .withValues(alpha: 0.30),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.orange
                            .withValues(alpha: 0.12),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: Stack(
                    children: [
                      // Background decorations
                      Positioned(
                        top: -55,
                        right: -50,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: AppColors.orange
                                .withValues(
                              alpha: 0.08,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: -70,
                        left: -60,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: AppColors.gold
                                .withValues(
                              alpha: 0.08,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),

                      Padding(
                        padding:
                        const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            const SizedBox(height: 4),

                            // ==========================
                            // NUMBER
                            // ==========================

                            Text(
                              item['number']!,
                              key: ValueKey(
                                '${item['number']}-number',
                              ),
                              style: const TextStyle(
                                color: AppColors.orange,
                                fontSize: 88,
                                height: 1,
                                fontWeight:
                                FontWeight.w900,
                              ),
                            )
                                .animate(
                              key: ValueKey(
                                '${item['number']}-number-animation',
                              ),
                            )
                                .fade(
                              duration: 250.ms,
                            )
                                .scale(
                              begin:
                              const Offset(.65, .65),
                              duration: 520.ms,
                              curve: Curves.elasticOut,
                            ),

                            const SizedBox(height: 4),

                            // ==========================
                            // NUMBER WORD
                            // ==========================

                            Container(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.orange
                                    .withValues(
                                  alpha: 0.10,
                                ),
                                borderRadius:
                                BorderRadius.circular(
                                  30,
                                ),
                              ),
                              child: Text(
                                item['word']!,
                                style: const TextStyle(
                                  color:
                                  AppColors.deepNavy,
                                  fontSize: 22,
                                  fontWeight:
                                  FontWeight.w900,
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // ==========================
                            // COUNTING OBJECTS
                            // ==========================

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
                                      fontSize: 39,
                                      height: 1.25,
                                    ),
                                  )
                                      .animate(
                                    key: ValueKey(
                                      '${item['number']}-objects-animation',
                                    ),
                                  )
                                      .fade(
                                    duration: 300.ms,
                                  )
                                      .scale(
                                    begin:
                                    const Offset(
                                      .85,
                                      .85,
                                    ),
                                    duration: 450.ms,
                                  ),
                                ),
                              ),
                            ),

                            // ==========================
                            // FUN LISTEN BUTTON
                            // ==========================

                            GestureDetector(
                              onTap: isSpeaking
                                  ? null
                                  : _speakCurrentNumber,
                              child: AnimatedContainer(
                                duration: const Duration(
                                  milliseconds: 250,
                                ),
                                width:
                                isSpeaking ? 100 : 108,
                                height:
                                isSpeaking ? 100 : 108,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,

                                  gradient:
                                  const LinearGradient(
                                    colors: [
                                      AppColors.orange,
                                      AppColors.gold,
                                    ],
                                    begin:
                                    Alignment.topLeft,
                                    end: Alignment
                                        .bottomRight,
                                  ),

                                  border: Border.all(
                                    color: Colors.white
                                        .withValues(
                                      alpha: 0.90,
                                    ),
                                    width: 4,
                                  ),

                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors
                                          .orange
                                          .withValues(
                                        alpha: isSpeaking
                                            ? 0.55
                                            : 0.30,
                                      ),
                                      blurRadius:
                                      isSpeaking
                                          ? 34
                                          : 20,
                                      spreadRadius:
                                      isSpeaking
                                          ? 7
                                          : 2,
                                    ),
                                  ],
                                ),

                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                                  children: [
                                    Icon(
                                      isSpeaking
                                          ? Icons
                                          .graphic_eq_rounded
                                          : Icons
                                          .volume_up_rounded,
                                      color:
                                      Colors.white,
                                      size: 41,
                                    ),

                                    const SizedBox(
                                      height: 2,
                                    ),

                                    Text(
                                      isSpeaking
                                          ? 'PLAYING'
                                          : 'LISTEN',
                                      style:
                                      const TextStyle(
                                        color:
                                        Colors.white,
                                        fontSize: 10,
                                        fontWeight:
                                        FontWeight
                                            .w900,
                                        letterSpacing:
                                        0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                                .animate(
                              target:
                              isSpeaking ? 1 : 0,
                              onPlay: (controller) {
                                if (isSpeaking) {
                                  controller.repeat(
                                    reverse: true,
                                  );
                                }
                              },
                            )
                                .scale(
                              begin:
                              const Offset(1, 1),
                              end: const Offset(
                                1.06,
                                1.06,
                              ),
                              duration: 500.ms,
                            ),

                            const SizedBox(height: 9),

                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                              children: [
                                Icon(
                                  isSpeaking
                                      ? Icons
                                      .music_note_rounded
                                      : Icons
                                      .touch_app_rounded,
                                  color:
                                  AppColors.orange,
                                  size: 17,
                                ),

                                const SizedBox(width: 5),

                                Text(
                                  isSpeaking
                                      ? 'Listen carefully!'
                                      : 'Tap to hear the number',
                                  style:
                                  const TextStyle(
                                    color: AppColors
                                        .textSecondary,
                                    fontSize: 12,
                                    fontWeight:
                                    FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 5),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ==================================
              // NAVIGATION
              // ==================================

              Row(
                children: [
                  SizedBox(
                    width: 70,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: currentIndex == 0
                          ? null
                          : _goToPrevious,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(18),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 28,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _goToNext,
                        icon: Icon(
                          isLast
                              ? Icons
                              .celebration_rounded
                              : Icons
                              .arrow_forward_rounded,
                          size: 25,
                        ),
                        label: Text(
                          isLast
                              ? 'Quiz Time!'
                              : 'Next',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight:
                            FontWeight.w900,
                          ),
                        ),
                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          AppColors.orange,
                          foregroundColor:
                          AppColors.deepNavy,
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                              18,
                            ),
                          ),
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
}