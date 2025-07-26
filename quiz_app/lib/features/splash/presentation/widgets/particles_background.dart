import 'package:flutter/material.dart';
import 'dart:math';

class ParticlesBackground extends StatelessWidget {
  const ParticlesBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: _ParticlesPainter(),
      ),
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final List<Particle> particles = List.generate(20, (index) => Particle());

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (final particle in particles) {
      particle.update();
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Particle {
  double x = Random().nextDouble();
  double y = Random().nextDouble() + 1; 
  double speed = Random().nextDouble() * 0.005 + 0.005;
  double angle = Random().nextDouble() * 2 * pi;

  void update() {
    y -= speed;
    x += sin(angle) * 0.001;
    
    if (y < -0.1) {
      y = 1.1;
      x = Random().nextDouble();
    }
  }
}