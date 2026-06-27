import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../models/badge_model.dart';
import 'kiddo_card.dart';

class BadgeCard extends StatelessWidget {
  final BadgeModel badge;
  final bool isUnlocked;

  const BadgeCard({
    super.key,
    required this.badge,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final Color badgeColor =
    isUnlocked ? badge.color : AppColors.textLight;

    return KiddoCard(
      backgroundColor: badgeColor.withValues(alpha: 0.12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUnlocked ? badge.icon : Icons.lock_rounded,
            color: badgeColor,
            size: 36,
          ),

          const SizedBox(height: 8),

          Text(
            badge.title,
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 6),

          Text(
            isUnlocked ? 'Unlocked' : badge.description,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}