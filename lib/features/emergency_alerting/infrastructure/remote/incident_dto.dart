/// An incident as the platform sends it (IncidentResource).
class IncidentDto {
  final String id;
  final String alertId;
  final String status;
  final String markedInAttentionAt;
  final String? stabilizedAt;
  final String? closedAt;
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

  factory IncidentDto.fromJson(Map<String, dynamic> json) {
    return IncidentDto(
      id: json['id'],
      alertId: json['alertId'],
      status: json['status'],
      markedInAttentionAt: json['markedInAttentionAt'],
      stabilizedAt: json['stabilizedAt'],
      closedAt: json['closedAt'],
      notes: json['notes'],
    );
  }
}
