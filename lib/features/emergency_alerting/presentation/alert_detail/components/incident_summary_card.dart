import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/incident.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_detail/components/detail_card.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/alert_labels.dart';
import 'package:guardian_plus_app/l10n/l10n.dart';

/// Facts of a stabilized or closed incident: what happened, when, how long and who answered.
class IncidentSummaryCard extends StatelessWidget {
  final Alert alert;
  final Incident incident;
  final String? acknowledgedByName;
  final String careRecipientFirstName;

  const new({
    super.key,
    required this.alert,
    required this.incident,
    required this.acknowledgedByName,
    required this.careRecipientFirstName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final endedAt = incident.closedAt ?? incident.stabilizedAt;
    final acknowledgedAt = alert.acknowledgedAt;
    final rows = [
      (l10n.summaryType, alert.sourceType.title(l10n, careRecipientFirstName)),
      (l10n.summaryStart, formatClockTime(alert.triggeredAt)),
      if (incident.stabilizedAt != null) (l10n.incidentStatusStabilized, formatClockTime(incident.stabilizedAt!)),
      if (incident.closedAt != null) (l10n.incidentStatusClosed, formatClockTime(incident.closedAt!)),
      if (endedAt != null) (l10n.alertDetailDuration, formatDuration(_seconds(alert.triggeredAt, endedAt))),
      if (acknowledgedAt != null)
        (
          l10n.summaryAcknowledgedBy,
          l10n.summaryAcknowledgedIn(
            acknowledgedByName ?? l10n.alertDetailSomeMember,
            formatDuration(_seconds(alert.lastDispatchedAt ?? alert.triggeredAt, acknowledgedAt)),
          ),
        ),
      if (incident.notes?.trim().isNotEmpty ?? false) (l10n.summaryNotes, incident.notes!.trim()),
    ];

    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return DetailCard(
      children: [
        Text(l10n.summaryTitle, style: text.titleMedium),
        for (final (label, value) in rows)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(value, textAlign: TextAlign.end, style: text.titleSmall),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static int _seconds(DateTime from, DateTime to) {
    final seconds = to.difference(from).inSeconds;
    return seconds < 0 ? 0 : seconds;
  }
}
