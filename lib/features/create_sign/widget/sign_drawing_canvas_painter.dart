import 'package:flutter/material.dart';

class SignDrawingCanvasPainter extends CustomPainter {
  SignDrawingCanvasPainter({
    required this.points,
    required this.color,
    required this.strokeWidth,
    super.repaint,
  });
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..strokeWidth = strokeWidth;

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (var i = 1; i < points.length - 1; i++) {
      final mid = calculateMidPoint(points[i - 1], points[i]);
      final control = points[i - 1];
      path.quadraticBezierTo(control.dx, control.dy, mid.dx, mid.dy);
    }

    canvas.drawPath(path, paint);
  }

  Offset calculateMidPoint(Offset p1, Offset p2) => Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);

  @override
  bool shouldRepaint(covariant SignDrawingCanvasPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.strokeWidth != strokeWidth || oldDelegate.color != color;
  }
}
