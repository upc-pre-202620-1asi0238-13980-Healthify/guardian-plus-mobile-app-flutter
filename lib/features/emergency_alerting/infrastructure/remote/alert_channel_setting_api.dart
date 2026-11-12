import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/alert_channel_setting_dto.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/configure_alert_channel_request_dto.dart';

class AlertChannelSettingApi {
  final ApiClient client;

  const new({required this.client});

  Future<List<AlertChannelSettingDto>> getChannelSettings(String userId) async {
    final List jsons = await client.get('alert-channel-settings/user/$userId');
    return jsons.map((json) => AlertChannelSettingDto.fromJson(json)).toList();
  }

  Future<AlertChannelSettingDto> configureChannel(
    String userId,
    String channel,
    ConfigureAlertChannelRequestDto request,
  ) async {
    final json = await client.put('alert-channel-settings/user/$userId/channels/$channel', body: request.toJson());
    return AlertChannelSettingDto.fromJson(json);
  }
}
