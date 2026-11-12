import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_labels.dart';

/// "Pulsera sincronizada · Hace 1 min", from the last activity sample the wristband sent.
class WristbandSyncNote extends StatelessWidget {
  final DateTime lastSyncAt;
  final DateTime now;

  const new({super.key, required this.lastSyncAt, required this.now});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.watch_outlined, size: 16, color: colors.onSurfaceVariant),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'Pulsera sincronizada · ${relativeTime(lastSyncAt, now)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
