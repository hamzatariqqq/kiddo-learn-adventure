import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/banner_ad_widget.dart';
import '../../core/widgets/rewarded_ad_button.dart';
import '../auth/providers/user_provider.dart';
import '../learning/alphabet/alphabet_learning_screen.dart';
import '../learning/animals/animal_lesson_screen.dart';
import '../learning/colors/colors_lesson_screen.dart';
import '../learning/counting/counting_lesson_screen.dart';
import '../parent/parent_dashboard_screen.dart';
import '../rewards/daily_reward_card.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),

      error: (error, stackTrace) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Oops! Something went wrong.\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),

      data: (user) {
        final name = user?.name ?? 'Explorer';
        final stars = user?.stars ?? 0;

        final completedLessonIds =
            user?.completedLessonIds ?? const <String>[];

        final alphabetDone =
        completedLessonIds.contains('alphabet');

        final numbersDone =
        completedLessonIds.contains('numbers');

        final animalsDone =
        completedLessonIds.contains('animals');

        final colorsDone =
        completedLessonIds.contains('colors');

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              const Positioned.fill(
                child: _KidBackground(),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(
                    AppSpacing.large,
                  ),
                  child: Column(
                    children: [
                      // =========================
                      // TOP BAR
                      // =========================

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hi, $name! 👋',
                                  maxLines: 1,
                                  overflow:
                                  TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 25,
                                    fontWeight:
                                    FontWeight.w900,
                                  ),
                                ),

                                const SizedBox(height: 3),

                                const Text(
                                  'Let\'s learn & play!',
                                  style: TextStyle(
                                    color:
                                    AppColors.textSecondary,
                                    fontSize: 14,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          _SmallTopButton(
                            icon:
                            Icons.family_restroom_rounded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const ParentDashboardScreen(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(width: 8),

                          _SmallTopButton(
                            icon: Icons.settings_rounded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const SettingsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // =========================
                      // FRIENDLY MASCOT AREA
                      // =========================

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(
                            alpha: 0.92,
                          ),
                          borderRadius:
                          BorderRadius.circular(28),
                          border: Border.all(
                            color: AppColors.cyan.withValues(
                              alpha: 0.25,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 78,
                              height: 78,
                              decoration: BoxDecoration(
                                color: AppColors.cyan.withValues(
                                  alpha: 0.15,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  '🐼',
                                  style: TextStyle(
                                    fontSize: 48,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            const Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'What do you want',
                                    style: TextStyle(
                                      color:
                                      AppColors.white,
                                      fontSize: 19,
                                      fontWeight:
                                      FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    'to learn today?',
                                    style: TextStyle(
                                      color:
                                      AppColors.gold,
                                      fontSize: 21,
                                      fontWeight:
                                      FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // =========================
                      // 4 MAIN CHILD CHOICES
                      // =========================

                      GridView.count(
                        shrinkWrap: true,
                        physics:
                        const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.92,
                        children: [
                          _KidLearningCard(
                            emoji: '🔤',
                            title: 'ABC',
                            subtitle: 'Alphabets',
                            color: AppColors.cyan,
                            isCompleted: alphabetDone,
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

                          _KidLearningCard(
                            emoji: '🔢',
                            title: '123',
                            subtitle: 'Numbers',
                            color: AppColors.orange,
                            isCompleted: numbersDone,
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

                          _KidLearningCard(
                            emoji: '🐶',
                            title: 'Animals',
                            subtitle: 'Learn Animals',
                            color: AppColors.green,
                            isCompleted: animalsDone,
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

                          _KidLearningCard(
                            emoji: '🎨',
                            title: 'Colors',
                            subtitle: 'Learn Colors',
                            color: AppColors.purple,
                            isCompleted: colorsDone,
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

                      const SizedBox(height: 25),

                      // =========================
                      // SIMPLE STAR REWARD
                      // =========================

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius:
                          BorderRadius.circular(22),
                          border: Border.all(
                            color: AppColors.gold.withValues(
                              alpha: 0.30,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              '⭐',
                              style: TextStyle(
                                fontSize: 38,
                              ),
                            ),

                            const SizedBox(width: 13),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'My Stars',
                                    style: TextStyle(
                                      color:
                                      AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight:
                                      FontWeight.w600,
                                    ),
                                  ),

                                  Text(
                                    '$stars Stars',
                                    style: const TextStyle(
                                      color:
                                      AppColors.white,
                                      fontSize: 20,
                                      fontWeight:
                                      FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Text(
                              '✨',
                              style: TextStyle(
                                fontSize: 28,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // =========================
                      // DAILY REWARD
                      // =========================

                      const DailyRewardCard(),

                      const SizedBox(height: 14),

                      // =========================
                      // OPTIONAL REWARDED AD
                      // Kept separate from learning
                      // =========================

                      const RewardedAdButton(),

                      const SizedBox(height: 26),

                      // =========================
                      // BANNER AD
                      // =========================

                      const BannerAdWidget(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// =====================================================
// LARGE CHILD LEARNING CARD
// =====================================================

class _KidLearningCard extends StatelessWidget {
  const _KidLearningCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isCompleted,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: color.withValues(alpha: 0.50),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -25,
                top: -25,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: color.withValues(
                      alpha: 0.10,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              if (isCompleted)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 29,
                    height: 29,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                ),

              Center(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Text(
                        emoji,
                        style: const TextStyle(
                          fontSize: 55,
                        ),
                      ),

                      const SizedBox(height: 9),

                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: color,
                          fontSize: 23,
                          fontWeight:
                          FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color:
                          AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight:
                          FontWeight.w600,
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
    );
  }
}

// =====================================================
// SMALL ADULT BUTTON
// =====================================================

class _SmallTopButton extends StatelessWidget {
  const _SmallTopButton({
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
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.white.withValues(
                alpha: 0.08,
              ),
            ),
          ),
          child: Icon(
            icon,
            color: AppColors.textSecondary,
            size: 21,
          ),
        ),
      ),
    );
  }
}

// =====================================================
// BACKGROUND
// =====================================================

class _KidBackground extends StatelessWidget {
  const _KidBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.deepNavy,
            AppColors.background,
            AppColors.navyBlue,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 130,
            right: -70,
            child: _SoftGlow(
              size: 200,
              color: AppColors.cyan,
            ),
          ),

          Positioned(
            top: 500,
            left: -90,
            child: _SoftGlow(
              size: 230,
              color: AppColors.purple,
            ),
          ),

          Positioned(
            bottom: 80,
            right: -80,
            child: _SoftGlow(
              size: 210,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftGlow extends StatelessWidget {
  const _SoftGlow({
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
        color: color.withValues(alpha: 0.05),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 70,
            spreadRadius: 25,
          ),
        ],
      ),
    );
  }
}