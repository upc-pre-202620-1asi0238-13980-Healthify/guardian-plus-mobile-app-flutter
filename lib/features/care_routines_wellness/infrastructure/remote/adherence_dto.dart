/// The adherence of one reminder type in a period as the platform sends it (AdherenceResource).
class AdherenceDto {
  final String type;
  final String from;
  final String to;
  final int due;
  final int confirmed;
  final int percentage;
  final List<DailyAdherenceDto>? days;

  const new({
    required this.type,
    required this.from,
    required this.to,
    required this.due,
    required this.confirmed,
    required this.percentage,
    required this.days,
  });

  factory AdherenceDto.fromJson(Map<String, dynamic> json) {
    return AdherenceDto(
      type: json['type'],
      from: json['from'],
      to: json['to'],
      due: json['due'],
      confirmed: json['confirmed'],
      percentage: json['percentage'],
      days: (json['days'] as List?)?.map((day) => DailyAdherenceDto.fromJson(day)).toList(),
    );
  }
}

class DailyAdherenceDto {
  final String date;
  final int due;
  final int confirmed;
  final int percentage;

  const new({required this.date, required this.due, required this.confirmed, required this.percentage});

  factory DailyAdherenceDto.fromJson(Map<String, dynamic> json) {
    return DailyAdherenceDto(
      date: json['date'],
      due: json['due'],
      confirmed: json['confirmed'],
      percentage: json['percentage'],
    );
  }
}
