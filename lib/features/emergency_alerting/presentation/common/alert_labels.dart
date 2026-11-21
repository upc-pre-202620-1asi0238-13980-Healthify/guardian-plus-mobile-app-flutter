import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_source_type.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/incident_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/severity.dart';
import 'package:guardian_plus_app/l10n/app_localizations.dart';

// Domain values → interface labels, following the label tables of the report (section 3.1.2.2)

extension SeverityLabel on Severity {
  String label(AppLocalizations l10n) => switch (this) {
    Severity.critical => l10n.alertSeverityCritical,
    Severity.high => l10n.alertSeverityHigh,
    Severity.medium => l10n.alertSeverityMedium,
  };
}

extension AlertStatusLabel on AlertStatus {
  String label(AppLocalizations l10n) => switch (this) {
    AlertStatus.pendingConfirmation => l10n.alertStatusPendingConfirmation,
    AlertStatus.triggered => l10n.alertStatusTriggered,
    AlertStatus.escalated => l10n.alertStatusEscalated,
    AlertStatus.acknowledged => l10n.alertStatusAcknowledged,
    AlertStatus.dismissed => l10n.alertStatusDismissed,
    AlertStatus.resolved => l10n.alertStatusResolved,
  };
}

extension IncidentStatusLabel on IncidentStatus {
  String label(AppLocalizations l10n) => switch (this) {
    IncidentStatus.inAttention => l10n.incidentStatusInAttention,
    IncidentStatus.stabilized => l10n.incidentStatusStabilized,
    IncidentStatus.closed => l10n.incidentStatusClosed,
  };
}

extension AlertSourceTypeLabel on AlertSourceType {
  String tag(AppLocalizations l10n) => switch (this) {
    AlertSourceType.fallDetected => l10n.alertSourceFall,
    AlertSourceType.sosTriggered => l10n.alertSourceSos,
    AlertSourceType.vitalSignAnomaly => l10n.alertSourceVitalSigns,
    AlertSourceType.safeZoneViolation => l10n.alertSourceSafeZone,
    AlertSourceType.prolongedInactivity => l10n.alertSourceInactivity,
    AlertSourceType.reminderReissued => l10n.alertSourceReminder,
    AlertSourceType.medicationRestockSuggested => l10n.alertSourceMedication,
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
  String title(AppLocalizations l10n, String careRecipientFirstName) => switch (this) {
    AlertSourceType.fallDetected => l10n.alertTitleFall,
    AlertSourceType.sosTriggered => l10n.alertTitleSos(careRecipientFirstName),
    AlertSourceType.vitalSignAnomaly => l10n.alertTitleVitalSign,
    AlertSourceType.safeZoneViolation => l10n.alertTitleSafeZone,
    AlertSourceType.prolongedInactivity => l10n.alertTitleInactivity,
    AlertSourceType.reminderReissued => l10n.alertTitleReminder,
    AlertSourceType.medicationRestockSuggested => l10n.alertTitleMedication,
  };
}

/// "Hace 42 s", "Hace 6 min"… measured against the screen clock so it keeps moving.
String relativeTime(AppLocalizations l10n, DateTime from, DateTime now) {
  final seconds = _nonNegative(now.difference(from).inSeconds);
  if (seconds < 5) return l10n.alertTimeNow;
  if (seconds < 60) return l10n.alertTimeSecondsAgo(seconds);
  if (seconds < 3600) return l10n.alertTimeMinutesAgo(seconds ~/ 60);
  if (seconds < 86400) return l10n.alertTimeHoursAgo(seconds ~/ 3600);
  return l10n.alertTimeDaysAgo(seconds ~/ 86400);
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
