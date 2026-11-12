import 'package:guardian_plus_app/features/care_routines_wellness/domain/activity_monitor.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/activity_monitor_repository.dart';

class GetActivityMonitorUseCase {
  final ActivityMonitorRepository repository;

  const new({required this.repository});

  Future<ActivityMonitor?> execute(String personUnderCareId) {
    return repository.getActivityMonitor(personUnderCareId);
  }
}
