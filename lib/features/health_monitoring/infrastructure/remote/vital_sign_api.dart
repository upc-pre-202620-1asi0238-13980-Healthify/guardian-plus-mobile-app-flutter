import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/features/health_monitoring/infrastructure/remote/live_vital_signs_dto.dart';
import 'package:guardian_plus_app/features/health_monitoring/infrastructure/remote/vital_sign_dto.dart';

class VitalSignApi {
  final ApiClient client;

  const new({required this.client});

  Future<LiveVitalSignsDto> getLiveVitalSigns(String careRecipientProfileId) async {
    final json = await client.get('vital-signs/live/$careRecipientProfileId');
    return LiveVitalSignsDto.fromJson(json);
  }

  /// [from] and [to] as yyyy-MM-dd.
  Future<List<VitalSignDto>> getVitalSignHistory(String careRecipientProfileId, {required String from, required String to}) async {
    final List jsons = await client.get('vital-signs/history/$careRecipientProfileId?from=$from&to=$to');
    return jsons.map((json) => VitalSignDto.fromJson(json)).toList();
  }
}
