import 'package:flutter/material.dart';

import 'achievement_model.dart';

class AchievementCard extends StatelessWidget {
  const AchievementCard({required this.achievement, super.key});

  final AchievementModel achievement;

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unlocked
            ? achievement.color.withValues(alpha: 0.14)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: unlocked
              ? achievement.color.withValues(alpha: 0.45)
              : Colors.grey.shade300,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: unlocked
                ? achievement.color
                : Colors.grey.shade400,
            child: Icon(
              unlocked ? achievement.icon : Icons.lock_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            unlocked ? achievement.description : 'Locked',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
