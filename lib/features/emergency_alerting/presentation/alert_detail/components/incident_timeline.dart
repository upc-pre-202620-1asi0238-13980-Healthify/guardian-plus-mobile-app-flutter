import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_source_type.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/fall_confirmation_window.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_detail/alert_detail_state.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_detail/components/detail_card.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/alert_labels.dart';
import 'package:guardian_plus_app/l10n/app_localizations.dart';
import 'package:guardian_plus_app/l10n/l10n.dart';

/// "Seguimiento del incidente": each recorded step with its exact time, plus the next escalation if any.
class IncidentTimeline extends StatelessWidget {
  final List<TimelineEvent> events;
  final AlertSourceType sourceType;
  final String careRecipientFirstName;

  const new({super.key, required this.events, required this.sourceType, required this.careRecipientFirstName});

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      children: [
        Text(context.l10n.alertDetailTimelineTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final event in events) _TimelineRow(event: event, text: _describe(context.l10n, event)),
      ],
    );
  }

  String _describe(AppLocalizations l10n, TimelineEvent event) {
    final names = event.names.isEmpty ? l10n.alertDetailSomeMember : event.names.join(', ');
    return switch (event.kind) {
      TimelineEventKind.detected => switch (sourceType) {
        AlertSourceType.fallDetected => l10n.timelineFallDetected,
        AlertSourceType.sosTriggered => l10n.alertTitleSos(careRecipientFirstName),
        _ => sourceType.title(l10n, careRecipientFirstName),
      },
      TimelineEventKind.confirmed => l10n.timelineNotCancelled(careRecipientFirstName, FallConfirmationWindow.seconds),
      TimelineEventKind.dismissed => l10n.timelineDismissed(careRecipientFirstName),
      TimelineEventKind.sentTo => l10n.timelineSentTo(names),
      TimelineEventKind.acknowledged => l10n.timelineAcknowledged(names),
      TimelineEventKind.onTheWay => l10n.timelineOnTheWay(names),
      TimelineEventKind.arrived => l10n.timelineArrived(names, careRecipientFirstName),
      TimelineEventKind.stabilized => l10n.alertDetailIncidentStabilized,
      TimelineEventKind.closed => l10n.alertDetailIncidentClosed,
      TimelineEventKind.nextEscalation => l10n.timelineNextEscalation,
    };
  }
}

class _TimelineRow extends StatelessWidget {
  final TimelineEvent event;
  final String text;

  const new({required this.event, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pending = event.kind == TimelineEventKind.nextEscalation;
    final alarming = event.kind == TimelineEventKind.detected || event.kind == TimelineEventKind.confirmed;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: pending ? null : (alarming ? scheme.error : scheme.primary),
              border: pending ? Border.all(color: scheme.onSurfaceVariant, width: 1.5) : null,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatClockTime(event.at, withSeconds: true),
            style: dataLabelStyle.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: pending ? scheme.onSurfaceVariant : scheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
