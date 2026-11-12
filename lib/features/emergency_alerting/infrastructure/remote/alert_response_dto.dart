class AlertResponseDto {
  final String id;
  final String responderUserId;
  final String responseStatus;
  final String claimedAt;
  final String? completedAt;
  final String? notes;

  const new({
    required this.id,
    required this.responderUserId,
    required this.responseStatus,
    required this.claimedAt,
    this.completedAt,
    this.notes,
  });

  factory AlertResponseDto.fromJson(Map<String, dynamic> json) {
    return AlertResponseDto(
      id: json['id'],
      responderUserId: json['responderUserId'],
      responseStatus: json['responseStatus'],
      claimedAt: json['claimedAt'],
      completedAt: json['completedAt'],
      notes: json['notes'],
    );
  }
}
