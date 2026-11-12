import 'package:guardian_plus_app/features/emergency_alerting/domain/incident.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/incident_repository.dart';

class GetIncidentByAlertIdUseCase {
  final IncidentRepository repository;

  const new({required this.repository});

  /// Null while nobody has acknowledged the alert.
  Future<Incident?> execute(String alertId) {
    return repository.getIncidentByAlertId(alertId);
  }
}
