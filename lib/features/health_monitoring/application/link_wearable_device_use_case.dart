import 'package:guardian_plus_app/features/health_monitoring/domain/device_type.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/wearable_device.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/wearable_device_repository.dart';

/// Links the wearable a care recipient will wear, so the platform accepts its readings. The serial number is the
/// one printed on the device (the IoT simulator uses the same ones).
class LinkWearableDeviceUseCase {
  final WearableDeviceRepository repository;

  const new({required this.repository});

  Future<WearableDevice> execute({
    required String careRecipientProfileId,
    required String serialNumber,
    required DeviceType deviceType,
  }) {
    return repository.linkWearableDevice(
      careRecipientProfileId: careRecipientProfileId,
      serialNumber: serialNumber.trim(),
      deviceType: deviceType,
    );
  }
}
