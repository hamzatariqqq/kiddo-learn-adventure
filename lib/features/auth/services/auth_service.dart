import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = credential.user;

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set(
        {
          'lastLogin': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    return credential;
  }

  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = credential.user;

    if (user != null) {
      await user.updateDisplayName(name.trim());

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),

        // Rewards
        'coins': 0,
        'xp': 0,
        'level': 1,
        'rewardStreak': 0,
        'lastRewardClaim': null,

        // Progress
        'stars': 0,
        'completedLessons': 0,
        'streak': 0,
        'completedLessonIds': <String>[],

        // Achievements
        'badges': <String>[],

        // Premium
        'isPremium': false,
        'premiumActivatedAt': null,

        // Dates
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
    }

    return credential;
  }

  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    final cleanEmail = email.trim();

    if (cleanEmail.isEmpty) {
      throw Exception(
        'Please enter your email address.',
      );
    }

    await _auth.sendPasswordResetEmail(
      email: cleanEmail,
    );
  }

  Future<void> deleteAccount({
    required String password,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No signed-in user was found.',
      );
    }

    final email = user.email;

    if (email == null || email.isEmpty) {
      throw Exception(
        'This account does not have an email address.',
      );
    }

    if (password.trim().isEmpty) {
      throw Exception(
        'Please enter your password.',
      );
    }

    // Firebase requires recent authentication
    // before deleting an account.
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password.trim(),
    );

    await user.reauthenticateWithCredential(
      credential,
    );

    // Delete the users Firestore document.
    await _firestore
        .collection('users')
        .doc(user.uid)
        .delete();

    // Delete Firebase Authentication account.
    await user.delete();
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}