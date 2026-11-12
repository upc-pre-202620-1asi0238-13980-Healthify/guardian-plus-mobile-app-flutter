import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';

/// A reading and the normal range it is judged against.
class RangeMarker {
  final double value;
  final double normalMinimum;
  final double normalMaximum;

  const new({required this.value, required this.normalMinimum, required this.normalMaximum});
}

/// Track with the normal range shaded and a tick on the reading. The track spans half a range more on each
/// side, so a normal value lands in the middle and an abnormal one visibly outside the shade.
class RangeBar extends StatelessWidget {
  final RangeMarker marker;
  final bool withinRange;

  const new({super.key, required this.marker, required this.withinRange});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 10,
      width: double.infinity,
      child: CustomPaint(
        painter: _RangeBarPainter(
          marker: marker,
          trackColor: GuardianColors.neutralMuted,
          rangeColor: colors.primary.withValues(alpha: 0.22),
          tickColor: withinRange ? colors.primary : colors.tertiary,
        ),
      ),
    );
  }
}

class _RangeBarPainter extends CustomPainter {
  final RangeMarker marker;
  final Color trackColor;
  final Color rangeColor;
  final Color tickColor;

  const new({required this.marker, required this.trackColor, required this.rangeColor, required this.tickColor});

  @override
  void paint(Canvas canvas, Size size) {
    final span = (marker.normalMaximum - marker.normalMinimum).clamp(1.0, double.infinity);
    final low = marker.normalMinimum - span / 2;
    final high = marker.normalMaximum + span / 2;
    double x(double value) => ((value - low) / (high - low)).clamp(0.0, 1.0) * size.width;

    const barHeight = 4.0;
    final barTop = (size.height - barHeight) / 2;
    const radius = Radius.circular(barHeight / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, barTop, size.width, barHeight), radius),
      Paint()..color = trackColor,
    );
    final rangeStart = x(marker.normalMinimum);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(rangeStart, barTop, x(marker.normalMaximum) - rangeStart, barHeight), radius),
      Paint()..color = rangeColor,
    );
    const tickWidth = 3.0;
    final tickX = x(marker.value).clamp(tickWidth / 2, size.width - tickWidth / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tickX - tickWidth / 2, 0, tickWidth, size.height),
        const Radius.circular(tickWidth / 2),
      ),
      Paint()..color = tickColor,
    );
  }

  @override
  bool shouldRepaint(_RangeBarPainter oldDelegate) => true;
}
