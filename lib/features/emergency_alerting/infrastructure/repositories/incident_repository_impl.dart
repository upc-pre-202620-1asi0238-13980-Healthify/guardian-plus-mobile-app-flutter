import 'dart:io';

import 'package:guardian_plus_app/core/network/api_exception.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/incident.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/incident_repository.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/mappers/incident_mapper.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/incident_api.dart';
import 'package:guardian_plus_app/features/emergency_alerting/infrastructure/remote/notes_request_dto.dart';

class IncidentRepositoryImpl implements IncidentRepository {
  final IncidentApi api;

  const new({required this.api});

  // 404 is expected: an alert only has an incident once someone acknowledged it
  @override
  Future<Incident?> getIncidentByAlertId(String alertId) async {
    try {
      final dto = await api.getIncidentByAlertId(alertId);
      return dto.toDomain();
    } on ApiException catch (e) {
      if (e.statusCode == HttpStatus.notFound) return null;
      rethrow;
    }
  }

  @override
  Future<Incident> stabilizeIncident({required String incidentId, String? notes}) async {
    final dto = await api.stabilizeIncident(incidentId, NotesRequestDto(notes: notes));
    return dto.toDomain();
  }

  @override
  Future<Incident> closeIncident({required String incidentId, String? notes}) async {
    final dto = await api.closeIncident(incidentId, NotesRequestDto(notes: notes));
    return dto.toDomain();
  }
}
