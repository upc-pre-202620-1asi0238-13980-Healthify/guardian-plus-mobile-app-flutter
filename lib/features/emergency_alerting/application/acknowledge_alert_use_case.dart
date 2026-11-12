import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_repository.dart';

/// Stops the escalation and opens the incident in attention (report, emergency route step 2).
class AcknowledgeAlertUseCase {
  final AlertRepository repository;

  const new({required this.repository});

  Future<Alert> execute({required String alertId, required String userId}) {
    return repository.acknowledgeAlert(alertId: alertId, userId: userId);
  }
}
