import 'package:flutter/material.dart';

class SignDrawingCanvasPainter extends CustomPainter {
  SignDrawingCanvasPainter({
    required this.paths,
    required this.color,
    required this.strokeWidth,
    super.repaint,
  });
  final List<Path> paths;

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (paths.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final path in paths) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SignDrawingCanvasPainter oldDelegate) {
    return oldDelegate.paths != paths || oldDelegate.strokeWidth != strokeWidth || oldDelegate.color != color;
  }
}
