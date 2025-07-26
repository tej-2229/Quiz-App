import 'package:flutter/material.dart';

class LoadingSection extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> animation;
  final String loadingText;

  const LoadingSection({
    super.key,
    required this.controller,
    required this.animation,
    required this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 50),
        RotationTransition(
          turns: Tween<double>(begin: 0, end: 1).animate(controller),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 3,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Center(
              child: SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        FadeTransition(
          opacity: animation,
          child: Text(
            loadingText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}