import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme/app_colors.dart';

Future<void> showDailyRewardDialog(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Daily Reward',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 450),
    pageBuilder: (
        context,
        animation,
        secondaryAnimation,
        ) {
      return const _RewardDialog();
    },
    transitionBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
        ) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.elasticOut,
      );

      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: curvedAnimation,
          child: child,
        ),
      );
    },
  );
}

class _RewardDialog extends StatelessWidget {
  const _RewardDialog();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 330,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F7FB),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.45),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.orange.withValues(alpha: 0.12),
                    ),
                  )
                      .animate(
                    onPlay: (controller) {
                      controller.repeat();
                    },
                  )
                      .scale(
                    begin: const Offset(0.90, 0.90),
                    end: const Offset(1.15, 1.15),
                    duration: 1400.ms,
                  )
                      .fade(
                    begin: 1,
                    end: 0.20,
                    duration: 1400.ms,
                  ),

                  const Text(
                    '🎁',
                    style: TextStyle(fontSize: 74),
                  )
                      .animate()
                      .fadeIn(
                    duration: 350.ms,
                  )
                      .scale(
                    begin: const Offset(0.30, 0.30),
                    end: const Offset(1, 1),
                    duration: 700.ms,
                    curve: Curves.elasticOut,
                  )
                      .then()
                      .shake(
                    hz: 4,
                    duration: 500.ms,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              const Text(
                'Daily Reward Claimed!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF183B56),
                ),
              )
                  .animate()
                  .fadeIn(
                delay: 250.ms,
                duration: 500.ms,
              )
                  .slideY(
                begin: 0.25,
                end: 0,
                curve: Curves.easeOut,
              ),

              const SizedBox(height: 8),

              const Text(
                'You received',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7A90),
                ),
              ),

              const SizedBox(height: 22),

              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _RewardItem(
                    emoji: '🪙',
                    value: '+100',
                    title: 'Coins',
                  ),
                  _RewardItem(
                    emoji: '⭐',
                    value: '+20',
                    title: 'Stars',
                  ),
                ],
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Awesome!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                    .animate(
                  onPlay: (controller) {
                    controller.repeat(reverse: true);
                  },
                )
                    .shimmer(
                  duration: 1800.ms,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardItem extends StatelessWidget {
  const _RewardItem({
    required this.emoji,
    required this.value,
    required this.title,
  });

  final String emoji;
  final String value;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 38),
          )
              .animate()
              .fadeIn(
            delay: 350.ms,
            duration: 350.ms,
          )
              .scale(
            begin: const Offset(0.20, 0.20),
            end: const Offset(1, 1),
            duration: 800.ms,
            curve: Curves.elasticOut,
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF183B56),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6B7A90),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}