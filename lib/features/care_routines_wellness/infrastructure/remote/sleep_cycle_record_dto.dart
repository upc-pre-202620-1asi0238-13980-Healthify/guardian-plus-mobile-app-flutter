/// A closed night of sleep as the platform sends it (SleepCycleRecordResource).
class SleepCycleRecordDto {
  final String id;
  final String personUnderCareId;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final int interruptionCount;
  final int continuityScore;
  final String classification;

  const new({
    required this.id,
    required this.personUnderCareId,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.interruptionCount,
    required this.continuityScore,
    required this.classification,
  });

  factory SleepCycleRecordDto.fromJson(Map<String, dynamic> json) {
    return SleepCycleRecordDto(
      id: json['id'],
      personUnderCareId: json['personUnderCareId'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      durationMinutes: json['durationMinutes'],
      interruptionCount: json['interruptionCount'],
      continuityScore: json['continuityScore'],
      classification: json['classification'],
    );
  }
}
