import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme/app_colors.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.title,
    required this.lessonCount,
    required this.icon,
    required this.color,
    this.onTap,
    this.isLocked = false,
  });

  final String title;
  final String lessonCount;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final displayColor = isLocked ? AppColors.textLight : color;

    return InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: isLocked ? null : onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.surfaceLight, AppColors.deepNavy],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isLocked
                    ? AppColors.border
                    : AppColors.gold.withValues(alpha: 0.40),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.32),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -18,
                  top: -18,
                  child: Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: displayColor.withValues(alpha: 0.15),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(17),
                  child: Column(
                    children: [
                      Container(
                            width: 66,
                            height: 66,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  displayColor,
                                  displayColor.withValues(alpha: 0.65),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: AppColors.gold.withValues(alpha: 0.65),
                                width: 1.4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: displayColor.withValues(alpha: 0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: Icon(
                              isLocked ? Icons.lock_rounded : icon,
                              color: AppColors.white,
                              size: 34,
                            ),
                          )
                          .animate(
                            onPlay: isLocked
                                ? null
                                : (controller) =>
                                      controller.repeat(reverse: true),
                          )
                          .scaleXY(begin: 0.96, end: 1.04, duration: 1500.ms),

                      const Spacer(),

                      Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        isLocked ? 'Complete previous adventure' : lessonCount,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                if (!isLocked)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      width: 27,
                      height: 27,
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.deepNavy,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        )
        .animate()
        .fade(duration: 450.ms)
        .slideY(begin: 0.18, end: 0, duration: 450.ms);
  }
}
