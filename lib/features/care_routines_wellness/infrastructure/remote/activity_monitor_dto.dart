/// The activity monitor of a person under care as the platform sends it (ActivityMonitorResource).
class ActivityMonitorDto {
  final String id;
  final String personUnderCareId;
  final String status;
  final String? inactivitySince;
  final double? inactiveMinutes;
  final String? lastMovementAt;
  final String? lastSampleAt;
  final bool detectionEnabled;
  final int? thresholdMinutes;
  final String? watchHoursStart;
  final String? watchHoursEnd;

  const new({
    required this.id,
    required this.personUnderCareId,
    required this.status,
    required this.inactivitySince,
    required this.inactiveMinutes,
    required this.lastMovementAt,
    required this.lastSampleAt,
    required this.detectionEnabled,
    required this.thresholdMinutes,
    required this.watchHoursStart,
    required this.watchHoursEnd,
  });

  factory ActivityMonitorDto.fromJson(Map<String, dynamic> json) {
    return ActivityMonitorDto(
      id: json['id'],
      personUnderCareId: json['personUnderCareId'],
      status: json['status'],
      inactivitySince: json['inactivitySince'],
      inactiveMinutes: (json['inactiveMinutes'] as num?)?.toDouble(),
      lastMovementAt: json['lastMovementAt'],
      lastSampleAt: json['lastSampleAt'],
      detectionEnabled: json['detectionEnabled'],
      thresholdMinutes: json['thresholdMinutes'],
      watchHoursStart: json['watchHoursStart'],
      watchHoursEnd: json['watchHoursEnd'],
    );
  }
}
