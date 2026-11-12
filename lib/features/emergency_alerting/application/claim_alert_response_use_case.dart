import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_repository.dart';

/// "Voy en camino": tells the rest of the Care Circle who is going (US25). It also acknowledges the alert.
class ClaimAlertResponseUseCase {
  final AlertRepository repository;

  const new({required this.repository});

  Future<Alert> execute({required String alertId, required String responderUserId}) {
    return repository.claimAlertResponse(alertId: alertId, responderUserId: responderUserId);
  }
}
