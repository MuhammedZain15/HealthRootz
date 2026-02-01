import 'dart:math';
import 'package:flutter/material.dart';

class WaveLoading extends StatefulWidget {
  const WaveLoading({super.key});

  @override
  State<WaveLoading> createState() => _WaveLoadingState();
}

class _WaveLoadingState extends State<WaveLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 80,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return CustomPaint(
            painter: _WavePainter(
              phase: _controller.value * 2 * pi,
            ),
          );
        },
      ),
    );
  }
}
class _WavePainter extends CustomPainter {
  final double phase;

  _WavePainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final amplitude = 12.0;
    final frequency = 2 * pi / size.width;

    // Wave paint
    final wavePaint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();

    for (double x = 0; x <= size.width; x++) {
      final y = centerY +
          amplitude * sin(frequency * x + phase);

      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, wavePaint);

    // Dots
    final dotPaint = Paint()..color = Colors.redAccent;

    for (final dx in [size.width * 0.4, size.width * 0.6]) {
      final dy =
          centerY + amplitude * sin(frequency * dx + phase);
      canvas.drawCircle(Offset(dx, dy), 4.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}
