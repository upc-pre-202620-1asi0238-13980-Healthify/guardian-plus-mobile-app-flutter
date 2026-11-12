import 'package:guardian_plus_app/features/care_routines_wellness/domain/activity_monitor.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/activity_monitor_repository.dart';

/// Turns prolonged-inactivity detection on or off and sets its threshold (30 to 240 minutes).
class ConfigureInactivityDetectionUseCase {
  final ActivityMonitorRepository repository;

  const new({required this.repository});

  Future<ActivityMonitor> execute({
    required String personUnderCareId,
    required bool enabled,
    required int thresholdMinutes,
  }) {
    return repository.configureInactivityDetection(
      personUnderCareId: personUnderCareId,
      enabled: enabled,
      thresholdMinutes: thresholdMinutes,
    );
  }
}
