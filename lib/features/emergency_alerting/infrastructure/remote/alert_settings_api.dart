import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/alert_settings_dto.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/update_alert_settings_request_dto.dart';

class AlertSettingsApi {
  final ApiClient client;

  const new({required this.client});

  Future<AlertSettingsDto> getAlertSettings(String careRecipientProfileId) async {
    final json = await client.get('alert-settings/care-recipient/$careRecipientProfileId');
    return AlertSettingsDto.fromJson(json);
  }

  Future<AlertSettingsDto> updateAlertSettings(
    String careRecipientProfileId,
    UpdateAlertSettingsRequestDto request,
  ) async {
    final json = await client.put('alert-settings/care-recipient/$careRecipientProfileId', body: request.toJson());
    return AlertSettingsDto.fromJson(json);
  }

  Future<AlertSettingsDto> activateSilentMode(String careRecipientProfileId) async {
    final json = await client.post('alert-settings/care-recipient/$careRecipientProfileId/silent-mode');
    return AlertSettingsDto.fromJson(json);
  }

  Future<AlertSettingsDto> deactivateSilentMode(String careRecipientProfileId) async {
    final json = await client.delete('alert-settings/care-recipient/$careRecipientProfileId/silent-mode');
    return AlertSettingsDto.fromJson(json);
  }
}
