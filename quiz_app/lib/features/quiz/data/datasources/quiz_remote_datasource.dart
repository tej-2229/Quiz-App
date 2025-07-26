import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/features/quiz/data/models/quiz_category_model.dart';
import '../models/question_model.dart';

class QuizRemoteDataSource {
  final FirebaseFirestore _firestore;

  QuizRemoteDataSource(this._firestore);

  Future<List<QuizCategory>> getCategories() async {
    try {
      debugPrint("Fetching categories from Firestore...");
      final categoriesSnapshot = await _firestore.collection('trivia_categories').get();
      
      debugPrint("Found ${categoriesSnapshot.docs.length} categories");
      
      final categories = <QuizCategory>[];
      
      for (final categoryDoc in categoriesSnapshot.docs) {
        final questionCount = await _getQuestionCount(categoryDoc.id);
        final category = QuizCategory(
          id: categoryDoc.id,
          name: categoryDoc['category_name'] ?? 'Unnamed Category',
          icon: _getCategoryIcon(categoryDoc['category_name']),
          questionCount: questionCount,
        );
        categories.add(category);
        debugPrint("Added category: ${category.name} with ${category.questionCount} questions");
      }
      
      return categories;
    } catch (e) {
      debugPrint("Error fetching categories: $e");
      throw Exception('Failed to get categories: $e');
    }
  }

  Stream<List<Question>> getQuestionsForCategory(String categoryId) {
    try {
      return _firestore
          .collection('trivia_categories')
          .doc(categoryId)
          .collection('questions')
          .snapshots()
          .map((snapshot) => snapshot.docs.map(_mapToQuestion).toList());
    } catch (e) {
      debugPrint("Error fetching questions: $e");
      throw Exception('Failed to get questions: $e');
    }
  }

  // Alternative method to count questions that works in all versions
  Future<int> _getQuestionCount(String categoryId) async {
    try {
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