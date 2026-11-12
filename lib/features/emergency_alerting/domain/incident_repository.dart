import 'package:guardian_plus_app/features/emergency_alerting/domain/incident.dart';

abstract class IncidentRepository {
  /// Null when nobody has acknowledged the alert yet, so it has no incident.
  Future<Incident?> getIncidentByAlertId(String alertId);

  Future<Incident> stabilizeIncident({required String incidentId, String? notes});

  Future<Incident> closeIncident({required String incidentId, String? notes});
}
