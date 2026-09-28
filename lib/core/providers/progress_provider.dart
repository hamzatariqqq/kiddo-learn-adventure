import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/progress_model.dart';

final progressProvider =
NotifierProvider<ProgressNotifier, ProgressModel>(
  ProgressNotifier.new,
);

class ProgressNotifier extends Notifier<ProgressModel> {
  // Existing/local account progress keys.
  static const String _starsKey = 'stars';
  static const String _completedLessonsKey =
      'completedLessons';

  // Guest progress keys used by LessonService.
  static const String _guestStarsKey = 'guest_stars';
  static const String _guestCompletedLessonsKey =
      'guest_completed_lesson_ids';

  bool get _isGuest =>
      FirebaseAuth.instance.currentUser == null;

  @override
  ProgressModel build() {
    _loadProgress();

    return const ProgressModel(
      stars: 0,
      completedLessons: 0,
    );
  }

  Future<void> _loadProgress() async {
    final prefs =
    await SharedPreferences.getInstance();

    if (_isGuest) {
      final stars =
          prefs.getInt(_guestStarsKey) ?? 0;

      final completedLessonIds =
          prefs.getStringList(
            _guestCompletedLessonsKey,
          ) ??
              <String>[];

      state = ProgressModel(
        stars: stars,
        completedLessons:
        completedLessonIds.length,
      );

      return;
    }

    final stars =
        prefs.getInt(_starsKey) ?? 0;

    final completedLessons =
        prefs.getInt(
          _completedLessonsKey,
        ) ??
            0;

    state = ProgressModel(
      stars: stars,
      completedLessons: completedLessons,
    );
  }

  Future<void> refreshProgress() async {
    await _loadProgress();
  }

  Future<void> _saveProgress() async {
    final prefs =
    await SharedPreferences.getInstance();

    if (_isGuest) {
      await prefs.setInt(
        _guestStarsKey,
        state.stars,
      );

      return;
    }

    await prefs.setInt(
      _starsKey,
      state.stars,
    );

    await prefs.setInt(
      _completedLessonsKey,
      state.completedLessons,
    );
  }

  void addStars(int amount) {
    state = ProgressModel(
      stars: state.stars + amount,
      completedLessons:
      state.completedLessons,
    );

    _saveProgress();
  }

  void completeLesson() {
    state = ProgressModel(
      stars: state.stars + 10,
      completedLessons:
      state.completedLessons + 1,
    );

    _saveProgress();
  }

  void resetProgress() {
    state = const ProgressModel(
      stars: 0,
      completedLessons: 0,
    );

    _resetStoredProgress();
  }

  Future<void> _resetStoredProgress() async {
    final prefs =
    await SharedPreferences.getInstance();

    if (_isGuest) {
      await prefs.remove(
        _guestCompletedLessonsKey,
      );

      await prefs.setInt(
        _guestStarsKey,
        0,
      );

      return;
    }

    await prefs.setInt(
      _starsKey,
      0,
    );

    await prefs.setInt(
      _completedLessonsKey,
      0,
    );
  }
}