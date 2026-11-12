import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_source_type.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/incident_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/severity.dart';

// Domain values → interface labels, following the label tables of the report (section 3.1.2.2)

extension SeverityLabel on Severity {
  String get label => switch (this) {
    Severity.critical => 'Crítica',
    Severity.high => 'Alta',
    Severity.medium => 'Media',
  };
}

extension AlertStatusLabel on AlertStatus {
  String get label => switch (this) {
    AlertStatus.pendingConfirmation => 'Confirmando',
    AlertStatus.triggered => 'Nueva',
    AlertStatus.escalated => 'Escalada',
    AlertStatus.acknowledged => 'Reconocida',
    AlertStatus.dismissed => 'Descartada',
    AlertStatus.resolved => 'Resuelta',
  };
}

extension IncidentStatusLabel on IncidentStatus {
  String get label => switch (this) {
    IncidentStatus.inAttention => 'En atención',
    IncidentStatus.stabilized => 'Estabilizado',
    IncidentStatus.closed => 'Cerrado',
  };
}

extension AlertSourceTypeLabel on AlertSourceType {
  String get tag => switch (this) {
    AlertSourceType.fallDetected => 'Caída',
    AlertSourceType.sosTriggered => 'SOS',
    AlertSourceType.vitalSignAnomaly => 'Signos vitales',
    AlertSourceType.safeZoneViolation => 'Zona segura',
    AlertSourceType.prolongedInactivity => 'Inactividad',
    AlertSourceType.reminderReissued => 'Recordatorio',
    AlertSourceType.medicationRestockSuggested => 'Medicación',
  };

  IconData get icon => switch (this) {
    AlertSourceType.fallDetected => Icons.warning_amber_rounded,
    AlertSourceType.sosTriggered => Icons.sos,
    AlertSourceType.vitalSignAnomaly => Icons.monitor_heart_outlined,
    AlertSourceType.safeZoneViolation => Icons.location_on_outlined,
    AlertSourceType.prolongedInactivity => Icons.hourglass_empty,
    AlertSourceType.reminderReissued => Icons.notifications_outlined,
    AlertSourceType.medicationRestockSuggested => Icons.medication_outlined,
  };

  /// Title of an alert; the SOS one names the person under care ("Elena presionó el botón SOS").
  String title(String careRecipientFirstName) => switch (this) {
    AlertSourceType.fallDetected => 'Posible caída detectada',
    AlertSourceType.sosTriggered => '$careRecipientFirstName presionó el botón SOS',
    AlertSourceType.vitalSignAnomaly => 'Signo vital fuera de rango',
    AlertSourceType.safeZoneViolation => 'Salida de zona segura',
    AlertSourceType.prolongedInactivity => 'Inactividad prolongada',
    AlertSourceType.reminderReissued => 'Recordatorio sin confirmar',
    AlertSourceType.medicationRestockSuggested => 'Medicamento por agotarse',
  };
}

/// "Hace 42 s", "Hace 6 min"… measured against the screen clock so it keeps moving.
String relativeTime(DateTime from, DateTime now) {
  final seconds = _nonNegative(now.difference(from).inSeconds);
  if (seconds < 5) return 'Ahora';
  if (seconds < 60) return 'Hace $seconds s';
  if (seconds < 3600) return 'Hace ${seconds ~/ 60} min';
  if (seconds < 86400) return 'Hace ${seconds ~/ 3600} h';
  return 'Hace ${seconds ~/ 86400} d';
}

/// 42 → "0:42", the escalation countdown format of the prototype.
String formatCountdown(int seconds) => '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

/// Wall-clock time on the phone's time zone: "14:32:05", or "14:32" without seconds.
String formatClockTime(DateTime instant, {bool withSeconds = false}) {
  final local = instant.toLocal();
  String two(int value) => value.toString().padLeft(2, '0');
  final time = '${two(local.hour)}:${two(local.minute)}';
  return withSeconds ? '$time:${two(local.second)}' : time;
}

/// "48 s", "1 min 22 s" (seconds matter while it is short), "18 min" or "1 h 05 min".
String formatDuration(int seconds) {
  if (seconds < 60) return '$seconds s';
  if (seconds < 600 && seconds % 60 != 0) return '${seconds ~/ 60} min ${seconds % 60} s';
  if (seconds < 3600) return '${seconds ~/ 60} min';
  return '${seconds ~/ 3600} h ${((seconds % 3600) ~/ 60).toString().padLeft(2, '0')} min';
}

int _nonNegative(int value) => value < 0 ? 0 : value;
