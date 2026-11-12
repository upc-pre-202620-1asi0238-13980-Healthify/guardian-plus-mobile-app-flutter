import 'package:guardian_plus_app/features/emergency_alerting/domain/response_status.dart';

/// A Care Circle member who said "Voy en camino" (US25), and whether they arrived.
class AlertResponse {
  final String id;
  final String responderUserId;
  final ResponseStatus status;
  final DateTime claimedAt;
  final DateTime? completedAt;
  final String? notes;

  const new({
    required this.id,
    required this.responderUserId,
    required this.status,
    required this.claimedAt,
    this.completedAt,
    this.notes,
  });
}
