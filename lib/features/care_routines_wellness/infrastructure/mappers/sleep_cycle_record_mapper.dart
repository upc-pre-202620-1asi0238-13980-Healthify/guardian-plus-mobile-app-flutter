import 'package:guardian_plus_app/features/care_routines_wellness/domain/sleep_classification.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/sleep_cycle_record.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/sleep_cycle_record_dto.dart';

extension SleepCycleRecordDtoMapper on SleepCycleRecordDto {
  SleepCycleRecord toDomain() {
    return SleepCycleRecord(
      id: id,
      startTime: DateTime.parse(startTime).toLocal(),
      endTime: DateTime.parse(endTime).toLocal(),
      durationMinutes: durationMinutes,
      interruptionCount: interruptionCount,
      continuityScore: continuityScore,
      classification: SleepClassificationMapper.fromApi(classification),
    );
  }
}

/// The platform names the sleep classifications in upper case (REGULAR, FRAGMENTED).
extension SleepClassificationMapper on SleepClassification {
  String toApi() {
    return switch (this) {
      SleepClassification.regular => 'REGULAR',
      SleepClassification.fragmented => 'FRAGMENTED',
    };
  }

  static SleepClassification fromApi(String value) {
    return SleepClassification.values.firstWhere(
      (classification) => classification.toApi() == value,
      orElse: () => throw FormatException('Unknown sleep classification: $value'),
    );
  }
}
