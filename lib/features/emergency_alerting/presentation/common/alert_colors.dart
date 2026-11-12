import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/incident_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/severity.dart';

/// Container and content colors of a chip, badge or icon circle.
typedef ToneColors = ({Color container, Color content});

// Semantic colors, following the state label table of the report (section 3.1.2.2)

/// Red, orange and yellow, like a traffic light.
extension SeverityColors on Severity {
  ToneColors colors(ColorScheme scheme) => switch (this) {
    Severity.critical => (container: scheme.errorContainer, content: scheme.onErrorContainer),
    Severity.high => (container: scheme.tertiaryContainer, content: scheme.tertiary),
    Severity.medium => (container: GuardianColors.pastelYellow, content: GuardianColors.pastelYellowText),
  };
}

extension AlertStatusColors on AlertStatus {
  ToneColors colors(ColorScheme scheme) => switch (this) {
    AlertStatus.pendingConfirmation => (
      container: GuardianColors.pastelYellow,
      content: GuardianColors.pastelYellowText,
    ),
    AlertStatus.triggered ||
    AlertStatus.escalated => (container: scheme.errorContainer, content: scheme.onErrorContainer),
    AlertStatus.acknowledged => (container: scheme.tertiaryContainer, content: scheme.tertiary),
    AlertStatus.dismissed ||
    AlertStatus.resolved => (container: scheme.surfaceContainerHighest, content: scheme.onSurfaceVariant),
  };
}

extension IncidentStatusColors on IncidentStatus {
  ToneColors colors(ColorScheme scheme) => switch (this) {
    IncidentStatus.inAttention => (container: scheme.tertiaryContainer, content: scheme.tertiary),
    IncidentStatus.stabilized => (container: scheme.primaryContainer, content: scheme.onPrimaryContainer),
    IncidentStatus.closed => (container: scheme.surfaceContainerHighest, content: scheme.onSurfaceVariant),
  };
}
