import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/activity_log_entry_dto.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/activity_monitor_dto.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/configure_inactivity_detection_request_dto.dart';

class ActivityMonitorApi {
  final ApiClient client;

  const new({required this.client});

  Future<ActivityMonitorDto> getActivityMonitor(String personUnderCareId) async {
    final json = await client.get('activity-monitors/citizen/$personUnderCareId');
    return ActivityMonitorDto.fromJson(json);
  }

  Future<ActivityMonitorDto> configureInactivityDetection(
    String personUnderCareId,
    ConfigureInactivityDetectionRequestDto request,
  ) async {
    final json = await client.put(
      'activity-monitors/citizen/$personUnderCareId/inactivity-detection',
      body: request.toJson(),
    );
    return ActivityMonitorDto.fromJson(json);
  }

  Future<List<ActivityLogEntryDto>> getActivityLog(String personUnderCareId, {required int limit}) async {
    final List jsons = await client.get('activity-monitors/citizen/$personUnderCareId/log-entries?limit=$limit');
    return jsons.map((json) => ActivityLogEntryDto.fromJson(json)).toList();
  }
}
