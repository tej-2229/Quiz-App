import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:quiz_app/features/quiz/data/models/question_model.dart';
import 'package:quiz_app/features/quiz/data/models/quiz_category_model.dart';

class QuizRepository {
  final FirebaseFirestore _firestore;

  QuizRepository(this._firestore);

  Stream<List<QuizCategory>> getCategories() async* {
  try {
    final categoriesSnapshot = await _firestore.collection('trivia_categories').get();
    
    // Collect all categories first
    final categories = <QuizCategory>[];
    
    // Get question counts for all categories
    for (final categoryDoc in categoriesSnapshot.docs) {
      final questionsCount = await _getQuestionCount(categoryDoc.id);
      categories.add(
        QuizCategory(
          id: categoryDoc.id,
          name: categoryDoc['category_name'] ?? 'Unknown',
          icon: _getCategoryIcon(categoryDoc['category_name']),
          questionCount: questionsCount,
        )
      );
    }
    
    // Yield the complete list once all counts are done
    yield categories;
  } catch (e) {
    debugPrint("Error getting categories: $e");
    yield [];  // Return empty list on error
  }
}

 

  Stream<List<Question>> getQuestionsForCategory(String categoryId) {
    return _firestore
        .collection('trivia_categories')
        .doc(categoryId)
        .collection('questions')
        .snapshots()
        .handleError((error) {
          debugPrint("Error getting questions: $error");
          return [];  // Return empty list on error
        })
        .map((snapshot) => snapshot.docs.map(_mapToQuestion).toList());
  }

  Future<int> _getQuestionCount(String categoryId) async {
    try {
      // Method 1: Using count query (requires Firestore ^4.8.0)
      // final snapshot = await _firestore
      //     .collection('trivia_categories')
      //     .doc(categoryId)
      //     .collection('questions')
      //     .count()
      //     .get();
      // return snapshot.count;

      // Method 2: Works in all versions (less efficient for large collections)
      final querySnapshot = await _firestore
          .collection('trivia_categories')
          .doc(categoryId)
          .collection('questions')
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      debugPrint("Error counting questions: $e");
      return 0;
    }
  }

  Question _mapToQuestion(QueryDocumentSnapshot doc) {
    return Question(
      id: doc.id,
      question: doc['question'] ?? '',
      options: List<String>.from(doc['options'] ?? []),
      correctAnswer: doc['correctAnswer'] ?? '',
    );
  }

  Future<void> updateUserStats({
    required String userId,
    required int score,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) return;

        final currentData = userDoc.data() as Map<String, dynamic>;
        final currentQuizzes = currentData['quizzesCompleted'] ?? 0;
        final currentAverage = currentData['averageScore']?.toDouble() ?? 0;
        final currentStreak = currentData['dayStreak'] ?? 0;

        // Calculate new average score
        final newAverage = ((currentAverage * currentQuizzes) + score) / (currentQuizzes + 1);

        // Check if streak should be incremented
        final now = DateTime.now();
        final lastUpdated = (currentData['updatedAt'] as Timestamp).toDate();
        final isNewDay = now.difference(lastUpdated).inDays >= 1;
        final newStreak = isNewDay ? currentStreak + 1 : currentStreak;

        transaction.update(userRef, {
          'quizzesCompleted': currentQuizzes + 1,
          'averageScore': newAverage,
          'dayStreak': newStreak,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      debugPrint("Error updating user stats: $e");
      rethrow;
    }
  }

  String _getCategoryIcon(String? categoryName) {
    if (categoryName == null) return '❓';
    
    switch (categoryName) {
      case 'Science': return '🔬';
      case 'History': return '🏛️';
      case 'Sports': return '⚽';
      case 'Movies': return '🎬';
      case 'Geography': return '🌍';
      case 'Technology': return '💻';
      default: return '❓';
    }
  }
}