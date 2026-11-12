/// How a reminder repeats, as the platform sends and receives it (RecurrenceResource).
class RecurrenceDto {
  final String frequency;
  final List<String>? daysOfWeek;
  final int? intervalHours;

  const new({required this.frequency, this.daysOfWeek, this.intervalHours});

  factory RecurrenceDto.fromJson(Map<String, dynamic> json) {
    return RecurrenceDto(
      frequency: json['frequency'],
      daysOfWeek: (json['daysOfWeek'] as List?)?.cast<String>(),
      intervalHours: json['intervalHours'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frequency': frequency,
      'daysOfWeek': ?daysOfWeek,
      'intervalHours': ?intervalHours,
    };
  }
}
