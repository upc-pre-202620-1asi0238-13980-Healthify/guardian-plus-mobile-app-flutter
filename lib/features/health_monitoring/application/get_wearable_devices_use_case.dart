import 'package:guardian_plus_app/features/health_monitoring/domain/wearable_device.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/wearable_device_repository.dart';

class GetWearableDevicesUseCase {
  final WearableDeviceRepository repository;

  const new({required this.repository});

  Future<List<WearableDevice>> execute(String careRecipientProfileId) {
    return repository.getWearableDevices(careRecipientProfileId);
  }
}
