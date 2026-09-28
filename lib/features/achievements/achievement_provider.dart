import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/progress_provider.dart';
import '../auth/providers/user_provider.dart';
import '../learning/services/lesson_service.dart';
import 'achievement_model.dart';
import 'achievement_service.dart';

final achievementServiceProvider =
Provider<AchievementService>((ref) {
  return AchievementService();
});

final achievementsProvider =
FutureProvider<List<AchievementModel>>((ref) async {
  final user =
  await ref.watch(currentUserProvider.future);

  final service =
  ref.read(achievementServiceProvider);

  // =====================================================
  // LOGGED-IN USER
  // =====================================================

  if (user != null) {
    return service.getAchievements(
      user.badges,
    );
  }

  // =====================================================
  // GUEST USER
  // =====================================================

  // Watch local progress so achievements refresh when
  // guest progress is refreshed/reset.
  ref.watch(progressProvider);

  final lessonService = LessonService();

  final completedLessons =
  await lessonService.getCompletedLessons();

  final guestBadges = <String>[];

  // First completed lesson.
  if (completedLessons.isNotEmpty) {
    guestBadges.add('first_lesson');
  }

  // Lesson-specific achievements.
  if (completedLessons.contains('alphabet')) {
    guestBadges.add('alphabet_master');
  }

  if (completedLessons.contains('numbers')) {
    guestBadges.add('number_master');
  }

  if (completedLessons.contains('animals')) {
    guestBadges.add('animal_explorer');
  }

  if (completedLessons.contains('colors')) {
    guestBadges.add('color_genius');
  }

  return service.getAchievements(
    guestBadges,
  );
});