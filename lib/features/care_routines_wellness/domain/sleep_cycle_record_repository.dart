import 'package:guardian_plus_app/features/care_routines_wellness/domain/sleep_cycle_record.dart';

abstract class SleepCycleRecordRepository {
  /// Closed nights, most recent first, optionally only those that ended at or after [from].
  Future<List<SleepCycleRecord>> getSleepCycleRecords(String personUnderCareId, {DateTime? from});
}