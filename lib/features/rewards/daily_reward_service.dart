import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyRewardStatus {
  const DailyRewardStatus({
    required this.canClaim,
    required this.remaining,
    required this.rewardStreak,
  });

  final bool canClaim;
  final Duration remaining;
  final int rewardStreak;
}

class DailyRewardService {
  DailyRewardService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const int coinsReward = 100;
  static const int starsReward = 20;

  static const Duration claimDelay =
  Duration(hours: 24);

  // These keys intentionally match the guest progress
  // keys used by LessonService.
  static const String _guestCoinsKey =
      'guest_coins';

  static const String _guestStarsKey =
      'guest_stars';

  static const String _guestRewardStreakKey =
      'guest_reward_streak';

  static const String _guestLastRewardClaimKey =
      'guest_last_reward_claim';

  DocumentReference<Map<String, dynamic>>?
  get _userDocument {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    return _firestore
        .collection('users')
        .doc(user.uid);
  }

  // =====================================================
  // REWARD STATUS
  // =====================================================

  Stream<DailyRewardStatus> watchRewardStatus() {
    final userDocument = _userDocument;

    // Guest user
    if (userDocument == null) {
      return _watchGuestRewardStatus();
    }

    // Firebase account
    return userDocument.snapshots().map(
          (snapshot) {
        final data =
            snapshot.data() ?? <String, dynamic>{};

        final lastRewardClaim =
        data['lastRewardClaim'] as Timestamp?;

        final rewardStreak =
        (data['rewardStreak'] ?? 0) as int;

        if (lastRewardClaim == null) {
          return DailyRewardStatus(
            canClaim: true,
            remaining: Duration.zero,
            rewardStreak: rewardStreak,
          );
        }

        final nextClaimTime =
        lastRewardClaim.toDate().add(
          claimDelay,
        );

        final remaining =
        nextClaimTime.difference(
          DateTime.now(),
        );

        return DailyRewardStatus(
          canClaim:
          remaining.isNegative ||
              remaining == Duration.zero,
          remaining: remaining.isNegative
              ? Duration.zero
              : remaining,
          rewardStreak: rewardStreak,
        );
      },
    );
  }

  Stream<DailyRewardStatus>
  _watchGuestRewardStatus() async* {
    yield await _getGuestRewardStatus();
  }

  Future<DailyRewardStatus>
  _getGuestRewardStatus() async {
    final prefs =
    await SharedPreferences.getInstance();

    final lastRewardClaimMilliseconds =
    prefs.getInt(
      _guestLastRewardClaimKey,
    );

    final rewardStreak =
        prefs.getInt(
          _guestRewardStreakKey,
        ) ??
            0;

    // Guest has never claimed before.
    if (lastRewardClaimMilliseconds == null) {
      return DailyRewardStatus(
        canClaim: true,
        remaining: Duration.zero,
        rewardStreak: rewardStreak,
      );
    }

    final lastRewardClaim =
    DateTime.fromMillisecondsSinceEpoch(
      lastRewardClaimMilliseconds,
    );

    final nextClaimTime =
    lastRewardClaim.add(claimDelay);

    final remaining =
    nextClaimTime.difference(
      DateTime.now(),
    );

    return DailyRewardStatus(
      canClaim:
      remaining.isNegative ||
          remaining == Duration.zero,
      remaining: remaining.isNegative
          ? Duration.zero
          : remaining,
      rewardStreak: rewardStreak,
    );
  }

  // =====================================================
  // CLAIM REWARD
  // =====================================================

  Future<bool> claimReward() async {
    final userDocument = _userDocument;

    // Guest
    if (userDocument == null) {
      return _claimGuestReward();
    }

    // Logged-in Firebase user
    return _claimFirebaseReward(
      userDocument,
    );
  }

  // =====================================================
  // FIREBASE ACCOUNT REWARD
  // =====================================================

  Future<bool> _claimFirebaseReward(
      DocumentReference<Map<String, dynamic>>
      userDocument,
      ) async {
    return _firestore.runTransaction<bool>(
          (transaction) async {
        final snapshot =
        await transaction.get(
          userDocument,
        );

        if (!snapshot.exists) {
          return false;
        }

        final data =
            snapshot.data() ??
                <String, dynamic>{};

        final now = DateTime.now();

        final lastRewardClaim =
        data['lastRewardClaim']
        as Timestamp?;

        final currentRewardStreak =
        (data['rewardStreak'] ?? 0)
        as int;

        if (lastRewardClaim != null) {
          final difference =
          now.difference(
            lastRewardClaim.toDate(),
          );

          if (difference < claimDelay) {
            return false;
          }
        }

        int newRewardStreak = 1;

        if (lastRewardClaim != null) {
          final difference =
          now.difference(
            lastRewardClaim.toDate(),
          );

          if (difference <
              const Duration(hours: 48)) {
            newRewardStreak =
                currentRewardStreak + 1;
          }
        }

        transaction.update(
          userDocument,
          {
            'coins':
            FieldValue.increment(
              coinsReward,
            ),
            'stars':
            FieldValue.increment(
              starsReward,
            ),
            'rewardStreak':
            newRewardStreak,
            'lastRewardClaim':
            Timestamp.fromDate(now),
          },
        );

        return true;
      },
    );
  }

  // =====================================================
  // GUEST REWARD
  // =====================================================

  Future<bool> _claimGuestReward() async {
    final prefs =
    await SharedPreferences.getInstance();

    final now = DateTime.now();

    final lastRewardClaimMilliseconds =
    prefs.getInt(
      _guestLastRewardClaimKey,
    );

    DateTime? lastRewardClaim;

    if (lastRewardClaimMilliseconds != null) {
      lastRewardClaim =
          DateTime.fromMillisecondsSinceEpoch(
            lastRewardClaimMilliseconds,
          );

      final difference =
      now.difference(
        lastRewardClaim,
      );

      // Reward already claimed during the
      // previous 24 hours.
      if (difference < claimDelay) {
        return false;
      }
    }

    final currentRewardStreak =
        prefs.getInt(
          _guestRewardStreakKey,
        ) ??
            0;

    int newRewardStreak = 1;

    if (lastRewardClaim != null) {
      final difference =
      now.difference(
        lastRewardClaim,
      );

      if (difference <
          const Duration(hours: 48)) {
        newRewardStreak =
            currentRewardStreak + 1;
      }
    }

    final currentCoins =
        prefs.getInt(_guestCoinsKey) ?? 0;

    final currentStars =
        prefs.getInt(_guestStarsKey) ?? 0;

    await prefs.setInt(
      _guestCoinsKey,
      currentCoins + coinsReward,
    );

    await prefs.setInt(
      _guestStarsKey,
      currentStars + starsReward,
    );

    await prefs.setInt(
      _guestRewardStreakKey,
      newRewardStreak,
    );

    await prefs.setInt(
      _guestLastRewardClaimKey,
      now.millisecondsSinceEpoch,
    );

    return true;
  }
}