import 'package:guardian_plus_app/features/care_routines_wellness/domain/activity_log_entry.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/activity_monitor_repository.dart';

class GetActivityLogUseCase {
  final ActivityMonitorRepository repository;

  const new({required this.repository});

  Future<List<ActivityLogEntry>> execute({required String personUnderCareId, required int limit}) {
    return repository.getActivityLog(personUnderCareId, limit: limit);
  }
}
