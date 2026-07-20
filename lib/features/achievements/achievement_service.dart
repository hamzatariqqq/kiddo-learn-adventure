import 'package:flutter/material.dart';

import 'achievement_model.dart';

class AchievementService {
  List<AchievementModel> getAchievements(List<String> unlockedBadges) {
    return [
      AchievementModel(
        id: 'first_lesson',
        title: 'First Lesson',
        description: 'Complete your first lesson.',
        icon: Icons.emoji_events_rounded,
        color: Colors.amber,
        isUnlocked: unlockedBadges.contains('first_lesson'),
      ),
      AchievementModel(
        id: 'alphabet_master',
        title: 'Alphabet Master',
        description: 'Complete the alphabet lesson.',
        icon: Icons.abc_rounded,
        color: Colors.blue,
        isUnlocked: unlockedBadges.contains('alphabet_master'),
      ),
      AchievementModel(
        id: 'number_master',
        title: 'Number Master',
        description: 'Complete the numbers lesson.',
        icon: Icons.numbers_rounded,
        color: Colors.orange,
        isUnlocked: unlockedBadges.contains('number_master'),
      ),
      AchievementModel(
        id: 'animal_explorer',
        title: 'Animal Explorer',
        description: 'Complete the animals lesson.',
        icon: Icons.pets_rounded,
        color: Colors.green,
        isUnlocked: unlockedBadges.contains('animal_explorer'),
      ),
      AchievementModel(
        id: 'color_genius',
        title: 'Color Genius',
        description: 'Complete the colors lesson.',
        icon: Icons.palette_rounded,
        color: Colors.purple,
        isUnlocked: unlockedBadges.contains('color_genius'),
      ),
    ];
  }
}
