import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.stars,
    required this.coins,
    required this.xp,
    required this.level,
    required this.completedLessons,
    required this.streak,
    required this.rewardStreak,
    required this.completedLessonIds,
    required this.badges,
    required this.isPremium,
    this.createdAt,
    this.lastLogin,
    this.lastRewardClaim,
    this.premiumActivatedAt,
  });

  final String uid;
  final String name;
  final String email;

  final int stars;
  final int coins;
  final int xp;
  final int level;

  final int completedLessons;
  final int streak;
  final int rewardStreak;

  final List<String> completedLessonIds;
  final List<String> badges;

  final bool isPremium;

  final Timestamp? createdAt;
  final Timestamp? lastLogin;
  final Timestamp? lastRewardClaim;
  final Timestamp? premiumActivatedAt;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      stars: map['stars'] ?? 0,
      coins: map['coins'] ?? 0,
      xp: map['xp'] ?? 0,
      level: map['level'] ?? 1,
      completedLessons: map['completedLessons'] ?? 0,
      streak: map['streak'] ?? 0,
      rewardStreak: map['rewardStreak'] ?? 0,
      completedLessonIds: List<String>.from(
        map['completedLessonIds'] ?? <String>[],
      ),
      badges: List<String>.from(
        map['badges'] ?? <String>[],
      ),
      isPremium: map['isPremium'] ?? false,
      createdAt: map['createdAt'] as Timestamp?,
      lastLogin: map['lastLogin'] as Timestamp?,
      lastRewardClaim: map['lastRewardClaim'] as Timestamp?,
      premiumActivatedAt:
      map['premiumActivatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'stars': stars,
      'coins': coins,
      'xp': xp,
      'level': level,
      'completedLessons': completedLessons,
      'streak': streak,
      'rewardStreak': rewardStreak,
      'completedLessonIds': completedLessonIds,
      'badges': badges,
      'isPremium': isPremium,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
      'lastRewardClaim': lastRewardClaim,
      'premiumActivatedAt': premiumActivatedAt,
    };
  }
}