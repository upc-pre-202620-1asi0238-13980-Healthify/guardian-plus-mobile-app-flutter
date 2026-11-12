import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/incident_dto.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/notes_request_dto.dart';

class IncidentApi {
  final ApiClient client;

  const new({required this.client});

  Future<IncidentDto> getIncidentByAlertId(String alertId) async {
    final json = await client.get('incidents/alert/$alertId');
    return IncidentDto.fromJson(json);
  }

  Future<IncidentDto> stabilizeIncident(String incidentId, NotesRequestDto request) async {
    final json = await client.post('incidents/$incidentId/stabilize', body: request.toJson());
    return IncidentDto.fromJson(json);
  }

  Future<IncidentDto> closeIncident(String incidentId, NotesRequestDto request) async {
    final json = await client.post('incidents/$incidentId/close', body: request.toJson());
    return IncidentDto.fromJson(json);
  }
}
