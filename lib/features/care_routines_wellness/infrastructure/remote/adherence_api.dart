import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/infrastructure/remote/adherence_dto.dart';

class AdherenceApi {
  final ApiClient client;

  const new({required this.client});

  Future<AdherenceDto> getAdherence(
    String personUnderCareId, {
    required String type,
    required String from,
    required String to,
  }) async {
    final query = Uri(queryParameters: {'type': type, 'from': from, 'to': to}).query;
    final json = await client.get('reminders/citizen/$personUnderCareId/adherence?$query');
    return AdherenceDto.fromJson(json);
  }
}
