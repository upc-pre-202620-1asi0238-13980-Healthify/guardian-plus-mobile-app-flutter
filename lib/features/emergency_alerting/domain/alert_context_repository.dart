import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_context.dart';

abstract class AlertContextRepository {
  /// Each part is filled in when it can be read; one that fails or does not exist yet is left out.
  Future<AlertContext> getAlertContext(Alert alert);
}
