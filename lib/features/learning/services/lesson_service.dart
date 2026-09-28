import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LessonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const int defaultStars = 10;
  static const int defaultCoins = 50;
  static const int defaultXp = 100;

  static const String _guestCompletedLessonsKey =
      'guest_completed_lesson_ids';

  static const String _guestStarsKey = 'guest_stars';
  static const String _guestCoinsKey = 'guest_coins';
  static const String _guestXpKey = 'guest_xp';
  static const String _guestLevelKey = 'guest_level';

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

    // ==========================
    // GUEST MODE
    // ==========================
    if (userDocument == null) {
      return _completeGuestLesson(
        lessonId: lessonId,
        starsEarned: starsEarned,
        coinsEarned: coinsEarned,
        xpEarned: xpEarned,
      );
    }

    // ==========================
    // LOGGED-IN USER
    // ==========================
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

      final newLevel = (newXp ~/ 500) + 1;

      final currentBadges = List<String>.from(
        data['badges'] ?? <String>[],
      );

      final newBadges = <String>[
        ...currentBadges,
      ];

      if (!newBadges.contains('first_lesson')) {
        newBadges.add('first_lesson');
      }

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

  Future<bool> _completeGuestLesson({
    required String lessonId,
    required int starsEarned,
    required int coinsEarned,
    required int xpEarned,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final completedLessons = prefs.getStringList(
      _guestCompletedLessonsKey,
    ) ??
        <String>[];

    // Don't give rewards twice for the same lesson.
    if (completedLessons.contains(lessonId)) {
      return false;
    }

    completedLessons.add(lessonId);

    final currentStars =
        prefs.getInt(_guestStarsKey) ?? 0;

    final currentCoins =
        prefs.getInt(_guestCoinsKey) ?? 0;

    final currentXp =
        prefs.getInt(_guestXpKey) ?? 0;

    final newXp = currentXp + xpEarned;
    final newLevel = (newXp ~/ 500) + 1;

    await prefs.setStringList(
      _guestCompletedLessonsKey,
      completedLessons,
    );

    await prefs.setInt(
      _guestStarsKey,
      currentStars + starsEarned,
    );

    await prefs.setInt(
      _guestCoinsKey,
      currentCoins + coinsEarned,
    );

    await prefs.setInt(
      _guestXpKey,
      newXp,
    );

    await prefs.setInt(
      _guestLevelKey,
      newLevel,
    );

    return true;
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

    // Guest progress
    if (userDocument == null) {
      final prefs =
      await SharedPreferences.getInstance();

      return prefs.getStringList(
        _guestCompletedLessonsKey,
      ) ??
          <String>[];
    }

    // Account progress
    final snapshot = await userDocument.get();

    if (!snapshot.exists) {
      return [];
    }

    final data = snapshot.data();

    return List<String>.from(
      data?['completedLessonIds'] ??
          <String>[],
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

    // Guest mode
    if (userDocument == null) {
      return Stream.fromFuture(
        getCompletedLessons(),
      );
    }

    // Logged-in account
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

  // ==========================
  // GUEST STATS
  // ==========================

  Future<int> getGuestStars() async {
    final prefs =
    await SharedPreferences.getInstance();

    return prefs.getInt(_guestStarsKey) ?? 0;
  }

  Future<int> getGuestCoins() async {
    final prefs =
    await SharedPreferences.getInstance();

    return prefs.getInt(_guestCoinsKey) ?? 0;
  }

  Future<int> getGuestXp() async {
    final prefs =
    await SharedPreferences.getInstance();

    return prefs.getInt(_guestXpKey) ?? 0;
  }

  Future<int> getGuestLevel() async {
    final prefs =
    await SharedPreferences.getInstance();

    return prefs.getInt(_guestLevelKey) ?? 1;
  }
}