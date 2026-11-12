import 'package:flutter/material.dart';

/// Thin line of the latest readings, oldest on the left, ending in a dot on the current one.
class Sparkline extends StatelessWidget {
  final List<double> values;
  final Color lineColor;
  final Color fillColor;

  const new({super.key, required this.values, required this.lineColor, required this.fillColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SparklinePainter(values, lineColor, fillColor), size: Size.infinite);
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final Color fillColor;

  const new(this.values, this.lineColor, this.fillColor);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const inset = 4.0;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final usableHeight = size.height - 2 * inset;
    double y(double value) {
      // A flat series would divide by zero; it is drawn through the middle instead
      final normalized = max == min ? 0.5 : (value - min) / (max - min);
      return inset + usableHeight * (1 - normalized);
    }

    // One reading is still a level worth showing, so it spans the whole width
    final List<Offset> points;
    if (values.length == 1) {
      points = [Offset(0, y(values.first)), Offset(size.width - inset, y(values.first))];
    } else {
      final stepX = (size.width - inset) / (values.length - 1);
      points = [for (final (index, value) in values.indexed) Offset(index * stepX, y(value))];
    }

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      line.lineTo(point.dx, point.dy);
    }
    final area = Path.from(line)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final bounds = Offset.zero & size;
    canvas.drawPath(
      area,
      Paint()..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fillColor, fillColor.withValues(alpha: 0)],
      ).createShader(bounds),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(points.last, 3, Paint()..color = lineColor);
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.lineColor != lineColor || oldDelegate.fillColor != fillColor;
}
