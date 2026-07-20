import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/data/alphabet_data.dart';
import '../services/lesson_service.dart';

class AlphabetQuizScreen extends StatefulWidget {
  const AlphabetQuizScreen({super.key});

  @override
  State<AlphabetQuizScreen> createState() => _AlphabetQuizScreenState();
}

class _AlphabetQuizScreenState extends State<AlphabetQuizScreen> {
  static const String lessonId = 'alphabet';

  final LessonService _lessonService = LessonService();
  final List<Map<String, String>> alphabetItems = AlphabetData.items;

  late final ConfettiController _confettiController;
  late List<String> currentOptions;

  int currentQuestion = 0;
  int score = 0;

  bool isAnswering = false;
  bool isSaving = false;

  String? selectedAnswer;
  bool? selectedAnswerIsCorrect;

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
    _confettiController.dispose();
    super.dispose();
  }

  void _generateOptions() {
    final correctLetter = alphabetItems[currentQuestion]['letter']!;

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

  Future<void> _handleAnswer(String letter) async {
    if (isAnswering || isSaving) return;

    final correctLetter = alphabetItems[currentQuestion]['letter']!;
    final bool isCorrect = letter == correctLetter;

    setState(() {
      isAnswering = true;
      selectedAnswer = letter;
      selectedAnswerIsCorrect = isCorrect;

      if (isCorrect) {
        score++;
      }
    });

    await Future<void>.delayed(
      const Duration(milliseconds: 700),
    );

    if (!mounted) return;

    if (!isCorrect) {
      setState(() {
        isAnswering = false;
        selectedAnswer = null;
        selectedAnswerIsCorrect = null;
      });

      return;
    }

    if (currentQuestion < alphabetItems.length - 1) {
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
      await _lessonService.completeLesson(
        lessonId: lessonId,
        starsEarned: score * 5,
      );

      if (!mounted) return;

      _confettiController.play();

      await Future<void>.delayed(
        const Duration(milliseconds: 350),
      );

      if (!mounted) return;

      await _showQuizCompleteDialog(
        firstCompletion: firstCompletion,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Progress could not be saved. Please check your internet.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.coral,
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
    final currentItem = alphabetItems[currentQuestion];

    final String word = currentItem['word']!;
    final String emoji = currentItem['emoji']!;

    final double progress =
        (currentQuestion + 1) / alphabetItems.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Alphabet Quiz'),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuizHeader(
                    word: word,
                    emoji: emoji,
                    progress: progress,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: currentOptions.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final letter = currentOptions[index];

                        return _AlphabetOptionButton(
                          key: ValueKey(
                            '$currentQuestion-$letter',
                          ),
                          letter: letter,
                          isDisabled: isAnswering || isSaving,
                          isSelected: selectedAnswer == letter,
                          isCorrect: selectedAnswer == letter
                              ? selectedAnswerIsCorrect
                              : null,
                          onTap: () => _handleAnswer(letter),
                        )
                            .animate()
                            .fadeIn(
                          delay: Duration(
                            milliseconds: index * 80,
                          ),
                          duration: 350.ms,
                        )
                            .scale(
                          begin: const Offset(0.85, 0.85),
                          end: const Offset(1, 1),
                          duration: 400.ms,
                          curve: Curves.easeOutBack,
                        );
                      },
                    ),
                  ),
                  if (isSaving)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 8),
                            Text('Saving your progress...'),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality:
            BlastDirectionality.explosive,
            shouldLoop: false,
            emissionFrequency: 0.04,
            numberOfParticles: 25,
            gravity: 0.18,
            maxBlastForce: 20,
            minBlastForce: 8,
            colors: const [
              AppColors.primaryBlue,
              AppColors.green,
              AppColors.yellow,
              AppColors.orange,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(
                  milliseconds: 350,
                ),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.15, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  'Which letter is for $word $emoji?',
                  key: ValueKey(currentQuestion),
                  style: AppTextStyles.headingMedium,
                ),
              ),
            ),
            const SizedBox(width: 12),
            _ScoreBadge(score: score),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Question ${currentQuestion + 1} '
              'of ${alphabetItems.length}',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: 12),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: 0,
            end: progress,
          ),
          duration: const Duration(
            milliseconds: 450,
          ),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return LinearProgressIndicator(
              value: value,
              minHeight: 10,
              borderRadius: BorderRadius.circular(20),
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation(
                AppColors.primaryBlue,
              ),
            );
          },
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(
      begin: -0.08,
      end: 0,
    );
  }

  Future<void> _showQuizCompleteDialog({
    required bool firstCompletion,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🏆',
                  style: TextStyle(fontSize: 70),
                )
                    .animate(
                  onPlay: (controller) {
                    controller.repeat(reverse: true);
                  },
                )
                    .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.08, 1.08),
                  duration: 700.ms,
                ),
                const SizedBox(height: 12),
                Text(
                  'Alphabet Quiz Complete!',
                  style: AppTextStyles.headingMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'You scored $score out of '
                      '${alphabetItems.length}.',
                  style: AppTextStyles.title,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  firstCompletion
                      ? 'You earned ${score * 5} stars, '
                      '50 coins and 100 XP!\n'
                      'Numbers are now unlocked! 🔓'
                      : 'You already completed this lesson.\n'
                      'No duplicate reward was added.',
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.home_rounded,
                    ),
                    label: const Text(
                      'Back to Lessons',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _restartQuiz();
                    },
                    icon: const Icon(
                      Icons.replay_rounded,
                    ),
                    label: const Text('Play Again'),
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms)
            .scale(
          begin: const Offset(0.75, 0.75),
          end: const Offset(1, 1),
          duration: 500.ms,
          curve: Curves.easeOutBack,
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
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      child: Container(
        key: ValueKey(score),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: AppColors.yellow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '⭐ $score',
          style: AppTextStyles.title.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _AlphabetOptionButton extends StatefulWidget {
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
  State<_AlphabetOptionButton> createState() =>
      _AlphabetOptionButtonState();
}

class _AlphabetOptionButtonState
    extends State<_AlphabetOptionButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color borderColor =
    AppColors.primaryBlue.withValues(alpha: 0.25);

    Color backgroundColor =
    AppColors.primaryBlue.withValues(alpha: 0.12);

    double borderWidth = 2;

    if (widget.isSelected &&
        widget.isCorrect == true) {
      borderColor = AppColors.green;
      backgroundColor =
          AppColors.green.withValues(alpha: 0.16);
      borderWidth = 6;
    } else if (widget.isSelected &&
        widget.isCorrect == false) {
      borderColor = AppColors.coral;
      backgroundColor =
          AppColors.coral.withValues(alpha: 0.16);
      borderWidth = 6;
    }

    return AnimatedScale(
      scale: isPressed ? 0.92 : 1,
      duration: const Duration(milliseconds: 120),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue
                  .withValues(alpha: 0.12),
              blurRadius:
              widget.isSelected ? 4 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: widget.isDisabled
                ? null
                : widget.onTap,
            onTapDown: widget.isDisabled
                ? null
                : (_) {
              setState(() {
                isPressed = true;
              });
            },
            onTapUp: widget.isDisabled
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
              alignment: Alignment.center,
              children: [
                Text(
                  widget.letter,
                  style:
                  AppTextStyles.headingLarge.copyWith(
                    color: AppColors.primaryBlue,
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.isSelected)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Icon(
                      widget.isCorrect == true
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: widget.isCorrect == true
                          ? AppColors.green
                          : AppColors.coral,
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