import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_source_type.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/fall_confirmation_window.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_detail/alert_detail_state.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_detail/components/detail_card.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/alert_labels.dart';

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
        Text('Seguimiento del incidente', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final event in events) _TimelineRow(event: event, text: _describe(event)),
      ],
    );
  }

  String _describe(TimelineEvent event) {
    final names = event.names.isEmpty ? 'Un miembro del círculo' : event.names.join(', ');
    return switch (event.kind) {
      TimelineEventKind.detected => switch (sourceType) {
        AlertSourceType.fallDetected => 'Caída detectada por la pulsera',
        AlertSourceType.sosTriggered => '$careRecipientFirstName presionó el botón SOS',
        _ => sourceType.title(careRecipientFirstName),
      },
      TimelineEventKind.confirmed =>
        '$careRecipientFirstName no canceló la alerta en ${FallConfirmationWindow.seconds} s',
      TimelineEventKind.dismissed => '$careRecipientFirstName confirmó desde la pulsera que está bien',
      TimelineEventKind.sentTo => 'Alerta enviada a $names',
      TimelineEventKind.acknowledged => '$names reconoció la alerta',
      TimelineEventKind.onTheWay => '$names va en camino',
      TimelineEventKind.arrived => '$names llegó con $careRecipientFirstName',
      TimelineEventKind.stabilized => 'Incidente estabilizado',
      TimelineEventKind.closed => 'Incidente cerrado',
      TimelineEventKind.nextEscalation => 'Envío a los siguientes contactos (pendiente)',
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
