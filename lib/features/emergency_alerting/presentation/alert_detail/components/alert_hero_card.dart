import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_source_type.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/fall_confirmation_window.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/incident.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/incident_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/severity.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/alert_labels.dart';

/// Top card of the detail. Red for critical alerts still in play (with the SOS variant of US15),
/// orange or yellow for high and medium ones, and green once the incident is stabilized or over.
class AlertHeroCard extends StatelessWidget {
  final Alert alert;
  final Incident? incident;
  final bool calm;
  final String careRecipientFirstName;
  final int? confirmationSecondsLeft;
  final DateTime now;

  const new({
    super.key,
    required this.alert,
    required this.incident,
    required this.calm,
    required this.careRecipientFirstName,
    required this.confirmationSecondsLeft,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (container, content) = switch (alert.severity) {
      _ when calm => (scheme.primary, scheme.onPrimary),
      Severity.critical => (scheme.error, scheme.onError),
      Severity.high => (scheme.tertiary, scheme.onTertiary),
      Severity.medium => (GuardianColors.noticeContainer, GuardianColors.onNoticeContainer),
    };
    final isActiveSos = alert.sourceType == AlertSourceType.sosTriggered && !calm;
    final tag = isActiveSos ? 'Máxima prioridad' : '${alert.sourceType.tag} · ${alert.severity.label}';

    return Material(
      color: container,
      elevation: calm ? 2 : 6,
      borderRadius: BorderRadius.circular(GuardianRadius.large),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: content.withAlpha(46),
                    borderRadius: BorderRadius.circular(GuardianRadius.subtle),
                  ),
                  child: Text(
                    tag.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: content),
                  ),
                ),
                Text(
                  calm ? formatClockTime(alert.triggeredAt) : relativeTime(alert.triggeredAt, now),
                  style: dataLabelStyle.copyWith(color: content),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isActiveSos)
              _SosHeadline(careRecipientFirstName: careRecipientFirstName, container: container, content: content)
            else ...[
              _IconHeadline(
                alert: alert,
                incident: incident,
                careRecipientFirstName: careRecipientFirstName,
                content: content,
              ),
              const SizedBox(height: 16),
              _HeroTiles(
                alert: alert,
                incident: incident,
                calm: calm,
                confirmationSecondsLeft: confirmationSecondsLeft,
                now: now,
                content: content,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SosHeadline extends StatelessWidget {
  final String careRecipientFirstName;
  final Color container;
  final Color content;

  const new({required this.careRecipientFirstName, required this.container, required this.content});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Column(
        children: [
          // Round pulse: the shape the style guide reserves for SOS
          CircleAvatar(
            radius: 56,
            backgroundColor: content.withAlpha(41),
            child: CircleAvatar(
              radius: 42,
              backgroundColor: content,
              child: Text(
                'SOS',
                style: text.headlineMedium?.copyWith(color: container, fontSize: 26, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$careRecipientFirstName presionó el botón SOS',
            textAlign: TextAlign.center,
            style: text.titleLarge?.copyWith(color: content),
          ),
          const SizedBox(height: 6),
          Text(
            'Pulsación sostenida de 3 s en la pulsera · Se envió su ubicación a tus contactos',
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: content.withAlpha(217)),
          ),
        ],
      ),
    );
  }
}

class _IconHeadline extends StatelessWidget {
  final Alert alert;
  final Incident? incident;
  final String careRecipientFirstName;
  final Color content;

  const new({required this.alert, required this.incident, required this.careRecipientFirstName, required this.content});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final sourceTitle = alert.sourceType.title(careRecipientFirstName);
    final title = switch (alert.status) {
      AlertStatus.dismissed => 'Falsa alarma descartada por $careRecipientFirstName',
      _ when incident?.status == IncidentStatus.closed || alert.status == AlertStatus.resolved => 'Incidente cerrado',
      _ when incident?.status == IncidentStatus.stabilized => 'Incidente estabilizado',
      _ when alert.sourceType == AlertSourceType.fallDetected && alert.status != AlertStatus.pendingConfirmation =>
        '$careRecipientFirstName no respondió tras una caída',
      _ => sourceTitle,
    };
    final subtitle = [
      if (title != sourceTitle && incident != null) sourceTitle,
      if (alert.sourceType == AlertSourceType.fallDetected) 'Impacto detectado por la pulsera',
    ].join(' · ');

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: content.withAlpha(46),
          child: Icon(alert.sourceType.icon, size: 24, color: content),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: text.titleLarge?.copyWith(color: content)),
              if (subtitle.isNotEmpty) Text(subtitle, style: text.bodyMedium?.copyWith(color: content.withAlpha(217))),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroTiles extends StatelessWidget {
  final Alert alert;
  final Incident? incident;
  final bool calm;
  final int? confirmationSecondsLeft;
  final DateTime now;
  final Color content;

  const new({
    required this.alert,
    required this.incident,
    required this.calm,
    required this.confirmationSecondsLeft,
    required this.now,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final List<(String, String)> tiles;
    if (calm) {
      final endedAt = incident?.closedAt ?? incident?.stabilizedAt ?? alert.resolvedAt ?? now;
      tiles = [
        ('Detectada', formatClockTime(alert.triggeredAt)),
        (incident?.status == IncidentStatus.stabilized ? 'Estabilizada' : 'Cerrada', formatClockTime(endedAt)),
        ('Duración', formatDuration(_seconds(alert.triggeredAt, endedAt))),
      ];
    } else {
      final left = confirmationSecondsLeft;
      tiles = [
        if (alert.sourceType == AlertSourceType.fallDetected)
          ('Ventana de cancelación', left != null ? 'Quedan $left s' : 'Vencida · ${FallConfirmationWindow.seconds} s')
        else
          ('Detectada', formatClockTime(alert.triggeredAt)),
        ('Desde la detección', formatCountdown(_seconds(alert.triggeredAt, now))),
      ];
    }

    return Row(
      children: [
        for (final (index, (label, value)) in tiles.indexed) ...[
          if (index > 0) const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: content.withAlpha(36),
                borderRadius: BorderRadius.circular(GuardianRadius.medium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: content.withAlpha(217))),
                  const SizedBox(height: 2),
                  Text(value, style: dataLabelStyle.copyWith(color: content)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  static int _seconds(DateTime from, DateTime to) {
    final seconds = to.difference(from).inSeconds;
    return seconds < 0 ? 0 : seconds;
  }
}
