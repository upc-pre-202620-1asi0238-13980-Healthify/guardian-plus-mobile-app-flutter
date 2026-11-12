import 'package:guardian_plus_app/features/emergency_alerting/domain/incident_status.dart';

/// Opened when someone acknowledges an alert; closing it resolves the alert.
class Incident {
  final String id;
  final String alertId;
  final IncidentStatus status;
  final DateTime markedInAttentionAt;
  final DateTime? stabilizedAt;
  final DateTime? closedAt;
  final String? notes;

  const new({
    required this.id,
    required this.alertId,
    required this.status,
    required this.markedInAttentionAt,
    this.stabilizedAt,
    this.closedAt,
    this.notes,
  });
}
