import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_page.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/severity.dart';

abstract class AlertRepository {
  /// [severity], [from] and [to] are optional filters; null means no filter.
  Future<AlertPage> getAlertHistory({
    required String careRecipientProfileId,
    Severity? severity,
    DateTime? from,
    DateTime? to,
    required int page,
    required int size,
  });

  Future<List<Alert>> getActiveAlerts(String careRecipientProfileId);

  Future<List<Alert>> getPendingAlerts(String userId);

  Future<Alert> getAlertById(String alertId);

  Future<Alert> acknowledgeAlert({required String alertId, required String userId});

  Future<Alert> claimAlertResponse({required String alertId, required String responderUserId});

  Future<Alert> completeAlertResponse({required String alertId, required String responseId, String? notes});
}
