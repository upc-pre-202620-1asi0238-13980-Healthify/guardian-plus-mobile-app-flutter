import 'package:guardian_plus_app/features/health_monitoring/domain/device_type.dart';

class WearableDevice {
  final String id;
  final String careRecipientId;
  final String serialNumber;
  final DeviceType deviceType;
  final DateTime linkedAt;

  const new({
    required this.id,
    required this.careRecipientId,
    required this.serialNumber,
    required this.deviceType,
    required this.linkedAt,
  });
}
