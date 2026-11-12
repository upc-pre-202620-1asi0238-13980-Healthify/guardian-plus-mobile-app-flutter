import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/status_chip.dart';

/// "Normal" (mint) or "En observación" (yellow); the long form reads "En rango normal".
class ReadingBadge extends StatelessWidget {
  final bool withinRange;
  final bool long;

  const new({super.key, required this.withinRange, this.long = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = switch ((withinRange, long)) {
      (false, _) => 'En observación',
      (true, true) => 'En rango normal',
      (true, false) => 'Normal',
    };
    return StatusChip(
      text: text,
      container: withinRange ? scheme.primaryContainer : GuardianColors.noticeContainer,
      content: withinRange ? scheme.onPrimaryContainer : GuardianColors.onNoticeContainer,
    );
  }
}
