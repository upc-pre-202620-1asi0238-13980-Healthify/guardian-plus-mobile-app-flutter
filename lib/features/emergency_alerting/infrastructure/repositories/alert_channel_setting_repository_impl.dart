import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_channel_setting.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_channel_setting_repository.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/notification_channel.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/mappers/alert_channel_setting_mapper.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/alert_channel_setting_api.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/configure_alert_channel_request_dto.dart';

class AlertChannelSettingRepositoryImpl implements AlertChannelSettingRepository {
  final AlertChannelSettingApi api;

  const new({required this.api});

  @override
  Future<List<AlertChannelSetting>> getChannelSettings(String userId) async {
    final dtos = await api.getChannelSettings(userId);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<AlertChannelSetting> configureChannel({
    required String userId,
    required NotificationChannel channel,
    required bool enabled,
  }) async {
    final dto = await api.configureChannel(
      userId,
      channel.toApi(),
      ConfigureAlertChannelRequestDto(enabled: enabled),
    );
    return dto.toDomain();
  }
}
