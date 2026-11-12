import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_repository.dart';

/// "Llegué": the member who was on the way reached the person under care.
class CompleteAlertResponseUseCase {
  final AlertRepository repository;

  const new({required this.repository});

  Future<Alert> execute({required String alertId, required String responseId, String? notes}) {
    return repository.completeAlertResponse(alertId: alertId, responseId: responseId, notes: notes);
  }
}
