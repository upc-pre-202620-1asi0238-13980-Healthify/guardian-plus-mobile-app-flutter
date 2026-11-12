import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/recurrence_dto.dart';

/// A reminder as the platform sends it (ReminderResource); instants as ISO-8601 strings.
class ReminderDto {
  final String id;
  final String? seriesId;
  final String personUnderCareId;
  final String type;
  final String? title;
  final String? dosage;
  final String? instructions;
  final String? location;
  final int? durationMinutes;
  final String scheduledTime;
  final int? leadTimeMinutes;
  final String? notifyAt;
  final RecurrenceDto? recurrence;
  final String? medicationStockId;
  final String? issuedAt;
  final String? confirmedAt;
  final String status;
  final int? reissueCount;

  const new({
    required this.id,
    required this.seriesId,
    required this.personUnderCareId,
    required this.type,
    required this.title,
    required this.dosage,
    required this.instructions,
    required this.location,
    required this.durationMinutes,
    required this.scheduledTime,
    required this.leadTimeMinutes,
    required this.notifyAt,
    required this.recurrence,
    required this.medicationStockId,
    required this.issuedAt,
    required this.confirmedAt,
    required this.status,
    required this.reissueCount,
  });

  factory ReminderDto.fromJson(Map<String, dynamic> json) {
    return ReminderDto(
      id: json['id'],
      seriesId: json['seriesId'],
      personUnderCareId: json['personUnderCareId'],
      type: json['type'],
      title: json['title'],
      dosage: json['dosage'],
      instructions: json['instructions'],
      location: json['location'],
      durationMinutes: json['durationMinutes'],
      scheduledTime: json['scheduledTime'],
      leadTimeMinutes: json['leadTimeMinutes'],
      notifyAt: json['notifyAt'],
      recurrence: json['recurrence'] != null ? RecurrenceDto.fromJson(json['recurrence']) : null,
      medicationStockId: json['medicationStockId'],
      issuedAt: json['issuedAt'],
      confirmedAt: json['confirmedAt'],
      status: json['status'],
      reissueCount: json['reissueCount'],
    );
  }
}
