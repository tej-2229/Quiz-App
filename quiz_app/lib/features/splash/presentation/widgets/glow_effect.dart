import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GlowEffect extends ConsumerStatefulWidget {
  const GlowEffect({super.key});

  @override
  ConsumerState<GlowEffect> createState() => _GlowEffectState();
}

class _GlowEffectState extends ConsumerState<GlowEffect> 
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.5, end: 0.2).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.white.withOpacity(_glowAnimation.value),
                Colors.transparent,
              ],
              stops: const [0, 0.7],
            ),
          ),
        );
      },
    );
  }
}