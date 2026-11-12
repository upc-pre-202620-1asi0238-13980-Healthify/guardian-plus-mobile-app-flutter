import 'package:flutter/material.dart';

const _maxMarkedPoints = 10;

/// Line of the history card, one point per hour or per day. Empty points are skipped, the line joins the ones around them.
class PeriodLineChart extends StatelessWidget {
  final List<double?> values;

  const new({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 96,
      width: double.infinity,
      child: CustomPaint(
        painter: _PeriodLineChartPainter(
          values: values,
          lineColor: colors.primary,
          fillColor: colors.primaryContainer,
          dotFill: colors.surface,
        ),
      ),
    );
  }
}

class _PeriodLineChartPainter extends CustomPainter {
  final List<double?> values;
  final Color lineColor;
  final Color fillColor;
  final Color dotFill;

  const new({required this.values, required this.lineColor, required this.fillColor, required this.dotFill});

  @override
  void paint(Canvas canvas, Size size) {
    final known = values.nonNulls.toList();
    if (known.isEmpty || values.length < 2) return;

    // The same inset on both axes keeps the first and last dots inside the canvas instead of cut in half
    const inset = 6.0;
    final min = known.reduce((a, b) => a < b ? a : b);
    final max = known.reduce((a, b) => a > b ? a : b);
    final usableHeight = size.height - 2 * inset;
    final stepX = (size.width - 2 * inset) / (values.length - 1);

    final points = [
      for (final (index, value) in values.indexed)
        if (value != null)
          // A flat series would divide by zero; draw it as a line in the middle instead
          Offset(inset + index * stepX, inset + usableHeight * (1 - (max == min ? 0.5 : (value - min) / (max - min)))),
    ];

    if (points.length == 1) {
      // A single point has no line to draw yet; a dashed level keeps the card from looking empty
      final y = points.first.dy;
      final dash = Paint()
        ..color = lineColor.withValues(alpha: 0.4)
        ..strokeWidth = 1.5;
      for (var x = inset; x < size.width - inset; x += 8) {
        canvas.drawLine(Offset(x, y), Offset((x + 4).clamp(0, size.width - inset), y), dash);
      }
    } else {
      final line = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        line.lineTo(point.dx, point.dy);
      }
      final area = Path.from(line)
        ..lineTo(points.last.dx, size.height)
        ..lineTo(points.first.dx, size.height)
        ..close();
      canvas.drawPath(
        area,
        Paint()..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [fillColor, fillColor.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
      );
      canvas.drawPath(
        line,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Small squares, as in the prototype. Long periods only mark the latest one, or the dots become a band
    const dot = 6.0;
    final marked = values.length <= _maxMarkedPoints ? points : [points.last];
    for (final point in marked) {
      final rect = Rect.fromCenter(center: point, width: dot, height: dot);
      canvas.drawRect(rect, Paint()..color = dotFill);
      canvas.drawRect(
        rect,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(_PeriodLineChartPainter oldDelegate) => oldDelegate.values != values;
}
