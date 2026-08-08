import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'badge_model.dart';

class BadgeData {
  static const List<BadgeModel> badges = [
    BadgeModel(
      title: 'Beginner Learner',
      description: 'Complete 1 lesson',
      icon: Icons.workspace_premium_rounded,
      color: AppColors.orange,
      requiredLessons: 1,
    ),
    BadgeModel(
      title: 'Learning Star',
      description: 'Complete 2 lessons',
      icon: Icons.star_rounded,
      color: AppColors.yellow,
      requiredLessons: 2,
    ),
    BadgeModel(
      title: 'Super Learner',
      description: 'Complete 3 lessons',
      icon: Icons.emoji_events_rounded,
      color: AppColors.primaryBlue,
      requiredLessons: 3,
    ),
    BadgeModel(
      title: 'Master Explorer',
      description: 'Complete 4 lessons',
      icon: Icons.rocket_launch_rounded,
      color: AppColors.purple,
      requiredLessons: 4,
    ),
  ];
}
