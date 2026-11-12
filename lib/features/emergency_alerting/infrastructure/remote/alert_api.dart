import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/acknowledge_alert_request_dto.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/alert_dto.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/alert_summary_dto.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/claim_alert_response_request_dto.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/notes_request_dto.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/page_dto.dart';

class AlertApi {
  final ApiClient client;

  const new({required this.client});

  /// Filters that are null are not sent, so the platform applies none.
  Future<PageDto<AlertSummaryDto>> getAlertHistory({
    required String careRecipientProfileId,
    String? severity,
    String? from,
    String? to,
    required int page,
    required int size,
  }) async {
    final query = Uri(
      queryParameters: {
        'careRecipientProfileId': careRecipientProfileId,
        'severity': ?severity,
        'from': ?from,
        'to': ?to,
        'page': '$page',
        'size': '$size',
      },
    ).query;
    final json = await client.get('alerts?$query');
    return PageDto.fromJson(json, AlertSummaryDto.fromJson);
  }

  Future<List<AlertSummaryDto>> getActiveAlerts(String careRecipientProfileId) async {
    final List jsons = await client.get('alerts/active/care-recipient/$careRecipientProfileId');
    return jsons.map((json) => AlertSummaryDto.fromJson(json)).toList();
  }

  Future<List<AlertSummaryDto>> getPendingAlerts(String userId) async {
    final List jsons = await client.get('alerts/pending/recipient/$userId');
    return jsons.map((json) => AlertSummaryDto.fromJson(json)).toList();
  }

  Future<AlertDto> getAlertById(String alertId) async {
    final json = await client.get('alerts/$alertId');
    return AlertDto.fromJson(json);
  }

  Future<AlertDto> acknowledgeAlert(String alertId, AcknowledgeAlertRequestDto request) async {
    final json = await client.post('alerts/$alertId/acknowledge', body: request.toJson());
    return AlertDto.fromJson(json);
  }

  Future<AlertDto> claimAlertResponse(String alertId, ClaimAlertResponseRequestDto request) async {
    final json = await client.post('alerts/$alertId/responses', body: request.toJson());
    return AlertDto.fromJson(json);
  }

  Future<AlertDto> completeAlertResponse(String alertId, String responseId, NotesRequestDto request) async {
    final json = await client.post('alerts/$alertId/responses/$responseId/complete', body: request.toJson());
    return AlertDto.fromJson(json);
  }
}
