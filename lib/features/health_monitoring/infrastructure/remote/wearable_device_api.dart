import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/features/health_monitoring/infrastructure/remote/link_wearable_device_request_dto.dart';
import 'package:guardian_plus_app/features/health_monitoring/infrastructure/remote/wearable_device_dto.dart';

class WearableDeviceApi {
  final ApiClient client;

  const new({required this.client});

  Future<List<WearableDeviceDto>> getWearableDevices(String careRecipientProfileId) async {
    final List jsons = await client.get('wearable-devices/care-recipient/$careRecipientProfileId');
    return jsons.map((json) => WearableDeviceDto.fromJson(json)).toList();
  }

  Future<WearableDeviceDto> linkWearableDevice(LinkWearableDeviceRequestDto request) async {
    final json = await client.post('wearable-devices', body: request.toJson());
    return WearableDeviceDto.fromJson(json);
  }
}
