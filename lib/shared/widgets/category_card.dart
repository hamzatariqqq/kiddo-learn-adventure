import 'package:flutter/material.dart';

import '../../app/theme/app_text_styles.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String lessonCount;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.lessonCount,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: color),

            const SizedBox(height: 12),

            Text(
              title,
              style: AppTextStyles.title,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 6),

            Text(lessonCount, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
