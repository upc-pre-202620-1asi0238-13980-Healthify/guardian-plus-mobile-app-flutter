import 'package:guardian_plus_app/features/care_routines_wellness/domain/sleep_cycle_record.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/sleep_cycle_record_repository.dart';

class GetSleepCycleRecordsUseCase {
  final SleepCycleRecordRepository repository;

  const new({required this.repository});

  Future<List<SleepCycleRecord>> execute(String personUnderCareId, {DateTime? from}) {
    return repository.getSleepCycleRecords(personUnderCareId, from: from);
  }
}
