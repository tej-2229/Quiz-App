import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/features/quiz/data/models/quiz_category_model.dart';
import 'package:quiz_app/features/quiz/data/repositories/quiz_repository.dart';
import 'package:quiz_app/features/quiz/data/models/question_model.dart';

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository(FirebaseFirestore.instance);
});

// final categoriesProvider = StreamProvider<List<QuizCategory>>((ref) {
//   return ref.watch(quizRepositoryProvider).getCategories();
// });

final categoriesProvider = StreamProvider<List<QuizCategory>>((ref) {
  final repository = ref.read(quizRepositoryProvider);
  return repository.getCategories();
});

// final categoryQuestionsProvider = StreamProvider.family<List<Question>, String>((ref, categoryId) {
//   return ref.watch(quizRepositoryProvider).getQuestionsForCategory(categoryId);
// });

final categoryQuestionsProvider = StreamProvider.family<List<Question>, String>((ref, categoryId) {
  final repository = ref.read(quizRepositoryProvider);
  return repository.getQuestionsForCategory(categoryId);
});

final quizControllerProvider = StateNotifierProvider<QuizController, AsyncValue<void>>((ref) {
  return QuizController(ref.read(quizRepositoryProvider));
});


class QuizController extends StateNotifier<AsyncValue<void>> {
  final QuizRepository _repository;

  QuizController(this._repository) : super(const AsyncValue.data(null));

  Future<void> updateUserStats({
    required String userId,
    required int score,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateUserStats(userId: userId, score: score);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}