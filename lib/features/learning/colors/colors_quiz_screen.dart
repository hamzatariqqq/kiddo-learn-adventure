import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/data/color_data.dart';
import '../services/lesson_service.dart';

class ColorsQuizScreen extends StatefulWidget {
  const ColorsQuizScreen({super.key});

  @override
  State<ColorsQuizScreen> createState() =>
      _ColorsQuizScreenState();
}

class _ColorsQuizScreenState
    extends State<ColorsQuizScreen> {
  static const String lessonId = 'colors';

  final LessonService _lessonService =
  LessonService();

  final AudioPlayer _audioPlayer =
  AudioPlayer();

  late final ConfettiController
  _confettiController;

  final List<Map<String, dynamic>> colors =
      ColorData.items;

  int currentQuestion = 0;
  int score = 0;

  bool isAnswering = false;
  bool isSaving = false;

  String? selectedAnswer;
  bool? selectedAnswerIsCorrect;

  late List<Map<String, dynamic>>
  currentOptions;

  @override
  void initState() {
    super.initState();

    _confettiController =
        ConfettiController(
          duration:
          const Duration(seconds: 3),
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
    final correctColor =
    colors[currentQuestion];

    final incorrectColors =
    List<Map<String, dynamic>>.from(
      colors,
    )
      ..removeWhere(
            (item) =>
        item['name'] ==
            correctColor['name'],
      )
      ..shuffle();

    currentOptions = [
      correctColor,
      ...incorrectColors.take(3),
    ]..shuffle();
  }

  Future<void> _playFeedbackAudio(
      String fileName,
      ) async {
    try {
      await _audioPlayer.stop();

      await _audioPlayer.play(
        AssetSource(
          'audio/feedback/$fileName',
        ),
      );

      await _audioPlayer
          .onPlayerComplete.first;
    } catch (error) {
      debugPrint(
        'Color quiz feedback audio error: $error',
      );
    }
  }

  Future<void> _handleAnswer(
      Map<String, dynamic> colorItem,
      ) async {
    if (isAnswering || isSaving) {
      return;
    }

    final selectedName =
    colorItem['name'] as String;

    final correctName =
    colors[currentQuestion]['name']
    as String;

    final bool isCorrect =
        selectedName == correctName;

    setState(() {
      isAnswering = true;
      selectedAnswer = selectedName;
      selectedAnswerIsCorrect =
          isCorrect;

      if (isCorrect) {
        score++;
      }
    });

    if (isCorrect) {
      await _playFeedbackAudio(
        'correct.mp3',
      );
    } else {
      await _playFeedbackAudio(
        'try_again.mp3',
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
        colors.length - 1) {
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
      final bool firstCompletion =
      await _lessonService
          .completeLesson(
        lessonId: lessonId,
        starsEarned: score * 5,
      );

      if (!mounted) return;

      _confettiController.play();

      await _playFeedbackAudio(
        'lesson_complete.mp3',
      );

      if (!mounted) return;

      await _showQuizCompleteDialog(
        firstCompletion:
        firstCompletion,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Progress could not be saved. Please check your internet.',
          ),
          behavior:
          SnackBarBehavior.floating,
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
    _audioPlayer.stop();

    setState(() {
      currentQuestion = 0;
      score = 0;
      selectedAnswer = null;
      selectedAnswerIsCorrect = null;
      isAnswering = false;
      isSaving = false;

      _generateOptions();
    });
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final currentColor =
    colors[currentQuestion];

    final progress =
        (currentQuestion + 1) /
            colors.length;

    return Scaffold(
      backgroundColor:
      AppColors.background,
      appBar: AppBar(
        title:
        const Text('Color Quiz'),
      ),
      body: Stack(
        alignment:
        Alignment.topCenter,
        children: [
          SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.all(
                AppSpacing.large,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  _buildTopInformation(
                    currentColor,
                    progress,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Expanded(
                    child:
                    GridView.builder(
                      physics:
                      const BouncingScrollPhysics(),
                      itemCount:
                      currentOptions
                          .length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      itemBuilder:
                          (context, index) {
                        final colorItem =
                        currentOptions[
                        index];

                        return _ColorOptionButton(
                          key: ValueKey(
                            '${currentQuestion}_${colorItem['name']}',
                          ),
                          colorItem:
                          colorItem,
                          isDisabled:
                          isAnswering ||
                              isSaving,
                          isSelected:
                          selectedAnswer ==
                              colorItem[
                              'name']
                              as String,
                          isCorrect:
                          selectedAnswer ==
                              colorItem[
                              'name']
                              as String
                              ? selectedAnswerIsCorrect
                              : null,
                          onTap: () =>
                              _handleAnswer(
                                colorItem,
                              ),
                        )
                            .animate()
                            .fadeIn(
                          delay: Duration(
                            milliseconds:
                            index * 80,
                          ),
                          duration:
                          350.ms,
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
                          curve:
                          Curves
                              .easeOutBack,
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
                            CircularProgressIndicator(),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              'Saving your progress...',
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
            emissionFrequency:
            0.04,
            numberOfParticles:
            25,
            gravity: 0.18,
            maxBlastForce: 20,
            minBlastForce: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildTopInformation(
      Map<String, dynamic>
      currentColor,
      double progress,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child:
              AnimatedSwitcher(
                duration:
                const Duration(
                  milliseconds: 350,
                ),
                transitionBuilder:
                    (
                    child,
                    animation,
                    ) {
                  return FadeTransition(
                    opacity:
                    animation,
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
                      child:
                      child,
                    ),
                  );
                },
                child: Text(
                  'Tap the ${currentColor['name']} color',
                  key: ValueKey(
                    currentQuestion,
                  ),
                  style:
                  AppTextStyles
                      .headingMedium,
                ),
              ),
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
          'Question ${currentQuestion + 1} of ${colors.length}',
          style:
          AppTextStyles
              .bodySmall,
        ),
        const SizedBox(
          height: 12,
        ),
        TweenAnimationBuilder<
            double>(
          tween:
          Tween(
            begin: 0,
            end: progress,
          ),
          duration:
          const Duration(
            milliseconds: 450,
          ),
          curve:
          Curves.easeOut,
          builder:
              (
              context,
              value,
              child,
              ) {
            return LinearProgressIndicator(
              value:
              value,
              minHeight: 10,
              borderRadius:
              BorderRadius.circular(
                20,
              ),
              backgroundColor:
              Colors.grey
                  .shade300,
              valueColor:
              const AlwaysStoppedAnimation(
                AppColors.purple,
              ),
            );
          },
        ),
      ],
    )
        .animate()
        .fadeIn(
      duration:
      400.ms,
    )
        .slideY(
      begin:
      -0.08,
      end: 0,
    );
  }

  Future<void>
  _showQuizCompleteDialog({
    required bool
    firstCompletion,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible:
      false,
      builder:
          (dialogContext) {
        return Dialog(
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
                    fontSize:
                    70,
                  ),
                )
                    .animate(
                  onPlay:
                      (controller) {
                    controller.repeat(
                      reverse:
                      true,
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
                  duration:
                  700.ms,
                ),
                const SizedBox(
                  height:
                  12,
                ),
                Text(
                  'Quiz Complete!',
                  style:
                  AppTextStyles
                      .headingMedium,
                  textAlign:
                  TextAlign
                      .center,
                ),
                const SizedBox(
                  height:
                  12,
                ),
                Text(
                  'You scored $score out of ${colors.length}.',
                  style:
                  AppTextStyles
                      .title,
                  textAlign:
                  TextAlign
                      .center,
                ),
                const SizedBox(
                  height:
                  8,
                ),
                Text(
                  firstCompletion
                      ? 'You earned ${score * 5} stars, 50 coins and 100 XP!'
                      : 'You already completed this lesson.\nNo duplicate reward was added.',
                  style:
                  AppTextStyles
                      .bodySmall,
                  textAlign:
                  TextAlign
                      .center,
                ),
                const SizedBox(
                  height:
                  24,
                ),
                SizedBox(
                  width:
                  double.infinity,
                  child:
                  FilledButton.icon(
                    onPressed:
                        () {
                      Navigator.pop(
                        dialogContext,
                      );

                      Navigator.pop(
                        context,
                      );
                    },
                    icon:
                    const Icon(
                      Icons
                          .home_rounded,
                    ),
                    label:
                    const Text(
                      'Back to Lessons',
                    ),
                  ),
                ),
                const SizedBox(
                  height:
                  8,
                ),
                SizedBox(
                  width:
                  double.infinity,
                  child:
                  OutlinedButton
                      .icon(
                    onPressed:
                        () {
                      Navigator.pop(
                        dialogContext,
                      );

                      _restartQuiz();
                    },
                    icon:
                    const Icon(
                      Icons
                          .replay_rounded,
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
          duration:
          300.ms,
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
          curve:
          Curves
              .easeOutBack,
          duration:
          500.ms,
        );
      },
    );
  }
}

class _ScoreBadge
    extends StatelessWidget {
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
        milliseconds:
        300,
      ),
      transitionBuilder:
          (
          child,
          animation,
          ) {
        return ScaleTransition(
          scale:
          animation,
          child:
          child,
        );
      },
      child: Container(
        key:
        ValueKey(score),
        padding:
        const EdgeInsets.symmetric(
          horizontal:
          14,
          vertical:
          9,
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
          AppTextStyles
              .title
              .copyWith(
            color:
            AppColors
                .textPrimary,
          ),
        ),
      ),
    );
  }
}

class _ColorOptionButton
    extends StatefulWidget {
  final Map<String, dynamic>
  colorItem;

  final bool isDisabled;
  final bool isSelected;
  final bool? isCorrect;
  final VoidCallback onTap;

  const _ColorOptionButton({
    super.key,
    required this.colorItem,
    required this.isDisabled,
    required this.isSelected,
    required this.isCorrect,
    required this.onTap,
  });

  @override
  State<_ColorOptionButton>
  createState() =>
      _ColorOptionButtonState();
}

class _ColorOptionButtonState
    extends State<
        _ColorOptionButton> {
  bool isPressed =
  false;

  @override
  Widget build(
      BuildContext context,
      ) {
    final color =
    widget.colorItem[
    'color']
    as Color;

    final name =
    widget.colorItem[
    'name']
    as String;

    Color borderColor =
        AppColors.border;

    double borderWidth =
    2;

    if (widget.isSelected &&
        widget.isCorrect ==
            true) {
      borderColor =
          AppColors.green;

      borderWidth =
      6;
    } else if (widget
        .isSelected &&
        widget.isCorrect ==
            false) {
      borderColor =
          AppColors.coral;

      borderWidth =
      6;
    }

    return AnimatedScale(
      scale:
      isPressed
          ? 0.92
          : 1,
      duration:
      const Duration(
        milliseconds:
        120,
      ),
      child:
      AnimatedContainer(
        duration:
        const Duration(
          milliseconds:
          250,
        ),
        decoration:
        BoxDecoration(
          color:
          color,
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
              Colors.black
                  .withValues(
                alpha:
                0.12,
              ),
              blurRadius:
              widget
                  .isSelected
                  ? 4
                  : 12,
              offset:
              const Offset(
                0,
                6,
              ),
            ),
          ],
        ),
        child:
        Material(
          color:
          Colors.transparent,
          borderRadius:
          BorderRadius.circular(
            24,
          ),
          child:
          InkWell(
            borderRadius:
            BorderRadius.circular(
              24,
            ),
            onTap:
            widget
                .isDisabled
                ? null
                : widget
                .onTap,
            onTapDown:
            widget
                .isDisabled
                ? null
                : (_) {
              setState(
                    () {
                  isPressed =
                  true;
                },
              );
            },
            onTapUp:
            widget
                .isDisabled
                ? null
                : (_) {
              setState(
                    () {
                  isPressed =
                  false;
                },
              );
            },
            onTapCancel:
                () {
              setState(
                    () {
                  isPressed =
                  false;
                },
              );
            },
            child:
            Stack(
              alignment:
              Alignment.center,
              children: [
                Text(
                  name,
                  style:
                  AppTextStyles
                      .title
                      .copyWith(
                    color:
                    _textColorFor(
                      name,
                    ),
                    fontSize:
                    19,
                    fontWeight:
                    FontWeight
                        .bold,
                  ),
                ),
                if (widget
                    .isSelected)
                  Positioned(
                    top:
                    12,
                    right:
                    12,
                    child:
                    Icon(
                      widget.isCorrect ==
                          true
                          ? Icons
                          .check_circle_rounded
                          : Icons
                          .cancel_rounded,
                      color:
                      widget.isCorrect ==
                          true
                          ? AppColors
                          .green
                          : AppColors
                          .coral,
                      size:
                      34,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _textColorFor(
      String colorName,
      ) {
    const darkTextColors =
    {
      'White',
      'Yellow',
      'Pink',
      'Orange',
    };

    return darkTextColors
        .contains(
      colorName,
    )
        ? AppColors
        .textPrimary
        : AppColors.white;
  }
}