import 'package:flutter/material.dart';

class TitleSlideAnimation extends StatefulWidget {
  const TitleSlideAnimation({super.key});

  @override
  State<TitleSlideAnimation> createState() => _TitleSlideAnimationState();
}

class _TitleSlideAnimationState extends State<TitleSlideAnimation> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _titleOpacityAnimation;
  late Animation<Offset> _subtitleSlideAnimation;
  late Animation<double> _subtitleOpacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    
    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    
    _titleOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
    
    _subtitleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    
    _subtitleOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SlideTransition(
          position: _titleSlideAnimation,
          child: FadeTransition(
            opacity: _titleOpacityAnimation,
            child: const Text(
              'QuizMaster',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SlideTransition(
          position: _subtitleSlideAnimation,
          child: FadeTransition(
            opacity: _subtitleOpacityAnimation,
            child: const Text(
              'Challenge Your Mind',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}