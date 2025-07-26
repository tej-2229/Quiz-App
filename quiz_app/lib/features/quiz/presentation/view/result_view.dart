import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class QuizResultView extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int timeSpent;
  final String categoryName;

  const QuizResultView({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.timeSpent,
    required this.categoryName,
  });

  @override
  State<QuizResultView> createState() => _QuizResultViewState();
}

class _QuizResultViewState extends State<QuizResultView>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  double _scorePercentage = 0;
  String _achievementText = 'Good Job!';
  Color _achievementColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..addListener(() {
            setState(() {
              _scorePercentage =
                  widget.score / (widget.totalQuestions * 10) * 100;
            });
          });

    final percentage = widget.score / (widget.totalQuestions * 10);
    if (percentage >= 0.9) {
      _achievementText = 'Excellent!';
      _achievementColor = const Color(0xFF4CAF50);
    } else if (percentage >= 0.7) {
      _achievementText = 'Great Job!';
      _achievementColor = const Color(0xFF2196F3);
    } else if (percentage >= 0.5) {
      _achievementText = 'Good Job!';
      _achievementColor = const Color(0xFFFFC107);
    } else {
      _achievementText = 'Keep Trying!';
      _achievementColor = const Color(0xFFF44336);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
      if (percentage >= 0.8) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final percentage = widget.score / (widget.totalQuestions * 10);
    final scoreText = '${widget.score}/${widget.totalQuestions * 10}';

    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF667EEA),
                    percentage >= 0.8
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF764BA2),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const Text(
                        'Quiz Results',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Congratulations!',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'You completed the ${widget.categoryName} quiz!',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 30),

                                SizedBox(
                                  width: 250,
                                  height: 250,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        height: 150,
                                        child: CircularProgressIndicator(
                                          value:
                                              _animationController.value *
                                              percentage,
                                          strokeWidth: 12,
                                          backgroundColor: Colors.grey[200],
                                          color: _achievementColor,
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${(_animationController.value * _scorePercentage).round()}%',
                                            style: TextStyle(
                                              fontSize: 36,
                                              fontWeight: FontWeight.bold,
                                              color: _achievementColor,
                                            ),
                                          ),
                                          Text(
                                            scoreText,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        _achievementColor,
                                        _achievementColor.withOpacity(0.7),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _achievementColor.withOpacity(
                                          0.3,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.emoji_events,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _achievementText,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatItem(
                                      value: widget.correctAnswers.toString(),
                                      label: 'Correct',
                                      color: const Color(0xFF4CAF50),
                                    ),
                                    _buildStatItem(
                                      value: widget.incorrectAnswers.toString(),
                                      label: 'Incorrect',
                                      color: const Color(0xFFF44336),
                                    ),
                                    _buildStatItem(
                                      value: _formatTime(widget.timeSpent),
                                      label: 'Time',
                                      color: const Color(0xFF667EEA),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),

                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF667EEA,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 15,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Play Again',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 15,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          side: const BorderSide(
                                            color: Color(0xFF667EEA),
                                          ),
                                        ),
                                        child: const Text(
                                          'Home',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF667EEA),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
