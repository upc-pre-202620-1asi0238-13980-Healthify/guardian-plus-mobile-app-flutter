import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_settings.dart';

abstract class AlertSettingsRepository {
  Future<AlertSettings> getAlertSettings(String careRecipientProfileId);

  Future<AlertSettings> updateAlertSettings({
    required String careRecipientProfileId,
    required int primaryAckTimeoutSec,
    required bool escalationEnabled,
    required bool broadcastCriticalImmediately,
  });

  Future<AlertSettings> setSilentMode({required String careRecipientProfileId, required bool enabled});
}
