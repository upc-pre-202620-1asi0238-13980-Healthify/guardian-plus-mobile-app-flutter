import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/active_alerts/active_alerts_state.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/alert_colors.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/alert_labels.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/severity_badge.dart';

/// Row of the "Otras alertas activas" list (component AlertaItem of the prototype).
class AlertItem extends StatelessWidget {
  final ActiveAlertItem item;
  final String careRecipientFirstName;
  final DateTime now;
  final VoidCallback onTap;

  const new({
    super.key,
    required this.item,
    required this.careRecipientFirstName,
    required this.now,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final alert = item.alert;
    final severityColors = alert.severity.colors(scheme);
    final elapsed = relativeTime(alert.triggeredAt, now);
    final (meta, metaColor) = switch (alert.status) {
      _ when alert.status.isAwaitingAcknowledgement => ('$elapsed · Sin reconocer', scheme.tertiary),
      AlertStatus.pendingConfirmation => ('$elapsed · Confirmando', scheme.onSurfaceVariant),
      _ => ('$elapsed · Reconocida', scheme.secondary),
    };

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
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: severityColors.container,
                child: Icon(alert.sourceType.icon, size: 20, color: severityColors.content),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            alert.sourceType.title(careRecipientFirstName),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleMedium?.copyWith(color: scheme.onSurface),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SeverityBadge(severity: alert.severity),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 12, color: metaColor),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            meta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.labelMedium?.copyWith(color: metaColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant, semanticLabel: 'Ver detalle de la alerta'),
            ],
          ),
        ),
      ),
    );
  }
}
