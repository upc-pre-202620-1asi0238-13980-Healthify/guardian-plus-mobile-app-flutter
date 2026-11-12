import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_repository.dart';

/// Alerts that were sent to this Care Circle member and still wait for them to acknowledge.
class GetPendingAlertsUseCase {
  final AlertRepository repository;

  const new({required this.repository});

  Future<List<Alert>> execute(String userId) {
    return repository.getPendingAlerts(userId);
  }
}
