import 'package:flutter/material.dart';
import 'dart:math';

class FloatingQuizIcons extends StatelessWidget {
  const FloatingQuizIcons({super.key});

  @override
  Widget build(BuildContext context) {
    const icons = ['🧠', '💡', '🎯', '⭐', '🏆', '📚', '🤔', '✨'];
    
    return Stack(
      children: List.generate(8, (index) {
        return FloatingIcon(
          icon: icons[index],
          delay: index * 0.5,
        );
      }),
    );
  }
}

class FloatingIcon extends StatefulWidget {
  final String icon;
  final double delay;

  const FloatingIcon({
    super.key,
    required this.icon,
    required this.delay,
  });

  @override
  State<FloatingIcon> createState() => _FloatingIconState();
}

class _FloatingIconState extends State<FloatingIcon> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    final duration = 6 + Random().nextInt(4);
    
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: duration),
    )..forward();
    
    _animation = Tween<double>(begin: 1.1, end: -0.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          left: Random().nextDouble() * MediaQuery.of(context).size.width,
          top: _animation.value * MediaQuery.of(context).size.height,
          child: Opacity(
            opacity: 0.1,
            child: Text(
              widget.icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        );
      },
    );
  }
}