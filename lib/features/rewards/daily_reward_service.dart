import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  DailyRewardService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const int coinsReward = 100;
  static const int starsReward = 20;
  static const Duration claimDelay = Duration(hours: 24);

  DocumentReference<Map<String, dynamic>>? get _userDocument {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    return _firestore.collection('users').doc(user.uid);
  }

  Stream<DailyRewardStatus> watchRewardStatus() {
    final userDocument = _userDocument;

    if (userDocument == null) {
      return Stream.value(
        const DailyRewardStatus(
          canClaim: false,
          remaining: Duration.zero,
          rewardStreak: 0,
        ),
      );
    }

    return userDocument.snapshots().map((snapshot) {
      final data = snapshot.data() ?? <String, dynamic>{};

      final lastRewardClaim = data['lastRewardClaim'] as Timestamp?;
      final rewardStreak = data['rewardStreak'] ?? 0;

      if (lastRewardClaim == null) {
        return DailyRewardStatus(
          canClaim: true,
          remaining: Duration.zero,
          rewardStreak: rewardStreak,
        );
      }

      final nextClaimTime = lastRewardClaim.toDate().add(claimDelay);
      final remaining = nextClaimTime.difference(DateTime.now());

      return DailyRewardStatus(
        canClaim: remaining.isNegative || remaining == Duration.zero,
        remaining: remaining.isNegative ? Duration.zero : remaining,
        rewardStreak: rewardStreak,
      );
    });
  }

  Future<bool> claimReward() async {
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
      final now = DateTime.now();

      final lastRewardClaim = data['lastRewardClaim'] as Timestamp?;
      final currentRewardStreak = data['rewardStreak'] ?? 0;

      if (lastRewardClaim != null) {
        final difference = now.difference(lastRewardClaim.toDate());

        if (difference < claimDelay) {
          return false;
        }
      }

      int newRewardStreak = 1;

      if (lastRewardClaim != null) {
        final difference = now.difference(lastRewardClaim.toDate());

        if (difference < const Duration(hours: 48)) {
          newRewardStreak = currentRewardStreak + 1;
        }
      }

      transaction.update(userDocument, {
        'coins': FieldValue.increment(coinsReward),
        'stars': FieldValue.increment(starsReward),
        'rewardStreak': newRewardStreak,
        'lastRewardClaim': Timestamp.fromDate(now),
      });

      return true;
    });
  }
}
