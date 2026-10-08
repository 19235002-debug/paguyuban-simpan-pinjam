import 'dart:math' as math;
import 'package:flutter/material.dart';

class LiquidAquariumLoader extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final Color color;
  final bool animateLoop;

  const LiquidAquariumLoader({
    super.key,
    required this.progress,
    this.size = 180,
    this.color = const Color(0xFF0D9488),
    this.animateLoop = true,
  });

  @override
  State<LiquidAquariumLoader> createState() => _LiquidAquariumLoaderState();
}

class _LiquidAquariumLoaderState extends State<LiquidAquariumLoader> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.animateLoop) {
      _waveController.repeat();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _AquariumPainter(
            progress: widget.progress,
            waveValue: _waveController.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _AquariumPainter extends CustomPainter {
  final double progress;
  final double waveValue;
  final Color color;

  _AquariumPainter({
    required this.progress,
    required this.waveValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, size.height / 2);

    // 1. Draw outer glass border (aquarium)
    final Paint borderPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    
    final Paint glowPaint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    
    // Draw background/inside tank
    canvas.drawCircle(center, radius - 2.5, glowPaint);
    canvas.drawCircle(center, radius - 2.5, borderPaint);

    // 2. Clip the paint region to be inside the circle
    final Path clipPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius - 5));
    canvas.save();
    canvas.clipPath(clipPath);

    // 3. Draw liquid wave
    final Paint liquidPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Paint liquidLightPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final double baseHeight = size.height - (size.height * progress);
    final double amplitude = 8.0; // wave height
    final double waveLength = size.width;

    // Draw secondary background wave (slightly offset for depth)
    final Path wavePath2 = Path();
    wavePath2.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x++) {
      final double angle = (x / waveLength) * 2 * math.pi + (waveValue * 2 * math.pi) + math.pi;
      final double y = baseHeight + math.sin(angle) * amplitude;
      wavePath2.lineTo(x, y);
    }
    wavePath2.lineTo(size.width, size.height);
    wavePath2.lineTo(0, size.height);
    wavePath2.close();
    canvas.drawPath(wavePath2, liquidLightPaint);

    // Draw primary wave
    final Path wavePath1 = Path();
    wavePath1.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x++) {
      final double angle = (x / waveLength) * 2 * math.pi - (waveValue * 2 * math.pi);
      final double y = baseHeight + math.sin(angle) * amplitude;
      wavePath1.lineTo(x, y);
    }
    wavePath1.lineTo(size.width, size.height);
    wavePath1.lineTo(0, size.height);
    wavePath1.close();
    canvas.drawPath(wavePath1, liquidPaint);

    // Restore clip state
    canvas.restore();
    
    // 4. Draw highlights / reflections on the glass
    final Paint reflectionPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    final Path reflectionPath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: radius - 15),
        -math.pi / 4,
        math.pi / 3,
      );
    canvas.drawPath(reflectionPath, reflectionPaint);
  }

  @override
  bool shouldRepaint(covariant _AquariumPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.waveValue != waveValue;
  }
}
