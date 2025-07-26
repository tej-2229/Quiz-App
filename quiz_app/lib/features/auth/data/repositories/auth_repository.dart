import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_app/features/auth/data/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._auth, this._firestore);

  Stream<AppUser?> get user {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      return doc.exists ? AppUser.fromFirestore(doc.data()!) : null;
    });
  }

  Future<void> updateUserStats({
    required String userId,
    required int score,
  }) async {
    final userRef = _firestore.collection('users').doc(userId);
    final userDoc = await userRef.get();

    if (!userDoc.exists) return;

    final userData = userDoc.data()!;
    final user = AppUser.fromFirestore(userData);

    final lastQuizTimestamp = userData['lastQuizDate'] as Timestamp?;
    final lastQuizDate = lastQuizTimestamp?.toDate();
    final now = DateTime.now();

    final isNewDay = lastQuizDate == null || now.difference(lastQuizDate).inDays >= 1;

    final newAverageScore = ((user.averageScore * user.quizzesCompleted) + score) /
        (user.quizzesCompleted + 1);

    await userRef.update({
      'quizzesCompleted': FieldValue.increment(1),
      'averageScore': newAverageScore,
      'dayStreak': isNewDay ? user.dayStreak + 1 : user.dayStreak,
      'lastQuizDate': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
  }
}
