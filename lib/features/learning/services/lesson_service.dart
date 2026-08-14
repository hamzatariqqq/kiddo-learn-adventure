import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LessonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Standard reward for every lesson.
  static const int defaultStars = 10;
  static const int defaultCoins = 50;
  static const int defaultXp = 100;

  DocumentReference<Map<String, dynamic>>? get _userDocument {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    return _firestore.collection('users').doc(user.uid);
  }

  Future<bool> completeLesson({
    required String lessonId,
    int starsEarned = defaultStars,
    int coinsEarned = defaultCoins,
    int xpEarned = defaultXp,
  }) async {
    final userDocument = _userDocument;

    if (userDocument == null) {
      return false;
    }

    return _firestore.runTransaction<bool>((transaction) async {
      final snapshot = await transaction.get(userDocument);

      if (!snapshot.exists) {
        return false;
      }

      final data = snapshot.data() ?? <String, dynamic>{};

      final completedLessonIds = List<String>.from(
        data['completedLessonIds'] ?? <String>[],
      );

      // Prevent duplicate rewards.
      if (completedLessonIds.contains(lessonId)) {
        return false;
      }

      final currentXp = (data['xp'] ?? 0) as int;
      final newXp = currentXp + xpEarned;

      // Every 500 XP increases the level.
      final newLevel = (newXp ~/ 500) + 1;

      final currentBadges = List<String>.from(
        data['badges'] ?? <String>[],
      );

      final newBadges = <String>[
        ...currentBadges,
      ];

      // First lesson badge.
      if (!newBadges.contains('first_lesson')) {
        newBadges.add('first_lesson');
      }

      // Lesson-specific badges.
      if (lessonId == 'alphabet' &&
          !newBadges.contains('alphabet_master')) {
        newBadges.add('alphabet_master');
      }

      if (lessonId == 'numbers' &&
          !newBadges.contains('number_master')) {
        newBadges.add('number_master');
      }

      if (lessonId == 'animals' &&
          !newBadges.contains('animal_explorer')) {
        newBadges.add('animal_explorer');
      }

      if (lessonId == 'colors' &&
          !newBadges.contains('color_genius')) {
        newBadges.add('color_genius');
      }

      transaction.update(
        userDocument,
        {
          'stars': FieldValue.increment(starsEarned),
          'coins': FieldValue.increment(coinsEarned),
          'xp': newXp,
          'level': newLevel,
          'completedLessons': FieldValue.increment(1),
          'streak': FieldValue.increment(1),
          'completedLessonIds': FieldValue.arrayUnion(
            [lessonId],
          ),
          'badges': newBadges,
          'lastLessonCompletedAt':
          FieldValue.serverTimestamp(),
        },
      );

      return true;
    });
  }

  Future<bool> isLessonCompleted(
      String lessonId,
      ) async {
    final completedLessons =
    await getCompletedLessons();

    return completedLessons.contains(lessonId);
  }

  Future<List<String>> getCompletedLessons() async {
    final userDocument = _userDocument;

    if (userDocument == null) {
      return [];
    }

    final snapshot = await userDocument.get();

    if (!snapshot.exists) {
      return [];
    }

    final data = snapshot.data();

    return List<String>.from(
      data?['completedLessonIds'] ?? <String>[],
    );
  }

  Future<bool> isLessonUnlocked({
    required String lessonId,
    String? requiredPreviousLessonId,
  }) async {
    if (requiredPreviousLessonId == null) {
      return true;
    }

    return isLessonCompleted(
      requiredPreviousLessonId,
    );
  }

  Stream<List<String>> watchCompletedLessons() {
    final userDocument = _userDocument;

    if (userDocument == null) {
      return Stream.value([]);
    }

    return userDocument.snapshots().map(
          (snapshot) {
        final data = snapshot.data();

        return List<String>.from(
          data?['completedLessonIds'] ??
              <String>[],
        );
      },
    );
  }
}