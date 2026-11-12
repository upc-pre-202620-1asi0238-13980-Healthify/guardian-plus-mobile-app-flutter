import 'package:guardian_plus_app/features/care_routines_wellness/domain/activity_status.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/local_time.dart';

/// Daytime watch for prolonged inactivity and the last movement the wristband reported.
class ActivityMonitor {
  final ActivityStatus status;
  final DateTime? inactivitySince;
  // Current minutes without movement, e.g. 3.3 for "03:18"
  final double inactiveMinutes;
  final DateTime? lastMovementAt;
  // Last telemetry sample received, i.e. when the wristband last synced
  final DateTime? lastSampleAt;
  final bool detectionEnabled;
  final int thresholdMinutes;
  // Inactivity is only watched outside the sleep window, e.g. 07:00 to 22:00
  final LocalTime? watchHoursStart;
  final LocalTime? watchHoursEnd;

  const new({
    required this.status,
    required this.inactivitySince,
    required this.inactiveMinutes,
    required this.lastMovementAt,
    required this.lastSampleAt,
    required this.detectionEnabled,
    required this.thresholdMinutes,
    required this.watchHoursStart,
    required this.watchHoursEnd,
  });
}