import 'package:guardian_plus_app/features/health_monitoring/domain/device_type.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/wearable_device.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/wearable_device_repository.dart';
import 'package:guardian_plus_app/features/health_monitoring/infrastructure/mappers/vital_sign_enums_mapper.dart';
import 'package:guardian_plus_app/features/health_monitoring/infrastructure/mappers/wearable_device_mapper.dart';
import 'package:guardian_plus_app/features/health_monitoring/infrastructure/remote/link_wearable_device_request_dto.dart';
import 'package:guardian_plus_app/features/health_monitoring/infrastructure/remote/wearable_device_api.dart';

class WearableDeviceRepositoryImpl implements WearableDeviceRepository {
  final WearableDeviceApi api;

  const new({required this.api});

  @override
  Future<List<WearableDevice>> getWearableDevices(String careRecipientProfileId) async {
    final dtos = await api.getWearableDevices(careRecipientProfileId);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<WearableDevice> linkWearableDevice({
    required String careRecipientProfileId,
    required String serialNumber,
    required DeviceType deviceType,
  }) async {
    final dto = await api.linkWearableDevice(
      LinkWearableDeviceRequestDto(
        careRecipientProfileId: careRecipientProfileId,
        serialNumber: serialNumber,
        deviceType: deviceType.toApi(),
      ),
    );
    return dto.toDomain();
  }
}
