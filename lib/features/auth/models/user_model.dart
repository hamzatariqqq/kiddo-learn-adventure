import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.stars,
    required this.completedLessons,
    required this.streak,
    this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final int stars;
  final int completedLessons;
  final int streak;
  final Timestamp? createdAt;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      stars: map['stars'] ?? 0,
      completedLessons: map['completedLessons'] ?? 0,
      streak: map['streak'] ?? 0,
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'stars': stars,
      'completedLessons': completedLessons,
      'streak': streak,
      'createdAt': createdAt,
    };
  }
}