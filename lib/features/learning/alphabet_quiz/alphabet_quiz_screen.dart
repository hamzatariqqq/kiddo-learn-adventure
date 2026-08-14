import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/data/alphabet_data.dart';
import '../../../core/services/tts_service.dart';
import '../services/lesson_service.dart';

class AlphabetQuizScreen extends StatefulWidget {
  const AlphabetQuizScreen({super.key});

  @override
  State<AlphabetQuizScreen> createState() =>
      _AlphabetQuizScreenState();
}

class _AlphabetQuizScreenState extends State<AlphabetQuizScreen> {
  static const String lessonId = 'alphabet';

  final LessonService _lessonService = LessonService();
  final List<Map<String, String>> alphabetItems = AlphabetData.items;
  final AudioPlayer _audioPlayer = AudioPlayer();

  late final ConfettiController _confettiController;
  late List<String> currentOptions;

  int currentQuestion = 0;
  int score = 0;

  bool isAnswering = false;
  bool isSaving = false;

  String? selectedAnswer;
  bool? selectedAnswerIsCorrect;

  static const Map<String, String> _questionAudioFiles = {
    'A': 'a_question.mp3',
    'B': 'b_question.mp3',
    'C': 'c_question.mp3',
    'D': 'd_question.mp3',
    'E': 'e_question.mp3',
    'F': 'f_question.mp3',
    'G': 'g_question.mp3',
    'H': 'h_question.mp3',
    'I': 'i_question.mp3',
    'J': 'j_question.mp3',
    'K': 'k_question.mp3',
    'L': 'l_question.mp3',
    'M': 'm_question.mp3',
    'N': 'n_question.mp3',
    'O': 'o_question.mp3',
    'P': 'p_question.mp3',
    'Q': 'q_question.mp3',
    'R': 'r_question.mp3',
    'S': 's_question.mp3',
    'T': 't_question.mp3',
    'U': 'u_question.mp3',
    'V': 'v_question.mp3',
    'W': 'w_question.mp3',
    'X': 'x_question.mp3',
    'Y': 'y_question.mp3',
    'Z': 'z_question.mp3',
  };

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _generateOptions();
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    _audioPlayer.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _generateOptions() {
    final correctLetter =
    alphabetItems[currentQuestion]['letter']!;

    final incorrectLetters = alphabetItems
        .map((item) => item['letter']!)
        .where((letter) => letter != correctLetter)
        .toList()
      ..shuffle();

    currentOptions = [
      correctLetter,
      ...incorrectLetters.take(3),
    ]..shuffle();
  }

  Future<void> _playAssetAudio(
      String assetPath, {
        String? fallbackText,
        bool waitForCompletion = false,
      }) async {
    try {
      await TtsService.instance.stop();
      await _audioPlayer.stop();

      await _audioPlayer.play(
        AssetSource(assetPath),
      );

      if (waitForCompletion) {
        await _audioPlayer.onPlayerComplete.first;
      }
    } catch (error) {
      debugPrint(
        'Alphabet quiz audio error: $error',
      );

      if (fallbackText != null) {
        await TtsService.instance.speak(
          fallbackText,
        );
      }
    }
  }

  Future<void> _speakQuestion() async {
    final item = alphabetItems[currentQuestion];

    final letter = item['letter']!;
    final word = item['word']!;

    final fileName =
    _questionAudioFiles[letter];

    if (fileName == null) {
      await TtsService.instance.speak(
        'Which letter is for $word?',
      );
      return;
    }

    //ed

    await _playAssetAudio(
      'audio/alphabet_quiz/$fileName',
      fallbackText:
      'Which letter is for $word?',
    );
  }

