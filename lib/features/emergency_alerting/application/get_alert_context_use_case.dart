import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_context.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_context_repository.dart';

/// The vital signs and the last known location around an alert, so whoever answers knows how the person is
/// and where to go.
class GetAlertContextUseCase {
  final AlertContextRepository repository;

  const new({required this.repository});

  Future<AlertContext> execute(Alert alert) {
    return repository.getAlertContext(alert);
  }
}
