import 'package:guardian_plus_app/features/emergency_alerting/domain/delivery_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/notification_channel.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/recipient_level.dart';

/// The alert sent to one Care Circle member through one channel.
class AlertDelivery {
  final String id;
  final String recipientUserId;
  final RecipientLevel recipientLevel;
  final NotificationChannel channel;
  final DeliveryStatus status;
  final DateTime? sentAt;
  final DateTime? deliveredAt;

  const new({
    required this.id,
    required this.recipientUserId,
    required this.recipientLevel,
    required this.channel,
    required this.status,
    this.sentAt,
    this.deliveredAt,
  });
}
