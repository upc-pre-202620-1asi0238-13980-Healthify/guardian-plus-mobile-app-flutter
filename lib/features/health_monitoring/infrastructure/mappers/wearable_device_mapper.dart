import 'package:guardian_plus_app/features/health_monitoring/domain/wearable_device.dart';
import 'package:guardian_plus_app/features/health_monitoring/infrastructure/mappers/vital_sign_enums_mapper.dart';
import 'package:guardian_plus_app/features/health_monitoring/infrastructure/remote/wearable_device_dto.dart';

extension WearableDeviceDtoMapper on WearableDeviceDto {
  WearableDevice toDomain() {
    return WearableDevice(
      id: id,
      careRecipientId: careRecipientProfileId,
      serialNumber: serialNumber,
      deviceType: DeviceTypeMapper.fromApi(deviceType),
      linkedAt: DateTime.parse(linkedAt).toLocal(),
    );
  }
}
