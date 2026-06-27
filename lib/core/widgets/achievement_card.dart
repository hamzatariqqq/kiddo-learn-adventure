import 'package:flutter/material.dart';
import '../../app/theme/app_text_styles.dart';
import 'kiddo_card.dart';

class AchievementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const AchievementCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return KiddoCard(
      backgroundColor: color.withValues(alpha: 0.12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 40,
            color: color,
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.title,
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}