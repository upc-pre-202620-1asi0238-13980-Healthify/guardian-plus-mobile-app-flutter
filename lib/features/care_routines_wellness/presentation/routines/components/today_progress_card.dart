import 'dart:math';

import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_labels.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_progress_bar.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/routines/routines_state.dart';

/// Green "HOY" card: how many of today's routines are done, as a ring, a bar and two counters.
class TodayProgressCard extends StatelessWidget {
  final String dateLabel;
  final RoutineCount count;

  const new({super.key, required this.dateLabel, required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final onContainer = colors.onPrimary;
    // Secondary text in the pastel mint of the prototype, readable on the green
    final softText = colors.primaryContainer;

    final headline = count.total == 0
        ? 'Sin rutinas para hoy'
        : count.pending == 0
        ? 'Rutinas del día completadas'
        : 'Tu día está en marcha';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(GuardianRadius.large)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('HOY · $dateLabel', style: dataLabelStyle.copyWith(color: onContainer)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(headline, style: text.titleLarge?.copyWith(color: onContainer)),
                    if (count.total > 0)
                      Text(
                        '${count.completed} de ${count.total} rutinas completadas',
                        style: text.bodySmall?.copyWith(color: softText),
                      ),
                  ],
                ),
              ),
              _ProgressRing(
                percentage: count.percentage,
                track: onContainer.withValues(alpha: 0.17),
                progress: softText,
                textColor: onContainer,
              ),
            ],
          ),
          const SizedBox(height: 14),
          RoutineProgressBar(
            percentage: count.percentage,
            track: onContainer.withValues(alpha: 0.2),
            progress: softText,
          ),
          const SizedBox(height: 14),
          // Wraps to a second line on narrow phones instead of overflowing
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 6,
            children: [
              _Counter(
                icon: Icons.check,
                text: plural(count.completed, '${count.completed} completada', '${count.completed} completadas'),
                color: onContainer,
              ),
              // Only shown when it happens, so the usual day looks like the prototype
              if (count.missed > 0)
                _Counter(
                  icon: Icons.close,
                  text: plural(count.missed, '${count.missed} omitida', '${count.missed} omitidas'),
                  color: onContainer,
                ),
              _Counter(
                icon: Icons.schedule,
                text: plural(count.pending, '${count.pending} pendiente', '${count.pending} pendientes'),
                color: onContainer,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final int percentage;
  final Color track;
  final Color progress;
  final Color textColor;

  const new({required this.percentage, required this.track, required this.progress, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 58,
      child: CustomPaint(
        painter: _RingPainter(fraction: percentage / 100, track: track, progress: progress),
        child: Center(
          child: Text(
            '$percentage%',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: textColor, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;
  final Color track;
  final Color progress;

  const new({required this.fraction, required this.track, required this.progress});

  static const _strokeWidth = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      _strokeWidth / 2,
      _strokeWidth / 2,
      size.width - _strokeWidth,
      size.height - _strokeWidth,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
    canvas.drawArc(rect, 0, 2 * pi, false, paint..color = track);
    // From the top, clockwise
    canvas.drawArc(rect, -pi / 2, 2 * pi * fraction, false, paint..color = progress);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.fraction != fraction || oldDelegate.track != track || oldDelegate.progress != progress;
  }
}

class _Counter extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const new({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
      ],
    );
  }
}
