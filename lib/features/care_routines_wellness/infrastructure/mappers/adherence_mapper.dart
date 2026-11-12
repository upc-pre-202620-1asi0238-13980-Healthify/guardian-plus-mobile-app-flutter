import 'package:guardian_plus_app/features/care_routines_wellness/domain/adherence.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/mappers/reminder_enums_mapper.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/adherence_dto.dart';

extension AdherenceDtoMapper on AdherenceDto {
  Adherence toDomain() {
    return Adherence(
      type: ReminderTypeMapper.fromApi(type),
      from: DateTime.parse(from),
      to: DateTime.parse(to),
      due: due,
      confirmed: confirmed,
      percentage: percentage,
      days: (days ?? []).map((day) => day.toDomain()).toList(),
    );
  }
}

extension DailyAdherenceDtoMapper on DailyAdherenceDto {
  DailyAdherence toDomain() {
    return DailyAdherence(date: DateTime.parse(date), due: due, confirmed: confirmed, percentage: percentage);
  }
}
