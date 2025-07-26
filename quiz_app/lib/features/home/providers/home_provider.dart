import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/features/auth/providers/auth_provider.dart';

final userStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return {};

  return {
    'quizzesCompleted': user.quizzesCompleted,
    'averageScore': user.averageScore,
    'dayStreak': user.dayStreak,
  };
});