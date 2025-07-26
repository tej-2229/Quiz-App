class QuizCategory {
  final String id;
  final String name;
  final String icon;
  final int questionCount;

  QuizCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.questionCount,
  });

  @override
  String toString() {
    return 'QuizCategory{id: $id, name: $name, icon: $icon, questionCount: $questionCount}';
  }
}