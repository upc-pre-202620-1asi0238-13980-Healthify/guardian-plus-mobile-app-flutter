import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/severity.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/alert_colors.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/alert_labels.dart';

/// "Crítica", "Alta" or "Media" on its traffic-light color.
class SeverityBadge extends StatelessWidget {
  final Severity severity;

  const new({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    final colors = severity.colors(Theme.of(context).colorScheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: colors.container, borderRadius: BorderRadius.circular(GuardianRadius.subtle)),
      child: Text(severity.label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colors.content)),
    );
  }
}
