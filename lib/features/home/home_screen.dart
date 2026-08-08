import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/category_card.dart';
import '../../core/widgets/home_header.dart';
import '../../core/widgets/progress_summary_card.dart';
import '../achievements/achievement_screen.dart';
import '../auth/providers/user_provider.dart';
import '../learning/alphabet/alphabet_learning_screen.dart';
import '../learning/animals/animal_lesson_screen.dart';
import '../learning/colors/colors_lesson_screen.dart';
import '../learning/counting/counting_lesson_screen.dart';
import '../parent/parent_dashboard_screen.dart';
import '../rewards/daily_reward_card.dart';
import '../settings/settings_screen.dart';

import '../../core/widgets/banner_ad_widget.dart';
import '../../core/widgets/rewarded_ad_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.gold,
          ),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Unable to load user data.\n$error',
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
        final coins = user?.coins ?? 0;
        final xp = user?.xp ?? 0;
        final level = user?.level ?? 1;
        final completedLessons = user?.completedLessons ?? 0;
        final streak = user?.streak ?? 0;

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
                child: _AdventureBackground(),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(
                    AppSpacing.large,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      HomeHeader(
                        childName: name,
                        stars: stars,
                        coins: coins,
                        xp: xp,
                        level: level,
                        streak: streak,
                      ),

                      const SizedBox(height: 22),

                      ProgressSummaryCard(
                        completedLessons:
                        completedLessons,
                        totalLessons: 4,
                        streakDays: streak,
                      ),

                      const SizedBox(height: 16),

                      //daly reward

                      const DailyRewardCard(),

                      const SizedBox(height: 16),

                      const RewardedAdButton(),



                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _NavigationButton(
                              icon: Icons
                                  .family_restroom_rounded,
                              label: 'Parent Zone',
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
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _NavigationButton(
                              icon:
                              Icons.settings_rounded,
                              label: 'Settings',
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
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      const Text(
                        'Choose Your Adventure',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),

                      const SizedBox(height: 7),

                      const Text(
                        'Complete each world to unlock the next one.',
                        style: TextStyle(
                          color:
                          AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 20),

                      GridView.count(
                        shrinkWrap: true,
                        physics:
                        const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.86,
                        children: [
                          CategoryCard(
                            title: 'Alphabets',
                            lessonCount: alphabetDone
                                ? 'Adventure completed'
                                : '24 learning levels',
                            icon: alphabetDone
                                ? Icons
                                .check_circle_rounded
                                : Icons.abc_rounded,
                            color: AppColors.cyan,
                            isLocked: false,
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

                          CategoryCard(
                            title: 'Numbers',
                            lessonCount: numbersDone
                                ? 'Adventure completed'
                                : '20 learning levels',
                            icon: numbersDone
                                ? Icons
                                .check_circle_rounded
                                : Icons.numbers_rounded,
                            color: AppColors.orange,
                            isLocked: !alphabetDone,
                            onTap: alphabetDone
                                ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const CountingLessonScreen(),
                                ),
                              );
                            }
                                : null,
                          ),

                          CategoryCard(
                            title: 'Animals',
                            lessonCount: animalsDone
                                ? 'Adventure completed'
                                : '15 learning levels',
                            icon: animalsDone
                                ? Icons
                                .check_circle_rounded
                                : Icons.pets_rounded,
                            color: AppColors.green,
                            isLocked: !numbersDone,
                            onTap: numbersDone
                                ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AnimalLessonScreen(),
                                ),
                              );
                            }
                                : null,
                          ),

                          CategoryCard(
                            title: 'Colors',
                            lessonCount: colorsDone
                                ? 'Adventure completed'
                                : '10 learning levels',
                            icon: colorsDone
                                ? Icons
                                .check_circle_rounded
                                : Icons.palette_rounded,
                            color: AppColors.purple,
                            isLocked: !animalsDone,
                            onTap: animalsDone
                                ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const ColorsLessonScreen(),
                                ),
                              );
                            }
                                : null,
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      const Text(
                        'Achievement Castle',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 14),

                      InkWell(
                        borderRadius:
                        BorderRadius.circular(24),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const AchievementScreen(),
                            ),
                          );
                        },
                        child: Ink(
                          width: double.infinity,
                          padding:
                          const EdgeInsets.all(19),
                          decoration: BoxDecoration(
                            gradient:
                            const LinearGradient(
                              colors: [
                                AppColors.surfaceLight,
                                AppColors.deepNavy,
                              ],
                            ),
                            borderRadius:
                            BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.gold
                                  .withValues(
                                alpha: 0.55,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(
                                  alpha: 0.30,
                                ),
                                blurRadius: 18,
                                offset:
                                const Offset(0, 9),
                              ),
                            ],
                          ),
                          child: const Row(
                            children: [
                              CircleAvatar(
                                radius: 27,
                                backgroundColor:
                                AppColors.gold,
                                child: Icon(
                                  Icons
                                      .workspace_premium_rounded,
                                  color:
                                  AppColors.deepNavy,
                                  size: 29,
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    Text(
                                      'View Achievements',
                                      style: TextStyle(
                                        color:
                                        AppColors.white,
                                        fontWeight:
                                        FontWeight.w900,
                                        fontSize: 17,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Discover unlocked badges and rewards',
                                      style: TextStyle(
                                        color: AppColors
                                            .textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons
                                    .arrow_forward_ios_rounded,
                                color: AppColors.gold,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

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

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(
            alpha: 0.90,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.gold.withValues(
              alpha: 0.32,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.gold,
              size: 19,
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdventureBackground extends StatelessWidget {
  const _AdventureBackground();

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
            top: 100,
            right: -60,
            child: _GlowCircle(
              size: 190,
              color: AppColors.cyan,
            ),
          ),
          Positioned(
            top: 460,
            left: -70,
            child: _GlowCircle(
              size: 210,
              color: AppColors.purple,
            ),
          ),
          Positioned(
            bottom: 80,
            right: -80,
            child: _GlowCircle(
              size: 220,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({
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
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.06),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.09),
            blurRadius: 70,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}