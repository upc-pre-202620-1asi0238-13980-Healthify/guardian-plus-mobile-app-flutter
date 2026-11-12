import 'package:guardian_plus_app/features/health_monitoring/domain/device_type.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/wearable_device.dart';

abstract class WearableDeviceRepository {
  Future<List<WearableDevice>> getWearableDevices(String careRecipientProfileId);

  /// Links a device to the care recipient; 409 if its serial number is already linked.
  Future<WearableDevice> linkWearableDevice({
    required String careRecipientProfileId,
    required String serialNumber,
    required DeviceType deviceType,
  });
}
