import 'package:guardian_plus_app/features/care_routines_wellness/domain/sleep_cycle_record.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/sleep_cycle_record_repository.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/mappers/sleep_cycle_record_mapper.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/sleep_cycle_record_api.dart';

class SleepCycleRecordRepositoryImpl implements SleepCycleRecordRepository {
  final SleepCycleRecordApi api;

  const new({required this.api});

  @override
  Future<List<SleepCycleRecord>> getSleepCycleRecords(String personUnderCareId, {DateTime? from}) async {
    final dtos = await api.getSleepCycleRecords(personUnderCareId, from: from?.toUtc().toIso8601String());
    return dtos.map((dto) => dto.toDomain()).toList()..sort((a, b) => b.endTime.compareTo(a.endTime));
  }
}
