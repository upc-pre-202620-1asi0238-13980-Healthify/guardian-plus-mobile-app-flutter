import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_channel_setting.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/notification_channel.dart';

abstract class AlertChannelSettingRepository {
  /// Only the channels the member configured; a member with none receives in-app alerts.
  Future<List<AlertChannelSetting>> getChannelSettings(String userId);

  Future<AlertChannelSetting> configureChannel({
    required String userId,
    required NotificationChannel channel,
    required bool enabled,
  });
}
