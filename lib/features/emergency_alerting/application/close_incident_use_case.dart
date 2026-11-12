import 'package:guardian_plus_app/features/emergency_alerting/domain/incident.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/incident_repository.dart';

/// Ends the incident; the platform then marks its alert as resolved.
class CloseIncidentUseCase {
  final IncidentRepository repository;

  const new({required this.repository});

  Future<Incident> execute({required String incidentId, String? notes}) {
    final trimmed = notes?.trim();
    return repository.closeIncident(
      incidentId: incidentId,
      notes: (trimmed == null || trimmed.isEmpty) ? null : trimmed,
    );
  }
}
