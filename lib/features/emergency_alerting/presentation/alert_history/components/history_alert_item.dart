import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/alert_colors.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/alert_labels.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/status_chip.dart';

/// Row of the history (component AlertaHistorialItem of the prototype): what happened, when and how it ended.
class HistoryAlertItem extends StatelessWidget {
  final Alert alert;
  final String careRecipientFirstName;
  final VoidCallback onTap;

  const new({super.key, required this.alert, required this.careRecipientFirstName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    // Finished alerts drop the severity color: green when someone answered, grey when it was dismissed
    final icon = switch (alert.status) {
      AlertStatus.resolved => (container: scheme.primaryContainer, content: scheme.primary),
      AlertStatus.dismissed => (container: scheme.surfaceContainerHighest, content: scheme.onSurfaceVariant),
      _ => alert.severity.colors(scheme),
    };
    final chip = alert.status.colors(scheme);

    return Material(
      color: scheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GuardianRadius.medium),
        side: BorderSide(color: scheme.outline),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: icon.container,
                child: Icon(alert.sourceType.icon, size: 20, color: icon.content),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            alert.sourceType.title(careRecipientFirstName),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleMedium?.copyWith(color: scheme.onSurface),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatClockTime(alert.triggeredAt),
                          style: dataLabelStyle.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(_outcome, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    StatusChip(text: alert.status.label, container: chip.container, content: chip.content),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// One sentence on how the alert ended, from what the list endpoint returns.
  String get _outcome {
    final acknowledgedAt = alert.acknowledgedAt;
    if (alert.status == AlertStatus.dismissed) {
      return '$careRecipientFirstName confirmó desde la pulsera que está bien';
    }
    if (acknowledgedAt != null) {
      final seconds = acknowledgedAt.difference(alert.triggeredAt).inSeconds;
      return 'Reconocida en ${formatDuration(seconds < 0 ? 0 : seconds)}';
    }
    if (alert.status == AlertStatus.pendingConfirmation) return 'Esperando que $careRecipientFirstName confirme';
    return 'Sin reconocer';
  }
}
