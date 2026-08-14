import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
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
        throw Exception('No audio file found for $letter');
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

      // Fallback if an MP3 is missing/broken.
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

    final isLast =
        currentIndex == alphabetItems.length - 1;

    final progress =
        (currentIndex + 1) / alphabetItems.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Learn Alphabets'),
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
                    'Letter ${currentIndex + 1}',
                    style: AppTextStyles.bodySmall,
                  ),
                  Text(
                    '${currentIndex + 1} / ${alphabetItems.length}',
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
                    AppColors.primaryBlue,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              Expanded(
                child: GestureDetector(
                  onTap: _speakCurrentItem,
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
                          item['emoji']!,
                          key: ValueKey(
                            '${item['letter']}-emoji',
                          ),
                          style: const TextStyle(
                            fontSize: 90,
                          ),
                        )
                            .animate(
                          key: ValueKey(
                            '${item['letter']}-emoji-animation',
                          ),
                        )
                            .fade(
                          duration: 300.ms,
                        )
                            .scale(
                          begin:
                          const Offset(0.7, 0.7),
                          duration: 500.ms,
                          curve: Curves.elasticOut,
                        ),

                        const SizedBox(height: 18),

                        Text(
                          item['letter']!,
                          key: ValueKey(
                            '${item['letter']}-letter',
                          ),
                          style: AppTextStyles
                              .headingLarge
                              .copyWith(
                            fontSize: 80,
                            color:
                            AppColors.primaryBlue,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        )
                            .animate(
                          key: ValueKey(
                            '${item['letter']}-letter-animation',
                          ),
                        )
                            .fade(
                          duration: 300.ms,
                        )
                            .slideY(begin: 0.2),

                        const SizedBox(height: 12),

                        Text(
                          '${item['letter']} for ${item['word']}',
                          key: ValueKey(
                            '${item['letter']}-word',
                          ),
                          style: AppTextStyles
                              .headingMedium
                              .copyWith(
                            color:
                            AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 22),

                        ElevatedButton.icon(
                          onPressed: isSpeaking
                              ? null
                              : _speakCurrentItem,
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
                          'Tap the card or the button to hear the sound.',
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