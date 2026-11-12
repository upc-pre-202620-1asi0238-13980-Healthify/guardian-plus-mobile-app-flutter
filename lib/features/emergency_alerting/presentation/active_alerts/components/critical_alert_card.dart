import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_source_type.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/recipient_level.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/active_alerts/active_alerts_state.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/alert_labels.dart';

/// Red card of the most urgent critical alert, with the escalation countdown and the two quick actions.
class CriticalAlertCard extends StatelessWidget {
  final ActiveAlertItem item;
  final String careRecipientFirstName;
  final DateTime now;
  final int? escalationSecondsLeft;
  final bool isAcknowledging;
  final VoidCallback onTap;
  final VoidCallback onAcknowledge;
  final VoidCallback onCall;

  const new({
    super.key,
    required this.item,
    required this.careRecipientFirstName,
    required this.now,
    required this.escalationSecondsLeft,
    required this.isAcknowledging,
    required this.onTap,
    required this.onAcknowledge,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final alert = item.alert;
    final onCard = scheme.onError;

    return Material(
      color: scheme.error,
      elevation: 6,
      shadowColor: scheme.error.withAlpha(90),
      borderRadius: BorderRadius.circular(GuardianRadius.large),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: onCard),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: onCard.withAlpha(46),
                        borderRadius: BorderRadius.circular(GuardianRadius.subtle),
                      ),
                      child: Text(
                        '${alert.severity.label} · ${alert.sourceType.tag}'.toUpperCase(),
                        style: text.labelSmall?.copyWith(color: onCard),
                      ),
                    ),
                    Text(relativeTime(alert.triggeredAt, now), style: dataLabelStyle.copyWith(color: onCard)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: onCard.withAlpha(46),
                      child: Icon(alert.sourceType.icon, size: 22, color: onCard),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.sourceType.title(careRecipientFirstName),
                            style: text.titleLarge?.copyWith(color: onCard),
                          ),
                          if (_subtitle != null)
                            Text(
                              _subtitle!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodyMedium?.copyWith(color: onCard.withAlpha(217)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                _EscalationStatus(alert: alert, secondsLeft: escalationSecondsLeft, onCard: onCard),
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (item.awaitsMyAcknowledgement) ...[
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: isAcknowledging ? null : onAcknowledge,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            backgroundColor: onCard,
                            foregroundColor: scheme.error,
                            disabledBackgroundColor: onCard.withAlpha(178),
                            disabledForegroundColor: scheme.error,
                          ),
                          icon: isAcknowledging
                              ? SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: scheme.error),
                                )
                              : const Icon(Icons.check, size: 18),
                          label: const Text('Reconocer'),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onCall,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          foregroundColor: onCard,
                          side: BorderSide(color: onCard.withAlpha(153)),
                        ),
                        icon: const Icon(Icons.phone_outlined, size: 18),
                        label: Text('Llamar a $careRecipientFirstName', maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? get _subtitle {
    final alert = item.alert;
    if (alert.status == AlertStatus.pendingConfirmation) {
      return 'Esperando que $careRecipientFirstName confirme que está bien';
    }
    return switch (alert.sourceType) {
      AlertSourceType.fallDetected => '$careRecipientFirstName no respondió en 20 s',
      AlertSourceType.sosTriggered => 'Pulsación sostenida en la pulsera',
      _ => null,
    };
  }
}

/// Countdown box: when the alert will reach the next contacts, or that it already reached everyone.
class _EscalationStatus extends StatelessWidget {
  final Alert alert;
  final int? secondsLeft;
  final Color onCard;

  const new({required this.alert, required this.secondsLeft, required this.onCard});

  @override
  Widget build(BuildContext context) {
    final left = secondsLeft;
    final String message;
    if (left == null) {
      if (alert.currentRecipientLevel != RecipientLevel.broadcast) return const SizedBox.shrink();
      message = 'Enviada a todo el círculo de cuidado';
    } else if (left == 0) {
      message = 'Sin reconocer · enviando a los siguientes contactos…';
    } else if (alert.currentRecipientLevel == RecipientLevel.primary) {
      message = 'Sin reconocer · se enviará a tus contactos secundarios en';
    } else {
      message = 'Sin reconocer · se enviará a todo el círculo de cuidado en';
    }

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: onCard.withAlpha(36),
        borderRadius: BorderRadius.circular(GuardianRadius.medium),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, size: 16, color: onCard),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: onCard)),
          ),
          if (left != null && left > 0) ...[
            const SizedBox(width: 8),
            Text(formatCountdown(left), style: dataLabelStyle.copyWith(color: onCard, fontSize: 16)),
          ],
        ],
      ),
    );
  }
}
