import 'package:guardian_plus_app/features/emergency_alerting/domain/incident.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/incident_repository.dart';

/// The person under care is out of danger, but the incident stays open until someone closes it.
class StabilizeIncidentUseCase {
  final IncidentRepository repository;

  const new({required this.repository});

  Future<Incident> execute({required String incidentId, String? notes}) {
    final trimmed = notes?.trim();
    return repository.stabilizeIncident(
      incidentId: incidentId,
      notes: (trimmed == null || trimmed.isEmpty) ? null : trimmed,
    );
  }
}
