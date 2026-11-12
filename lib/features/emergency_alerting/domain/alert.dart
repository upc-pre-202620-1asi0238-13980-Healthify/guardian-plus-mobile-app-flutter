import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_delivery.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_response.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_source_type.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/recipient_level.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/response_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/severity.dart';

class Alert {
  final String id;
  final String careRecipientProfileId;
  final AlertSourceType sourceType;
  final Severity severity;
  final AlertStatus status;
  // null until the alert is dispatched for the first time
  final RecipientLevel? currentRecipientLevel;
  final DateTime triggeredAt;
  final DateTime? acknowledgedAt;
  // The fields below are only present when the alert is read in full (GET /alerts/{id}), not in list summaries
  final DateTime? confirmedAt;
  final DateTime? lastDispatchedAt;
  final String? acknowledgedByUserId;
  final DateTime? resolvedAt;
  final List<AlertDelivery> deliveries;
  final List<AlertResponse> responses;

  const new({
    required this.id,
    required this.careRecipientProfileId,
    required this.sourceType,
    required this.severity,
    required this.status,
    required this.currentRecipientLevel,
    required this.triggeredAt,
    this.acknowledgedAt,
    this.confirmedAt,
    this.lastDispatchedAt,
    this.acknowledgedByUserId,
    this.resolvedAt,
    this.deliveries = const [],
    this.responses = const [],
  });

  /// The member currently on the way, if any; the platform allows only one at a time.
  AlertResponse? get activeResponse {
    for (final response in responses) {
      if (response.status == ResponseStatus.claimed) return response;
    }
    return null;
  }
}
