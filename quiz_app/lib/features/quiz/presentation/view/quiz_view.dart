import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/features/auth/providers/auth_provider.dart';
import 'package:quiz_app/features/quiz/data/models/question_model.dart';
import 'package:quiz_app/features/quiz/presentation/view/result_view.dart';
import 'package:quiz_app/features/quiz/providers/quiz_providers.dart';

class QuizView extends ConsumerStatefulWidget {
  final String categoryId;
  final String categoryName;

  const QuizView({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  ConsumerState<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends ConsumerState<QuizView> with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  int _score = 0;
  int _timeLeft = 30;
  late AnimationController _timerController;
  bool _isNextButtonEnabled = false;
  late List<Question> _questions;
  bool _showAnswerFeedback = false;
  int? _correctAnswerIndex;
  int _correctAnswersCount = 0;
  int _incorrectAnswersCount = 0;
  int _totalTimeSpent = 0;
  DateTime? _questionStartTime;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..addListener(() {
        setState(() {
          _timeLeft = 30 - (_timerController.value * 30).round();
          if (_timeLeft <= 0) {
            _moveToNextQuestion();
          }
        });
      });
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  void _selectAnswer(int index) {
    if (_showAnswerFeedback) return;

    // Record time spent on this question
    if (_questionStartTime != null) {
      _totalTimeSpent += DateTime.now().difference(_questionStartTime!).inSeconds;
    }

    setState(() {
      _selectedAnswerIndex = index;
      _showAnswerFeedback = true;
      
      // Find the correct answer index
      _correctAnswerIndex = _questions[_currentQuestionIndex].options
          .indexOf(_questions[_currentQuestionIndex].correctAnswer);
      
      // Update correct/incorrect counts
      if (_selectedAnswerIndex == _correctAnswerIndex) {
        _correctAnswersCount++;
      } else {
        _incorrectAnswersCount++;
      }
    });
  }

  void _moveToNextQuestion() {
    if (!_showAnswerFeedback && _selectedAnswerIndex == null && _timeLeft > 0) return;

    setState(() {
      // Check if answer was correct
      if (_selectedAnswerIndex != null && 
          _questions[_currentQuestionIndex].options[_selectedAnswerIndex!] == 
          _questions[_currentQuestionIndex].correctAnswer) {
        _score += 1;
      }

      // Move to next question or end quiz
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _showAnswerFeedback = false;
        _correctAnswerIndex = null;
        _questionStartTime = DateTime.now();
        _timerController.reset();
        _timerController.forward();
      } else {
        // Quiz completed
        _completeQuiz();
      }
    });
  }

  Future<void> _completeQuiz() async {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      await ref.read(quizControllerProvider.notifier).updateUserStats(
        userId: user.uid,
        score: _score,
      );
    }

    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultView(
          score: _score,
          totalQuestions: _questions.length,
          correctAnswers: _correctAnswersCount,
          incorrectAnswers: _incorrectAnswersCount,
          timeSpent: _totalTimeSpent,
          categoryName: widget.categoryName,
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(categoryQuestionsProvider(widget.categoryId));
    
    return questionsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text('Error: $error'))),
      data: (questions) {
        _questions = questions;
        if (questions.isEmpty) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No questions available for this category'),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go back'),
                  ),
                ],
              ),
            ),
          );
        }

        final progressValue = (_currentQuestionIndex + 1) / questions.length;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Text(
                      'Score: $_score',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(_timeLeft),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  color: Colors.green,
                  minHeight: 8,
                ),
                
                const SizedBox(height: 30),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question ${_currentQuestionIndex + 1} of ${questions.length}',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          questions[_currentQuestionIndex].question,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2C3E50),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        Expanded(
                          child: ListView.builder(
                            itemCount: questions[_currentQuestionIndex].options.length,
                            itemBuilder: (context, index) {
                              return _buildAnswerOption(
                                index,
                                questions[_currentQuestionIndex].options[index],
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _showAnswerFeedback ? _moveToNextQuestion : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667EEA),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              _currentQuestionIndex < questions.length - 1 
                                  ? 'Next Question' 
                                  : 'Finish Quiz',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnswerOption(int index, String answer) {
    final isSelected = _selectedAnswerIndex == index;
    final answerLabels = ['A', 'B', 'C', 'D'];
    bool isCorrectAnswer = index == _correctAnswerIndex;
    bool isWrongSelection = isSelected && !isCorrectAnswer;

    Color backgroundColor = const Color(0xFFF8F9FA);
    Color borderColor = const Color(0xFFE9ECEF);
    Color textColor = const Color(0xFF333333);

    if (_showAnswerFeedback) {
      if (isCorrectAnswer) {
        backgroundColor = const Color(0xFF4CAF50).withOpacity(0.1);
        borderColor = const Color(0xFF4CAF50);
        textColor = const Color(0xFF4CAF50);
      } else if (isWrongSelection) {
        backgroundColor = const Color(0xFFF44336).withOpacity(0.1);
        borderColor = const Color(0xFFF44336);
        textColor = const Color(0xFFF44336);
      }
    } else if (isSelected) {
      backgroundColor = const Color(0xFF667EEA).withOpacity(0.1);
      borderColor = const Color(0xFF667EEA);
      textColor = const Color(0xFF667EEA);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () => _selectAnswer(index),
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: borderColor,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _showAnswerFeedback
                      ? isCorrectAnswer
                          ? const Color(0xFF4CAF50)
                          : isWrongSelection
                              ? const Color(0xFFF44336)
                              : const Color(0xFF667EEA)
                      : isSelected
                          ? Colors.white
                          : const Color(0xFF667EEA),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    answerLabels[index],
                    style: TextStyle(
                      color: _showAnswerFeedback
                          ? isCorrectAnswer || isWrongSelection
                              ? Colors.white
                              : Colors.white
                          : isSelected
                              ? const Color(0xFF667EEA)
                              : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  answer,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              if (_showAnswerFeedback && isCorrectAnswer)
                const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
              if (_showAnswerFeedback && isWrongSelection)
                const Icon(Icons.cancel, color: Color(0xFFF44336)),
            ],
          ),
        ),
      ),
    );
  }
}