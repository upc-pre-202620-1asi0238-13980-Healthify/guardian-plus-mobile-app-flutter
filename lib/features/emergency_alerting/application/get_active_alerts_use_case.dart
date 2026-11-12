import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_repository.dart';

/// Alerts of the person under care that are still in play.
class GetActiveAlertsUseCase {
  final AlertRepository repository;

  const new({required this.repository});

  Future<List<Alert>> execute(String careRecipientProfileId) {
    return repository.getActiveAlerts(careRecipientProfileId);
  }
}
