import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import 'kiddo_card.dart';

class ProgressSummaryCard extends StatelessWidget {
  final int completedLessons;
  final int totalLessons;
  final int streakDays;

  const ProgressSummaryCard({
    super.key,
    required this.completedLessons,
    required this.totalLessons,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = completedLessons / totalLessons;

    return KiddoCard(
      backgroundColor: AppColors.softYellowBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today’s Progress',
            style: AppTextStyles.title,
          ),
          const SizedBox(height: 12),

          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(20),
            backgroundColor: AppColors.white,
            color: AppColors.orange,
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completedLessons / $totalLessons lessons',
                style: AppTextStyles.bodySmall,
              ),
              Text(
                '🔥 $streakDays day streak',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}