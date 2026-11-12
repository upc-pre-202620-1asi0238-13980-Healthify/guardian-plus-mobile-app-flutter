/// A noteworthy activity fact as the platform sends it (ActivityLogEntryResource).
class ActivityLogEntryDto {
  final String id;
  final String type;
  final String occurredAt;
  final int? durationMinutes;
  final int? steps;
  final double? inactiveMinutes;

  const new({
    required this.id,
    required this.type,
    required this.occurredAt,
    required this.durationMinutes,
    required this.steps,
    required this.inactiveMinutes,
  });

  factory ActivityLogEntryDto.fromJson(Map<String, dynamic> json) {
    return ActivityLogEntryDto(
      id: json['id'],
      type: json['type'],
      occurredAt: json['occurredAt'],
      durationMinutes: json['durationMinutes'],
      steps: json['steps'],
      inactiveMinutes: (json['inactiveMinutes'] as num?)?.toDouble(),
    );
  }
}
