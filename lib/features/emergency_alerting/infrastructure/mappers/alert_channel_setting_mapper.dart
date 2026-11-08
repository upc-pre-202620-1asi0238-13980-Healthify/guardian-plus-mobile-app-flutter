import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_channel_setting.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/notification_channel.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/alert_channel_setting_dto.dart';

extension AlertChannelSettingDtoMapper on AlertChannelSettingDto {
  AlertChannelSetting toDomain() {
    return AlertChannelSetting(
      userId: userId,
      channel: NotificationChannelMapper.fromApi(channel),
      enabled: enabled,
      deviceTokenRegistered: deviceTokenRegistered,
    );
  }
}

/// The platform names the channels in upper snake case (PUSH, SMS, IN_APP).
extension NotificationChannelMapper on NotificationChannel {
  String toApi() {
    return switch (this) {
      NotificationChannel.push => 'PUSH',
      NotificationChannel.sms => 'SMS',
      NotificationChannel.inApp => 'IN_APP',
    };
  }

  static NotificationChannel fromApi(String value) {
    return NotificationChannel.values.firstWhere(
      (channel) => channel.toApi() == value,
      orElse: () => throw FormatException('Unknown notification channel: $value'),
    );
  }
}
