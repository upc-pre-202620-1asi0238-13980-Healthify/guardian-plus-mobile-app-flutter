import 'package:guardian_plus_app/features/care_routines_wellness/domain/activity_log_entry.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/activity_monitor.dart';

abstract class ActivityMonitorRepository {
  /// Null until the wristband sends its first activity sample or the family configures detection.
  Future<ActivityMonitor?> getActivityMonitor(String personUnderCareId);

  /// Turns prolonged-inactivity detection on or off and sets its threshold (30 to 240 minutes).
  Future<ActivityMonitor> configureInactivityDetection({
    required String personUnderCareId,
    required bool enabled,
    required int thresholdMinutes,
  });

  /// Most recent noteworthy activity, newest first.
  Future<List<ActivityLogEntry>> getActivityLog(String personUnderCareId, {required int limit});
}