import 'package:guardian_plus_app/core/network/api_exception.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/activity_log_entry.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/activity_monitor.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/activity_monitor_repository.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/mappers/activity_monitor_mapper.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/activity_monitor_api.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/configure_inactivity_detection_request_dto.dart';

class ActivityMonitorRepositoryImpl implements ActivityMonitorRepository {
  final ActivityMonitorApi api;

  const new({required this.api});

  // 404 is the platform's "no telemetry or configuration received yet"
  @override
  Future<ActivityMonitor?> getActivityMonitor(String personUnderCareId) async {
    try {
      final dto = await api.getActivityMonitor(personUnderCareId);
      return dto.toDomain();
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<ActivityMonitor> configureInactivityDetection({
    required String personUnderCareId,
    required bool enabled,
    required int thresholdMinutes,
  }) async {
    final dto = await api.configureInactivityDetection(
      personUnderCareId,
      ConfigureInactivityDetectionRequestDto(enabled: enabled, thresholdMinutes: thresholdMinutes),
    );
    return dto.toDomain();
  }

  @override
  Future<List<ActivityLogEntry>> getActivityLog(String personUnderCareId, {required int limit}) async {
    final dtos = await api.getActivityLog(personUnderCareId, limit: limit);
    return dtos.map((dto) => dto.toDomainOrNull()).nonNulls.toList();
  }
}
