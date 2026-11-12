import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/alert_delivery_dto.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/alert_response_dto.dart';

/// Response of GET /alerts/{id} and of the alert commands (AlertResource).
class AlertDto {
  final String id;
  final String careRecipientProfileId;
  final String sourceType;
  final String severity;
  final String status;
  final String? currentRecipientLevel;
  final String triggeredAt;
  final String? confirmedAt;
  final String? lastDispatchedAt;
  final String? acknowledgedAt;
  final String? acknowledgedByUserId;
  final String? resolvedAt;
  final List<AlertDeliveryDto> deliveries;
  final List<AlertResponseDto> responses;

  const new({
    required this.id,
    required this.careRecipientProfileId,
    required this.sourceType,
    required this.severity,
    required this.status,
    this.currentRecipientLevel,
    required this.triggeredAt,
    this.confirmedAt,
    this.lastDispatchedAt,
    this.acknowledgedAt,
    this.acknowledgedByUserId,
    this.resolvedAt,
    this.deliveries = const [],
    this.responses = const [],
  });

  factory AlertDto.fromJson(Map<String, dynamic> json) {
    return AlertDto(
      id: json['id'],
      careRecipientProfileId: json['careRecipientProfileId'],
      sourceType: json['sourceType'],
      severity: json['severity'],
      status: json['status'],
      currentRecipientLevel: json['currentRecipientLevel'],
      triggeredAt: json['triggeredAt'],
      confirmedAt: json['confirmedAt'],
      lastDispatchedAt: json['lastDispatchedAt'],
      acknowledgedAt: json['acknowledgedAt'],
      acknowledgedByUserId: json['acknowledgedByUserId'],
      resolvedAt: json['resolvedAt'],
      deliveries: [for (final item in json['deliveries'] ?? const []) AlertDeliveryDto.fromJson(item)],
      responses: [for (final item in json['responses'] ?? const []) AlertResponseDto.fromJson(item)],
    );
  }
}
