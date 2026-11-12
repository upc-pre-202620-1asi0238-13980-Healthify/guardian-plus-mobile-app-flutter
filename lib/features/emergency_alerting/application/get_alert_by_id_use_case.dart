import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_repository.dart';

class GetAlertByIdUseCase {
  final AlertRepository repository;

  const new({required this.repository});

  Future<Alert> execute(String alertId) {
    return repository.getAlertById(alertId);
  }
}
