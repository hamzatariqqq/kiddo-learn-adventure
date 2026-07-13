import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LessonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> completeLesson({
    required String lessonId,
    required int starsEarned,
  }) async {
    final user = _auth.currentUser;

    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'stars': FieldValue.increment(starsEarned),
      'completedLessons': FieldValue.increment(1),
      'streak': FieldValue.increment(1),
      'completedLessonIds': FieldValue.arrayUnion([lessonId]),
    });
  }

  Future<bool> isLessonCompleted(String lessonId) async {
    final user = _auth.currentUser;

    if (user == null) return false;

    final doc =
    await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) return false;

    final data = doc.data();

    final completed =
    List<String>.from(data?['completedLessonIds'] ?? []);

    return completed.contains(lessonId);
  }

  Future<List<String>> getCompletedLessons() async {
    final user = _auth.currentUser;

    if (user == null) return [];

    final doc =
    await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) return [];

    final data = doc.data();

    return List<String>.from(data?['completedLessonIds'] ?? []);
  }
}