  Future<void> _handleAnswer(
      String letter,
      ) async {
    if (isAnswering || isSaving) return;

    final currentItem =
    alphabetItems[currentQuestion];

    final correctLetter =
    currentItem['letter']!;

    final isCorrect =
        letter == correctLetter;

    setState(() {
      isAnswering = true;
      selectedAnswer = letter;
      selectedAnswerIsCorrect =
          isCorrect;

      if (isCorrect) {
        score++;
      }
    });

    //Currect / wrong

    if (isCorrect) {
      await _playAssetAudio(
        'audio/feedback/correct.mp3',
        fallbackText: 'Correct!',
        waitForCompletion: true,
      );
    } else {
      await _playAssetAudio(
        'audio/feedback/try_again.mp3',
        fallbackText: 'Try again',
        waitForCompletion: true,
      );
    }

    if (!mounted) return;

    if (!isCorrect) {
      setState(() {
        isAnswering = false;
        selectedAnswer = null;
        selectedAnswerIsCorrect = null;
      });

      return;
    }

    if (currentQuestion <
        alphabetItems.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
        selectedAnswerIsCorrect = null;
        isAnswering = false;

        _generateOptions();
      });
    } else {
      await _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      final firstCompletion =
      await _lessonService.completeLesson(
        lessonId: lessonId,
      );

      if (!mounted) return;

      _confettiController.play();

      //real voice..

      await _playAssetAudio(
        'audio/feedback/lesson_complete.mp3',
        fallbackText:
        'Amazing job! You completed the lesson!',
        waitForCompletion: true,
      );

      if (!mounted) return;

      await _showQuizCompleteDialog(
        firstCompletion: firstCompletion,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Progress could not be saved. Check your internet connection.',
          ),
          behavior:
          SnackBarBehavior.floating,
          backgroundColor:
          AppColors.coral,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
          isAnswering = false;
        });
      }
    }
  }

  void _restartQuiz() {
    TtsService.instance.stop();
    _audioPlayer.stop();

    setState(() {
      currentQuestion = 0;
      score = 0;
      isAnswering = false;
      isSaving = false;
      selectedAnswer = null;
      selectedAnswerIsCorrect = null;

      _generateOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentItem =
    alphabetItems[currentQuestion];

    final word =
    currentItem['word']!;

    final emoji =
    currentItem['emoji']!;

    final progress =
        (currentQuestion + 1) /
            alphabetItems.length;

    return Scaffold(
      backgroundColor:
      AppColors.background,
      appBar: AppBar(
        title:
        const Text('Alphabet Quiz'),
        actions: [
          IconButton(
            tooltip: 'Listen',
            onPressed: _speakQuestion,
            icon: const Icon(
              Icons.volume_up_rounded,
            ),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.all(
                AppSpacing.large,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _buildQuizHeader(
                    word: word,
                    emoji: emoji,
                    progress: progress,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Expanded(
                    child: GridView.builder(
                      physics:
                      const BouncingScrollPhysics(),
                      itemCount:
                      currentOptions.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      itemBuilder:
                          (context, index) {
                        final letter =
                        currentOptions[index];

                        return _AlphabetOptionButton(
                          key: ValueKey(
                            '$currentQuestion-$letter',
                          ),
                          letter: letter,
                          isDisabled:
                          isAnswering ||
                              isSaving,
                          isSelected:
                          selectedAnswer ==
                              letter,
                          isCorrect:
                          selectedAnswer ==
                              letter
                              ? selectedAnswerIsCorrect
                              : null,
                          onTap: () =>
                              _handleAnswer(
                                letter,
                              ),
                        )
                            .animate()
                            .fadeIn(
                          delay: Duration(
                            milliseconds:
                            index * 80,
                          ),
                          duration: 350.ms,
                        )
                            .scale(
                          begin:
                          const Offset(
                            0.85,
                            0.85,
                          ),
                          end:
                          const Offset(
                            1,
                            1,
                          ),
                          duration: 400.ms,
                          curve:
                          Curves.easeOutBack,
                        );
                      },
                    ),
                  ),
                  if (isSaving)
                    const Padding(
                      padding:
                      EdgeInsets.only(
                        top: 12,
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              color:
                              AppColors.orange,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              'Saving your progress...',
                              style:
                              TextStyle(
                                color:
                                AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          ConfettiWidget(
            confettiController:
            _confettiController,
            blastDirectionality:
            BlastDirectionality
                .explosive,
            shouldLoop: false,
            emissionFrequency: 0.04,
            numberOfParticles: 25,
            gravity: 0.18,
            maxBlastForce: 20,
            minBlastForce: 8,
            colors: const [
              AppColors.orange,
              AppColors.green,
              AppColors.yellow,
              AppColors.purple,
              AppColors.coral,
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuizHeader({
    required String word,
    required String emoji,
    required double progress,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration:
                const Duration(
                  milliseconds: 350,
                ),
                transitionBuilder:
                    (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child:
                    SlideTransition(
                      position:
                      Tween<Offset>(
                        begin:
                        const Offset(
                          0.15,
                          0,
                        ),
                        end:
                        Offset.zero,
                      ).animate(
                        animation,
                      ),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  'Which letter is for $word $emoji?',
                  key: ValueKey(
                    currentQuestion,
                  ),
                  style: AppTextStyles
                      .headingMedium
                      .copyWith(
                    color:
                    AppColors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            _ScoreBadge(
              score: score,
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          'Question ${currentQuestion + 1} of ${alphabetItems.length}',
          style: AppTextStyles
              .bodySmall
              .copyWith(
            color:
            AppColors.textSecondary,
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: 0,
            end: progress,
          ),
          duration:
          const Duration(
            milliseconds: 450,
          ),
          curve: Curves.easeOut,
          builder:
              (context, value, child) {
            return LinearProgressIndicator(
              value: value,
              minHeight: 10,
              borderRadius:
              BorderRadius.circular(
                20,
              ),
              backgroundColor:
              Colors.white
                  .withValues(
                alpha: 0.20,
              ),
              valueColor:
              const AlwaysStoppedAnimation(
                AppColors.orange,
              ),
            );
          },
        ),
      ],
    )
        .animate()
        .fadeIn(
      duration: 400.ms,
    )
        .slideY(
      begin: -0.08,
      end: 0,
    );
  }

  Future<void>
  _showQuizCompleteDialog({
    required bool firstCompletion,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) {
        return Dialog(
          backgroundColor:
          Colors.white,
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              28,
            ),
          ),
          child: Padding(
            padding:
            const EdgeInsets.all(
              24,
            ),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                const Text(
                  '🏆',
                  style:
                  TextStyle(
                    fontSize: 70,
                  ),
                )
                    .animate(
                  onPlay:
                      (controller) {
                    controller.repeat(
                      reverse: true,
                    );
                  },
                )
                    .scale(
                  begin:
                  const Offset(
                    0.9,
                    0.9,
                  ),
                  end:
                  const Offset(
                    1.08,
                    1.08,
                  ),
                  duration: 700.ms,
                ),
                const SizedBox(
                  height: 12,
                ),
                const Text(
                  'Alphabet Quiz Complete!',
                  textAlign:
                  TextAlign.center,
                  style:
                  TextStyle(
                    color:
                    Colors.black87,
                    fontSize: 24,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  'Your score is $score / ${alphabetItems.length}',
                  textAlign:
                  TextAlign.center,
                  style:
                  const TextStyle(
                    color:
                    AppColors.orange,
                    fontSize: 21,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  firstCompletion
                      ? 'You earned 10 stars, '
                      '50 coins and 100 XP!\n'
                      'Numbers are now unlocked! 🔓'
                      : 'You already completed this lesson.\n'
                      'No duplicate reward was added.',
                  textAlign:
                  TextAlign.center,
                  style:
                  const TextStyle(
                    color:
                    Colors.black87,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                SizedBox(
                  width:
                  double.infinity,
                  child:
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(
                        dialogContext,
                      );

                      Navigator.pop(
                        context,
                      );
                    },
                    style:
                    FilledButton
                        .styleFrom(
                      backgroundColor:
                      AppColors.orange,
                      foregroundColor:
                      Colors.white,
                    ),
                    icon:
                    const Icon(
                      Icons.home_rounded,
                    ),
                    label:
                    const Text(
                      'Back to Lessons',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                SizedBox(
                  width:
                  double.infinity,
                  child:
                  OutlinedButton
                      .icon(
                    onPressed: () {
                      Navigator.pop(
                        dialogContext,
                      );

                      _restartQuiz();
                    },
                    style:
                    OutlinedButton
                        .styleFrom(
                      foregroundColor:
                      AppColors.orange,
                      side:
                      const BorderSide(
                        color:
                        AppColors.orange,
                      ),
                    ),
                    icon:
                    const Icon(
                      Icons.replay_rounded,
                    ),
                    label:
                    const Text(
                      'Play Again',
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(
          duration: 300.ms,
        )
            .scale(
          begin:
          const Offset(
            0.75,
            0.75,
          ),
          end:
          const Offset(
            1,
            1,
          ),
          duration: 500.ms,
          curve:
          Curves.easeOutBack,
        );
      },
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;

  const _ScoreBadge({
    required this.score,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return AnimatedSwitcher(
      duration:
      const Duration(
        milliseconds: 300,
      ),
      transitionBuilder:
          (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      child: Container(
        key:
        ValueKey(score),
        padding:
        const EdgeInsets
            .symmetric(
          horizontal: 14,
          vertical: 9,
        ),
        decoration:
        BoxDecoration(
          color:
          AppColors.yellow,
          borderRadius:
          BorderRadius.circular(
            20,
          ),
        ),
        child: Text(
          '⭐ $score',
          style:
          AppTextStyles.title
              .copyWith(
            color:
            AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _AlphabetOptionButton
    extends StatefulWidget {
  final String letter;
  final bool isDisabled;
  final bool isSelected;
  final bool? isCorrect;
  final VoidCallback onTap;

  const _AlphabetOptionButton({
    super.key,
    required this.letter,
    required this.isDisabled,
    required this.isSelected,
    required this.isCorrect,
    required this.onTap,
  });

  @override
  State<_AlphabetOptionButton>
  createState() =>
      _AlphabetOptionButtonState();
}

class _AlphabetOptionButtonState
    extends State<
        _AlphabetOptionButton> {
  bool isPressed = false;

  @override
  Widget build(
      BuildContext context,
      ) {
    Color borderColor =
    AppColors.orange
        .withValues(
      alpha: 0.75,
    );

    Color backgroundColor =
        Colors.white;

    Color letterColor =
        AppColors.orange;

    double borderWidth = 2;

    if (widget.isSelected &&
        widget.isCorrect == true) {
      borderColor =
          AppColors.green;
      backgroundColor =
          AppColors.green;
      letterColor =
          Colors.white;
      borderWidth = 5;
    } else if (widget.isSelected &&
        widget.isCorrect == false) {
      borderColor =
          AppColors.coral;
      backgroundColor =
          AppColors.coral;
      letterColor =
          Colors.white;
      borderWidth = 5;
    }

    return AnimatedScale(
      scale:
      isPressed ? 0.92 : 1,
      duration:
      const Duration(
        milliseconds: 120,
      ),
      child:
      AnimatedContainer(
        duration:
        const Duration(
          milliseconds: 250,
        ),
        decoration:
        BoxDecoration(
          color:
          backgroundColor,
          borderRadius:
          BorderRadius.circular(
            24,
          ),
          border:
          Border.all(
            color:
            borderColor,
            width:
            borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color:
              AppColors.orange
                  .withValues(
                alpha: 0.15,
              ),
              blurRadius:
              widget.isSelected
                  ? 5
                  : 14,
              offset:
              const Offset(
                0,
                6,
              ),
            ),
          ],
        ),
        child: Material(
          color:
          Colors.transparent,
          borderRadius:
          BorderRadius.circular(
            24,
          ),
          child: InkWell(
            borderRadius:
            BorderRadius.circular(
              24,
            ),
            onTap:
            widget.isDisabled
                ? null
                : widget.onTap,
            onTapDown:
            widget.isDisabled
                ? null
                : (_) {
              setState(() {
                isPressed = true;
              });
            },
            onTapUp:
            widget.isDisabled
                ? null
                : (_) {
              setState(() {
                isPressed = false;
              });
            },
            onTapCancel: () {
              setState(() {
                isPressed = false;
              });
            },
            child: Stack(
              alignment:
              Alignment.center,
              children: [
                Text(
                  widget.letter,
                  style:
                  AppTextStyles
                      .headingLarge
                      .copyWith(
                    color:
                    letterColor,
                    fontSize: 58,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
                if (widget.isSelected)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Icon(
                      widget.isCorrect ==
                          true
                          ? Icons
                          .check_circle_rounded
                          : Icons
                          .cancel_rounded,
                      color:
                      Colors.white,
                      size: 34,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
