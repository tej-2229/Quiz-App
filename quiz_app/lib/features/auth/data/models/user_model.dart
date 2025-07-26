import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String fullName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int quizzesCompleted;
  final double averageScore;
  final int dayStreak;

  AppUser({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.createdAt,
    required this.updatedAt,
    this.quizzesCompleted = 0,
    this.averageScore = 0,
    this.dayStreak = 0,
  });

  factory AppUser.fromFirestore(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      quizzesCompleted: data['quizzesCompleted'] ?? 0,
      averageScore: data['averageScore']?.toDouble() ?? 0,
      dayStreak: data['dayStreak'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'quizzesCompleted': quizzesCompleted,
      'averageScore': averageScore,
      'dayStreak': dayStreak,
    };
  }
}