import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_source_type.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/recipient_level.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/active_alerts/active_alerts_state.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/alert_labels.dart';
import 'package:guardian_plus_app/l10n/app_localizations.dart';
import 'package:guardian_plus_app/l10n/l10n.dart';

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
    final l10n = context.l10n;
    final alert = item.alert;
    final onCard = scheme.onError;
    final subtitle = _subtitle(l10n);

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
                        '${alert.severity.label(l10n)} · ${alert.sourceType.tag(l10n)}'.toUpperCase(),
                        style: text.labelSmall?.copyWith(color: onCard),
                      ),
                    ),
                    Text(relativeTime(l10n, alert.triggeredAt, now), style: dataLabelStyle.copyWith(color: onCard)),
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
                            alert.sourceType.title(l10n, careRecipientFirstName),
                            style: text.titleLarge?.copyWith(color: onCard),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle,
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
                          label: Text(l10n.alertsAcknowledge),
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
                        label: Text(
                          l10n.alertsCall(careRecipientFirstName),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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

  String? _subtitle(AppLocalizations l10n) {
    final alert = item.alert;
    if (alert.status == AlertStatus.pendingConfirmation) {
      return l10n.alertsWaitingConfirmation(careRecipientFirstName);
    }
    return switch (alert.sourceType) {
      AlertSourceType.fallDetected => l10n.alertsFallNoResponse(careRecipientFirstName),
      AlertSourceType.sosTriggered => l10n.alertsSosHeld,
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
    final l10n = context.l10n;
    final left = secondsLeft;
    final String message;
    if (left == null) {
      if (alert.currentRecipientLevel != RecipientLevel.broadcast) return const SizedBox.shrink();
      message = l10n.alertsSentToEveryone;
    } else if (left == 0) {
      message = l10n.alertsEscalatingNow;
    } else if (alert.currentRecipientLevel == RecipientLevel.primary) {
      message = l10n.alertsEscalatesToSecondary;
    } else {
      message = l10n.alertsEscalatesToEveryone;
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
