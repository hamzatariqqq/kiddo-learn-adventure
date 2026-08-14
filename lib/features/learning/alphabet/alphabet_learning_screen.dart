import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/data/alphabet_data.dart';
import '../../../core/services/tts_service.dart';
import '../alphabet_quiz/alphabet_quiz_screen.dart';

class AlphabetLearningScreen extends StatefulWidget {
  const AlphabetLearningScreen({super.key});

  @override
  State<AlphabetLearningScreen> createState() =>
      _AlphabetLearningScreenState();
}

class _AlphabetLearningScreenState
    extends State<AlphabetLearningScreen> {
  final alphabetItems = AlphabetData.items;
  final AudioPlayer _audioPlayer = AudioPlayer();

  int currentIndex = 0;
  bool isSpeaking = false;

  static const Map<String, String> _audioFiles = {
    'A': 'a_apple.mp3',
    'B': 'b_ball.mp3',
    'C': 'c_cat.mp3',
    'D': 'd_dog.mp3',
    'E': 'e_elephant.mp3',
    'F': 'f_fish.mp3',
    'G': 'g_grapes.mp3',
    'H': 'h_hat.mp3',
    'I': 'i_ice_cream.mp3',
    'J': 'j_juice.mp3',
    'K': 'k_kite.mp3',
    'L': 'l_lion.mp3',
    'M': 'm_mango.mp3',
    'N': 'n_nest.mp3',
    'O': 'o_orange.mp3',
    'P': 'p_pineapple.mp3',
    'Q': 'q_queen.mp3',
    'R': 'r_rabbit.mp3',
    'S': 's_strawberry.mp3',
    'T': 't_tiger.mp3',
    'U': 'u_umbrella.mp3',
    'V': 'v_violin.mp3',
    'W': 'w_watch.mp3',
    'X': 'x_xylophone.mp3',
    'Y': 'y_yak.mp3',
    'Z': 'z_zebra.mp3',
  };

  Future<void> _speakCurrentItem() async {
    if (isSpeaking) return;

    final item = alphabetItems[currentIndex];
    final letter = item['letter']!;
    final fileName = _audioFiles[letter];

    setState(() {
      isSpeaking = true;
    });

    try {
      await TtsService.instance.stop();
      await _audioPlayer.stop();

      if (fileName == null) {
        throw Exception(
          'No audio file found for $letter',
        );
      }

      await _audioPlayer.play(
        AssetSource(
          'audio/alphabet/$fileName',
        ),
      );

      await _audioPlayer.onPlayerComplete.first;
    } catch (error) {
      debugPrint(
        'Alphabet natural audio error: $error',
      );

      await TtsService.instance.speak(
        '${item['letter']} for ${item['word']}',
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
        currentIndex == alphabetItems.length - 1;

    TtsService.instance.stop();
    _audioPlayer.stop();

    if (isLast) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
          const AlphabetQuizScreen(),
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
    final item = alphabetItems[currentIndex];

    final letter = item['letter']!;
    final word = item['word']!;
    final emoji = item['emoji']!;

    final isLast =
        currentIndex == alphabetItems.length - 1;

    final progress =
        (currentIndex + 1) / alphabetItems.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: _AlphabetBackground(),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.large,
                12,
                AppSpacing.large,
                16,
              ),
              child: Column(
                children: [
                  // =========================
                  // TOP BAR
                  // =========================

                  Row(
                    children: [
                      _CircleActionButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Column(
                          children: [
                            Text(
                              'ABC Adventure',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 21,
                                fontWeight:
                                FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Learn your letters',
                              style: TextStyle(
                                color:
                                AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface
                              .withValues(alpha: 0.92),
                          borderRadius:
                          BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.cyan
                                .withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          '${currentIndex + 1}/${alphabetItems.length}',
                          style: const TextStyle(
                            color: AppColors.cyan,
                            fontWeight:
                            FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // =========================
                  // PROGRESS
                  // =========================

                  Row(
                    children: [
                      const Text(
                        '⭐',
                        style: TextStyle(
                          fontSize: 19,
                        ),
                      ),

                      const SizedBox(width: 9),

                      Expanded(
                        child: ClipRRect(
                          borderRadius:
                          BorderRadius.circular(30),
                          child:
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor:
                            AppColors.white
                                .withValues(
                              alpha: 0.10,
                            ),
                            valueColor:
                            const AlwaysStoppedAnimation<
                                Color>(
                              AppColors.cyan,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // =========================
                  // MAIN CARD
                  // =========================

                  Expanded(
                    child: GestureDetector(
                      onTap: isSpeaking
                          ? null
                          : _speakCurrentItem,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(36),
                          border: Border.all(
                            color: AppColors.cyan
                                .withValues(alpha: 0.20),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyan
                                  .withValues(
                                alpha: 0.13,
                              ),
                              blurRadius: 30,
                              offset:
                              const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius:
                          BorderRadius.circular(34),
                          child: Stack(
                            children: [
                              // decorative bubbles

                              Positioned(
                                top: -55,
                                right: -45,
                                child:
                                _DecorativeCircle(
                                  size: 155,
                                  color:
                                  AppColors.cyan,
                                  opacity: 0.09,
                                ),
                              ),

                              Positioned(
                                bottom: -75,
                                left: -55,
                                child:
                                _DecorativeCircle(
                                  size: 185,
                                  color:
                                  AppColors.gold,
                                  opacity: 0.08,
                                ),
                              ),

                              Positioned(
                                top: 135,
                                left: -30,
                                child:
                                _DecorativeCircle(
                                  size: 70,
                                  color: AppColors
                                      .primaryBlue,
                                  opacity: 0.06,
                                ),
                              ),

                              Padding(
                                padding:
                                const EdgeInsets
                                    .symmetric(
                                  horizontal: 18,
                                  vertical: 16,
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                                  children: [
                                    // =================
                                    // EMOJI BUBBLE
                                    // =================

                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration:
                                      BoxDecoration(
                                        color: AppColors
                                            .cyan
                                            .withValues(
                                          alpha: 0.10,
                                        ),
                                        shape:
                                        BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors
                                              .cyan
                                              .withValues(
                                            alpha: 0.15,
                                          ),
                                          width: 2,
                                        ),
                                      ),
                                      alignment:
                                      Alignment.center,
                                      child: Text(
                                        emoji,
                                        key: ValueKey(
                                          '$letter-emoji',
                                        ),
                                        style:
                                        const TextStyle(
                                          fontSize: 72,
                                        ),
                                      )
                                          .animate(
                                        key: ValueKey(
                                          '$letter-emoji-animation',
                                        ),
                                      )
                                          .fadeIn(
                                        duration:
                                        250.ms,
                                      )
                                          .scale(
                                        begin:
                                        const Offset(
                                          0.65,
                                          0.65,
                                        ),
                                        end:
                                        const Offset(
                                          1,
                                          1,
                                        ),
                                        duration:
                                        550.ms,
                                        curve: Curves
                                            .elasticOut,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 10,
                                    ),

                                    // =================
                                    // BIG LETTER
                                    // =================

                                    Text(
                                      letter,
                                      key: ValueKey(
                                        '$letter-letter',
                                      ),
                                      style:
                                      const TextStyle(
                                        color:
                                        AppColors.cyan,
                                        fontSize: 92,
                                        height: 0.95,
                                        fontWeight:
                                        FontWeight
                                            .w900,
                                      ),
                                    )
                                        .animate(
                                      key: ValueKey(
                                        '$letter-letter-animation',
                                      ),
                                    )
                                        .fadeIn(
                                      duration: 280.ms,
                                    )
                                        .slideY(
                                      begin: 0.20,
                                      end: 0,
                                      duration: 350.ms,
                                    ),

                                    const SizedBox(
                                      height: 12,
                                    ),

                                    // =================
                                    // WORD CHIP
                                    // =================

                                    Container(
                                      padding:
                                      const EdgeInsets
                                          .symmetric(
                                        horizontal: 22,
                                        vertical: 11,
                                      ),
                                      decoration:
                                      BoxDecoration(
                                        color: AppColors
                                            .deepNavy
                                            .withValues(
                                          alpha: 0.06,
                                        ),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                          22,
                                        ),
                                      ),
                                      child: Text(
                                        '$letter for $word',
                                        textAlign:
                                        TextAlign
                                            .center,
                                        style:
                                        const TextStyle(
                                          color: AppColors
                                              .deepNavy,
                                          fontSize: 22,
                                          fontWeight:
                                          FontWeight
                                              .w900,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 22,
                                    ),

                                    // =================
                                    // PREMIUM LISTEN
                                    // =================

                                    _ListenButton(
                                      isSpeaking:
                                      isSpeaking,
                                      onTap:
                                      _speakCurrentItem,
                                    ),

                                    const SizedBox(
                                      height: 10,
                                    ),

                                    AnimatedSwitcher(
                                      duration:
                                      const Duration(
                                        milliseconds:
                                        250,
                                      ),
                                      child: Row(
                                        key: ValueKey(
                                          isSpeaking,
                                        ),
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
                                            color: AppColors
                                                .textSecondary,
                                            size: 17,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            isSpeaking
                                                ? 'Listen carefully!'
                                                : 'Tap the big button',
                                            style:
                                            const TextStyle(
                                              color: AppColors
                                                  .textSecondary,
                                              fontSize:
                                              12,
                                              fontWeight:
                                              FontWeight
                                                  .w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // =========================
                  // BOTTOM NAVIGATION
                  // =========================

                  Row(
                    children: [
                      SizedBox(
                        width: 62,
                        height: 58,
                        child: OutlinedButton(
                          onPressed:
                          currentIndex == 0
                              ? null
                              : _goToPrevious,
                          style:
                          OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                20,
                              ),
                            ),
                          ),
                          child: const Icon(
                            Icons
                                .arrow_back_rounded,
                            size: 28,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: SizedBox(
                          height: 58,
                          child:
                          ElevatedButton.icon(
                            onPressed: _goToNext,
                            style:
                            ElevatedButton.styleFrom(
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  20,
                                ),
                              ),
                            ),
                            icon: Icon(
                              isLast
                                  ? Icons
                                  .celebration_rounded
                                  : Icons
                                  .arrow_forward_rounded,
                              size: 26,
                            ),
                            label: Text(
                              isLast
                                  ? 'Quiz Time!'
                                  : 'Next Letter',
                              style:
                              const TextStyle(
                                fontSize: 17,
                                fontWeight:
                                FontWeight.w900,
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
        ],
      ),
    );
  }
}

// =====================================================
// LISTEN BUTTON
// =====================================================

class _ListenButton extends StatelessWidget {
  const _ListenButton({
    required this.isSpeaking,
    required this.onTap,
  });

  final bool isSpeaking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap:
          isSpeaking ? null : onTap,
          child: AnimatedContainer(
            duration:
            const Duration(
              milliseconds: 250,
            ),
            width:
            isSpeaking ? 108 : 116,
            height:
            isSpeaking ? 108 : 116,
            decoration: BoxDecoration(
              shape: BoxShape.circle,

              gradient:
              const LinearGradient(
                colors: [
                  AppColors.cyan,
                  AppColors.primaryBlue,
                ],
                begin:
                Alignment.topLeft,
                end:
                Alignment.bottomRight,
              ),

              border: Border.all(
                color: Colors.white
                    .withValues(
                  alpha: 0.95,
                ),
                width: 4,
              ),

              boxShadow: [
                BoxShadow(
                  color: AppColors.cyan
                      .withValues(
                    alpha: isSpeaking
                        ? 0.50
                        : 0.30,
                  ),
                  blurRadius:
                  isSpeaking ? 34 : 22,
                  spreadRadius:
                  isSpeaking ? 7 : 2,
                ),

                BoxShadow(
                  color: AppColors
                      .primaryBlue
                      .withValues(
                    alpha: 0.18,
                  ),
                  blurRadius: 18,
                  offset:
                  const Offset(0, 9),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Icon(
                  isSpeaking
                      ? Icons
                      .graphic_eq_rounded
                      : Icons
                      .volume_up_rounded,
                  color: Colors.white,
                  size: 44,
                ),

                const SizedBox(height: 3),

                Text(
                  isSpeaking
                      ? 'PLAYING'
                      : 'LISTEN',
                  style:
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w900,
                    letterSpacing: 1,
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
          end:
          const Offset(
            1.06,
            1.06,
          ),
          duration: 500.ms,
        ),

        if (!isSpeaking) ...[
          const SizedBox(height: 5),
          const Text(
            '✨',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ],
      ],
    );
  }
}

// =====================================================
// TOP ACTION BUTTON
// =====================================================

class _CircleActionButton
    extends StatelessWidget {
  const _CircleActionButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder:
        const CircleBorder(),
        child: Ink(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: AppColors.surface
                .withValues(
              alpha: 0.92,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.white
                  .withValues(
                alpha: 0.08,
              ),
            ),
          ),
          child: Icon(
            icon,
            color:
            AppColors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}

// =====================================================
// BACKGROUND
// =====================================================

class _AlphabetBackground
    extends StatelessWidget {
  const _AlphabetBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration:
      const BoxDecoration(
        gradient:
        LinearGradient(
          colors: [
            AppColors.deepNavy,
            AppColors.background,
            AppColors.navyBlue,
          ],
          begin:
          Alignment.topCenter,
          end:
          Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 120,
            right: -70,
            child:
            _BackgroundGlow(
              size: 210,
              color:
              AppColors.cyan,
            ),
          ),
          Positioned(
            bottom: 80,
            left: -80,
            child:
            _BackgroundGlow(
              size: 220,
              color:
              AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundGlow
    extends StatelessWidget {
  const _BackgroundGlow({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.05,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(
              alpha: 0.07,
            ),
            blurRadius: 70,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}

// =====================================================
// DECORATIVE CIRCLE
// =====================================================

class _DecorativeCircle
    extends StatelessWidget {
  const _DecorativeCircle({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: opacity,
        ),
        shape: BoxShape.circle,
      ),
    );
  }
}