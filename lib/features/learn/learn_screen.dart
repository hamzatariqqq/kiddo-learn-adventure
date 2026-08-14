import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

import '../learning/alphabet/alphabet_learning_screen.dart';
import '../learning/animals/animal_lesson_screen.dart';
import '../learning/colors/colors_lesson_screen.dart';
import '../learning/counting/counting_lesson_screen.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Learn'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            children: [
              // =========================
              // FRIENDLY INTRO
              // =========================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: AppColors.cyan.withValues(
                      alpha: 0.25,
                    ),
                  ),
                ),
                child: const Row(
                  children: [
                    Text(
                      '🦊',
                      style: TextStyle(
                        fontSize: 50,
                      ),
                    ),

                    SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Let\'s Learn!',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            'Tap a picture to start.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // =========================
              // BIG LEARNING CARDS
              // =========================

              GridView.count(
                shrinkWrap: true,
                physics:
                const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,

                // Taller cards = no overflow
                childAspectRatio: 0.76,

                children: [
                  // ALPHABETS
                  _LearningCard(
                    emoji: '🔤',
                    bigText: 'ABC',
                    title: 'Alphabets',
                    color: AppColors.cyan,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const AlphabetLearningScreen(),
                        ),
                      );
                    },
                  ),

                  // NUMBERS
                  _LearningCard(
                    emoji: '🔢',
                    bigText: '123',
                    title: 'Numbers',
                    color: AppColors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const CountingLessonScreen(),
                        ),
                      );
                    },
                  ),

                  // ANIMALS
                  _LearningCard(
                    emoji: '🐶',
                    bigText: '🐾',
                    title: 'Animals',
                    color: AppColors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const AnimalLessonScreen(),
                        ),
                      );
                    },
                  ),

                  // COLORS
                  _LearningCard(
                    emoji: '🎨',
                    bigText: '🌈',
                    title: 'Colors',
                    color: AppColors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const ColorsLessonScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // =========================
              // ENCOURAGEMENT CARD
              // =========================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.gold.withValues(
                      alpha: 0.25,
                    ),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Text(
                      '⭐',
                      style: TextStyle(fontSize: 24),
                    ),

                    SizedBox(width: 8),

                    Flexible(
                      child: Text(
                        'Learn and earn stars!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    SizedBox(width: 8),

                    Text(
                      '⭐',
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// LARGE PRESCHOOL LEARNING CARD
// =====================================================

class _LearningCard extends StatefulWidget {
  const _LearningCard({
    required this.emoji,
    required this.bigText,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final String emoji;
  final String bigText;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_LearningCard> createState() =>
      _LearningCardState();
}

class _LearningCardState extends State<_LearningCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.96 : 1,
      duration: const Duration(
        milliseconds: 120,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) {
            setState(() {
              _pressed = true;
            });
          },
          onTapUp: (_) {
            setState(() {
              _pressed = false;
            });
          },
          onTapCancel: () {
            setState(() {
              _pressed = false;
            });
          },
          borderRadius: BorderRadius.circular(28),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: widget.color.withValues(
                  alpha: 0.45,
                ),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(
                    alpha: 0.10,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative background circle
                Positioned(
                  right: -28,
                  top: -28,
                  child: Container(
                    width: 95,
                    height: 95,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(
                        alpha: 0.09,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 14,
                    ),
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.emoji,
                          style: const TextStyle(
                            fontSize: 42,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          widget.bigText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: widget.color,
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 7),

                        Container(
                          width: 31,
                          height: 31,
                          decoration: BoxDecoration(
                            color: widget.color,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.deepNavy,
                            size: 22,
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
      ),
    );
  }
}