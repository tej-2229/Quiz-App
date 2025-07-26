class Question {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  @override
  String toString() {
    return 'Question{id: $id, question: $question, options: $options, correctAnswer: $correctAnswer}';
  }
}