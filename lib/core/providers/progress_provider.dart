import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/progress_model.dart';

final progressProvider =
NotifierProvider<ProgressNotifier, ProgressModel>(
  ProgressNotifier.new,
);

class ProgressNotifier extends Notifier<ProgressModel> {
  static const String _starsKey = 'stars';
  static const String _completedLessonsKey = 'completedLessons';

  @override
  ProgressModel build() {
    _loadProgress();

    return const ProgressModel(
      stars: 0,
      completedLessons: 0,
    );
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();

    final stars = prefs.getInt(_starsKey) ?? 0;
    final completedLessons = prefs.getInt(_completedLessonsKey) ?? 0;

    state = ProgressModel(
      stars: stars,
      completedLessons: completedLessons,
    );
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_starsKey, state.stars);
    await prefs.setInt(_completedLessonsKey, state.completedLessons);
  }

  void addStars(int amount) {
    state = ProgressModel(
      stars: state.stars + amount,
      completedLessons: state.completedLessons,
    );

    _saveProgress();
  }

  void completeLesson() {
    state = ProgressModel(
      stars: state.stars + 10,
      completedLessons: state.completedLessons + 1,
    );

    _saveProgress();
  }

  void resetProgress() {
    state = const ProgressModel(
      stars: 0,
      completedLessons: 0,
    );

    _saveProgress();
  }
}