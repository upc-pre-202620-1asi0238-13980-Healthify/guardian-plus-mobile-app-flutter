/// Item of GET /alerts/active/... , GET /alerts/pending/... and the history pages (AlertSummaryResource).
class AlertSummaryDto {
  final String id;
  final String careRecipientProfileId;
  final String sourceType;
  final String severity;
  final String status;
  // null while a fall waits for its 20 s confirmation window: it was not sent to anyone yet
  final String? currentRecipientLevel;
  final String triggeredAt;
  final String? acknowledgedAt;

  const new({
    required this.id,
    required this.careRecipientProfileId,
    required this.sourceType,
    required this.severity,
    required this.status,
    this.currentRecipientLevel,
    required this.triggeredAt,
    this.acknowledgedAt,
  });

  factory AlertSummaryDto.fromJson(Map<String, dynamic> json) {
    return AlertSummaryDto(
      id: json['id'],
      careRecipientProfileId: json['careRecipientProfileId'],
      sourceType: json['sourceType'],
      severity: json['severity'],
      status: json['status'],
      currentRecipientLevel: json['currentRecipientLevel'],
      triggeredAt: json['triggeredAt'],
      acknowledgedAt: json['acknowledgedAt'],
    );
  }
}
