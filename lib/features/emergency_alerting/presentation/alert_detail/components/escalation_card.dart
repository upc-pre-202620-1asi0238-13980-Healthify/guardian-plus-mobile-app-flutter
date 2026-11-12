import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/text/initials.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_detail/components/detail_card.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/recipient_level.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_detail/alert_detail_state.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/alert_labels.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/status_chip.dart';

/// Who the alert reached and what each contact did. While it waits for an acknowledgement it also shows the
/// countdown to the next escalation level (US11); a broadcast lists everyone at once (US25).
class EscalationCard extends StatelessWidget {
  final List<EscalationContact> contacts;
  final int? escalationSecondsLeft;
  final int ackTimeoutSec;
  final RecipientLevel? currentRecipientLevel;

  const new({
    super.key,
    required this.contacts,
    required this.escalationSecondsLeft,
    required this.ackTimeoutSec,
    required this.currentRecipientLevel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final left = escalationSecondsLeft;
    final description = switch (left) {
      null => 'Cuando alguien la reconozca o vaya en camino, los demás lo verán aquí.',
      _ when currentRecipientLevel == RecipientLevel.primary =>
        'Si no reconoces la alerta, se enviará a tus contactos secundarios.',
      _ => 'Si nadie la reconoce, se enviará a todo el círculo de cuidado.',
    };

    return DetailCard(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                left != null ? 'Escalamiento automático' : 'Aviso enviado a tus contactos',
                style: text.titleMedium,
              ),
            ),
            if (left != null)
              Text(formatCountdown(left), style: dataLabelStyle.copyWith(fontSize: 16, color: scheme.error)),
          ],
        ),
        const SizedBox(height: 4),
        Text(description, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
        if (left != null && ackTimeoutSec > 0) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (1 - left / ackTimeoutSec).clamp(0.0, 1.0),
              minHeight: 6,
              color: scheme.error,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
        ],
        const SizedBox(height: 8),
        for (final item in contacts) _ContactRow(item: item),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  final EscalationContact item;

  const new({required this.item});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final contact = item.contact;
    final isPrimary = contact.priorityOrder == 1;
    final (label, positive) = switch (item.status) {
      ContactStatus.waiting => ('En espera', false),
      ContactStatus.sending => ('Enviando', false),
      ContactStatus.sent => ('Notificada', true),
      ContactStatus.delivered => ('Entregada', true),
      ContactStatus.failed => ('Falló', false),
      ContactStatus.acknowledged => ('Reconoció', true),
      ContactStatus.onTheWay => ('En camino', true),
      ContactStatus.arrived => ('Llegó', true),
      ContactStatus.notNeeded => ('No fue necesario', false),
    };
    final (chipContainer, chipContent) = switch (item.status) {
      ContactStatus.failed => (scheme.errorContainer, scheme.onErrorContainer),
      _ when positive => (scheme.primaryContainer, scheme.onPrimaryContainer),
      _ => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: isPrimary ? scheme.primaryContainer : scheme.surfaceContainerHighest,
            child: Text(
              initialsOf(contact.displayName),
              style: text.labelMedium?.copyWith(color: isPrimary ? scheme.primary : scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contact.displayName, style: text.titleSmall),
                Text(
                  '${isPrimary ? 'Primario' : 'Secundario'} · ${contact.relationship}',
                  style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          StatusChip(text: label, container: chipContainer, content: chipContent, showCheck: positive),
        ],
      ),
    );
  }
}
