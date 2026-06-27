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
      description: 'Complete 5 lessons',
      icon: Icons.star_rounded,
      color: AppColors.yellow,
      requiredLessons: 5,
    ),
    BadgeModel(
      title: 'Super Learner',
      description: 'Complete 10 lessons',
      icon: Icons.emoji_events_rounded,
      color: AppColors.primaryBlue,
      requiredLessons: 10,
    ),
    BadgeModel(
      title: 'Master Explorer',
      description: 'Complete 25 lessons',
      icon: Icons.rocket_launch_rounded,
      color: AppColors.purple,
      requiredLessons: 25,
    ),
  ];
}