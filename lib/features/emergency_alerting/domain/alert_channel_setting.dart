import 'package:guardian_plus_app/features/emergency_alerting/domain/notification_channel.dart';

/// Whether a Care Circle member receives alerts through one channel (push, SMS or in-app).
class AlertChannelSetting {
  final String userId;
  final NotificationChannel channel;
  final bool enabled;
  final bool deviceTokenRegistered;

  const new({
    required this.userId,
    required this.channel,
    required this.enabled,
    required this.deviceTokenRegistered,
  });
}
