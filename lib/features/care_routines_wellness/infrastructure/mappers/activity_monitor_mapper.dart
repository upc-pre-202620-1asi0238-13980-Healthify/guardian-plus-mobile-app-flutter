import 'package:guardian_plus_app/features/care_routines_wellness/domain/activity_log_entry.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/activity_monitor.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/activity_status.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/mappers/local_time_mapper.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/activity_log_entry_dto.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/activity_monitor_dto.dart';

// Detection settings exist before the first sample, so the threshold falls back to the platform default
const _defaultThresholdMinutes = 60;

extension ActivityMonitorDtoMapper on ActivityMonitorDto {
  ActivityMonitor toDomain() {
    return ActivityMonitor(
      status: ActivityStatusMapper.fromApi(status),
      inactivitySince: inactivitySince != null ? DateTime.parse(inactivitySince!).toLocal() : null,
      inactiveMinutes: inactiveMinutes ?? 0.0,
      lastMovementAt: lastMovementAt != null ? DateTime.parse(lastMovementAt!).toLocal() : null,
      lastSampleAt: lastSampleAt != null ? DateTime.parse(lastSampleAt!).toLocal() : null,
      detectionEnabled: detectionEnabled,
      thresholdMinutes: thresholdMinutes ?? _defaultThresholdMinutes,
      watchHoursStart: watchHoursStart != null ? LocalTimeMapper.fromApi(watchHoursStart!) : null,
      watchHoursEnd: watchHoursEnd != null ? LocalTimeMapper.fromApi(watchHoursEnd!) : null,
    );
  }
}

extension ActivityLogEntryDtoMapper on ActivityLogEntryDto {
  /// Null for an entry type the app does not know yet, so it is left out rather than failing the whole log.
  ActivityLogEntry? toDomainOrNull() {
    final entryType = ActivityLogEntryTypeMapper.tryFromApi(type);
    if (entryType == null) return null;
    return ActivityLogEntry(
      id: id,
      type: entryType,
      occurredAt: DateTime.parse(occurredAt).toLocal(),
      durationMinutes: durationMinutes,
      steps: steps,
      inactiveMinutes: inactiveMinutes,
    );
  }
}

/// The platform names the activity statuses in upper snake case (NORMAL, INACTIVITY_DETECTED).
extension ActivityStatusMapper on ActivityStatus {
  String toApi() {
    return switch (this) {
      ActivityStatus.normal => 'NORMAL',
      ActivityStatus.inactivityDetected => 'INACTIVITY_DETECTED',
    };
  }

  static ActivityStatus fromApi(String value) {
    return ActivityStatus.values.firstWhere(
      (status) => status.toApi() == value,
      orElse: () => throw FormatException('Unknown activity status: $value'),
    );
  }
}

extension ActivityLogEntryTypeMapper on ActivityLogEntryType {
  String toApi() {
    return switch (this) {
      ActivityLogEntryType.movementDetected => 'MOVEMENT_DETECTED',
      ActivityLogEntryType.walkDetected => 'WALK_DETECTED',
      ActivityLogEntryType.prolongedInactivityDetected => 'PROLONGED_INACTIVITY_DETECTED',
    };
  }

  static ActivityLogEntryType? tryFromApi(String value) {
    for (final type in ActivityLogEntryType.values) {
      if (type.toApi() == value) return type;
    }
    return null;
  }
}
