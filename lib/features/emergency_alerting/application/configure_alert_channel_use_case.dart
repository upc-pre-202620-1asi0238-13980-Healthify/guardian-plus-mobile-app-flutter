import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_channel_setting.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_channel_setting_repository.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/notification_channel.dart';

/// Turns one channel on or off (US12). The platform refuses to turn off the member's last channel.
class ConfigureAlertChannelUseCase {
  final AlertChannelSettingRepository repository;

  const new({required this.repository});

  Future<AlertChannelSetting> execute({
    required String userId,
    required NotificationChannel channel,
    required bool enabled,
  }) {
    return repository.configureChannel(userId: userId, channel: channel, enabled: enabled);
  }
}
